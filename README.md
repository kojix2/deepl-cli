# DeepL CLI

[![build](https://github.com/kojix2/deepl-cli/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/deepl-cli/actions/workflows/build.yml)

DeepL CLI is a simple command-line tool for the [DeepL API](https://www.deepl.com/pro-api/), written in [Crystal](https://github.com/crystal-lang/crystal). 

- Supports document translation
- Supports glossaries
- Precompiled binaries available

## Installation

### Download

- Download the Linux binary from the [Releases](https://github.com/kojix2/deepl-cli/releases)
- Unzip: `tar -xvf deepl.tar.gz`
- Move to the executable path: `sudo mv deepl /usr/local/bin/`

Note: Binaries for Linux are statically linked. For macOS, we recommend using homebrew.

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

You will need an API key for DeepL. [Create one here](https://www.deepl.com/pro-api) and set it as an environment variable:

```sh
export DEEPL_AUTH_KEY=your_api_key_here
```

## Usage

```sh
deepl [options] <file>
```

### Translate text

```sh
deepl [options] <file>
```

Options:

```txt
    -i, --input TEXT                 Input text
    -f, --from [LANG]                Source language [AUTO]
    -t, --to [LANG]                  Target language [EN]
    -g, --glossary ID                Glossary ID
    -F, --formality OPT              Formality (default more less)
    -C, --context TEXT               Context (experimental)
    -S, --split-sentences OPT        Split sentences
    -A, --ansi                       Do not remove ANSI escape codes
```

Note: ANSI escape sequences are removed by default.

### Translate documents

To translate a document, use the `doc` subcommand:

```sh
deepl doc [options] <file>
```

Options for document translation:

```txt
    -f, --from [LANG]                Source language [AUTO]
    -t, --to [LANG]                  Target language [EN]
    -g, --glossary ID                Glossary ID
    -F, --formality OPT              Formality (default more less)
    -o, --output FILE                Output file
    -O, --output-format FORMAT       Output file format
```

### Manage Glossaries

For glossary management, use the `glossary` subcommand:

```sh
deepl glossary [options]
```

Options for glossary management:

```txt
    list                             List glossaries
    create                           Create a glossary
    delete                           Delete a glossary
    view                             View a glossary
    -l, --list                       List glossaries
    -p, --language-pairs             List language pairs
```

## Examples

Below are examples for translating text, translating documents, and working with glossaries.

### Translate Text

To translate the text "Hola mundo" from Spanish (ES) to English (EN):

```sh
deepl -i "Hola mundo" -t EN        # Hello world
```

Or, using standard stream:

```sh
echo "Hola mundo" | deepl -t en    # Hello world
```

Translation from standard input is useful for viewing help.

```sh
git --help | deepl -t fr | less
```

man can also be translated. (removing ANSI escape sequences)

```sh
man git | deepl -t de | less
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

( Experimental feature ) Translate text from the clipboard.

```
deepl --paste
```

You can also pass a text file as an argument.

```
deepl -t pl foo.txt
```

Multiple text files can be passed.

```
deepl -t nl foo.txt bar.txt
```

However, if you are translating multiple files, you may want to add filename to the header.

```
bat --style header *.txt | deepl -t it
```

### Translate documents

You can translate documents directly.

```sh
deepl doc your.pdf -t EN
# Save to your_EN.pdf
```

Translation of multiple documents.

```sh
find . -name "*.pdf" -exec deepl doc -t ja {} +
```

```sh
ls -1 *.docx | xargs -L1 deepl doc -t ko
```

```sh
fd -e pdf -e docx -x deepl doc -t zh
```

### Glossaries

Create a glossary.

```sh
deepl glossary create -n mydic -f en -t ja mydict.tsv
```

List glossaries.

```sh
deepl glossary list
# deepl glossary -l
```

Using glossary for translation.

```sh
deepl -g mydict
```

```sh
deepl doc -g mydict
```

Display the contents of the glossary.

```sh
deepl glossary view -n mydict
```

List of languages in which Glossary can be created.

```sh
deepl glossary -p
```

### Information

Display a list of available languages (from)

```sh
deepl -f
```

Display a list of available languages (to)

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

## Development

Contributions are always welcome.

- Report bugs
- Fix bugs and submit pull requests
- Write, clarify, or fix documentation
- Suggest or add new features

### Compilation from source code

```sh
git clone https://github.com/kojix2/deepl-cli
cd deepl-cli
shards build --release
# sudo cp bin/deepl /usr/local/bin
```

A compiled binary file will be created in the `bin` directory.

### DeepL API Library

- [https://github.com/kojix2/deepl.cr/](https://github.com/kojix2/deepl.cr/)

## License

This project is licensed under the MIT License.

Happy translating!
