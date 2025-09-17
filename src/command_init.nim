import std/os
import std/parseopt
import std/strutils
import log

proc init() =
  ## Initialize deployment configuration
  const configFile = "dede.yml"

  if fileExists(configFile):
    echoError "Error: ", configFile, " already exists"
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
      of "verbose", "v":
        isVerbose = true
      else:
        echoError "init: Unknown option: --", parser.key
        showInitHelp()
        quit(1)
    of cmdArgument:
      remainingArgs.add(parser.key)

  ## Execute init
  init()