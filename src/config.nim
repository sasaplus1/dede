import std/os
import std/streams
import yaml

type
  Config* = object
    expand*: seq[string] = @["HOME"]
    directories*: seq[string] = @[]
    symlinks*: seq[array[2, string]] = @[]
    copies*: seq[array[2, string]] = @[]

# TODO: std/optionsをimportしてOption[T]を使う
proc loadConfig*(configFile: string): Config =
  ## Load configuration from YAML file
  if not fileExists(configFile):
    echo "Error: ", configFile, " not found"
    echo "Run 'dede init' first to create configuration file"
    quit(1)

  var s = newFileStream(configFile)
  if s == nil:
    echo "Error: Cannot open ", configFile
    quit(1)

  var config: Config
  try:
    load(s, config)
  except YamlConstructionError:
    echo "Error: Invalid YAML format in ", configFile
    quit(1)
  except YamlParserError:
    echo "Error: Failed to parse ", configFile
    quit(1)
  finally:
    s.close()

  return config