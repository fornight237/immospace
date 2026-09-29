# PowerShell cleanup script for Windows
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
$root = Resolve-Path (Join-Path $root "..")
Write-Host "Cleaning build artifacts in $root"

$paths = @(
    "$root\build",
    "$root\app\build",
    "$root\.gradle",
    "$root\app\.gradle"
)

foreach ($p in $paths) {
    if (Test-Path $p) {
        Write-Host "Removing: $p"
        Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Removing any 'build' directories under the tree (may be slow)"
Get-ChildItem -Path $root -Recurse -Directory -Filter build -ErrorAction SilentlyContinue | ForEach-Object {
    try { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
    catch {}
}

Write-Host "Done. You can now open the project in Android Studio and run a clean build."