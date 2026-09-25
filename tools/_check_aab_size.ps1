$a = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\build\app\outputs\bundle\release\app-release.aab'
if (Test-Path $a) {
  $f = Get-Item $a
  Write-Output ("AAB_BYTES=" + $f.Length)
  Write-Output ("AAB_MB=" + [math]::Round($f.Length/1MB, 2))
  Write-Output ("AAB_MTIME=" + $f.LastWriteTime)
} else {
  Write-Output 'AAB_MISSING'
}
