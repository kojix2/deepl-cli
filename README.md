# DeepL CLI

[![build](https://github.com/kojix2/deepl-cli/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/deepl-cli/actions/workflows/build.yml)

A simple command-line interface (CLI) tool for translating text using the [DeepL API](https://www.deepl.com/pro-api/), written in Crystal programming language. This tool enables quick and easy text translation via the command line without visiting the [DeepL website](https://www.deepl.com/).

## Prerequisites

First, [obtain a valid API key from DeepL](https://www.deepl.com/pro-api), then set it as an environment variable:

```bash
export DEEPL_AUTH_KEY=your_api_key_here
```

## Installation

Download the latest source code, then run the following commands:

```bash
cd deepl-cli
shards build --release
```

To use DeepL API Pro, compile with the environment variable DEEPL_API_PRO=1. 

```
DEEPL_API_PRO=1 shards build --release # for DeepL API Pro
```

A compiled binary file will be created in the `bin` folder.

#### Proxy settings (optional)

```
export HTTP_PROXY=http://[IP]:[port]
export HTTPS_PROXY=https://[IP]:[port]
```

## Usage

To use the DeepL Translator CLI, simply run the `deepl` command followed by the arguments you wish to pass.

```bash
$ ./bin/deepl [arguments]
```

### Arguments

Options available for the CLI tool:

- `-i, --input=TEXT`: Input text to translate.
- `-f, --from=LANG`: Set the source language (default: AUTO). Example: `-f EN`.
- `-t, --to=LANG`: Set the target language (default: EN). Example: `-t ES`.
- `-u, --usage`: Check Usage and Limits
- `-v, --version`: Show the current version.
- `-h, --help`: Show the help message.

### Examples

To translate the text "Hola mundo" from Spanish (ES) to English (EN):

```bash
$ deepl -i "Hola mundo" -f ES -t EN
Hello world
```

Short options:

```
$ deepl -i "Hola mundo" -f es
Hello world
```

From stream:

```bash
$ echo "Hola mundo" | deepl -f ES -t EN
Hello world
```

Multiple lines:
Press `Ctrl+D` when finished typing.
This is especially useful when copy-pasting from the clipboard.

```
$ deepl -f es
Hola
mundo
```

Display a list of available languages

```
$ deepl -f
$ deepl -t
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
