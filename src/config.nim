import std/os
import std/streams
import std/tables
import yaml
import yaml/dom
import log

type
  Config* = object
    expand*: seq[string] = @[]
    directories*: seq[string] = @[]
    symlinks*: seq[array[2, string]] = @[]
    copies*: seq[array[2, string]] = @[]

proc parseStringSeq(node: YamlNode): seq[string] =
  ## Parse YAML sequence into seq[string]
  result = @[]
  if node.kind == ySequence:
    for item in node.elems:
      if item.kind == yScalar:
        result.add(item.content)

proc parseStringPairs(node: YamlNode): seq[array[2, string]] =
  ## Parse YAML sequence of pairs into seq[array[2, string]]
  result = @[]
  if node.kind == ySequence:
    for item in node.elems:
      if item.kind == ySequence and item.elems.len == 2:
        if item.elems[0].kind == yScalar and item.elems[1].kind == yScalar:
          var pair: array[2, string]
          pair[0] = item.elems[0].content
          pair[1] = item.elems[1].content
          result.add(pair)

proc findDefaultConfigFile*(): string =
  ## Find the default configuration file
  ## Returns the first existing file: dede.yml, .dede.yml
  ## Returns empty string if none exist
  if fileExists("dede.yml"):
    return "dede.yml"
  elif fileExists(".dede.yml"):
    return ".dede.yml"
  else:
    return ""

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

  # Initialize with default values
  result = Config()

  try:
    # Load the YAML file as YamlNode
    var yamlDoc: YamlNode
    load(s, yamlDoc)
    s.close()

    # Check if document is a mapping
    if yamlDoc.kind != yMapping:
      echoError "Error: YAML document must be a mapping"
      quit(1)

    # Parse each field if it exists
    for key, value in yamlDoc.fields:
      if key.kind != yScalar:
        continue

      case key.content
      of "expand":
        result.expand = parseStringSeq(value)
      of "directories":
        result.directories = parseStringSeq(value)
      of "symlinks":
        result.symlinks = parseStringPairs(value)
      of "copies":
        result.copies = parseStringPairs(value)

      else:
        # Ignore unknown fields
        discard

  except YamlConstructionError:
    echoError "Error: Invalid YAML format in ", configFile
    quit(1)
  except YamlParserError:
    echoError "Error: Failed to parse ", configFile
    quit(1)
  except:
    echoError "Error: Failed to load configuration from ", configFile
    quit(1)
