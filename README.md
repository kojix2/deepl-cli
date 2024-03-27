# DeepL CLI

[![build](https://github.com/kojix2/deepl-cli/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/deepl-cli/actions/workflows/build.yml)

A simple command-line tool for the [DeepL API](https://www.deepl.com/pro-api/), written in [Crystal](https://github.com/crystal-lang/crystal).

- Supports document translation
- Supports glossaries
- Precompiled binaries available

## Installation

### Download

- Download Linux binary from [Releases](https://github.com/kojix2/deepl-cli/releases)
- unzip file: `tar -xvf deepl.tar.gz`
- move file to executable path: `sudo mv deepl /usr/local/bin/`
- Binaries for Linux are statically linked, but not for macOS. homebrew is recommended for macOS.

### Homebrew (macOS)

```sh
brew install kojix2/brew/deepl-cli
```

### Proxy settings (optional)

```sh
export HTTP_PROXY=http://[IP]:[port]
export HTTPS_PROXY=https://[IP]:[port]
```

## Prerequisites

[Create a API key for DeepL](https://www.deepl.com/pro-api), then set it as an environment variable:

```sh
export DEEPL_AUTH_KEY=your_api_key_here
```

## Usage

```sh
deepl [options] <file>
```

### Translate Text

```sh
deepl [options] <file>
```

    -i, --input TEXT                 Input text
    -f, --from [LANG]                Source language [AUTO]
    -t, --to [LANG]                  Target language [EN]
    -g, --glossary ID                Glossary ID
    -F, --formality OPT              Formality (default more less)
    -C, --context TEXT               Context (experimental)
    -S, --split-sentences OPT        Split sentences
    -A, --ansi                       Do not remove ANSI escape codes

Note that since this tool is used on a terminal, ANSI escape sequences are removed by default.

### Translate Document

To translate a document, use the `doc` subcommand:

```sh
deepl doc [options] <file>
```

    -f, --from [LANG]                Source language [AUTO]
    -t, --to [LANG]                  Target language [EN]
    -g, --glossary ID                Glossary ID
    -F, --formality OPT              Formality (default more less)
    -o, --output FILE                Output file
    -O, --output-format FORMAT       Output file format

### Manage Glossaries

For glossary management, use the `glossary` subcommand:

```sh
deepl glossary [options]
```

    list                             List glossaries
    create                           Create glossary
    delete                           Delete glossary
    view                             View glossary
    -l, --list                       List glossaries (short form)
    -p, --language-pairs             List language pairs

### Examples

To translate the text "Hola mundo" from Spanish (ES) to English (EN):

```sh
deepl -i "Hola mundo" -f ES -t EN
# Hello world
```

Short options:

```sh
deepl -i "Hola mundo" -f es
# Hello world
```

From stream:

```sh
echo "Hola mundo" | deepl -f ES -t EN
# Hello world
```

Multiple lines:
Press `Ctrl+D` when finished typing.
This is especially useful when copy-pasting from the clipboard.

```sh
deepl -f es
# Hola
# mundo
# Ctrl + D
```

Display a list of available languages

```sh
deepl -f
```

```sh
deepl -t
```

Output usage information

```sh
deepl -u

# https://api.deepl.com/v2
# character_count: 614842
# character_limit: 1000000000000
```

## Contributing

1. Fork this repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Compilation from source code

```sh
git clone https://github.com/kojix2/deepl-cli
cd deepl-cli
shards build --release
# sudo cp bin/deepl /usr/local/bin
```

A compiled binary file will be created in the `bin` directory.

## License

This project is licensed under the MIT License.

Happy translating!
