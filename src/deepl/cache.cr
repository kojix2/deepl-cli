{% if flag?(:sqlite_cache) %}
  require "digest/sha256"
  require "file_utils"
  require "json"
  require "sqlite3"
  require "./options"

  module DeepL
    class Cache
      SCHEMA_VERSION = 1

      getter path : Path

      def self.default_path : Path
        if path = ENV["DEEPL_CACHE_PATH"]?
          Path[path]
        else
          Path.home / ".cache/deepl-cli/cache.sqlite3"
        end
      end

      def initialize(@path : Path = self.class.default_path)
      end

      def lookup(key : String) : Array(TextResult)?
        with_db do |db|
          response_json = db.query_one?(
            "SELECT response_json FROM translation_cache WHERE cache_key = ?",
            key,
            as: String
          )
          return unless response_json

          db.exec "UPDATE translation_cache SET last_used_at = ? WHERE cache_key = ?", timestamp, key
          parse_results(response_json)
        end
      end

      def store(key : String, results : Array(TextResult)) : Nil
        now = timestamp
        with_db do |db|
          db.exec(
            <<-SQL,
            INSERT INTO translation_cache (cache_key, response_json, created_at, last_used_at)
            VALUES (?, ?, ?, ?)
            ON CONFLICT(cache_key) DO UPDATE SET
              response_json = excluded.response_json,
              last_used_at = excluded.last_used_at
            SQL
            key,
            results_to_json(results),
            now,
            now
          )
        end
      end

      def key_for(option : Options) : String
        payload = JSON.build do |json|
          json.object do
            json.field "schema_version", SCHEMA_VERSION
            json.field "text", option.input_text
            json.field "target_lang", option.target_lang
            json.field "source_lang", option.source_lang
            json.field "formality", option.formality
            json.field "glossary_name", option.glossary_name
            json.field "context", option.context
            json.field "split_sentences", option.split_sentences
            json.field "preserve_formatting", option.preserve_formatting?
            json.field "tag_handling", option.tag_handling
            json.field "outline_detection", option.outline_detection?
            json.field "non_splitting_tags", option.non_splitting_tags
            json.field "splitting_tags", option.splitting_tags
            json.field "ignore_tags", option.ignore_tags
            json.field "model_type", option.model_type
          end
        end

        Digest::SHA256.hexdigest(payload)
      end

      private def with_db(& : DB::Database -> T) : T forall T
        FileUtils.mkdir_p(path.dirname.to_s)
        DB.open(db_uri) do |db|
          db.exec "PRAGMA journal_mode=WAL"
          db.exec "PRAGMA busy_timeout=5000"
          initialize_schema(db)
          yield db
        end
      end

      private def initialize_schema(db) : Nil
        db.exec <<-SQL
        CREATE TABLE IF NOT EXISTS translation_cache (
          cache_key TEXT PRIMARY KEY,
          response_json TEXT NOT NULL,
          created_at TEXT NOT NULL,
          last_used_at TEXT NOT NULL
        )
        SQL
      end

      private def db_uri : String
        "sqlite3://#{path}"
      end

      private def timestamp : String
        Time.utc.to_rfc3339
      end

      private def results_to_json(results : Array(TextResult)) : String
        JSON.build do |json|
          json.array do
            results.each do |result|
              json.object do
                json.field "text", result.text
                json.field "detected_source_language", result.detected_source_language
                json.field "billed_characters", result.billed_characters
                json.field "model_type_used", result.model_type_used
              end
            end
          end
        end
      end

      private def parse_results(response_json : String) : Array(TextResult)
        JSON.parse(response_json).as_a.map do |item|
          billed_characters = nilable_i64(item["billed_characters"]?)
          model_type_used = nilable_string(item["model_type_used"]?)
          TextResult.new(
            text: item["text"].as_s,
            detected_source_language: item["detected_source_language"].as_s,
            billed_characters: billed_characters,
            model_type_used: model_type_used
          )
        end
      end

      private def nilable_i64(value : JSON::Any?) : Int64?
        return unless value
        return if value.raw.nil?

        value.as_i64
      end

      private def nilable_string(value : JSON::Any?) : String?
        return unless value
        return if value.raw.nil?

        value.as_s
      end
    end
  end
{% end %}
