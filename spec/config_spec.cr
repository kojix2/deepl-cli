require "./spec_helper"

describe DeepL::Config do
  it "returns the target language" do
    original = ENV["DEEPL_TARGET_LANG"]?
    begin
      ENV["DEEPL_TARGET_LANG"] = "CRYSTAL"
      DeepL::Config.default_target_lang.should eq("CRYSTAL")
    ensure
      if original
        ENV["DEEPL_TARGET_LANG"] = original
      else
        ENV.delete("DEEPL_TARGET_LANG")
      end
    end
  end

  it "prefers LC_ALL over LANG locales" do
    original_deepl_target_lang = ENV["DEEPL_TARGET_LANG"]?
    original_lc_all = ENV["LC_ALL"]?
    original_lc_messages = ENV["LC_MESSAGES"]?
    original_lang = ENV["LANG"]?

    begin
      ENV.delete("DEEPL_TARGET_LANG")
      ENV["LC_ALL"] = "ja_JP.UTF-8"
      ENV["LC_MESSAGES"] = "fr_FR.UTF-8"
      ENV["LANG"] = "de_DE.UTF-8"

      DeepL::Config.default_target_lang.should eq("JA")
    ensure
      if original_deepl_target_lang
        ENV["DEEPL_TARGET_LANG"] = original_deepl_target_lang
      else
        ENV.delete("DEEPL_TARGET_LANG")
      end

      if original_lc_all
        ENV["LC_ALL"] = original_lc_all
      else
        ENV.delete("LC_ALL")
      end

      if original_lc_messages
        ENV["LC_MESSAGES"] = original_lc_messages
      else
        ENV.delete("LC_MESSAGES")
      end

      if original_lang
        ENV["LANG"] = original_lang
      else
        ENV.delete("LANG")
      end
    end
  end

  it "uses DEEPL_CLI_CACHE_DIR when set" do
    original = ENV["DEEPL_CLI_CACHE_DIR"]?
    begin
      ENV["DEEPL_CLI_CACHE_DIR"] = "/tmp/deepl-cli-cache-spec"
      DeepL::Config.cache_dir.to_s.should eq("/tmp/deepl-cli-cache-spec")
    ensure
      if original
        ENV["DEEPL_CLI_CACHE_DIR"] = original
      else
        ENV.delete("DEEPL_CLI_CACHE_DIR")
      end
    end
  end
end
