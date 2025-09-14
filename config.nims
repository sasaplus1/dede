switch("app", "console")

when defined(release):
  switch("define", "lto")
  switch("define", "strip")
  switch("forceBuild")
  switch("opt", "size")
