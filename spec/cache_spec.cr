{% if flag?(:sqlite_cache) %}
  require "./spec_helper"

  describe DeepL::Cache do
    it "stores and looks up translation results" do
      with_cache do |cache|
        option = cache_option("Hello")
        key = cache.key_for(option)
        results = [DeepL::TextResult.new("こんにちは", "EN", 5_i64, "quality_optimized")]

        cache.lookup(key).should be_nil
        cache.store(key, results)

        cached = cache.lookup(key)
        cached.should_not be_nil
        cached.not_nil!.should eq(results)
      end
    end

    it "changes keys when translation-affecting options change" do
      with_cache do |cache|
        base = cache_option("Hello")

        changes = [] of DeepL::Options
        changed = cache_option("Hello")
        changed.target_lang = "DE"
        changes << changed
        changed = cache_option("Hello")
        changed.source_lang = "EN"
        changes << changed
        changed = cache_option("Hello")
        changed.formality = "more"
        changes << changed
        changed = cache_option("Hello")
        changed.context = "Greeting"
        changes << changed
        changed = cache_option("Hello")
        changed.model_type = "quality_optimized"
        changes << changed
        changed = cache_option("Hello")
        changed.glossary_name = "my glossary"
        changes << changed

        changes.each do |changed|
          cache.key_for(base).should_not eq(cache.key_for(changed))
        end
      end
    end

    it "uses the normalized input text in cache keys" do
      with_cache do |cache|
        ansi = cache_option("\e[31mHello\e[0m")
        plain = cache_option("Hello")

        cache.key_for(ansi).should_not eq(cache.key_for(plain))
        ansi.input_text = "Hello"
        cache.key_for(ansi).should eq(cache.key_for(plain))
      end
    end
  end

  private def cache_option(text : String) : DeepL::Options
    option = DeepL::Options.new
    option.input_text = text
    option.target_lang = "JA"
    option
  end

  private def with_cache(&)
    dir = File.tempname("deepl-cli-cache-spec")
    FileUtils.mkdir_p(dir)
    cache = DeepL::Cache.new(Path[dir] / "cache.sqlite3")
    yield cache
  ensure
    FileUtils.rm_rf(dir) if dir
  end
{% end %}
