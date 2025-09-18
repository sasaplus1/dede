import std/strutils

var isVerbose* = false

template echoError*(args: varargs[string, `$`]) =
  stderr.write(args.join("") & "\n")
  stderr.flushFile()

template echoVerbose*(args: varargs[string, `$`]) =
  if isVerbose:
    echo args.join("")
