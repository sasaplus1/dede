import std/os
import std/parseopt
import std/strutils

proc init() =
  ## Initialize deployment configuration
  const configFile = "dede.yml"

  if fileExists(configFile):
    echo "Error: ", configFile, " already exists"
    quit(1)

  const defaultConfig = """
    # expand environment variables (optional)
    # expand:
    #   - USER
    #   - XDG_CONFIG_HOME

    # create directories
    directories:
      # - "$HOME/.local/bin"
      - ""

    # create symlinks
    symlinks:
      # - ["/path/to/dotfiles/vim/.vimrc", "$HOME/.vimrc"]
      - []

    # copy files
    copies:
      # - ["/path/to/.claude/settings.json", "$HOME/.claude/settings.json"]
      - []
  """.dedent()

  writeFile(configFile, defaultConfig)

proc showInitHelp() =
  const message = """
    dede init - Initialize deployment configuration

    Usage:
      dede init [OPTIONS]

    Options:
      -h, --help  Show this help message
  """.dedent().strip()
  echo message

proc commandInit*(args: seq[string]) =
  ## Init command implementation

  var parser = initOptParser(args)
  var remainingArgs: seq[string] = @[]

  while true:
    parser.next()
    case parser.kind
    of cmdEnd:
      break
    of cmdLongOption, cmdShortOption:
      case parser.key
      of "h", "help":
        showInitHelp()
        quit(0)
      else:
        echo "init: Unknown option: --", parser.key
        showInitHelp()
        quit(1)
    of cmdArgument:
      remainingArgs.add(parser.key)

  ## Execute init
  init()