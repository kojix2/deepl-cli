module DeepL
  class CLI
    VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
  end
end
