import std/os
import std/parseopt
import std/strutils

proc init() =
  ## Initialize deployment configuration
  const configFile = "dede.yml"

  if fileExists(configFile):
    echo "Error: ", configFile, " already exists"
    quit(1)

  const defaultConfig = staticRead("default_config.yml")
  writeFile(configFile, defaultConfig)

proc showInitHelp() =
  const message = staticRead("command_init_help.txt")
  echo strip(message)

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
      of "help":
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