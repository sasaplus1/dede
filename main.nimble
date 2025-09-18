import os
include "meta.nim"

# Package

version = VERSION
author = "sasaplus1"
description = "simple dotfiles manager"
license = "MIT"
srcDir = "src"
namedBin["main"] = "dede"
binDir = "bin"


# Dependencies

requires "nim >= 2.2.4"
requires "yaml"

# Tasks

task build, "Build binary":
  exec "nim c -o:bin/dede src/main.nim"

task clean, "Clean build artifacts":
  if dirExists("bin"):
    rmDir("bin", true)
  if dirExists("nimcache"):
    rmDir("nimcache", true)

task format, "Format source code":
  for file in walkDirRec("."):
    if file.endsWith(".nim") or file.endsWith(".nimble"):
      exec "nimpretty " & file

task lint, "Run style checks":
  for file in walkDirRec("."):
    if file.endsWith(".nim"):
      exec "nim check --styleCheck:error " & file

task release, "Build release binary":
  when defined(windows):
    exec "nim c -o:bin/dede.exe --opt:size -d:release -d:lto -d:strip -d:mingw src/main.nim"
  else:
    exec "nim c -o:bin/dede --opt:size -d:release -d:lto -d:strip src/main.nim"

task test, "Run tests":
  exec "nim c -o:bin/dede_test src/main.nim"
  try:
    exec "nim r test/test.nim"
  finally:
    if fileExists("bin/dede_test"):
      rmFile("bin/dede_test")
