{{#if (is_executable "go")}}
# Go proxy
$env:GO111MODULE = "on"
$env:GOPROXY = "https://goproxy.cn"
$env:GOPATH = {{env_gopath}}
$env:PATH += ";$env:GOPATH\bin"
{{/if}}

{{#if (is_executable "rustup")}}
# Rustup proxy
$env:RUSTUP_DIST_SERVER = "https://rsproxy.cn"
$env:RUSTUP_UPDATE_ROOT = "https://rsproxy.cn/rustup"
{{/if}}

{{#if (is_executable "vcpkg")}}
# Vcpkg and Cmake
{{#if vcpkg_target}}
# x64-windows \ x64-mingw-dynamic \ x64-mingw-static
$env:VCPKG_TARGET_TRIPLET = {{vcpkg_target}}
$env:VCPKG_DEFAULT_TRIPLET = {{vcpkg_target}}
$env:VCPKG_DEFAULT_HOST_TRIPLET = {{vcpkg_target}}
{{/if}}
$env:VCPKG_ROOT = {{vcpkg_root}}
$env:PATH += ";$env:VCPKG_ROOT"
{{#if (is_executable "cmake")}}
$env:CMAKE_TOOLCHAIN_FILE = "$env:VCPKG_ROOT\scripts\buildsystems\vcpkg.cmake"
{{/if}}
{{/if}}

# Android SDK and NDK
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
if (Test-Path $env:ANDROID_HOME) {
    $LatestNDKVersion = Get-ChildItem -Path "$env:ANDROID_HOME\ndk" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
    if ($LatestNDKVersion -ne $null) {
        $env:NDK_HOME = $LatestNDKVersion.FullName
    }
}

# PATH modifications
$env:PATH += ";$env:USERPROFILE\.local\bin"

function proxy {
    $env:HTTP_PROXY = "127.0.0.1:10808"
    $env:HTTPS_PROXY = "127.0.0.1:10808"
}

function unproxy {
    Remove-Item Env:HTTP_PROXY -ErrorAction SilentlyContinue
    Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue
}

{{#if (is_executable "eza")}}
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
{{/if}}

# Exit
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit

{{#if (is_executable "fzf")}}
# PsFzf
Set-PsFzfOption -PSReadlineChordProvider ctrl+t -PSReadlineChordReverseHistory ctrl+r
{{/if}}