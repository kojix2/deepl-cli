crystal_doc_search_index_callback({"repository_name":"deepl-cli","body":"# DeepL CLI\n\n[![build](https://github.com/kojix2/deepl-cli/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/deepl-cli/actions/workflows/build.yml)\n\nA simple command-line interface (CLI) tool for translating text using the [DeepL API](https://www.deepl.com/pro-api/), written in Crystal programming language. This tool enables quick and easy text translation via the command line without visiting the [DeepL website](https://www.deepl.com/).\n\n## Prerequisites\n\nFirst, [obtain a valid API key from DeepL](https://www.deepl.com/pro-api), then set it as an environment variable:\n\n```bash\nexport DEEPL_AUTH_KEY=your_api_key_here\n```\n\n## Installation\n\n- Precompiled binaries are available from [GitHub Releases](https://github.com/kojix2/deepl-cli/releases). (binaries for Linux are statically linked)\n- Compiling from source code is recommended for environments other than Linux.\n\n### Compilation from source code\n\n```bash\ngit clone https://github.com/kojix2/deepl-cli\ncd deepl-cli\nshards build --release\n```\n\nA compiled binary file will be created in the `bin` directory.\n\n### Proxy settings (optional)\n\n```\nexport HTTP_PROXY=http://[IP]:[port]\nexport HTTPS_PROXY=https://[IP]:[port]\n```\n\n## Usage\n\nTo use the DeepL Translator CLI, simply run the `deepl` command followed by the arguments you wish to pass.\n\n```bash\n$ ./bin/deepl [arguments]\n```\n\n### Arguments\n\nOptions available for the CLI tool:\n\n- `-i, --input=TEXT`: Input text to translate.\n- `-f, --from=LANG`: Set the source language (default: AUTO). Example: `-f EN`.\n- `-t, --to=LANG`: Set the target language (default: EN). Example: `-t ES`.\n- `-u, --usage`: Check Usage and Limits\n- `-v, --version`: Show the current version.\n- `-h, --help`: Show the help message.\n\n### Examples\n\nTo translate the text \"Hola mundo\" from Spanish (ES) to English (EN):\n\n```bash\n$ deepl -i \"Hola mundo\" -f ES -t EN\nHello world\n```\n\nShort options:\n\n```\n$ deepl -i \"Hola mundo\" -f es\nHello world\n```\n\nFrom stream:\n\n```bash\n$ echo \"Hola mundo\" | deepl -f ES -t EN\nHello world\n```\n\nMultiple lines:\nPress `Ctrl+D` when finished typing.\nThis is especially useful when copy-pasting from the clipboard.\n\n```\n$ deepl -f es\nHola\nmundo\n```\n\nDisplay a list of available languages\n\n```\n$ deepl -f\n$ deepl -t\n```\n\n## Contributing\n\nIf you would like to contribute to the development of this CLI tool, please follow the steps below:\n\n1. Fork this repository\n2. Create your feature branch (`git checkout -b my-new-feature`)\n3. Commit your changes (`git commit -am 'Add some feature'`)\n4. Push to the branch (`git push origin my-new-feature`)\n5. Create a new Pull Request\n\n## License\n\nThis project is licensed under the MIT License.\n\nHappy translating!\n","program":{"html_id":"deepl-cli/toplevel","path":"toplevel.html","kind":"module","full_name":"Top Level Namespace","name":"Top Level Namespace","abstract":false,"locations":[],"repository_name":"deepl-cli","program":true,"enum":false,"alias":false,"const":false,"types":[{"html_id":"deepl-cli/Deepl","path":"Deepl.html","kind":"module","full_name":"Deepl","name":"Deepl","abstract":false,"locations":[{"filename":"src/deepl.cr","line_number":8,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl.cr#L8"},{"filename":"src/deepl/options.cr","line_number":1,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L1"},{"filename":"src/deepl/parser.cr","line_number":5,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/parser.cr#L5"},{"filename":"src/deepl/translator.cr","line_number":4,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L4"},{"filename":"src/deepl/version.cr","line_number":1,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/version.cr#L1"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"constants":[{"id":"VERSION","name":"VERSION","value":"{{ (`shards version /home/runner/work/deepl-cli/deepl-cli/src/deepl`).chomp.stringify }}"}],"class_methods":[{"html_id":"run-class-method","name":"run","abstract":false,"location":{"filename":"src/deepl.cr","line_number":9,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl.cr#L9"},"def":{"name":"run","visibility":"Public","body":"begin\n  translator = Deepl::Translator.new\n  parser = Deepl::Parser.new(translator)\n  option = parser.parse(ARGV)\n  if option.input.empty?\n    option.input = ARGF.gets_to_end\n  end\n  if option.no_ansi\n    option.input = option.input.gsub(/\\e\\[[0-9;]*[mGKHF]/, \"\")\n  end\n  spinner = Term::Spinner.new\n  translated_text = \"\"\n  spinner = Term::Spinner.new(clear: true)\n  spinner.run do\n    translated_text = translator.translate(option)\n  end\n  puts(translated_text)\nrescue ex\n  STDERR.puts(\"ERROR: #{ex.class} #{ex.message}\")\n  exit(1)\nend"}}],"types":[{"html_id":"deepl-cli/Deepl/ApiKeyError","path":"Deepl/ApiKeyError.html","kind":"class","full_name":"Deepl::ApiKeyError","name":"ApiKeyError","abstract":false,"superclass":{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},"ancestors":[{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/translator.cr","line_number":5,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L5"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"},"constructors":[{"html_id":"new-class-method","name":"new","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":6,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L6"},"def":{"name":"new","visibility":"Public","body":"_ = allocate\n_.initialize\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}]},{"html_id":"deepl-cli/Deepl/Options","path":"Deepl/Options.html","kind":"struct","full_name":"Deepl::Options","name":"Options","abstract":false,"superclass":{"html_id":"deepl-cli/Struct","kind":"struct","full_name":"Struct","name":"Struct"},"ancestors":[{"html_id":"deepl-cli/Struct","kind":"struct","full_name":"Struct","name":"Struct"},{"html_id":"deepl-cli/Value","kind":"struct","full_name":"Value","name":"Value"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/options.cr","line_number":7,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L7"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"},"constructors":[{"html_id":"new-class-method","name":"new","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":7,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L7"},"def":{"name":"new","visibility":"Public","body":"x = allocate\nif x.responds_to?(:finalize)\n  ::GC.add_finalizer(x)\nend\nx\n"}}],"instance_methods":[{"html_id":"formality:String|Nil-instance-method","name":"formality","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":12,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L12"},"def":{"name":"formality","return_type":"String | ::Nil","visibility":"Public","body":"@formality"}},{"html_id":"formality=(formality:String|Nil)-instance-method","name":"formality=","abstract":false,"args":[{"name":"formality","external_name":"formality","restriction":"String | ::Nil"}],"args_string":"(formality : String | Nil)","args_html":"(formality : String | Nil)","location":{"filename":"src/deepl/options.cr","line_number":12,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L12"},"def":{"name":"formality=","args":[{"name":"formality","external_name":"formality","restriction":"String | ::Nil"}],"visibility":"Public","body":"@formality = formality"}},{"html_id":"glossary_id:String|Nil-instance-method","name":"glossary_id","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":13,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L13"},"def":{"name":"glossary_id","return_type":"String | ::Nil","visibility":"Public","body":"@glossary_id"}},{"html_id":"glossary_id=(glossary_id:String|Nil)-instance-method","name":"glossary_id=","abstract":false,"args":[{"name":"glossary_id","external_name":"glossary_id","restriction":"String | ::Nil"}],"args_string":"(glossary_id : String | Nil)","args_html":"(glossary_id : String | Nil)","location":{"filename":"src/deepl/options.cr","line_number":13,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L13"},"def":{"name":"glossary_id=","args":[{"name":"glossary_id","external_name":"glossary_id","restriction":"String | ::Nil"}],"visibility":"Public","body":"@glossary_id = glossary_id"}},{"html_id":"initialize-instance-method","name":"initialize","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":7,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L7"},"def":{"name":"initialize","visibility":"Public","body":""}},{"html_id":"input:String-instance-method","name":"input","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":9,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L9"},"def":{"name":"input","return_type":"String","visibility":"Public","body":"@input"}},{"html_id":"input=(input:String)-instance-method","name":"input=","abstract":false,"args":[{"name":"input","external_name":"input","restriction":"String"}],"args_string":"(input : String)","args_html":"(input : String)","location":{"filename":"src/deepl/options.cr","line_number":9,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L9"},"def":{"name":"input=","args":[{"name":"input","external_name":"input","restriction":"String"}],"visibility":"Public","body":"@input = input"}},{"html_id":"no_ansi:Bool-instance-method","name":"no_ansi","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":14,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L14"},"def":{"name":"no_ansi","return_type":"Bool","visibility":"Public","body":"@no_ansi"}},{"html_id":"no_ansi=(no_ansi:Bool)-instance-method","name":"no_ansi=","abstract":false,"args":[{"name":"no_ansi","external_name":"no_ansi","restriction":"Bool"}],"args_string":"(no_ansi : Bool)","args_html":"(no_ansi : Bool)","location":{"filename":"src/deepl/options.cr","line_number":14,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L14"},"def":{"name":"no_ansi=","args":[{"name":"no_ansi","external_name":"no_ansi","restriction":"Bool"}],"visibility":"Public","body":"@no_ansi = no_ansi"}},{"html_id":"source_lang:String|Nil-instance-method","name":"source_lang","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":11,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L11"},"def":{"name":"source_lang","return_type":"String | ::Nil","visibility":"Public","body":"@source_lang"}},{"html_id":"source_lang=(source_lang:String|Nil)-instance-method","name":"source_lang=","abstract":false,"args":[{"name":"source_lang","external_name":"source_lang","restriction":"String | ::Nil"}],"args_string":"(source_lang : String | Nil)","args_html":"(source_lang : String | Nil)","location":{"filename":"src/deepl/options.cr","line_number":11,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L11"},"def":{"name":"source_lang=","args":[{"name":"source_lang","external_name":"source_lang","restriction":"String | ::Nil"}],"visibility":"Public","body":"@source_lang = source_lang"}},{"html_id":"sub_command:SubCmd-instance-method","name":"sub_command","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":8,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L8"},"def":{"name":"sub_command","return_type":"SubCmd","visibility":"Public","body":"@sub_command"}},{"html_id":"sub_command=(sub_command:SubCmd)-instance-method","name":"sub_command=","abstract":false,"args":[{"name":"sub_command","external_name":"sub_command","restriction":"SubCmd"}],"args_string":"(sub_command : SubCmd)","args_html":"(sub_command : <a href=\"../Deepl/SubCmd.html\">SubCmd</a>)","location":{"filename":"src/deepl/options.cr","line_number":8,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L8"},"def":{"name":"sub_command=","args":[{"name":"sub_command","external_name":"sub_command","restriction":"SubCmd"}],"visibility":"Public","body":"@sub_command = sub_command"}},{"html_id":"target_lang:String-instance-method","name":"target_lang","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":10,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L10"},"def":{"name":"target_lang","return_type":"String","visibility":"Public","body":"@target_lang"}},{"html_id":"target_lang=(target_lang:String)-instance-method","name":"target_lang=","abstract":false,"args":[{"name":"target_lang","external_name":"target_lang","restriction":"String"}],"args_string":"(target_lang : String)","args_html":"(target_lang : String)","location":{"filename":"src/deepl/options.cr","line_number":10,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L10"},"def":{"name":"target_lang=","args":[{"name":"target_lang","external_name":"target_lang","restriction":"String"}],"visibility":"Public","body":"@target_lang = target_lang"}}]},{"html_id":"deepl-cli/Deepl/Parser","path":"Deepl/Parser.html","kind":"class","full_name":"Deepl::Parser","name":"Parser","abstract":false,"superclass":{"html_id":"deepl-cli/OptionParser","kind":"class","full_name":"OptionParser","name":"OptionParser"},"ancestors":[{"html_id":"deepl-cli/OptionParser","kind":"class","full_name":"OptionParser","name":"OptionParser"},{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/parser.cr","line_number":6,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/parser.cr#L6"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"},"constructors":[{"html_id":"new(translator:Deepl::Translator)-class-method","name":"new","abstract":false,"args":[{"name":"translator","external_name":"translator","restriction":"::Deepl::Translator"}],"args_string":"(translator : Deepl::Translator)","args_html":"(translator : <a href=\"../Deepl/Translator.html\">Deepl::Translator</a>)","location":{"filename":"src/deepl/parser.cr","line_number":10,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/parser.cr#L10"},"def":{"name":"new","args":[{"name":"translator","external_name":"translator","restriction":"::Deepl::Translator"}],"visibility":"Public","body":"_ = allocate\n_.initialize(translator)\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"html_id":"opt:Options-instance-method","name":"opt","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":7,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/parser.cr#L7"},"def":{"name":"opt","return_type":"Options","visibility":"Public","body":"@opt"}},{"html_id":"parse(args)-instance-method","name":"parse","doc":"Parses the passed *args* (defaults to `ARGV`), running the handlers associated to each option.","summary":"<p>Parses the passed <em>args</em> (defaults to <code>ARGV</code>), running the handlers associated to each option.</p>","abstract":false,"args":[{"name":"args","external_name":"args","restriction":""}],"args_string":"(args)","args_html":"(args)","location":{"filename":"src/deepl/parser.cr","line_number":54,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/parser.cr#L54"},"def":{"name":"parse","args":[{"name":"args","external_name":"args","restriction":""}],"visibility":"Public","body":"super(args)\nopt\n"}},{"html_id":"show_help-instance-method","name":"show_help","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":87,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/parser.cr#L87"},"def":{"name":"show_help","visibility":"Public","body":"puts(self)\nexit\n"}},{"html_id":"show_source_languages-instance-method","name":"show_source_languages","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":59,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/parser.cr#L59"},"def":{"name":"show_source_languages","visibility":"Public","body":"translator.source_languages.each do |lang|\n  language, name = lang.values.map(&.to_s)\n  puts(\"- #{language.ljust(7)}#{name}\")\nend\nexit\n"}},{"html_id":"show_target_languages-instance-method","name":"show_target_languages","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":67,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/parser.cr#L67"},"def":{"name":"show_target_languages","visibility":"Public","body":"translator.target_languages.each do |lang|\n  language, name, supports_formality = lang.values.map(&.to_s)\n  formality = (  supports_formality == \"true\") ? \"YES\" : \"NO\"\n  puts(\"- #{language.ljust(7)}#{name.ljust(20)}\\tformality support [#{formality}]\")\nend\nexit\n"}},{"html_id":"show_usage-instance-method","name":"show_usage","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":76,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/parser.cr#L76"},"def":{"name":"show_usage","visibility":"Public","body":"puts(translator.api_url_base)\nputs(translator.usage.map do |k, v|\n  \"#{k}: #{v}\"\nend.join(\"\\n\"))\nexit\n"}},{"html_id":"show_version-instance-method","name":"show_version","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":82,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/parser.cr#L82"},"def":{"name":"show_version","visibility":"Public","body":"puts(Deepl::VERSION)\nexit\n"}},{"html_id":"translator:Translator-instance-method","name":"translator","abstract":false,"location":{"filename":"src/deepl/parser.cr","line_number":8,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/parser.cr#L8"},"def":{"name":"translator","return_type":"Translator","visibility":"Public","body":"@translator"}}]},{"html_id":"deepl-cli/Deepl/RequestError","path":"Deepl/RequestError.html","kind":"class","full_name":"Deepl::RequestError","name":"RequestError","abstract":false,"superclass":{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},"ancestors":[{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/translator.cr","line_number":11,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L11"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"},"constructors":[{"html_id":"new(message)-class-method","name":"new","abstract":false,"args":[{"name":"message","external_name":"message","restriction":""}],"args_string":"(message)","args_html":"(message)","location":{"filename":"src/deepl/translator.cr","line_number":12,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L12"},"def":{"name":"new","args":[{"name":"message","external_name":"message","restriction":""}],"visibility":"Public","body":"_ = allocate\n_.initialize(message)\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}]},{"html_id":"deepl-cli/Deepl/SubCmd","path":"Deepl/SubCmd.html","kind":"enum","full_name":"Deepl::SubCmd","name":"SubCmd","abstract":false,"ancestors":[{"html_id":"deepl-cli/Enum","kind":"struct","full_name":"Enum","name":"Enum"},{"html_id":"deepl-cli/Comparable","kind":"module","full_name":"Comparable","name":"Comparable"},{"html_id":"deepl-cli/Value","kind":"struct","full_name":"Value","name":"Value"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/options.cr","line_number":2,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L2"}],"repository_name":"deepl-cli","program":false,"enum":true,"alias":false,"const":false,"constants":[{"id":"Text","name":"Text","value":"0_u8"},{"id":"Document","name":"Document","value":"1_u8"}],"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"},"instance_methods":[{"html_id":"document?-instance-method","name":"document?","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":4,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L4"},"def":{"name":"document?","visibility":"Public","body":"self == Document"}},{"html_id":"text?-instance-method","name":"text?","abstract":false,"location":{"filename":"src/deepl/options.cr","line_number":3,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/options.cr#L3"},"def":{"name":"text?","visibility":"Public","body":"self == Text"}}]},{"html_id":"deepl-cli/Deepl/Translator","path":"Deepl/Translator.html","kind":"class","full_name":"Deepl::Translator","name":"Translator","abstract":false,"superclass":{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/translator.cr","line_number":23,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L23"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"constants":[{"id":"API_URL_BASE_FREE","name":"API_URL_BASE_FREE","value":"\"https://api-free.deepl.com/v2\""},{"id":"API_URL_BASE_PRO","name":"API_URL_BASE_PRO","value":"\"https://api.deepl.com/v2\""}],"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"},"constructors":[{"html_id":"new-class-method","name":"new","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":29,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L29"},"def":{"name":"new","visibility":"Public","body":"_ = allocate\n_.initialize\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"html_id":"api_url_base:String-instance-method","name":"api_url_base","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":27,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L27"},"def":{"name":"api_url_base","visibility":"Public","body":"@api_url_base"}},{"html_id":"api_url_translate:String-instance-method","name":"api_url_translate","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":27,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L27"},"def":{"name":"api_url_translate","visibility":"Public","body":"@api_url_translate"}},{"html_id":"request_languages(type)-instance-method","name":"request_languages","abstract":false,"args":[{"name":"type","external_name":"type","restriction":""}],"args_string":"(type)","args_html":"(type)","location":{"filename":"src/deepl/translator.cr","line_number":145,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L145"},"def":{"name":"request_languages","args":[{"name":"type","external_name":"type","restriction":""}],"visibility":"Public","body":"begin\n  HTTP::Client.get(\"#{api_url_base}/languages?type=#{type}\", headers: http_headers_for_text)\nrescue ex\n  raise(RequestError.new(\"#{ex.class} #{ex.message}\"))\nend"}},{"html_id":"source_languages-instance-method","name":"source_languages","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":158,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L158"},"def":{"name":"source_languages","visibility":"Public","body":"begin\n  response = request_languages(\"source\")\n  parse_languages_response(response)\nrescue ex\n  raise(RequestError.new(\"#{ex.class} #{ex.message}\"))\nend"}},{"html_id":"target_languages-instance-method","name":"target_languages","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":151,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L151"},"def":{"name":"target_languages","visibility":"Public","body":"begin\n  response = request_languages(\"target\")\n  parse_languages_response(response)\nrescue ex\n  raise(RequestError.new(\"#{ex.class} #{ex.message}\"))\nend"}},{"html_id":"translate(option)-instance-method","name":"translate","abstract":false,"args":[{"name":"option","external_name":"option","restriction":""}],"args_string":"(option)","args_html":"(option)","location":{"filename":"src/deepl/translator.cr","line_number":71,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L71"},"def":{"name":"translate","args":[{"name":"option","external_name":"option","restriction":""}],"visibility":"Public","body":"case option.sub_command\nwhen SubCmd::Text\n  translate_text(option.input, option.target_lang, option.source_lang, option.formality, option.glossary_id)\nelse\n  raise(UnknownSubCommandError.new)\nend"}},{"html_id":"translate_text(text,target_lang,source_lang=nil,formality=nil,glossary_id=nil)-instance-method","name":"translate_text","abstract":false,"args":[{"name":"text","external_name":"text","restriction":""},{"name":"target_lang","external_name":"target_lang","restriction":""},{"name":"source_lang","default_value":"nil","external_name":"source_lang","restriction":""},{"name":"formality","default_value":"nil","external_name":"formality","restriction":""},{"name":"glossary_id","default_value":"nil","external_name":"glossary_id","restriction":""}],"args_string":"(text, target_lang, source_lang = nil, formality = nil, glossary_id = nil)","args_html":"(text, target_lang, source_lang = <span class=\"n\">nil</span>, formality = <span class=\"n\">nil</span>, glossary_id = <span class=\"n\">nil</span>)","location":{"filename":"src/deepl/translator.cr","line_number":85,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L85"},"def":{"name":"translate_text","args":[{"name":"text","external_name":"text","restriction":""},{"name":"target_lang","external_name":"target_lang","restriction":""},{"name":"source_lang","default_value":"nil","external_name":"source_lang","restriction":""},{"name":"formality","default_value":"nil","external_name":"formality","restriction":""},{"name":"glossary_id","default_value":"nil","external_name":"glossary_id","restriction":""}],"visibility":"Public","body":"params = HTTP::Params.build do |form|\n  form.add(\"text\", text)\n  form.add(\"target_lang\", target_lang)\n  if source_lang\n    form.add(\"source_lang\", source_lang)\n  end\n  if formality\n    form.add(\"formality\", formality)\n  end\n  if glossary_id\n    form.add(\"glossary_id\", glossary_id)\n  end\nend\nresponse = execute_post_request(api_url_translate, params, http_headers_for_text)\ncase response.status_code\nwhen 456\n  raise(RequestError.new(\"Quota exceeded\"))\nwhen HTTP::Status::FORBIDDEN\n  raise(RequestError.new(\"Authorization failed\"))\nwhen HTTP::Status::NOT_FOUND\n  raise(RequestError.new(\"Not found\"))\nwhen HTTP::Status::BAD_REQUEST\n  raise(RequestError.new(\"Bad request\"))\nwhen HTTP::Status::TOO_MANY_REQUESTS\n  raise(RequestError.new(\"Too many requests\"))\nwhen HTTP::Status::SERVICE_UNAVAILABLE\n  raise(RequestError.new(\"Service unavailable\"))\nend\nparsed_response = JSON.parse(response.body)\nbegin\n  parsed_response.dig(\"translations\", 0, \"text\")\nrescue ex\n  raise(RequestError.new(\"#{ex.class} #{ex.message}\"))\nend\n"}},{"html_id":"usage-instance-method","name":"usage","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":169,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L169"},"def":{"name":"usage","visibility":"Public","body":"begin\n  response = request_usage\n  parse_usage_response(response)\nrescue ex\n  raise(RequestError.new(\"#{ex.class} #{ex.message}\"))\nend"}}]},{"html_id":"deepl-cli/Deepl/UnknownSubCommandError","path":"Deepl/UnknownSubCommandError.html","kind":"class","full_name":"Deepl::UnknownSubCommandError","name":"UnknownSubCommandError","abstract":false,"superclass":{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},"ancestors":[{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/translator.cr","line_number":17,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L17"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"},"constructors":[{"html_id":"new-class-method","name":"new","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":18,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/translator.cr#L18"},"def":{"name":"new","visibility":"Public","body":"_ = allocate\n_.initialize\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}]}]},{"html_id":"deepl-cli/HTTP","path":"HTTP.html","kind":"module","full_name":"HTTP","name":"HTTP","abstract":false,"locations":[{"filename":"lib/http_proxy/src/ext/http/client.cr","line_number":3,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/lib/http_proxy/src/ext/http/client.cr#L3"},{"filename":"lib/http_proxy/src/http/proxy/client.cr","line_number":10,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/lib/http_proxy/src/http/proxy/client.cr#L10"},{"filename":"lib/http_proxy/src/http_proxy.cr","line_number":8,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/lib/http_proxy/src/http_proxy.cr#L8"},{"filename":"src/deepl/utils/proxy.cr","line_number":29,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/utils/proxy.cr#L29"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"doc":"Monkey-patch `HTTP::Client` to make it respect the `*_PROXY`\n  environment variables","summary":"<p>Monkey-patch <code><a href=\"HTTP/Client.html\">HTTP::Client</a></code> to make it respect the <code>*_PROXY</code>   environment variables</p>","types":[{"html_id":"deepl-cli/HTTP/Client","path":"HTTP/Client.html","kind":"class","full_name":"HTTP::Client","name":"Client","abstract":false,"superclass":{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"lib/http_proxy/src/ext/http/client.cr","line_number":4,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/lib/http_proxy/src/ext/http/client.cr#L4"},{"filename":"src/deepl/utils/proxy.cr","line_number":30,"url":"https://github.com/kojix2/deepl-cli/blob/2bddc022b807450a285f5190fd9fc6b3904a8c6c/src/deepl/utils/proxy.cr#L30"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/HTTP","kind":"module","full_name":"HTTP","name":"HTTP"},"doc":"An HTTP Client.\n\nNOTE: To use `Client`, you must explicitly import it with `require \"http/client\"`\n\n### One-shot usage\n\nWithout a block, an `HTTP::Client::Response` is returned and the response's body\nis available as a `String` by invoking `HTTP::Client::Response#body`.\n\n```\nrequire \"http/client\"\n\nresponse = HTTP::Client.get \"http://www.example.com\"\nresponse.status_code      # => 200\nresponse.body.lines.first # => \"<!doctype html>\"\n```\n\n### Parameters\n\nParameters can be added to any request with the `URI::Params.encode` method, which\nconverts a `Hash` or `NamedTuple` to a URL encoded HTTP query.\n\n```\nrequire \"http/client\"\n\nparams = URI::Params.encode({\"author\" => \"John Doe\", \"offset\" => \"20\"}) # => \"author=John+Doe&offset=20\"\nresponse = HTTP::Client.get URI.new(\"http\", \"www.example.com\", query: params)\nresponse.status_code # => 200\n```\n\n### Streaming\n\nWith a block, an `HTTP::Client::Response` body is returned and the response's body\nis available as an `IO` by invoking `HTTP::Client::Response#body_io`.\n\n```\nrequire \"http/client\"\n\nHTTP::Client.get(\"http://www.example.com\") do |response|\n  response.status_code  # => 200\n  response.body_io.gets # => \"<!doctype html>\"\nend\n```\n\n### Reusing a connection\n\nSimilar to the above cases, but creating an instance of an `HTTP::Client`.\n\n```\nrequire \"http/client\"\n\nclient = HTTP::Client.new \"www.example.com\"\nresponse = client.get \"/\"\nresponse.status_code      # => 200\nresponse.body.lines.first # => \"<!doctype html>\"\nclient.close\n```\n\nWARNING: A single `HTTP::Client` instance is not safe for concurrent use by multiple fibers.\n\n### Compression\n\nIf `compress` isn't set to `false`, and no `Accept-Encoding` header is explicitly specified,\nan HTTP::Client will add an `\"Accept-Encoding\": \"gzip, deflate\"` header, and automatically decompress\nthe response body/body_io.\n\n### Encoding\n\nIf a response has a `Content-Type` header with a charset, that charset is set as the encoding\nof the returned IO (or used for creating a String for the body). Invalid bytes in the given encoding\nare silently ignored when reading text content.","summary":"<p>An HTTP Client.</p>"}]}]}})