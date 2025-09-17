import std/parseopt
import std/strutils
import ../meta
import command_deploy
import command_init
import command_test
import log

proc showVersion() =
  echo VERSION

proc showHelp() =
  const message = staticRead("main_help.txt")
  echo strip(message)

when isMainModule:
  var parser = initOptParser(longNoVal = @["help", "version"])
  var command = ""

  while true:
    parser.next()
    case parser.kind
    of cmdEnd:
      break
    of cmdLongOption, cmdShortOption:
      case parser.key
      of "help":
        showHelp()
        quit(0)
      of "version":
        showVersion()
        quit(0)
      else:
        echoError "Unknown option: ", parser.key
        showHelp()
        quit(1)
    of cmdArgument:
      command = parser.key
      break

  ## Show help if no command provided
  if command == "":
    showHelp()
    quit(1)

  ## Pass remaining args to the command handler
  let remainingArgs = parser.remainingArgs()
  case command
  of "init":
    commandInit(remainingArgs)
  of "deploy":
    commandDeploy(remainingArgs)
  of "test":
    commandTest(remainingArgs)
  else:
    showHelp()
    quit(1)