include "meta.nim"

# Package

version          = VERSION
author           = "sasaplus1"
description      = "simple dotfiles manager"
license          = "MIT"
srcDir           = "src"
namedBin["main"] = "dede"
binDir           = "bin"


# Dependencies

requires "nim >= 2.2.4"
requires "yaml"

# Tasks

task test, "Run tests":
  # exec "nim c -d:release -o:bin/dede src/main.nim"
  exec "nimble build"
  exec "nim r test/test.nim"
  rmFile("bin/dede")

task release, "Build release binary":
  exec "nimble build -d:release"
