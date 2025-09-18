import std/[unittest, osproc, strutils, strformat, os]

let exePath = getCurrentDir() / "bin" / "dede_test"

proc runExecutable(args: string): tuple[output: string, exitCode: int] =
  execCmdEx(fmt"{exePath} {args}")

suite "executable tests":
  test "no arguments exits with 1":
    let (output, code) = runExecutable("")
    check code == 1
    check "Usage" in output

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

suite "init command tests":
  test "init creates default config file":
    let tmpDir = getTempDir()
    let origDir = getCurrentDir()
    setCurrentDir(tmpDir)

    let (_, code) = runExecutable("init")
    check code == 0
    check fileExists("dede.yml")

    if fileExists("dede.yml"):
      removeFile("dede.yml")
    setCurrentDir(origDir)

  test "init with -c creates custom config file":
    let tmpDir = getTempDir()
    let origDir = getCurrentDir()
    setCurrentDir(tmpDir)
    let configPath = "custom_config.yml"

    let (_, code) = runExecutable(fmt"init -c {configPath}")
    check code == 0
    check fileExists(configPath)

    if fileExists(configPath):
      removeFile(configPath)
    setCurrentDir(origDir)

  test "init fails if dede.yml exists":
    let tmpDir = getTempDir()
    let origDir = getCurrentDir()
    setCurrentDir(tmpDir)

    writeFile("dede.yml", "test: config")

    let (output, code) = runExecutable("init")
    check code == 1
    check "already exists" in output

    removeFile("dede.yml")
    setCurrentDir(origDir)

  test "init fails if .dede.yml exists":
    let tmpDir = getTempDir()
    let origDir = getCurrentDir()
    setCurrentDir(tmpDir)

    writeFile(".dede.yml", "test: config")

    let (output, code) = runExecutable("init")
    check code == 1
    check "already exists" in output

    removeFile(".dede.yml")
    setCurrentDir(origDir)

suite "deploy command tests":
  test "deploy shows error when no config":
    let (output, code) = runExecutable("deploy")
    check code == 1
    check "not found" in output or "Error" in output

  test "deploy with -c option":
    let tmpDir = getTempDir()
    let configPath = tmpDir / "test_deploy.yml"
    writeFile(configPath, "deploy:\n")

    let (_, code) = runExecutable(fmt"deploy -c {configPath}")
    check code == 1

    removeFile(configPath)

suite "test command tests":
  test "test shows error when no config":
    let (output, code) = runExecutable("test")
    check code == 1
    check "not found" in output or "Error" in output

  test "test with -c option":
    let tmpDir = getTempDir()
    let configPath = tmpDir / "test_config.yml"
    writeFile(configPath, "expand:\n  - HOME\ndirectories: []\nsymlinks: []\ncopies: []\n")

    let (output, code) = runExecutable(fmt"test -c {configPath}")
    check code == 0
    check "Test completed" in output

    removeFile(configPath)

suite "config file priority tests":
  test "dede.yml has priority over .dede.yml":
    let tmpDir = getTempDir()
    let origDir = getCurrentDir()
    setCurrentDir(tmpDir)

    let testDir1 = tmpDir / "dede_test"
    let testDir2 = tmpDir / "dede_test2"

    # dede.yml with a specific directory
    let dedeYmlContent = dedent(fmt"""
      expand:
        - HOME
      directories:
        - "{testDir1}"
      symlinks: []
      copies: []
      """)
    writeFile("dede.yml", dedeYmlContent)

    # .dede.yml with a different directory
    let dotDedeYmlContent = dedent(fmt"""
      expand:
        - HOME
      directories:
        - "{testDir2}"
      symlinks: []
      copies: []
      """)
    writeFile(".dede.yml", dotDedeYmlContent)

    let (output, code) = runExecutable("test -v")
    check code == 0
    check testDir1 in output # Should use dede.yml, not .dede.yml

    removeFile("dede.yml")
    removeFile(".dede.yml")
    setCurrentDir(origDir)

  test ".dede.yml is used when dede.yml doesn't exist":
    let tmpDir = getTempDir()
    let origDir = getCurrentDir()
    setCurrentDir(tmpDir)

    let testDir2 = tmpDir / "dede_test2"

    let configContent = dedent(fmt"""
      expand:
        - HOME
      directories:
        - "{testDir2}"
      symlinks: []
      copies: []
      """)
    writeFile(".dede.yml", configContent)

    let (output, code) = runExecutable("test -v")
    check code == 0
    check testDir2 in output

    removeFile(".dede.yml")
    setCurrentDir(origDir)
