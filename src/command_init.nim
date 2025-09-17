import std/os
import std/parseopt
import std/strutils
import config
import log

proc init(configFile: string = "dede.yml") =
  ## Initialize deployment configuration

  # Check if any default config exists when no config specified
  if configFile == "dede.yml":
    let existingConfig = findDefaultConfigFile()
    if existingConfig != "":
      echoError "Error: ", existingConfig, " already exists"
      quit(1)
  else:
    # Check if specified config exists
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

  var parser = initOptParser(args, shortNoVal = {'v'}, longNoVal = @["help", "verbose"])
  var remainingArgs: seq[string] = @[]
  var configFile = "dede.yml"
  var expectConfigFile = false

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
      of "c", "config":
        if parser.val != "":
          configFile = parser.val
        else:
          expectConfigFile = true
      else:
        echoError "init: Unknown option: --", parser.key
        showInitHelp()
        quit(1)
    of cmdArgument:
      if expectConfigFile:
        configFile = parser.key
        expectConfigFile = false
      else:
        remainingArgs.add(parser.key)

  ## Check if we're still expecting a config file
  if expectConfigFile:
    echoError "Error: -c/--config requires a value (use -c FILE or --config=FILE)"
    quit(1)

  ## Execute init
  init(configFile)