import std/os
import std/streams
import yaml
import log

type
  Config* = object
    expand*: seq[string] = @[]
    directories*: seq[string] = @[]
    symlinks*: seq[array[2, string]] = @[]
    copies*: seq[array[2, string]] = @[]

# TODO: std/optionsをimportしてOption[T]を使う
proc loadConfig*(configFile: string): Config =
  ## Load configuration from YAML file
  if not fileExists(configFile):
    echoError "Error: ", configFile, " not found"
    echoError "Run 'dede init' first to create configuration file"
    quit(1)

  var s = newFileStream(configFile)
  if s == nil:
    echoError "Error: Cannot open ", configFile
    quit(1)

  var config: Config
  try:
    load(s, config)
  except YamlConstructionError:
    echoError "Error: Invalid YAML format in ", configFile
    quit(1)
  except YamlParserError:
    echoError "Error: Failed to parse ", configFile
    quit(1)
  finally:
    s.close()

  return config