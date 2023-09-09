crystal_doc_search_index_callback({"repository_name":"deepl-cli","body":"# DeepL CLI\n\nA simple command-line interface (CLI) tool for translating text using the [DeepL API](https://www.deepl.com/pro-api/), written in Crystal programming language. This tool enables quick and easy text translation via the command line without visiting the [DeepL website](https://www.deepl.com/).\n\n## Prerequisites\n\nFirst, [obtain a valid API key from DeepL](https://www.deepl.com/pro-api), then set it as an environment variable:\n\n```bash\nexport DEEPL_API_KEY=your_api_key_here\n```\n\n## Installation\n\nDownload the latest source code, then run the following commands:\n\n```bash\ncd deepl-cli\nshards build --release\n# DEEPL_API_PRO=1 shards build --release # for DeepL API Pro\n```\n\nA compiled binary file will be created in the `bin` folder.\n\n#### Proxy settings (optional)\n\n```\nexport HTTP_PROXY=http://[IP]:[port]\nexport HTTPS_PROXY=https://[IP]:[port]\n```\n\n## Usage\n\nTo use the DeepL Translator CLI, simply run the `deepl` command followed by the arguments you wish to pass.\n\n```bash\n$ ./bin/deepl [arguments]\n```\n\n### Arguments\n\nOptions available for the CLI tool:\n\n- `-i, --input=TEXT`: Input text to translate.\n- `-f, --from=LANG`: Set the source language (default: AUTO). Example: `-f EN`.\n- `-t, --to=LANG`: Set the target language (default: EN). Example: `-t ES`.\n- `-u, --usage`: Check Usage and Limits\n- `-v, --version`: Show the current version.\n- `-h, --help`: Show the help message.\n\n### Examples\n\nTo translate the text \"Hola mundo\" from Spanish (ES) to English (EN):\n\n```bash\n$ deepl -i \"Hola mundo\" -f ES -t EN\nHello world\n```\n\nShort options:\n\n```\n$ deepl -i \"Hola mundo\" -f es\nHello world\n```\n\nFrom stream:\n\n```bash\n$ echo \"Hola mundo\" | deepl -f ES -t EN\nHello world\n```\n\nMultiple lines:\nPress `Ctrl+D` when finished typing.\nThis is especially useful when copy-pasting from the clipboard.\n\n```\n$ deepl -f es\nHola\nmundo\n```\n\nDisplay a list of available languages\n\n```\n$ deepl -f\n$ deepl -t\n```\n\n## Contributing\n\nIf you would like to contribute to the development of this CLI tool, please follow the steps below:\n\n1. Fork this repository\n2. Create your feature branch (`git checkout -b my-new-feature`)\n3. Commit your changes (`git commit -am 'Add some feature'`)\n4. Push to the branch (`git push origin my-new-feature`)\n5. Create a new Pull Request\n\n## License\n\nThis project is licensed under the MIT License.\n\nHappy translating!\n","program":{"html_id":"deepl-cli/toplevel","path":"toplevel.html","kind":"module","full_name":"Top Level Namespace","name":"Top Level Namespace","abstract":false,"locations":[],"repository_name":"deepl-cli","program":true,"enum":false,"alias":false,"const":false,"types":[{"html_id":"deepl-cli/Deepl","path":"Deepl.html","kind":"module","full_name":"Deepl","name":"Deepl","abstract":false,"locations":[{"filename":"src/deepl/options.cr","line_number":1,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/options.cr#L1"},{"filename":"src/deepl/parser.cr","line_number":5,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/parser.cr#L5"},{"filename":"src/deepl/translator.cr","line_number":4,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/translator.cr#L4"},{"filename":"src/deepl/version.cr","line_number":1,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/version.cr#L1"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"constants":[{"id":"VERSION","name":"VERSION","value":"{{ (`shards version /home/runner/work/deepl-cli/deepl-cli/src/deepl`).chomp.stringify }}"}],"types":[{"html_id":"deepl-cli/Deepl/ApiKeyError","path":"Deepl/ApiKeyError.html","kind":"class","full_name":"Deepl::ApiKeyError","name":"ApiKeyError","abstract":false,"superclass":{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},"ancestors":[{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/translator.cr","line_number":5,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/translator.cr#L5"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"}},{"html_id":"deepl-cli/Deepl/Options","path":"Deepl/Options.html","kind":"struct","full_name":"Deepl::Options","name":"Options","abstract":false,"superclass":{"html_id":"deepl-cli/Struct","kind":"struct","full_name":"Struct","name":"Struct"},"ancestors":[{"html_id":"deepl-cli/Struct","kind":"struct","full_name":"Struct","name":"Struct"},{"html_id":"deepl-cli/Value","kind":"struct","full_name":"Value","name":"Value"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/options.cr","line_number":2,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/options.cr#L2"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"},"constructors":[{"html_id":"new-class-method","name":"new","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":2,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/options.cr#L2"},"def":{"name":"new","visibility":"Public","body":"x = allocate\nif x.responds_to?(:finalize)\n  ::GC.add_finalizer(x)\nend\nx\n"}}],"instance_methods":[{"html_id":"doc:Bool-instance-method","name":"doc","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":6,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/options.cr#L6"},"def":{"name":"doc","return_type":"Bool","visibility":"Public","body":"@doc"}},{"html_id":"doc=(doc:Bool)-instance-method","name":"doc=","abstract":false,"args":[{"name":"doc","external_name":"doc","restriction":"Bool"}],"args_string":"(doc : Bool)","args_html":"(doc : Bool)","location":{"filename":"src/deepl/options.cr","line_number":6,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/options.cr#L6"},"def":{"name":"doc=","args":[{"name":"doc","external_name":"doc","restriction":"Bool"}],"visibility":"Public","body":"@doc = doc"}},{"html_id":"initialize-instance-method","name":"initialize","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":2,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/options.cr#L2"},"def":{"name":"initialize","visibility":"Public","body":""}},{"html_id":"input:String-instance-method","name":"input","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":5,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/options.cr#L5"},"def":{"name":"input","return_type":"String","visibility":"Public","body":"@input"}},{"html_id":"input=(input:String)-instance-method","name":"input=","abstract":false,"args":[{"name":"input","external_name":"input","restriction":"String"}],"args_string":"(input : String)","args_html":"(input : String)","location":{"filename":"src/deepl/options.cr","line_number":5,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/options.cr#L5"},"def":{"name":"input=","args":[{"name":"input","external_name":"input","restriction":"String"}],"visibility":"Public","body":"@input = input"}},{"html_id":"source_lang:String-instance-method","name":"source_lang","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":4,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/options.cr#L4"},"def":{"name":"source_lang","return_type":"String","visibility":"Public","body":"@source_lang"}},{"html_id":"source_lang=(source_lang:String)-instance-method","name":"source_lang=","abstract":false,"args":[{"name":"source_lang","external_name":"source_lang","restriction":"String"}],"args_string":"(source_lang : String)","args_html":"(source_lang : String)","location":{"filename":"src/deepl/options.cr","line_number":4,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/options.cr#L4"},"def":{"name":"source_lang=","args":[{"name":"source_lang","external_name":"source_lang","restriction":"String"}],"visibility":"Public","body":"@source_lang = source_lang"}},{"html_id":"target_lang:String-instance-method","name":"target_lang","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":3,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/options.cr#L3"},"def":{"name":"target_lang","return_type":"String","visibility":"Public","body":"@target_lang"}},{"html_id":"target_lang=(target_lang:String)-instance-method","name":"target_lang=","abstract":false,"args":[{"name":"target_lang","external_name":"target_lang","restriction":"String"}],"args_string":"(target_lang : String)","args_html":"(target_lang : String)","location":{"filename":"src/deepl/options.cr","line_number":3,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/options.cr#L3"},"def":{"name":"target_lang=","args":[{"name":"target_lang","external_name":"target_lang","restriction":"String"}],"visibility":"Public","body":"@target_lang = target_lang"}}]},{"html_id":"deepl-cli/Deepl/Parser","path":"Deepl/Parser.html","kind":"class","full_name":"Deepl::Parser","name":"Parser","abstract":false,"superclass":{"html_id":"deepl-cli/OptionParser","kind":"class","full_name":"OptionParser","name":"OptionParser"},"ancestors":[{"html_id":"deepl-cli/OptionParser","kind":"class","full_name":"OptionParser","name":"OptionParser"},{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/parser.cr","line_number":6,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/parser.cr#L6"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"},"constructors":[{"html_id":"new(translator:Deepl::Translator)-class-method","name":"new","abstract":false,"args":[{"name":"translator","external_name":"translator","restriction":"::Deepl::Translator"}],"args_string":"(translator : Deepl::Translator)","args_html":"(translator : <a href=\"../Deepl/Translator.html\">Deepl::Translator</a>)","location":{"filename":"src/deepl/parser.cr","line_number":10,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/parser.cr#L10"},"def":{"name":"new","args":[{"name":"translator","external_name":"translator","restriction":"::Deepl::Translator"}],"visibility":"Public","body":"_ = allocate\n_.initialize(translator)\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"html_id":"opt:Options-instance-method","name":"opt","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":7,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/parser.cr#L7"},"def":{"name":"opt","return_type":"Options","visibility":"Public","body":"@opt"}},{"html_id":"parse(args)-instance-method","name":"parse","doc":"Parses the passed *args* (defaults to `ARGV`), running the handlers associated to each option.","summary":"<p>Parses the passed <em>args</em> (defaults to <code>ARGV</code>), running the handlers associated to each option.</p>","abstract":false,"args":[{"name":"args","external_name":"args","restriction":""}],"args_string":"(args)","args_html":"(args)","location":{"filename":"src/deepl/parser.cr","line_number":45,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/parser.cr#L45"},"def":{"name":"parse","args":[{"name":"args","external_name":"args","restriction":""}],"visibility":"Public","body":"super(args)\nopt\n"}},{"html_id":"show_help-instance-method","name":"show_help","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":77,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/parser.cr#L77"},"def":{"name":"show_help","visibility":"Public","body":"puts(self)\nexit\n"}},{"html_id":"show_source_languages-instance-method","name":"show_source_languages","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":50,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/parser.cr#L50"},"def":{"name":"show_source_languages","visibility":"Public","body":"translator.source_languages.each do |lang|\n  language, name = lang.values.map(&.to_s)\n  puts(\"- #{language.ljust(7)}#{name}\")\nend\nexit\n"}},{"html_id":"show_target_languages-instance-method","name":"show_target_languages","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":58,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/parser.cr#L58"},"def":{"name":"show_target_languages","visibility":"Public","body":"translator.target_languages.each do |lang|\n  language, name, supports_formality = lang.values.map(&.to_s)\n  puts(\"- #{language.ljust(7)}#{name.ljust(20)}\\t#{supports_formality}\")\nend\nexit\n"}},{"html_id":"show_usage-instance-method","name":"show_usage","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":66,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/parser.cr#L66"},"def":{"name":"show_usage","visibility":"Public","body":"puts(Translator::API_URL_BASE)\nputs(translator.usage.map do |k, v|\n  \"#{k}: #{v}\"\nend.join(\"\\n\"))\nexit\n"}},{"html_id":"show_version-instance-method","name":"show_version","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":72,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/parser.cr#L72"},"def":{"name":"show_version","visibility":"Public","body":"puts(Deepl::VERSION)\nexit\n"}},{"html_id":"translator:Translator-instance-method","name":"translator","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":8,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/parser.cr#L8"},"def":{"name":"translator","return_type":"Translator","visibility":"Public","body":"@translator"}}]},{"html_id":"deepl-cli/Deepl/RequestError","path":"Deepl/RequestError.html","kind":"class","full_name":"Deepl::RequestError","name":"RequestError","abstract":false,"superclass":{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},"ancestors":[{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/translator.cr","line_number":7,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/translator.cr#L7"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"}},{"html_id":"deepl-cli/Deepl/Translator","path":"Deepl/Translator.html","kind":"class","full_name":"Deepl::Translator","name":"Translator","abstract":false,"superclass":{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/translator.cr","line_number":9,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/translator.cr#L9"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"constants":[{"id":"API_URL_BASE","name":"API_URL_BASE","value":"{% if env(\"DEEPL_API_PRO\") %}\n                     \"https://api.deepl.com/v2\"\n                   {% else %}\n                     \"https://api-free.deepl.com/v2\"\n                   {% end %}"},{"id":"API_URL_DOCUMENT","name":"API_URL_DOCUMENT","value":"\"#{API_URL_BASE}/document\""},{"id":"API_URL_TRANSLATE","name":"API_URL_TRANSLATE","value":"\"#{API_URL_BASE}/translate\""}],"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"},"constructors":[{"html_id":"new-class-method","name":"new","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":18,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/translator.cr#L18"},"def":{"name":"new","visibility":"Public","body":"_ = allocate\n_.initialize\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"html_id":"request_languages(type)-instance-method","name":"request_languages","abstract":false,"args":[{"name":"type","external_name":"type","restriction":""}],"args_string":"(type)","args_html":"(type)","location":{"filename":"src/deepl/translator.cr","line_number":92,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/translator.cr#L92"},"def":{"name":"request_languages","args":[{"name":"type","external_name":"type","restriction":""}],"visibility":"Public","body":"begin\n  HTTP::Client.get(\"#{API_URL_BASE}/languages?type=#{type}\", headers: http_headers_for_text)\nrescue ex\n  raise(RequestError.new(\"Error: #{ex.message}\"))\nend"}},{"html_id":"source_languages-instance-method","name":"source_languages","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":105,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/translator.cr#L105"},"def":{"name":"source_languages","visibility":"Public","body":"begin\n  response = request_languages(\"source\")\n  parse_languages_response(response)\nrescue ex\n  raise(RequestError.new(\"Error: #{ex.message}\"))\nend"}},{"html_id":"target_languages-instance-method","name":"target_languages","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":98,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/translator.cr#L98"},"def":{"name":"target_languages","visibility":"Public","body":"begin\n  response = request_languages(\"target\")\n  parse_languages_response(response)\nrescue ex\n  raise(RequestError.new(\"Error: #{ex.message}\"))\nend"}},{"html_id":"translate(option)-instance-method","name":"translate","abstract":false,"args":[{"name":"option","external_name":"option","restriction":""}],"args_string":"(option)","args_html":"(option)","location":{"filename":"src/deepl/translator.cr","line_number":49,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/translator.cr#L49"},"def":{"name":"translate","args":[{"name":"option","external_name":"option","restriction":""}],"visibility":"Public","body":"if option.doc\n  translate_document(option)\nelse\n  translate_text(option.input, option.target_lang, option.source_lang)\nend"}},{"html_id":"translate_document(option)-instance-method","name":"translate_document","abstract":false,"args":[{"name":"option","external_name":"option","restriction":""}],"args_string":"(option)","args_html":"(option)","location":{"filename":"src/deepl/translator.cr","line_number":72,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/translator.cr#L72"},"def":{"name":"translate_document","args":[{"name":"option","external_name":"option","restriction":""}],"visibility":"Public","body":"pp(option)\nio = IO::Memory.new\nbuilder = HTTP::FormData::Builder.new(io)\nbuilder.field(\"target_lang\", option.target_lang)\nif option.source_lang == \"AUTO\"\nelse\n  builder.field(\"source_lang\", option.source_lang)\nend\nfile = File.open(option.input)\nfilename = File.basename(option.input)\nbuilder.file(\"file\", file, HTTP::FormData::FileMetadata.new(filename: filename))\nbuilder.finish\npp(execute_post_request(API_URL_DOCUMENT, io, http_headers_for_document(builder.content_type)))\n"}},{"html_id":"translate_text(text,target_lang,source_lang)-instance-method","name":"translate_text","abstract":false,"args":[{"name":"text","external_name":"text","restriction":""},{"name":"target_lang","external_name":"target_lang","restriction":""},{"name":"source_lang","external_name":"source_lang","restriction":""}],"args_string":"(text, target_lang, source_lang)","args_html":"(text, target_lang, source_lang)","location":{"filename":"src/deepl/translator.cr","line_number":57,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/translator.cr#L57"},"def":{"name":"translate_text","args":[{"name":"text","external_name":"text","restriction":""},{"name":"target_lang","external_name":"target_lang","restriction":""},{"name":"source_lang","external_name":"source_lang","restriction":""}],"visibility":"Public","body":"params = HTTP::Params.build do |form|\n  form.add(\"text\", text)\n  form.add(\"target_lang\", target_lang)\n  if source_lang == \"AUTO\"\n  else\n    form.add(\"source_lang\", source_lang)\n  end\nend\nresponse = execute_post_request(API_URL_TRANSLATE, params, http_headers_for_text)\nparsed_response = JSON.parse(response.body)\nbegin\n  parsed_response.dig(\"translations\", 0, \"text\")\nrescue\n  raise(RequestError.new(\"Error: #{parsed_response}\"))\nend\n"}},{"html_id":"usage-instance-method","name":"usage","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":116,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/translator.cr#L116"},"def":{"name":"usage","visibility":"Public","body":"begin\n  response = request_usage\n  parse_usage_response(response)\nrescue ex\n  raise(RequestError.new(\"Error: #{ex.message}\"))\nend"}}]}]},{"html_id":"deepl-cli/HTTP","path":"HTTP.html","kind":"module","full_name":"HTTP","name":"HTTP","abstract":false,"locations":[{"filename":"lib/http_proxy/src/ext/http/client.cr","line_number":3,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/lib/http_proxy/src/ext/http/client.cr#L3"},{"filename":"lib/http_proxy/src/http/proxy/client.cr","line_number":10,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/lib/http_proxy/src/http/proxy/client.cr#L10"},{"filename":"lib/http_proxy/src/http_proxy.cr","line_number":8,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/lib/http_proxy/src/http_proxy.cr#L8"},{"filename":"src/deepl/utils/proxy.cr","line_number":29,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/utils/proxy.cr#L29"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"doc":"Monkey-patch `HTTP::Client` to make it respect the `*_PROXY`\n  environment variables","summary":"<p>Monkey-patch <code><a href=\"HTTP/Client.html\">HTTP::Client</a></code> to make it respect the <code>*_PROXY</code>   environment variables</p>","types":[{"html_id":"deepl-cli/HTTP/Client","path":"HTTP/Client.html","kind":"class","full_name":"HTTP::Client","name":"Client","abstract":false,"superclass":{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"lib/http_proxy/src/ext/http/client.cr","line_number":4,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/lib/http_proxy/src/ext/http/client.cr#L4"},{"filename":"src/deepl/utils/proxy.cr","line_number":30,"url":"https://github.com/kojix2/deepl-cli/blob/fbe6d4f7d0baf36cd2da773ce626664d37613b25/src/deepl/utils/proxy.cr#L30"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/HTTP","kind":"module","full_name":"HTTP","name":"HTTP"},"doc":"An HTTP Client.\n\nNOTE: To use `Client`, you must explicitly import it with `require \"http/client\"`\n\n### One-shot usage\n\nWithout a block, an `HTTP::Client::Response` is returned and the response's body\nis available as a `String` by invoking `HTTP::Client::Response#body`.\n\n```\nrequire \"http/client\"\n\nresponse = HTTP::Client.get \"http://www.example.com\"\nresponse.status_code      # => 200\nresponse.body.lines.first # => \"<!doctype html>\"\n```\n\n### Parameters\n\nParameters can be added to any request with the `URI::Params.encode` method, which\nconverts a `Hash` or `NamedTuple` to a URL encoded HTTP query.\n\n```\nrequire \"http/client\"\n\nparams = URI::Params.encode({\"author\" => \"John Doe\", \"offset\" => \"20\"}) # => \"author=John+Doe&offset=20\"\nresponse = HTTP::Client.get URI.new(\"http\", \"www.example.com\", query: params)\nresponse.status_code # => 200\n```\n\n### Streaming\n\nWith a block, an `HTTP::Client::Response` body is returned and the response's body\nis available as an `IO` by invoking `HTTP::Client::Response#body_io`.\n\n```\nrequire \"http/client\"\n\nHTTP::Client.get(\"http://www.example.com\") do |response|\n  response.status_code  # => 200\n  response.body_io.gets # => \"<!doctype html>\"\nend\n```\n\n### Reusing a connection\n\nSimilar to the above cases, but creating an instance of an `HTTP::Client`.\n\n```\nrequire \"http/client\"\n\nclient = HTTP::Client.new \"www.example.com\"\nresponse = client.get \"/\"\nresponse.status_code      # => 200\nresponse.body.lines.first # => \"<!doctype html>\"\nclient.close\n```\n\nWARNING: A single `HTTP::Client` instance is not safe for concurrent use by multiple fibers.\n\n### Compression\n\nIf `compress` isn't set to `false`, and no `Accept-Encoding` header is explicitly specified,\nan HTTP::Client will add an `\"Accept-Encoding\": \"gzip, deflate\"` header, and automatically decompress\nthe response body/body_io.\n\n### Encoding\n\nIf a response has a `Content-Type` header with a charset, that charset is set as the encoding\nof the returned IO (or used for creating a String for the body). Invalid bytes in the given encoding\nare silently ignored when reading text content.","summary":"<p>An HTTP Client.</p>"}]}]}})