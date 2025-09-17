import std/os
import std/parseopt
import std/strutils
import config
import log
import utility

proc checkDirectories(directories: seq[string], envVars: seq[string]) =
  ## Check if directories exist
  for dir in directories:
    let path = expandEnvVars(dir, envVars)
    if path == "":
      continue
    if dirExists(path):
      echoVerbose "✓ Directory exists: ", path
    else:
      echoVerbose "✗ Directory missing: ", path

proc checkSymlinks(symlinks: seq[array[2, string]], envVars: seq[string]) =
  ## Check if symlinks are correctly set
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
        echoVerbose "✗ Symlink incorrect: ", target, " -> ", actual, " (expected ", source, ")"
    else:
      echoVerbose "✗ Symlink missing: ", target

proc checkCopies(copies: seq[array[2, string]], envVars: seq[string]) =
  ## Check if copied files match
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
      else:
        echoVerbose "✗ Source file missing: ", source
    else:
      echoVerbose "✗ Target file missing: ", target

proc test(envVars: seq[string] = @[]) =
  ## Test deployed dotfiles
  const configFile = "dede.yml"

  var config = loadConfig(configFile)

  # Combine environment variables from config and command line
  let expandedVars = mergeEnvVars(config.expand, envVars)

  echoVerbose "Testing deployment configuration..."
  if expandedVars.len > 0:
    echoVerbose "Expanding variables: ", $expandedVars
  echoVerbose ""

  # Check directories
  if config.directories.len > 0:
    echoVerbose "Checking directories..."
    checkDirectories(config.directories, expandedVars)
    echoVerbose ""

  # Check symlinks
  if config.symlinks.len > 0:
    echoVerbose "Checking symlinks..."
    checkSymlinks(config.symlinks, expandedVars)
    echoVerbose ""

  # Check copies
  if config.copies.len > 0:
    echoVerbose "Checking copied files..."
    checkCopies(config.copies, expandedVars)
    echoVerbose ""

  echo "Test completed"

proc showTestHelp() =
  const message = staticRead("command_test_help.txt")
  echo strip(message)

proc commandTest*(args: seq[string]) =
  ## Test command implementation

  var parser = initOptParser(args, shortNoVal = {'h'}, longNoVal = @["help"])
  var envVars: seq[string] = @[]
  var remainingArgs: seq[string] = @[]

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
      of "verbose", "v":
        isVerbose = true
      else:
        echoError "test: Unknown option: --", parser.key
        showTestHelp()
        quit(1)
    of cmdArgument:
      remainingArgs.add(parser.key)

  ## Execute test
  test(envVars)