# dede

Simple dotfiles deployment tool

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
