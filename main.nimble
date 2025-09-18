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
  exec "nimble build -d:release"

task test, "Run tests":
  exec "nim c -o:bin/dede_test src/main.nim"
  try:
    exec "nim r test/test.nim"
  finally:
    if fileExists("bin/dede_test"):
      rmFile("bin/dede_test")
