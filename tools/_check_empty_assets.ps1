$ErrorActionPreference = 'Continue'
$root = 'C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2'
Set-Location $root
$out = 'tools\_empty_declared_assets.txt'
$L = New-Object System.Collections.Generic.List[string]
$declared = @(
  'assets/images/logo.svg','assets/images/logo_mark.svg','assets/images/splash.svg',
  'assets/images/mascote','assets/images/home','assets/images/treinos','assets/images/corrida',
  'assets/images/hidratacao','assets/images/receitas','assets/images/recipes','assets/images/recipes/neon',
  'assets/images/alimentacao','assets/images/progresso','assets/images/rotina','assets/images/bem_estar',
  'assets/images/lily_fit','assets/images/referencias','assets/mascot/png','assets/mascot/extras',
  'assets/icons','assets/icons/personal-ai','assets/icons/app','assets/icons/app/extras_hidratacao',
  'assets/icons/navigation','assets/icons/health','assets/icons/hydration','assets/icons/actions',
  'assets/icons/mood','assets/icons/achievements','assets/icons/premium',
  'assets/icons/neon/corrida/icone_neon_de_corrida_e_saude_cardiaca.jpg','assets/icons/neon/treinos',
  'assets/content','assets/animations','assets/rive','assets/avatars','assets/stickers','assets/badges',
  'assets/backgrounds','assets/illustrations/banners','assets/onboarding','assets/loading','assets/empty',
  'assets/success','assets/error','assets/premium','assets/exercises','assets/recipes','assets/habits',
  'assets/challenges','assets/lily','assets/lily_treinos','assets/lily_exercicios',
  'assets/amanda/promo','assets/amanda/optimized','assets/amanda/thumbs','assets/app_icon'
)
foreach ($d in $declared) {
  $p = Join-Path $root ($d -replace '/','\')
  if (-not (Test-Path $p)) {
    [void]$L.Add("MISSING`t$d")
    continue
  }
  $item = Get-Item $p
  if ($item.PSIsContainer) {
    $files = @(Get-ChildItem $p -Recurse -File -EA SilentlyContinue)
    if ($files.Count -eq 0) { [void]$L.Add("EMPTY_DIR`t$d") }
    else { [void]$L.Add("OK_DIR`t$d`t$($files.Count)") }
  } else {
    [void]$L.Add("OK_FILE`t$d`t$($item.Length)")
  }
}
# cadeiras
foreach ($c in @('lily_fit_cadeira_abdutora.jpeg','lily_fit_cadeira_extensora.jpeg')) {
  [void]$L.Add("CADEIRA`t$c`t$(Test-Path (Join-Path $root \"assets\\lily_exercicios\\$c\"))")
}
$L | Set-Content $out -Encoding UTF8
Write-Output ("WROTE $out")
$L | Where-Object { $_ -match 'EMPTY|MISSING' } | ForEach-Object { Write-Output $_ }
