$ErrorActionPreference = 'Continue'
$p1 = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\assets\lily_exercicios\lily_fit_cadeira_abdutora.jpeg'
$p2 = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\assets\lily_exercicios\lily_fit_cadeira_extensora.jpeg'
$out = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\tools\_cadeira_verify.txt'
@(
  ("abdutora=" + (Test-Path -LiteralPath $p1)),
  ("extensora=" + (Test-Path -LiteralPath $p2)),
  ("count_lily_ex=" + (@(Get-ChildItem 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\assets\lily_exercicios' -File).Count))
) | Set-Content $out -Encoding UTF8
Get-Content $out
# Find latest gradle failure
$gradleLogs = Get-ChildItem 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\android' -Recurse -Filter '*.log' -EA SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 5
$gradleLogs | ForEach-Object { $_.FullName }
$buildFail = Get-ChildItem 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\build' -Recurse -Filter '*outputs*' -Directory -EA SilentlyContinue | Select-Object -First 5
# Try flutter assemble error from .dart_tool
if (Test-Path 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\build\app\outputs\flutter-apk') { 'has_apk_dir' }
