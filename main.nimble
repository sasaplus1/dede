# Package

include "meta.nim"

version = VERSION
author = "sasaplus1"
description = "Simple dotfiles deployment tool"
license = "MIT"
srcDir = "src"
namedBin["main"] = "dede"
binDir = "bin"


# Dependencies

requires "nim >= 2.2.4"
requires "yaml"


# Tasks

import os
import strformat

task build, "Build binary":
  exec "nim c -o:bin/dede src/main.nim"

task clean, "Clean build artifacts":
  if dirExists("bin"):
    rmDir("bin", true)
  if dirExists("release"):
    rmDir("release", true)
  if dirExists("nimcache"):
    rmDir("nimcache", true)

task format, "Format source code":
  for file in walkDirRec("."):
    if ($DirSep & "nimbledeps" & $DirSep) in file:
      continue
    if file.endsWith(".nim") or file.endsWith(".nimble"):
      exec "nimpretty " & file

task lint, "Run style checks":
  for file in walkDirRec("."):
    if ($DirSep & "nimbledeps" & $DirSep) in file:
      continue
    if file.endsWith(".nim"):
      exec "nim check --styleCheck:error " & file

task release, "Build release binary":
  const nimFlags = "--forceBuild --opt:size -d:release -d:lto -d:strip"
  # when defined(windows):
  #   echo "Release build on Windows is not supported."
  when defined(macosx):
    # x86_64
    exec fmt"nim c -o:release/dede-macos-x86_64/dede --cpu:amd64 --passC:'-target x86_64-apple-macos11' --passL:'-target x86_64-apple-macos11' {nimFlags} src/main.nim"
    cpFile("README.md", "release/dede-macos-x86_64/README.md")
    cpFile("LICENSE", "release/dede-macos-x86_64/LICENSE")
    # aarch64
    exec fmt"nim c -o:release/dede-macos-aarch64/dede --cpu:arm64 --passC:'-target arm64-apple-macos11' --passL:'-target arm64-apple-macos11' {nimFlags} src/main.nim"
    cpFile("README.md", "release/dede-macos-aarch64/README.md")
    cpFile("LICENSE", "release/dede-macos-aarch64/LICENSE")
    # universal
    mkDir("release/dede-macos-universal")
    exec "lipo -create -output release/dede-macos-universal/dede release/dede-macos-x86_64/dede release/dede-macos-aarch64/dede"
    cpFile("README.md", "release/dede-macos-universal/README.md")
    cpFile("LICENSE", "release/dede-macos-universal/LICENSE")
  elif defined(linux):
    const compilerOptions = "--cc:clang --clang.exe:zigcc --clang.linkerexe:zigcc"
    # x86_64-windows
    exec fmt"nim c -o:release/dede-windows-x86_64/dede.exe -d:mingw --cpu:amd64 {compilerOptions} --passC:'-target x86_64-windows-gnu' --passL:'-target x86_64-windows-gnu -static' {nimFlags} src/main.nim"
    cpFile("README.md", "release/dede-windows-x86_64/README.md")
    cpFile("LICENSE", "release/dede-windows-x86_64/LICENSE")
    # x86_64-gnu
    exec fmt"nim c -o:release/dede-linux-x86_64-gnu/dede --cpu:amd64 {compilerOptions} --passC:'-target x86_64-linux-gnu' --passL:'-target x86_64-linux-gnu' {nimFlags} src/main.nim"
    cpFile("README.md", "release/dede-linux-x86_64-gnu/README.md")
    cpFile("LICENSE", "release/dede-linux-x86_64-gnu/LICENSE")
    # x86_64-musl
    exec fmt"nim c -o:release/dede-linux-x86_64-musl/dede --cpu:amd64 {compilerOptions} --passC:'-target x86_64-linux-musl' --passL:'-target x86_64-linux-musl -static' {nimFlags} src/main.nim"
    cpFile("README.md", "release/dede-linux-x86_64-musl/README.md")
    cpFile("LICENSE", "release/dede-linux-x86_64-musl/LICENSE")
    # aarch64-gnu
    exec fmt"nim c -o:release/dede-linux-aarch64-gnu/dede --cpu:arm64 {compilerOptions} --passC:'-target aarch64-linux-gnu' --passL:'-target aarch64-linux-gnu' {nimFlags} src/main.nim"
    cpFile("README.md", "release/dede-linux-aarch64-gnu/README.md")
    cpFile("LICENSE", "release/dede-linux-aarch64-gnu/LICENSE")
    # aarch64-musl
    exec fmt"nim c -o:release/dede-linux-aarch64-musl/dede --cpu:arm64 {compilerOptions} --passC:'-target aarch64-linux-musl' --passL:'-target aarch64-linux-musl -static' {nimFlags} src/main.nim"
    cpFile("README.md", "release/dede-linux-aarch64-musl/README.md")
    cpFile("LICENSE", "release/dede-linux-aarch64-musl/LICENSE")
  else:
    echo "Unsupported OS for release build."
    quit(1)

task test, "Run tests":
  exec "nim c -o:bin/dede_test src/main.nim"
  try:
    exec "nim r test/test.nim"
  finally:
    if fileExists("bin/dede_test"):
      rmFile("bin/dede_test")
