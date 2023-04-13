# DeepL CLI

A simple command-line interface (CLI) tool for translating text using [DeepL API](https://www.deepl.com/pro-api/). This tool allows you to quickly and easily translate text via the command line without going to the [DeepL website](https://www.deepl.com/).

## Requirements

- [Crystal programming language](https://crystal-lang.org/)
- [A DeepL API key](https://www.deepl.com/pro-api)

## Installation

Compiled binary versions of deepl-cli are uploaded to GitHub Release.
(Windows version is also uploaded but does not work properly)

### From source code

1. Clone this repository: `git clone https://github.com/kojix2/deepl-cli.git`
2. Change to the cloned directory: `cd deepl-cli`
3. Build the project using shards: `shards build`
4. [Get a valid API key from DeepL](https://www.deepl.com/pro-api) and set it as an environment variable:

```bash
export DEEPL_API_KEY=your_api_key_here
```

## Usage

To use the DeepL Translator CLI, simply run the `deepl` command followed by the arguments you wish to pass.

```bash
$ ./bin/deepl [arguments]
```

### Arguments

Options available for the CLI tool:

- `-f, --from=LANG`: Set the source language (default: AUTO). Example: `-f EN`.
- `-t, --to=LANG`: Set the target language (default: EN). Example: `-t ES`.
- `-v, --version`: Show the current version.
- `-h, --help`: Show the help message.

### Example

To translate the text "Hola mundo" from Spanish (ES) to English (EN):

```bash
$ ./bin/deepl --from ES --to EN "Hola mundo"
Hello world
```

```bash
$ echo "Hola mundo" | ./bin/deepl --from ES --to EN
Hello world
```

## Contributing

If you would like to contribute to the development of this CLI tool, please follow the steps below:

1. Fork this repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This project is licensed under the MIT License.

Happy translating!
