import std/os
import std/parseopt
import std/strutils
import config
import utility

proc checkDirectories(directories: seq[string], envVars: seq[string]) =
  ## Check if directories exist
  for dir in directories:
    let path = expandEnvVars(dir, envVars)
    if path == "":
      continue
    if dirExists(path):
      echo "✓ Directory exists: ", path
    else:
      echo "✗ Directory missing: ", path

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
        echo "✓ Symlink correct: ", target, " -> ", source
      else:
        echo "✗ Symlink incorrect: ", target, " -> ", actual, " (expected ", source, ")"
    else:
      echo "✗ Symlink missing: ", target

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
          echo "✓ File matches: ", target
        else:
          echo "✗ File differs: ", target
      else:
        echo "✗ Source file missing: ", source
    else:
      echo "✗ Target file missing: ", target

proc test(additionalEnvVars: seq[string] = @[]) =
  ## Test deployed dotfiles
  const configFile = "dede.yml"

  var config = loadConfig(configFile)

  # Combine environment variables from config and command line
  # Always include HOME by default
  var envVars = @["HOME"]
  for v in config.expand:
    if v notin envVars:
      envVars.add(v)
  for v in additionalEnvVars:
    if v notin envVars:
      envVars.add(v)

  echo "Testing deployment configuration..."
  if envVars.len > 0:
    echo "Expanding variables: ", envVars
  echo ""

  # Check directories
  if config.directories.len > 0:
    echo "Checking directories..."
    checkDirectories(config.directories, envVars)
    echo ""

  # Check symlinks
  if config.symlinks.len > 0:
    echo "Checking symlinks..."
    checkSymlinks(config.symlinks, envVars)
    echo ""

  # Check copies
  if config.copies.len > 0:
    echo "Checking copied files..."
    checkCopies(config.copies, envVars)
    echo ""

  echo "Test completed"

proc showTestHelp() =
  const message = """
    dede test - Test deployed dotfiles

    Usage:
      dede test [OPTIONS]

    Options:
      -e, --expand VAR  Expand additional environment variable
      -h, --help        Show this help message
  """.dedent().strip()
  echo message

proc commandTest*(args: seq[string]) =
  ## Test command implementation

  var parser = initOptParser(args, shortNoVal = {'h'}, longNoVal = @["help"])
  var additionalEnvVars: seq[string] = @[]
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
      of "e", "expand":
        if parser.val != "":
          additionalEnvVars.add(parser.val)
        else:
          echo "Error: -e/--expand requires a value (use -e VAR or --expand=VAR)"
          quit(1)
      else:
        echo "test: Unknown option: --", parser.key
        showTestHelp()
        quit(1)
    of cmdArgument:
      remainingArgs.add(parser.key)

  ## Execute test
  test(additionalEnvVars)