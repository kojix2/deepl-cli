require "json"
require "digest/sha256"
require "file_utils"
require "deepl"
require "./config"
require "./options"

module DeepL
  class QueryCache
    class CachedResult
      include JSON::Serializable

      property text : String
      property detected_source_language : String
      property billed_characters : Int64?
      property target_language : String?

      def initialize(
        @text : String,
        @detected_source_language : String,
        @billed_characters : Int64? = nil,
        @target_language : String? = nil,
      )
      end

      def self.from_text_result(result : DeepL::TextResult) : self
        new(
          text: result.text,
          detected_source_language: result.detected_source_language,
          billed_characters: result.billed_characters
        )
      end

      def self.from_rephrase_result(result : DeepL::RephraseResult) : self
        new(
          text: result.text,
          detected_source_language: result.detected_source_language,
          target_language: result.target_language
        )
      end

      def to_text_result : DeepL::TextResult
        DeepL::TextResult.new(
          text: text,
          detected_source_language: detected_source_language,
          billed_characters: billed_characters,
          model_type_used: nil
        )
      end

      def to_rephrase_result : DeepL::RephraseResult
        DeepL::RephraseResult.new(
          detected_source_language: detected_source_language,
          text: text,
          target_language: target_language
        )
      end
    end

    class CacheEntry
      include JSON::Serializable

      property key : String
      property action : String
      property created_at : Int64
      property last_accessed_at : Int64
      property results : Array(CachedResult)

      def initialize(
        @key : String,
        @action : String,
        @created_at : Int64,
        @last_accessed_at : Int64,
        @results : Array(CachedResult),
      )
      end
    end

    class CacheData
      include JSON::Serializable

      property entries : Array(CacheEntry)

      def initialize(@entries : Array(CacheEntry) = [] of CacheEntry)
      end
    end

    getter file_path : Path
    getter max_entries : Int32

    def initialize(@file_path : Path = Config.cache_file, @max_entries : Int32 = Options::DEFAULT_CACHE_SIZE, @enabled : Bool = true)
    end

    def fetch_text(key : String) : Array(DeepL::TextResult)?
      return nil unless @enabled

      cached_results = fetch(key, "translate_text")
      return nil unless cached_results

      cached_results.map(&.to_text_result)
    end

    def fetch_rephrase(key : String) : Array(DeepL::RephraseResult)?
      return nil unless @enabled

      cached_results = fetch(key, "rephrase_text")
      return nil unless cached_results

      cached_results.map(&.to_rephrase_result)
    end

    def store_text(key : String, results : Array(DeepL::TextResult)) : Nil
      return unless @enabled

      store(key, "translate_text", results.map { |result| CachedResult.from_text_result(result) })
    end

    def store_rephrase(key : String, results : Array(DeepL::RephraseResult)) : Nil
      return unless @enabled

      store(key, "rephrase_text", results.map { |result| CachedResult.from_rephrase_result(result) })
    end

    def self.translate_key(option : Options) : String
      digest_for({
        "action"              => "translate_text",
        "input_text"          => option.input_text,
        "target_lang"         => option.target_lang,
        "source_lang"         => option.source_lang,
        "formality"           => option.formality,
        "split_sentences"     => option.split_sentences,
        "preserve_formatting" => option.preserve_formatting?,
        "tag_handling"        => option.tag_handling,
        "outline_detection"   => option.outline_detection?,
        "non_splitting_tags"  => normalized_tags(option.non_splitting_tags),
        "splitting_tags"      => normalized_tags(option.splitting_tags),
        "ignore_tags"         => normalized_tags(option.ignore_tags),
        "glossary_name"       => option.glossary_name,
        "context"             => option.context,
        "model_type"          => option.model_type,
      })
    end

    def self.rephrase_key(option : Options) : String
      digest_for({
        "action"        => "rephrase_text",
        "input_text"    => option.input_text,
        "source_lang"   => option.source_lang,
        "writing_style" => option.writing_style,
        "tone"          => option.tone,
      })
    end

    private def fetch(key : String, action : String) : Array(CachedResult)?
      cache_data = load_cache_data
      now = Time.utc.to_unix
      entry = cache_data.entries.find do |cache_entry|
        cache_entry.key == key && cache_entry.action == action
      end
      return nil unless entry

      entry.last_accessed_at = now
      persist(cache_data)
      entry.results
    rescue ex
      STDERR.puts "[deepl-cli] WARNING: Failed to read cache: #{ex.message}"
      nil
    end

    private def store(key : String, action : String, results : Array(CachedResult)) : Nil
      cache_data = load_cache_data
      now = Time.utc.to_unix
      cache_data.entries.reject! do |entry|
        entry.key == key && entry.action == action
      end
      cache_data.entries << CacheEntry.new(
        key: key,
        action: action,
        created_at: now,
        last_accessed_at: now,
        results: results
      )

      trim_entries(cache_data)
      persist(cache_data)
    rescue ex
      STDERR.puts "[deepl-cli] WARNING: Failed to write cache: #{ex.message}"
    end

    private def trim_entries(cache_data : CacheData) : Nil
      return if max_entries <= 0
      return if cache_data.entries.size <= max_entries

      cache_data.entries.sort_by!(&.last_accessed_at)
      cache_data.entries = cache_data.entries.last(max_entries)
    end

    private def load_cache_data : CacheData
      return CacheData.new unless File.exists?(file_path)

      raw = File.read(file_path)
      return CacheData.new if raw.blank?

      CacheData.from_json(raw)
    rescue ex : JSON::ParseException
      backup_corrupt_cache
      STDERR.puts "[deepl-cli] WARNING: Cache file is corrupt and has been reset."
      CacheData.new
    end

    private def persist(cache_data : CacheData) : Nil
      FileUtils.mkdir_p(file_path.parent.to_s)
      tmp_path = "#{file_path}.tmp.#{Process.pid}"
      File.write(tmp_path, cache_data.to_json)
      File.rename(tmp_path, file_path)
    end

    private def backup_corrupt_cache : Nil
      return unless File.exists?(file_path)

      broken_path = file_path.to_s + ".broken.#{Time.utc.to_unix}"
      File.rename(file_path, broken_path)
    rescue
      # Ignore backup failures and continue with a fresh cache.
    end

    private def self.normalized_tags(tags : Array(String)?) : Array(String)?
      return nil unless tags

      normalized_tags = tags.map(&.strip).reject(&.empty?)
      normalized_tags.sort!
      normalized_tags
    end

    private def self.digest_for(payload : Hash(String, String | Bool | Array(String) | Nil)) : String
      json = payload.to_a.sort_by(&.[0]).to_h.to_json
      Digest::SHA256.hexdigest(json)
    end
  end
end
