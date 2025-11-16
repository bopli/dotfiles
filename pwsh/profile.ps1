$env:PATH += ";$env:USERPROFILE\.local\bin"

$env:PAGER = "bat"

# Go proxy
$env:GO111MODULE = "on"
$env:GOPROXY = "https://goproxy.cn"

# Rustup proxy
$env:RUSTUP_DIST_SERVER = "https://rsproxy.cn"
$env:RUSTUP_UPDATE_ROOT = "https://rsproxy.cn/rustup"

# PostgreSQL
$env:PGDATA = "$env:USERPROFILE\.local\opt\pgsql\data"
$env:PATH += ";$env:USERPROFILE\.local\opt\pgsql\bin"

# Vcpkg
$env:VCPKG_ROOT = "$env:USERPROFILE\.local\opt\vcpkg"
$env:PATH += ";$env:VCPKG_ROOT"

# Cmake
$env:CMAKE_TOOLCHAIN_FILE = "$env:VCPKG_ROOT\scripts\buildsystems\vcpkg.cmake"

# Android SDK and NDK
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
if (Test-Path $env:ANDROID_HOME) {
    $LatestNDKVersion = Get-ChildItem -Path "$env:ANDROID_HOME\ndk" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
    if ($LatestNDKVersion -ne $null) {
        $env:NDK_HOME = $LatestNDKVersion.FullName
    }
}

function proxy {
    $env:HTTP_PROXY = "http://127.0.0.1:10808"
    $env:HTTPS_PROXY = "http://127.0.0.1:10808"
}

function unproxy {
    Remove-Item Env:HTTP_PROXY -ErrorAction SilentlyContinue
    Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue
}

# eza
function Invoke-Eza {
    param (
      [Parameter(ValueFromRemainingArguments = $true)]
      [string[]]$Args
    )
    eza @Args
}
Set-Alias ls Invoke-Eza

function Invoke-Eza_All {
    param (
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )
    eza -a @Args
}
Set-Alias la Invoke-Eza_All

function Invoke-Eza_List {
    param (
      [Parameter(ValueFromRemainingArguments = $true)]
      [string[]]$Args
    )
    eza -l --git --icons=always @Args
}
Set-Alias ll Invoke-Eza_List


# Exit
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit

# PsFzf
Set-PsFzfOption -PSReadlineChordProvider ctrl+t -PSReadlineChordReverseHistory ctrl+r

# Starship
Invoke-Expression (&starship init powershell)
