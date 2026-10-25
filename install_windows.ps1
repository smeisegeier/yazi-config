# install_windows.ps1 - set up this yazi config on Windows
# Shell bindings and openers run their bash scripts through Git Bash (scripts\win\yzsh.cmd).
# usage (PowerShell):  Set-ExecutionPolicy -Scope Process Bypass; .\install_windows.ps1

$ErrorActionPreference = "Stop"

# 1. dependencies (vscode is assumed to be installed already)
$packages = @(
    "sxyazi.yazi", "Git.Git", "7zip.7zip", "jqlang.jq", "sharkdp.fd", "BurntSushi.ripgrep.MSVC",
    "junegunn.fzf", "ajeetdsouza.zoxide", "ImageMagick.ImageMagick", "Gyan.FFmpeg",
    "oschwartz10612.Poppler", "charmbracelet.glow", "sharkdp.bat", "DuckDB.cli", "Nushell.Nushell",
    "Dystroy.broot", "MediaArea.MediaInfo", "OliverBetz.ExifTool", "astral-sh.uv",
    "DEVCOM.JetBrainsMonoNerdFont"
)
foreach ($p in $packages) {
    winget install --id $p --exact --silent --accept-source-agreements --accept-package-agreements
}

# pick up the PATH changes of the installs above in this session
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

# 2. clone the config to the same place as on unix
$cfg = Join-Path $env:USERPROFILE ".config\yazi"
if (-not (Test-Path $cfg)) {
    git clone https://github.com/smeisegeier/yazi-config $cfg
}

# 3. environment for yazi and the scripts
$gitRoot = Join-Path $env:ProgramFiles "Git"
if (-not (Test-Path $gitRoot)) { $gitRoot = Join-Path $env:LOCALAPPDATA "Programs\Git" }
$gitUsrBin = Join-Path $gitRoot "usr\bin"

[Environment]::SetEnvironmentVariable("YAZI_CONFIG_HOME", $cfg, "User")
# yazi needs `file` for mime detection; Git for Windows ships one
[Environment]::SetEnvironmentVariable("YAZI_FILE_ONE", (Join-Path $gitUsrBin "file.exe"), "User")

# Git's usr\bin gives `sh` (piper previewer), `file`, `xargs`, `diff`, ...; scripts\win gives `yzsh`
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$parts = @($userPath -split ";" | Where-Object { $_ })
foreach ($dir in @($gitUsrBin, (Join-Path $cfg "scripts\win"))) {
    if ($parts -notcontains $dir) { $parts += $dir }
}
[Environment]::SetEnvironmentVariable("Path", ($parts -join ";"), "User")

# 4. `y` wrapper that changes the shell's cwd when yazi exits (same as in ~/.zshrc on unix)
$wrapper = @'
function y {
    $tmp = (New-TemporaryFile).FullName
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
    }
    Remove-Item -Path $tmp
}
'@
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
if (-not (Select-String -Path $PROFILE -Pattern "function y " -Quiet)) {
    Add-Content -Path $PROFILE -Value "`n$wrapper"
    Write-Host "y() wrapper added to $PROFILE"
}

Write-Host "`nDone. Open a new terminal (so the PATH and env changes apply), set a Nerd Font, then run: y"
