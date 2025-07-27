# DeepL CLI

[![build](https://github.com/kojix2/deepl-cli/actions/workflows/build.yml/badge.svg)](https://github.com/kojix2/deepl-cli/actions/workflows/build.yml)
[![Lines of Code](https://img.shields.io/endpoint?url=https%3A%2F%2Ftokei.kojix2.net%2Fbadge%2Fgithub%2Fkojix2%2Fdeepl-cli%2Flines)](https://tokei.kojix2.net/github/kojix2/deepl-cli)

DeepL CLI is a fast and lightweight command-line tool for the [DeepL API](https://www.deepl.com/pro-api/), written in [Crystal](https://github.com/crystal-lang/crystal).

- Supports document translation `pdf`, `docx`, `txt`, etc.
- Supports glossaries
- Precompiled binaries available

## Installation

### Download

- Download the binary from the [Releases](https://github.com/kojix2/deepl-cli/releases)

### Homebrew

[![deepl-cli (macos)](https://github.com/kojix2/homebrew-brew/actions/workflows/deepl-cli-macos.yml/badge.svg)](https://github.com/kojix2/homebrew-brew/actions/workflows/deepl-cli-macos.yml)
[![deepl-cli (ubuntu)](https://github.com/kojix2/homebrew-brew/actions/workflows/deepl-cli-ubuntu.yml/badge.svg)](https://github.com/kojix2/homebrew-brew/actions/workflows/deepl-cli-ubuntu.yml)

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
    -p, --paste                      Input text from clipboard
    -g, --glossary NAME              Glossary name
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
    -g, --glossary NAME              Glossary name
    -F, --formality OPT              Formality (default more less)
    -o, --output FILE                Output file
    -O, --output-format FORMAT       Output file format
```

Supported file formats.

- `docx` - Microsoft Word Document
- `pptx` - Microsoft PowerPoint Document
- `xlsx` - Microsoft Excel Document
- `pdf` - Portable Document Format
- `htm` / `html` - HTML Document
- `txt` - Plain Text Document
- `xlf` / `xliff` - XLIFF Document, version 2.1

### Manage Glossaries

For glossary management, use the `glossary` subcommand:

```sh
deepl glossary [options]
```

Options for glossary management:

```txt
    list                             List glossaries
    create                           Create a glossary
    delete                           Delete glossaries
    edit                             Edit glossaries
    view                             View glossaries
    -l, --list                       List glossaries
    -p, --language-pairs             List language pairs
```

## Examples

Below are examples for translating text, translating documents, and working with glossaries.

### Translate Text

To translate the text "Hola mundo" from Spanish (ES) to English (EN):

```sh
deepl -i "Hola mundo" -t en        # Translation: Hello world
```

Or, using standard input:

```sh
echo "Hola mundo" | deepl -t en    # Translation: Hello world
```

Standard input translation is useful for quick references.

```sh
git --help | deepl -t fr | less
```

The `man` command can also be translated (by removing ANSI escape sequences):

```sh
man git | deepl -t de | less
```

To translate multiple lines, press `Ctrl+D` when you have finished typing. This is particularly useful when copying and pasting from the clipboard.

```sh
deepl -f es
# Hola
# mundo
# Ctrl + D
```

Translate text from the clipboard:

```sh
deepl --paste
```

You can also pass a text file as an argument:

```sh
deepl -t tr foo.txt
```

It's possible to pass multiple text files:

```sh
deepl -t nl foo.txt bar.txt
```

If you are translating multiple files, you might want to add the filename to the header:

```sh
bat --style header *.txt | deepl -t it
```

To use a glossary for translation:

```sh
deepl -g myglossary -f ru
```

To refer to the original text, you can use `tee dev/stderr`:

```sh
fortune | tee /dev/stderr | deepl
```

### Translate documents

You can directly translate documents:

```sh
deepl doc your.pdf -t pt
# The translated document will be saved as your_PT.pdf
```

To use a glossary for translation:

```sh
deepl doc -g myglossary -f pl
```

To translate a PDF document and save it in docx format:

```
deepl doc input.pdf -O docx -o output.docx
```

To translate multiple files, use Unix commands such as `find`, `xargs`, `fd`:

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

The DeepL API supports glossaries. See [here](https://developers.deepl.com/docs/api-reference/glossaries#formats) for the format of the glossary file.

To create a glossary:

```sh
deepl glossary create -n mydic -f en -t pt mydict.tsv
```

To list glossaries:

```sh
deepl glossary list
```

To list only the names of the glossary:

```sh
deepl glossary -l
```

To use a glossary for text translation:

```sh
deepl -g mydict -f en deep.txt
```

To use a glossary for document translation:

```sh
deepl doc -g mydict -f en deep.pdf
```

To display the contents of the glossary:

```sh
deepl glossary view mydict
```

To list the languages in which glossaries can be created:

```sh
deepl glossary -p
```

### Information

To display a list of available source languages:

```sh
deepl -f
```

To display a list of available target languages:

```sh
deepl -t
```

To output usage information:

```sh
deepl -u

# https://api.deepl.com/v2
# character_count: 614842
# character_limit: 1000000000000
```

### Environment Variables

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>DEEPL_AUTH_KEY</td>
      <td>DeepL API authentication key</td>
    </tr>
    <tr>
      <td>DEEPL_TARGET_LANG</td>
      <td>Default target language</td>
    </tr>
    <tr>
      <td>DEEPL_USER_AGENT</td>
      <td>User-Agent</td>
    </tr>
    <tr>
      <td>EDITOR</td>
      <td>Text editor for editing glossary</td>
    </tr>
  </tbody>
</table>

DeepL CLI automatically detects the target language, but if this does not work, the environment variable `DEEPL_TARGET_LANG` can be set.

## Contributing

- Fork this repository
- Report bugs
- Fix bugs and submit pull requests
- Write, clarify, or fix documentation
- Suggest or add new features

## Development

Compilation from source code

```sh
git clone https://github.com/kojix2/deepl-cli
cd deepl-cli
shards build --release
```

A compiled binary file will be created in the `bin` directory. Installation is simply copying the generated binary.

```
sudo cp bin/deepl /usr/local/bin
```

If you encounter a bug, follow the command with the `-d` option and run it. You can view the backtrace.

```sh
deepl doc -d a.pdf
```

### DeepL API Library

- [https://github.com/kojix2/deepl.cr/](https://github.com/kojix2/deepl.cr/)

## License

This project is licensed under the MIT License.

Happy translating!
