import std/parseopt
import std/strutils

proc test() =
  ## Test deployed dotfiles
  discard

proc showTestHelp() =
  const message = """
    dede test - Test deployed dotfiles

    Usage:
      dede test [OPTIONS]

    Options:
      -h, --help  Show this help message
  """.dedent().strip()
  echo(message)

proc commandTest*(args: seq[string]) =
  ## Test command implementation

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
        showTestHelp()
        quit(0)
      else:
        echo "test: Unknown option: --", parser.key
        showTestHelp()
        quit(1)
    of cmdArgument:
      remainingArgs.add(parser.key)

  ## Execute test
  test()
