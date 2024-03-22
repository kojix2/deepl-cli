# DeepL CLI

[![build](https://github.com/kojix2/deepl-cli/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/deepl-cli/actions/workflows/build.yml)

A simple command-line interface (CLI) tool for translating text using the [DeepL API](https://www.deepl.com/pro-api/), written in Crystal programming language. This tool enables quick and easy text translation via the command line without visiting the [DeepL website](https://www.deepl.com/).

## Prerequisites

First, [obtain a valid API key from DeepL](https://www.deepl.com/pro-api), then set it as an environment variable:

```bash
export DEEPL_AUTH_KEY=your_api_key_here
```

## Installation

- Precompiled binaries are available from [GitHub Releases](https://github.com/kojix2/deepl-cli/releases). (binaries for Linux are statically linked)
- Compiling from source code is recommended for environments other than Linux.

### Compilation from source code

```bash
git clone https://github.com/kojix2/deepl-cli
cd deepl-cli
shards build --release
# sudo cp bin/deepl /usr/local/bin
```

A compiled binary file will be created in the `bin` directory.

### Proxy settings (optional)

```
export HTTP_PROXY=http://[IP]:[port]
export HTTPS_PROXY=https://[IP]:[port]
```

## Usage

To use the DeepL Translator CLI, simply run the `deepl` command followed by the arguments you wish to pass.

```bash
deepl [options] <file>
```

### Arguments

Options available for the CLI tool:

    -i, --input TEXT                 Input text
    -f, --from [LANG]                Source language [AUTO]
    -t, --to [LANG]                  Target language [EN]
    -g ID, --glossary ID             Glossary ID
    -F, --formality OPT              Formality (default more less)
    -A, --ansi                       Do not remove ANSI escape codes
    -u, --usage                      Check Usage and Limits
    -d, --debug                      Show backtrace on error
    -v, --version                    Show version
    -h, --help                       Show this help

Note that since this tool is used on a terminal, ANSI escape sequences are removed by default.

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
