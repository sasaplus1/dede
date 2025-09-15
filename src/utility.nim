import std/os
import std/strutils

proc expandEnvVars*(path: string, envVars: seq[string] = @[]): string =
  ## Expand environment variables in path
  if path == "":
    return ""
  result = path

  # Expand specified environment variables
  for varName in envVars:
    let pattern = "$" & varName
    if contains(result, pattern):
      # Returns "" if not set
      let envValue = getEnv(varName)
      result = replace(result, pattern, envValue)
