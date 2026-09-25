$ErrorActionPreference = 'Continue'
$root = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2'
$out = Join-Path $root 'tools\_gradle_fail_diag.txt'
$L = New-Object System.Collections.Generic.List[string]

# Find Java used by Flutter
$flutterBat = 'C:\Users\Lenovo\Desktop\flutter\flutter\bin\flutter.bat'
$javaHomeCandidates = @(
  "$env:LOCALAPPDATA\Android\Sdk\jbr",
  "$env:ProgramFiles\Android\Android Studio\jbr",
  "$env:ProgramFiles\Android\Android Studio\jre",
  'C:\Program Files\Android\Android Studio\jbr',
  'C:\Program Files\Java\jdk-17',
  'C:\Program Files\Eclipse Adoptium\jdk-17*'
)
foreach ($c in $javaHomeCandidates) {
  Get-Item $c -EA SilentlyContinue | ForEach-Object {
    [void]$L.Add(("JAVA_CAND`t" + $_.FullName + "`tjava=" + (Test-Path (Join-Path $_.FullName 'bin\java.exe'))))
  }
}

# Newest kotlin errors
Get-ChildItem (Join-Path $root 'android\.kotlin\errors') -Filter '*.log' -EA SilentlyContinue |
  Sort-Object LastWriteTime -Descending | Select-Object -First 3 | ForEach-Object {
    [void]$L.Add(("KOTLIN_ERR`t" + $_.Name + "`t" + $_.LastWriteTime))
    Get-Content $_.FullName -TotalCount 30 | ForEach-Object { [void]$L.Add("K`t$_") }
  }

# Search build for failure markers
$patterns = @('FAILURE:','What went wrong','Execution failed','error:','OutOfMemory','Daemon compilation failed','No file or variants')
Get-ChildItem (Join-Path $root 'build') -Recurse -Include *.txt,*.log -EA SilentlyContinue |
  Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-3) } |
  Sort-Object LastWriteTime -Descending | Select-Object -First 40 | ForEach-Object {
    $hits = Select-String -Path $_.FullName -Pattern ($patterns -join '|') -EA SilentlyContinue | Select-Object -First 3
    if ($hits) {
      [void]$L.Add(("HIT_FILE`t" + $_.FullName))
      foreach ($h in $hits) { [void]$L.Add(("HIT`t" + $h.Line.Trim())) }
    }
  }

$L | Set-Content $out -Encoding UTF8
Write-Output ("WROTE " + $out + " lines=" + $L.Count)
