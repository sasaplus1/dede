import std/parseopt
import std/strutils
import ../meta
import command_deploy
import command_init
import command_test

proc showVersion() =
  echo VERSION

proc showHelp() =
  const message = """
    dede - simple dotfiles manager

    Usage:
      dede [OPTIONS]
      dede COMMAND [OPTIONS]

    Options:
      -h, --help     Show this help message
      -v, --version  Show version information

    Commands:
      init           Initialize deployment configuration
      deploy         Deploy dotfiles
      test           Test deployed dotfiles
  """.dedent().strip()
  echo message

when isMainModule:
  var parser = initOptParser()
  var command = ""

  while true:
    parser.next()
    case parser.kind
    of cmdEnd:
      break
    of cmdLongOption, cmdShortOption:
      case parser.key
      of "h", "help":
        showHelp()
        quit(0)
      of "v", "version":
        showVersion()
        quit(0)
      else:
        echo "Unknown option: ", parser.key
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