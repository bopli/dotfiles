# Windows 应用安装状态检查工具
# 用于检测列表中应用的安装情况
# 作者: bopli

# 应用列表
$applications = @(
    "9MTXQQCC8FSS # 22与33的环球旅行",
    "aria2.aria2",
    "astral-sh.ruff",
    "astral-sh.ty",
    "astral-sh.uv",
    "Bin-Huang.Chatbox",
    "bootandy.dust",
    "BurntSushi.ripgrep.MSVC",
    "ducaale.xh",
    "eza-community.eza",
    "Genymobile.scrcpy",
    "Git.Git",
    "GitHub.cli",
    "Google.AndroidStudio",
    "Google.Chrome",
    "Google.PlatformTools",
    "Helix.Helix",
    "junegunn.fzf",
    "LocalSend.LocalSend",
    "lyswhut.lx-music-desktop",
    "Microsoft.DotNet.DesktopRuntime.8",
    "Microsoft.OpenJDK.21",
    "Microsoft.PowerShell",
    "Microsoft.VCRedist.2015+.x64",
    "Microsoft.VisualStudio.BuildTools",
    "Microsoft.VisualStudioCode",
    "Microsoft.WindowsTerminal",
    "Mozilla.sccache",
    "Mozilla.Thunderbird.zh-CN",
    "OpenJS.NodeJS.LTS",
    "pnpm.pnpm",
    "Python.Python.3.10",
    "Python.Python.3.11",
    "QL-Win.QuickLook",
    "Rustlang.Rustup",
    "sharkdp.bat",
    "sharkdp.fd",
    "sharkdp.hexyl",
    "Starship.Starship",
    "SublimeHQ.SublimeText.4",
    "SuperCuber.Dotter",
    "Telegram.Unigram",
    "Valve.Steam",
    "voidtools.Everything",
    "Wilfred.difftastic",
    "ZedIndustries.Zed",
    "zhongyang219.TrafficMonitor.Lite"
)

# 获取应用ID和描述
function Get-AppInfo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppLine
    )

    if ($AppLine -match '#') {
        $parts = $AppLine -split '#', 2
        $appId = $parts[0].Trim()
        $description = $parts[1].Trim()
        return @{
            Id = $appId
            Description = $description
        }
    }

    return @{
        Id = $AppLine.Trim()
        Description = ""
    }
}

# 检查应用是否已安装
function Test-AppInstalled {
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppId
    )

    # 特殊处理 VCRedist 包
    if ($AppId -match "Microsoft\.VCRedist") {
        try {
            # 使用更宽松的匹配方式
            $result = winget list --name "Microsoft Visual C++" 2>&1
            $output = $result -join "`n"

            if ($AppId -match "2015\+\.x64") {
                # 检查是否安装了 2015-2022 x64 版本
                if ($output -match "Visual C\+\+.+(2015|2017|2019|2022).+x64") {
                    return $true
                }
            } elseif ($AppId -match "2015\+\.x86") {
                # 检查是否安装了 2015-2022 x86 版本
                if ($output -match "Visual C\+\+.+(2015|2017|2019|2022).+x86") {
                    return $true
                }
            } elseif ($output -match $AppId.Replace(".", "\.")) {
                # 其他版本进行精确匹配
                return $true
            }
            return $false
        } catch {
            return $false
        }
    }

    # 其他应用程序的正常处理
    try {
        $result = winget list --id $AppId 2>&1
        $output = $result -join "`n"

        # 确保有更准确的匹配
        foreach ($line in $result) {
            if ($line -match $AppId -and $line -notmatch "No installed package found") {
                return $true
            }
        }
        return $false
    }
    catch {
        # 尝试使用名称进行备用检查
        try {
            $appName = $AppId -replace '.*\.', ''
            $result = winget list --name $appName 2>&1
            $output = $result -join "`n"

            if ($output -match $appName -and $output -notmatch "No installed package found") {
                return $true
            }
            return $false
        }
        catch {
            return $false
        }
    }
}

# 显示标题
function Show-Header {
    Clear-Host
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host "           Windows 应用安装状态检查工具               " -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "正在检查应用安装状态，请稍候..." -ForegroundColor Yellow
    Write-Host ""
}

# 调试信息输出
function Write-DebugInfo {
    param (
        [string]$AppId,
        [string]$Output
    )

    if ($DebugMode) {
        Write-Host "DEBUG: 检查应用 $AppId" -ForegroundColor Gray
        Write-Host "DEBUG: winget 输出:" -ForegroundColor Gray
        Write-Host $Output -ForegroundColor Gray
        Write-Host "------------------------------" -ForegroundColor Gray
    }
}

# 主函数
function Check-Applications {
    param(
        [switch]$Debug
    )

    $global:DebugMode = $Debug

    Show-Header

    $installedCount = 0
    $notInstalledCount = 0
    $total = 0
    $problemApps = @()

    Write-Host "应用安装状态:"
    Write-Host "--------------------------------------------------------"

    foreach ($appLine in $applications) {
        if ([string]::IsNullOrWhiteSpace($appLine)) {
            continue
        }

        $total++
        $appInfo = Get-AppInfo -AppLine $appLine
        $isInstalled = Test-AppInstalled -AppId $appInfo.Id

        # 显示状态
        if ($isInstalled) {
            # 已安装 - 白色
            if ($appInfo.Description) {
                Write-Host "✓ $($appInfo.Id) - $($appInfo.Description)" -ForegroundColor White
            } else {
                Write-Host "✓ $($appInfo.Id)" -ForegroundColor White
            }
            $installedCount++
        } else {
            # 未安装 - 绿色
            if ($appInfo.Description) {
                Write-Host "✗ $($appInfo.Id) - $($appInfo.Description)" -ForegroundColor Green
            } else {
                Write-Host "✗ $($appInfo.Id)" -ForegroundColor Green
            }
            $notInstalledCount++
            $problemApps += $appInfo.Id
        }
    }

    Write-Host "--------------------------------------------------------"
    Write-Host "检查完成! 共计: $total 应用" -ForegroundColor Cyan
    Write-Host "已安装: $installedCount" -ForegroundColor White
    Write-Host "未安装: $notInstalledCount" -ForegroundColor Green
    Write-Host ""

    if ($notInstalledCount -gt 0) {
        Write-Host "可能需要安装的应用:" -ForegroundColor Yellow
        foreach ($app in $problemApps) {
            Write-Host " - $app" -ForegroundColor Yellow
        }
        Write-Host ""
    }
}

# 执行应用检查
Check-Applications
