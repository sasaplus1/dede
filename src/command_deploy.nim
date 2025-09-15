import std/os
import std/parseopt
import std/strutils
import config
import utility

type
  DeployConfig* = object
    dryRun*: bool = false
    force*: bool = false

proc deploy(deployConfig: DeployConfig) =
  ## Execute deployment

  if deployConfig.dryRun and deployConfig.force:
    echo "Error: --dry-run and --force options are both set."
    quit(1)

  # Load configuration
  let config = loadConfig("dede.yml")

  # Process directories
  for dir in config.directories:
    let expandedPath = expandEnvVars(dir, config.expand)

    if deployConfig.dryRun:
      echo "[DRY-RUN] Would create directory: ", expandedPath
    else:
      if not dirExists(expandedPath):
        echo "Creating directory: ", expandedPath
        createDir(expandedPath)
      else:
        echo "Directory already exists: ", expandedPath

  # Process symlinks
  for link in config.symlinks:
    if link[0] == "" or link[1] == "":
      continue

    let source = expandEnvVars(link[0], config.expand)
    let dest = expandEnvVars(link[1], config.expand)

    if deployConfig.dryRun:
      echo "[DRY-RUN] Would create symlink: ", source, " -> ", dest
    else:
      let destExists = symlinkExists(dest) or fileExists(dest) or dirExists(dest)

      if destExists and not deployConfig.force:
        echo "Symlink destination already exists: ", dest
      else:
        if destExists and deployConfig.force:
          echo "Removing existing: ", dest
          if symlinkExists(dest):
            removeFile(dest)
          elif fileExists(dest):
            removeFile(dest)
          elif dirExists(dest):
            removeDir(dest)

        echo "Creating symlink: ", source, " -> ", dest
        createSymlink(source, dest)

  # Process file copies
  for copy in config.copies:
    if copy[0] == "" or copy[1] == "":
      continue

    let source = expandEnvVars(copy[0], config.expand)
    let dest = expandEnvVars(copy[1], config.expand)

    if deployConfig.dryRun:
      echo "[DRY-RUN] Would copy file: ", source, " -> ", dest
    else:
      if not fileExists(source):
        echo "Warning: Source file not found: ", source
        continue

      let destExists = fileExists(dest)

      if destExists and not deployConfig.force:
        echo "Destination file already exists: ", dest
      else:
        if destExists and deployConfig.force:
          echo "Overwriting existing file: ", dest
        else:
          echo "Copying file: ", source, " -> ", dest

        copyFileWithPermissions(source, dest)

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
  echo message

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