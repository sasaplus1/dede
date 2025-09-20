# dede

Simple dotfiles deployment tool

## Installation

Download archive via [releases](https://github.com/sasaplus1/dede/releases)

## Getting started

Create `dede.yml` configuration file:

```sh
$ dede init
```

Edit `dede.yml` to specify your dotfiles and directories:

```yml
expand:
  - HOME

directories:
  - "$HOME/.config"
  - "$HOME/.local/bin"
  - "$HOME/.local/share"

symlnks:
  - ["/path/to/.bashrc", "$HOME/.bashrc"]
  - ["/path/to/.vimrc", "$HOME/.vimrc"]

copies:
  - []
```

Deploy dotfiles and directories:

```sh
$ dede deploy
```

Test deployed dotfiles and directories:

```sh
$ dede test
```

## Commands

### init

```
dede init - Initialize deployment configuration

Usage:
  dede init [OPTIONS]

Options:
  -c, --config FILE  Specify configuration file (default: dede.yml, .dede.yml)
  --help             Show this help message
```

### deploy

```
dede deploy - Deploy dotfiles

Usage:
  dede deploy [OPTIONS]

Options:
  -c, --config FILE  Specify configuration file (default: dede.yml, .dede.yml)
  -e, --expand VAR   Expand additional environment variable
  --dry-run          Show what would be deployed without executing
  --force            Force deployment execution
  --help             Show this help message
```

### test

```
dede test - Test deployed dotfiles

Usage:
  dede test [OPTIONS]

Options:
  -c, --config FILE  Specify configuration file (default: dede.yml, .dede.yml)
  -e, --expand VAR   Expand additional environment variable
  --help             Show this help message
```

## Development

```sh
$ nimble --localdeps install -dy
$ nimble --localdeps setup
$ nimble test
```

## License

The MIT license
