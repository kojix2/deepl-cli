require "uuid"
require "file_utils"
require "json"
require "digest/sha256"
require "./spec_helper"

describe DeepL::QueryCache do
  it "stores and reads translated text results" do
    cache_dir = Path[Dir.tempdir, "deepl-cli-cache-spec-#{UUID.random}"]
    cache_file = cache_dir.join("query_cache.json")
    begin
      cache = DeepL::QueryCache.new(file_path: cache_file, max_entries: 10)
      key = "translate-key"
      payload = [DeepL::TextResult.new("hello", "EN", 5_i64, nil)]

      cache.store_text(key, payload)
      fetched = cache.fetch_text(key) || raise "expected cache hit"
      fetched.size.should eq(1)
      fetched.first.text.should eq("hello")
      fetched.first.detected_source_language.should eq("EN")
      fetched.first.billed_characters.should eq(5_i64)
    ensure
      FileUtils.rm_rf(cache_dir)
    end
  end

  it "keeps only the most recent n entries" do
    cache_dir = Path[Dir.tempdir, "deepl-cli-cache-spec-#{UUID.random}"]
    cache_file = cache_dir.join("query_cache.json")
    begin
      cache = DeepL::QueryCache.new(file_path: cache_file, max_entries: 1)

      cache.store_text("k1", [DeepL::TextResult.new("a", "EN", nil, nil)])
      cache.store_text("k2", [DeepL::TextResult.new("b", "EN", nil, nil)])

      cache.fetch_text("k1").should be_nil
      cache.fetch_text("k2").should_not be_nil
    ensure
      FileUtils.rm_rf(cache_dir)
    end
  end

  it "normalizes tag order in translate cache key" do
    option1 = DeepL::Options.new
    option1.input_text = "hello"
    option1.target_lang = "JA"
    option1.non_splitting_tags = ["x", "a"]

    option2 = DeepL::Options.new
    option2.input_text = "hello"
    option2.target_lang = "JA"
    option2.non_splitting_tags = ["a", "x"]

    DeepL::QueryCache.translate_key(option1).should eq(DeepL::QueryCache.translate_key(option2))
  end

  it "resets corrupt cache files" do
    cache_dir = Path[Dir.tempdir, "deepl-cli-cache-spec-#{UUID.random}"]
    cache_file = cache_dir.join("query_cache.json")
    begin
      FileUtils.mkdir_p(cache_file.parent.to_s)
      File.write(cache_file, "not-json")

      cache = DeepL::QueryCache.new(file_path: cache_file, max_entries: 10)
      cache.fetch_text("missing").should be_nil

      broken_files = Dir.glob("#{cache_file}.broken.*")
      broken_files.size.should eq(1)
    ensure
      FileUtils.rm_rf(cache_dir)
    end
  end
end
