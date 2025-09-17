import std/[unittest, osproc, strutils, strformat]

const exe = "bin/dede"

proc runExecutable(args: string): tuple[output: string, exitCode: int] =
  execCmdEx(fmt"./{exe} {args}")

suite "executable tests":
  test "no arguments exits with 1":
    let (_, code) = runExecutable("")
    check code == 1

  test "--version shows version":
    let (_, code) = runExecutable("--version")
    check code == 0

  test "--help shows usage":
    let (output, code) = runExecutable("--help")
    check code == 0
    check "Usage" in output

  test "invalid command fails":
    let (_, code) = runExecutable("invalid_command")
    check code == 1