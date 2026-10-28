# install_windows.ps1 - set up this yazi config on Windows
# Shell bindings and openers run their bash scripts through Git Bash (scripts\win\yzsh.cmd).
# usage (PowerShell):  Set-ExecutionPolicy -Scope Process Bypass; .\install_windows.ps1

$ErrorActionPreference = "Stop"

# 0. preflight: managed machines may lock PowerShell down or lack winget
if ($ExecutionContext.SessionState.LanguageMode -ne "FullLanguage") {
    # Constrained Language Mode (AppLocker/WDAC) blocks the .NET calls used below
    Write-Host "PowerShell runs in $($ExecutionContext.SessionState.LanguageMode) mode here, this script needs FullLanguage. Ask your IT or install manually (see README)."
    return
}
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget not found. Install 'App Installer' from the Microsoft Store, then run this script again."
    return
}

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

# 5. let the profile (and so `y`) load: the windows default "Restricted" blocks it
# the first non-Undefined scope below Process is what applies in a new terminal
$policy = Get-ExecutionPolicy -List | Where-Object { $_.Scope -ne "Process" -and $_.ExecutionPolicy -ne "Undefined" } | Select-Object -First 1
if (-not $policy -or $policy.ExecutionPolicy -in @("Restricted", "AllSigned")) {
    try {
        Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
        Write-Host "Execution policy for your user set to RemoteSigned"
    } catch {
        # group policy on managed machines overrides the user scope
        Write-Host "Could not set the execution policy ($($_.Exception.Message)). Your profile may not load."
    }
}

# 6. use the nerd font in Windows Terminal for all profiles, unless a default font is already set
$wtSettings = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$font = "JetBrainsMono Nerd Font"
$fontSet = $false
if (Test-Path $wtSettings) {
    try {
        $wt = Get-Content -Path $wtSettings -Raw | ConvertFrom-Json
        $defaults = $wt.profiles.defaults
        if ($defaults -and -not $defaults.font.face) {
            if (-not $defaults.font) { $defaults | Add-Member -NotePropertyName font -NotePropertyValue ([pscustomobject]@{}) }
            $defaults.font | Add-Member -NotePropertyName face -NotePropertyValue $font -Force
            Copy-Item -Path $wtSettings -Destination "$wtSettings.bak" -Force
            # UTF-8 without BOM, as Windows Terminal writes it
            [IO.File]::WriteAllText($wtSettings, ($wt | ConvertTo-Json -Depth 32), (New-Object Text.UTF8Encoding $false))
            Write-Host "Windows Terminal font set to $font (backup: settings.json.bak)"
        }
        $fontSet = [bool]($defaults -and $defaults.font.face)
    } catch {
        # settings.json with comments does not parse in Windows PowerShell 5.1
        Write-Host "Could not update Windows Terminal settings ($($_.Exception.Message))."
    }
}

Write-Host "`nDone. Open a new terminal (so the PATH and env changes apply), then run: y"
if (-not $fontSet) { Write-Host "Set '$font' as your terminal font." }
