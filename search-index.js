crystal_doc_search_index_callback({"repository_name":"deepl-cli","body":"# DeepL CLI\n\nA simple command-line interface (CLI) tool for translating text using [DeepL API](https://www.deepl.com/pro-api/). This tool allows you to quickly and easily translate text via the command line without going to the [DeepL website](https://www.deepl.com/).\n\n## Requirements\n\n- [Crystal programming language](https://crystal-lang.org/)\n- [A DeepL API key](https://www.deepl.com/pro-api)\n\n## Installation\n\n1. Clone this repository: `git clone https://github.com/kojix2/deepl-cli.git`\n2. Change to the cloned directory: `cd deepl-cli`\n3. Build the project using shards: `shards build`\n4. [Get a valid API key from DeepL](https://www.deepl.com/pro-api) and set it as an environment variable:\n\n```bash\nexport DEEPL_API_KEY=your_api_key_here\n```\n\n## Usage\n\nTo use the DeepL Translator CLI, simply run the `deepl` command followed by the arguments you wish to pass.\n\n```bash\n$ ./bin/deepl [arguments]\n```\n\n### Arguments\n\nOptions available for the CLI tool:\n\n- `-f, --from=LANG`: Set the source language (default: AUTO). Example: `-f EN`.\n- `-t, --to=LANG`: Set the target language (default: EN). Example: `-t ES`.\n- `-v, --version`: Show the current version.\n- `-h, --help`: Show the help message.\n\n### Example\n\nTo translate the text \"Hola mundo\" from Spanish (ES) to English (EN):\n\n```bash\n$ ./bin/deepl --from ES --to EN \"Hola mundo\"\nHello world\n```\n\n```bash\n$ echo \"Hola mundo\" | ./bin/deepl --from ES --to EN\nHello world\n```\n\n## Contributing\n\nIf you would like to contribute to the development of this CLI tool, please follow the steps below:\n\n1. Fork this repository\n2. Create your feature branch (`git checkout -b my-new-feature`)\n3. Commit your changes (`git commit -am 'Add some feature'`)\n4. Push to the branch (`git push origin my-new-feature`)\n5. Create a new Pull Request\n\n## License\n\nThis project is licensed under the MIT License.\n\nHappy translating!\n","program":{"html_id":"deepl-cli/toplevel","path":"toplevel.html","kind":"module","full_name":"Top Level Namespace","name":"Top Level Namespace","abstract":false,"locations":[],"repository_name":"deepl-cli","program":true,"enum":false,"alias":false,"const":false,"types":[{"html_id":"deepl-cli/Deepl","path":"Deepl.html","kind":"module","full_name":"Deepl","name":"Deepl","abstract":false,"locations":[{"filename":"src/deepl/translator.cr","line_number":4,"url":"https://github.com/kojix2/deepl-cli/blob/6084a15e59f6d8e408188e64054ac92468062dab/src/deepl/translator.cr#L4"},{"filename":"src/deepl/version.cr","line_number":1,"url":"https://github.com/kojix2/deepl-cli/blob/6084a15e59f6d8e408188e64054ac92468062dab/src/deepl/version.cr#L1"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"constants":[{"id":"VERSION","name":"VERSION","value":"\"0.1.0\""}],"types":[{"html_id":"deepl-cli/Deepl/ApiKeyError","path":"Deepl/ApiKeyError.html","kind":"class","full_name":"Deepl::ApiKeyError","name":"ApiKeyError","abstract":false,"superclass":{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},"ancestors":[{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/translator.cr","line_number":5,"url":"https://github.com/kojix2/deepl-cli/blob/6084a15e59f6d8e408188e64054ac92468062dab/src/deepl/translator.cr#L5"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"}},{"html_id":"deepl-cli/Deepl/RequestError","path":"Deepl/RequestError.html","kind":"class","full_name":"Deepl::RequestError","name":"RequestError","abstract":false,"superclass":{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},"ancestors":[{"html_id":"deepl-cli/Exception","kind":"class","full_name":"Exception","name":"Exception"},{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/translator.cr","line_number":7,"url":"https://github.com/kojix2/deepl-cli/blob/6084a15e59f6d8e408188e64054ac92468062dab/src/deepl/translator.cr#L7"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"}},{"html_id":"deepl-cli/Deepl/Translator","path":"Deepl/Translator.html","kind":"class","full_name":"Deepl::Translator","name":"Translator","abstract":false,"superclass":{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"deepl-cli/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"deepl-cli/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"src/deepl/translator.cr","line_number":9,"url":"https://github.com/kojix2/deepl-cli/blob/6084a15e59f6d8e408188e64054ac92468062dab/src/deepl/translator.cr#L9"}],"repository_name":"deepl-cli","program":false,"enum":false,"alias":false,"const":false,"constants":[{"id":"API_ENDPOINT","name":"API_ENDPOINT","value":"\"https://api-free.deepl.com/v2\""},{"id":"API_TRANSLATE_ENDPOINT","name":"API_TRANSLATE_ENDPOINT","value":"\"#{API_ENDPOINT}/translate\""}],"namespace":{"html_id":"deepl-cli/Deepl","kind":"module","full_name":"Deepl","name":"Deepl"},"constructors":[{"html_id":"new-class-method","name":"new","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":15,"url":"https://github.com/kojix2/deepl-cli/blob/6084a15e59f6d8e408188e64054ac92468062dab/src/deepl/translator.cr#L15"},"def":{"name":"new","visibility":"Public","body":"_ = allocate\n_.initialize\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"html_id":"request_languages(type)-instance-method","name":"request_languages","abstract":false,"args":[{"name":"type","external_name":"type","restriction":""}],"args_string":"(type)","args_html":"(type)","location":{"filename":"src/deepl/translator.cr","line_number":56,"url":"https://github.com/kojix2/deepl-cli/blob/6084a15e59f6d8e408188e64054ac92468062dab/src/deepl/translator.cr#L56"},"def":{"name":"request_languages","args":[{"name":"type","external_name":"type","restriction":""}],"visibility":"Public","body":"begin\n  HTTP::Client.get(\"#{API_ENDPOINT}/languages?type=#{type}\", headers: @http_headers)\nrescue ex\n  raise(RequestError.new(\"Error: #{ex.message}\"))\nend"}},{"html_id":"request_translation(text,target_lang,source_lang)-instance-method","name":"request_translation","abstract":false,"args":[{"name":"text","external_name":"text","restriction":""},{"name":"target_lang","external_name":"target_lang","restriction":""},{"name":"source_lang","external_name":"source_lang","restriction":""}],"args_string":"(text, target_lang, source_lang)","args_html":"(text, target_lang, source_lang)","location":{"filename":"src/deepl/translator.cr","line_number":30,"url":"https://github.com/kojix2/deepl-cli/blob/6084a15e59f6d8e408188e64054ac92468062dab/src/deepl/translator.cr#L30"},"def":{"name":"request_translation","args":[{"name":"text","external_name":"text","restriction":""},{"name":"target_lang","external_name":"target_lang","restriction":""},{"name":"source_lang","external_name":"source_lang","restriction":""}],"visibility":"Public","body":"params = [\"text=#{URI.encode_www_form(text)}\", \"target_lang=#{target_lang}\"]\nif source_lang == \"AUTO\"\nelse\n  params << \"source_lang=#{source_lang}\"\nend\nrequest_payload = params.join(\"&\")\nsend_post_request(request_payload)\n"}},{"html_id":"source_languages-instance-method","name":"source_languages","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":69,"url":"https://github.com/kojix2/deepl-cli/blob/6084a15e59f6d8e408188e64054ac92468062dab/src/deepl/translator.cr#L69"},"def":{"name":"source_languages","visibility":"Public","body":"begin\n  response = request_languages(\"source\")\n  parse_languages_response(response)\nrescue ex\n  raise(RequestError.new(\"Error: #{ex.message}\"))\nend"}},{"html_id":"target_languages-instance-method","name":"target_languages","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":62,"url":"https://github.com/kojix2/deepl-cli/blob/6084a15e59f6d8e408188e64054ac92468062dab/src/deepl/translator.cr#L62"},"def":{"name":"target_languages","visibility":"Public","body":"begin\n  response = request_languages(\"target\")\n  parse_languages_response(response)\nrescue ex\n  raise(RequestError.new(\"Error: #{ex.message}\"))\nend"}},{"html_id":"translate(text,target_lang,source_lang)-instance-method","name":"translate","abstract":false,"args":[{"name":"text","external_name":"text","restriction":""},{"name":"target_lang","external_name":"target_lang","restriction":""},{"name":"source_lang","external_name":"source_lang","restriction":""}],"args_string":"(text, target_lang, source_lang)","args_html":"(text, target_lang, source_lang)","location":{"filename":"src/deepl/translator.cr","line_number":46,"url":"https://github.com/kojix2/deepl-cli/blob/6084a15e59f6d8e408188e64054ac92468062dab/src/deepl/translator.cr#L46"},"def":{"name":"translate","args":[{"name":"text","external_name":"text","restriction":""},{"name":"target_lang","external_name":"target_lang","restriction":""},{"name":"source_lang","external_name":"source_lang","restriction":""}],"visibility":"Public","body":"response = request_translation(text, target_lang, source_lang)\nparsed_response = JSON.parse(response.body)\nbegin\n  parsed_response.dig(\"translations\", 0, \"text\")\nrescue\n  raise(RequestError.new(\"Error: #{parsed_response}\"))\nend\n"}},{"html_id":"usage-instance-method","name":"usage","abstract":false,"location":{"filename":"src/deepl/translator.cr","line_number":80,"url":"https://github.com/kojix2/deepl-cli/blob/6084a15e59f6d8e408188e64054ac92468062dab/src/deepl/translator.cr#L80"},"def":{"name":"usage","visibility":"Public","body":"begin\n  response = request_usage\n  parse_usage_response(response)\nrescue ex\n  raise(RequestError.new(\"Error: #{ex.message}\"))\nend"}}]}]}]}})