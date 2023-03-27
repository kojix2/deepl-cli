# DeepL Translator CLI

A command-line interface (CLI) tool for translating text using DeepL API.

## Installation

1. Clone this repository
2. [Get a valid API key from DeepL](https://www.deepl.com/pro-api)

## Usage

```bash
$ deepl [arguments]
```

### Arguments

Options available for the CLI tool:

- `-f, --from=LANG`: Set the source language (default: AUTO)
- `-t, --to=LANG`: Set the target language (default: EN)
- `-v, --version`: Show the current version
- `-h, --help`: Show the help message

### Example

```bash
$ deepl --from=ES --to=EN "Hola mundo"
Hello world
```

## Contributing

1. Fork this repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This project is licensed under the MIT License. 