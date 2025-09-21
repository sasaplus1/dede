import std/os
import std/parseopt
import std/strutils
import config
import log
import env

proc checkDirectories(directories: seq[string], envVars: seq[string]): int =
  ## Check if directories exist
  result = 0
  for dir in directories:
    let path = expandEnvVars(dir, envVars)
    if path == "":
      continue
    if dirExists(path):
      echoVerbose "✓ Directory exists: ", path
    else:
      echoVerbose "✗ Directory missing: ", path
      inc(result)

proc checkSymlinks(symlinks: seq[array[2, string]], envVars: seq[string]): int =
  ## Check if symlinks are correctly set
  result = 0
  for link in symlinks:
    if link[0] == "" or link[1] == "":
      continue
    let source = expandEnvVars(link[0], envVars)
    let target = expandEnvVars(link[1], envVars)

    if symlinkExists(target):
      let actual = expandSymlink(target)
      if actual == source:
        echoVerbose "✓ Symlink correct: ", target, " -> ", source
      else:
        echoVerbose "✗ Symlink incorrect: ", target, " -> ", actual,
            " (expected ", source, ")"
        inc(result)
    else:
      echoVerbose "✗ Symlink missing: ", target
      inc(result)

proc checkCopies(copies: seq[array[2, string]], envVars: seq[string]): int =
  ## Check if copied files match
  result = 0
  for copy in copies:
    if copy[0] == "" or copy[1] == "":
      continue
    let source = expandEnvVars(copy[0], envVars)
    let target = expandEnvVars(copy[1], envVars)

    if fileExists(target):
      if fileExists(source):
        let sourceContent = readFile(source)
        let targetContent = readFile(target)
        if sourceContent == targetContent:
          echoVerbose "✓ File matches: ", target
        else:
          echoVerbose "✗ File differs: ", target
          inc(result)
      else:
        echoVerbose "✗ Source file missing: ", source
        inc(result)
    else:
      echoVerbose "✗ Target file missing: ", target
      inc(result)

proc test(configFile: string = "dede.yml", envVars: seq[string] = @[]) =
  ## Test deployed dotfiles

  var config = loadConfig(configFile)

  # Combine environment variables from config and command line
  let expandedVars = mergeEnvVars(config.expand, envVars)

  echoVerbose "Testing deployment configuration..."
  if expandedVars.len > 0:
    echoVerbose "Expanding variables: ", $expandedVars
  echoVerbose ""

  var totalErrors = 0

  # Check directories
  if config.directories.len > 0:
    echoVerbose "Checking directories..."
    let errors = checkDirectories(config.directories, expandedVars)
    totalErrors += errors
    echoVerbose ""

  # Check symlinks
  if config.symlinks.len > 0:
    echoVerbose "Checking symlinks..."
    let errors = checkSymlinks(config.symlinks, expandedVars)
    totalErrors += errors
    echoVerbose ""

  # Check copies
  if config.copies.len > 0:
    echoVerbose "Checking copied files..."
    let errors = checkCopies(config.copies, expandedVars)
    totalErrors += errors
    echoVerbose ""

  if totalErrors == 0:
    echoVerbose "Test completed successfully"
  else:
    echoVerbose "Test completed with ", totalErrors, " error(s)"
    quit(1)

proc showTestHelp() =
  const message = staticRead("command_test_help.txt")
  echo strip(message)

proc commandTest*(args: seq[string]) =
  ## Test command implementation

  var parser = initOptParser(args, shortNoVal = {'v'}, longNoVal = @["help", "verbose"])
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
      of "help":
        showTestHelp()
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
        echoError "test: Unknown option: --", parser.key
        showTestHelp()
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

  ## Execute test
  test(configFile, envVars)
