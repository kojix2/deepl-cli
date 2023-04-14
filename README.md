# DeepL CLI

A simple command-line interface (CLI) tool for translating text using the [DeepL API](https://www.deepl.com/pro-api/). This tool allows you to quickly and easily translate text via the command line without having to visit the [DeepL website](https://www.deepl.com/).

## Installation

Compiled binary files can be downloaded from [GitHub Release](https://github.com/kojix2/deepl-cli/releases/latest).
(Note: The Windows version is currently not working properly)

First, [obtain a valid API key from DeepL](https://www.deepl.com/pro-api), then set it as an environment variable:

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
- `-u, --usage`: Check Usage and Limits
- `-v, --version`: Show the current version.
- `-h, --help`: Show the help message.

### Example

To translate the text "Hola mundo" from Spanish (ES) to English (EN):

```bash
$ deepl --from ES --to EN "Hola mundo"
Hello world
```

Short options:

```
$ deepl -f es "Hola mundo"
Hello world
```

From stream:

```bash
$ echo "Hola mundo" | deepl --from ES --to EN
Hello world
```

Multiple lines:
Press Ctrl+D when finished typing.
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