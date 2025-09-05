import std/parseopt
import std/strutils

type
  DeployConfig* = object
    dryRun*: bool = false
    force*: bool = false

proc deploy(config: DeployConfig) =
  ## Execute deployment

  if config.dryRun and config.force:
    echo("Error: --dry-run and --force options are both set.")
    quit(1)

proc showDeployHelp() =
  ## Show help message for deploy command

  const message = """
    dede deploy - Deploy dotfiles

    Usage:
      dede deploy [OPTIONS]

    Options:
      --dry-run   Show what would be deployed without executing
      --force     Force deployment execution
      -h, --help  Show this help message
  """.dedent().strip()
  echo(message)

proc commandDeploy*(args: seq[string]) =
  ## Deploy command implementation

  var parser = initOptParser(args)
  var dryRun = false
  var force = false
  var remainingArgs: seq[string] = @[]
  
  while true:
    parser.next()
    case parser.kind
    of cmdEnd:
      break
    of cmdLongOption, cmdShortOption:
      case parser.key
      of "dry-run":
        dryRun = true
      of "force":
        force = true
      of "h", "help":
        showDeployHelp()
        quit(0)
      else:
        echo "deploy: Unknown option: --", parser.key
        showDeployHelp()
        quit(1)
    of cmdArgument:
      remainingArgs.add(parser.key)

  ## Execute deploy
  let deployConfig = DeployConfig(dryRun: dryRun, force: force)
  deploy(deployConfig)
