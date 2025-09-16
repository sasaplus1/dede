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
