import std/os
import std/parseopt
import std/strutils
import config
import log
import utility

type
  DeployConfig* = object
    dryRun*: bool = false
    force*: bool = false
    envVars*: seq[string] = @[]

proc deploy(deployConfig: DeployConfig, configFile: string = "dede.yml") =
  ## Execute deployment

  if deployConfig.dryRun and deployConfig.force:
    echoError "Error: --dry-run and --force options are both set."
    quit(1)

  # Load configuration
  let config = loadConfig(configFile)

  # Merge environment variables from config and command line
  let expandedVars = mergeEnvVars(config.expand, deployConfig.envVars)

  # Process directories
  for dir in config.directories:
    let expandedPath = expandEnvVars(dir, expandedVars)

    if deployConfig.dryRun:
      echoVerbose "[DRY-RUN] Would create directory: ", expandedPath
    else:
      if not dirExists(expandedPath):
        echoVerbose "Creating directory: ", expandedPath
        createDir(expandedPath)
      else:
        echoVerbose "Directory already exists: ", expandedPath

  # Process symlinks
  for link in config.symlinks:
    if link[0] == "" or link[1] == "":
      continue

    let source = expandEnvVars(link[0], expandedVars)
    let dest = expandEnvVars(link[1], expandedVars)

    if deployConfig.dryRun:
      echoVerbose "[DRY-RUN] Would create symlink: ", source, " -> ", dest
    else:
      let destExists = symlinkExists(dest) or fileExists(dest) or dirExists(dest)

      if destExists and not deployConfig.force:
        echoVerbose "Symlink destination already exists: ", dest
      else:
        if destExists and deployConfig.force:
          echoVerbose "Removing existing: ", dest
          if symlinkExists(dest):
            removeFile(dest)
          elif fileExists(dest):
            removeFile(dest)
          elif dirExists(dest):
            removeDir(dest)

        echoVerbose "Creating symlink: ", source, " -> ", dest
        createSymlink(source, dest)

  # Process file copies
  for copy in config.copies:
    if copy[0] == "" or copy[1] == "":
      continue

    let source = expandEnvVars(copy[0], expandedVars)
    let dest = expandEnvVars(copy[1], expandedVars)

    if deployConfig.dryRun:
      echoVerbose "[DRY-RUN] Would copy file: ", source, " -> ", dest
    else:
      if not fileExists(source):
        echoError "Warning: Source file not found: ", source
        continue

      let destExists = fileExists(dest)

      if destExists and not deployConfig.force:
        echoVerbose "Destination file already exists: ", dest
      else:
        if destExists and deployConfig.force:
          echoVerbose "Overwriting existing file: ", dest
        else:
          echoVerbose "Copying file: ", source, " -> ", dest

        copyFileWithPermissions(source, dest)

proc showDeployHelp() =
  ## Show help message for deploy command
  const message = staticRead("command_deploy_help.txt")
  echo strip(message)

proc commandDeploy*(args: seq[string]) =
  ## Deploy command implementation

  var parser = initOptParser(args, shortNoVal = {'v'}, longNoVal = @["help",
      "verbose", "dry-run", "force"])
  var dryRun = false
  var force = false
  var envVars: seq[string] = @[]
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
      of "dry-run":
        dryRun = true
      of "force":
        force = true
      of "help":
        showDeployHelp()
        quit(0)
      of "e", "expand":
        if parser.val != "":
          envVars.add(parser.val)
        else:
          echoError "Error: -e/--expand requires a value (use -e VAR or --expand=VAR)"
          quit(1)
      of "c", "config":
        if parser.val != "":
          configFile = parser.val
        else:
          expectConfigFile = true
      of "verbose", "v":
        log.isVerbose = true
      else:
        echoError "deploy: Unknown option: --", parser.key
        showDeployHelp()
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

  ## If no config file specified, look for default configs
  if configFile == "dede.yml":
    let foundConfig = findDefaultConfigFile()
    if foundConfig != "":
      configFile = foundConfig

  ## Execute deploy
  let deployConfig = DeployConfig(dryRun: dryRun, force: force,
      envVars: envVars)
  deploy(deployConfig, configFile)
