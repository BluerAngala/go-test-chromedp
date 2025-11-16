# Mac 平台构建脚本 (Windows 上运行)
# 使用方法: .\script\build-mac.ps1 [选项]
# 选项:
#   -Clean      清理旧的构建文件
#   -Arch       指定架构 (amd64 或 arm64，默认 amd64)

param(
    [switch]$Clean,
    [string]$Arch = "amd64"
)

$ErrorActionPreference = "Stop"

# 颜色输出函数
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# 读取 wails.json 配置
$wailsConfigPath = "wails.json"
if (-not (Test-Path $wailsConfigPath)) {
    Write-ColorOutput Red "错误: 未找到 wails.json 文件"
    exit 1
}

$wailsConfig = Get-Content $wailsConfigPath | ConvertFrom-Json
$appName = $wailsConfig.name
$outputFilename = $wailsConfig.outputfilename
$productName = if ($wailsConfig.info.productName) { $wailsConfig.info.productName } else { $appName }
$productVersion = if ($wailsConfig.info.productVersion) { $wailsConfig.info.productVersion } else { "1.0.0" }
$copyright = if ($wailsConfig.info.copyright) { $wailsConfig.info.copyright } else { "Copyright © 2025" }
$comments = if ($wailsConfig.info.comments) { $wailsConfig.info.comments } else { $productName }

Write-ColorOutput Green "开始构建 Mac 应用 (Windows 交叉编译)..."
Write-ColorOutput Yellow "应用名称: $appName"
Write-ColorOutput Yellow "输出文件名: $outputFilename"
Write-ColorOutput Yellow "目标架构: $Arch"

# 检查 Go 是否安装
if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
    Write-ColorOutput Red "错误: 未找到 Go 命令，请先安装 Go"
    exit 1
}

# 清理旧的构建文件
if ($Clean) {
    Write-ColorOutput Yellow "清理旧的构建文件..."
    if (Test-Path "build\bin\$outputFilename.app") {
        Remove-Item -Recurse -Force "build\bin\$outputFilename.app"
    }
    if (Test-Path "frontend\dist") {
        Remove-Item -Recurse -Force "frontend\dist"
    }
}

# 构建前端
Write-ColorOutput Green "构建前端资源..."
Push-Location frontend
if (-not (Test-Path "node_modules")) {
    Write-ColorOutput Yellow "安装前端依赖..."
    npm install
}
Write-ColorOutput Yellow "编译前端..."
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput Red "前端构建失败"
    Pop-Location
    exit 1
}
Pop-Location

# 检查前端构建结果
if (-not (Test-Path "frontend\dist")) {
    Write-ColorOutput Red "错误: 前端构建失败，未找到 dist 目录"
    exit 1
}

# 设置交叉编译环境变量
$env:GOOS = "darwin"
$env:GOARCH = $Arch
# 注意: Wails 可能需要 CGO，如果编译失败，可以尝试设置 CGO_ENABLED=1
# 但这需要 Mac 的交叉编译工具链，通常建议在 macOS 上构建
$env:CGO_ENABLED = "0"  # 禁用 CGO，避免交叉编译问题

Write-ColorOutput Green "交叉编译 Go 程序 (GOOS=darwin GOARCH=$Arch)..."
Write-ColorOutput Yellow "注意: 如果编译失败，可能是由于 CGO 依赖，建议在 macOS 系统上构建"

# 构建 Go 程序
$buildOutput = "build\bin\$outputFilename"
Write-ColorOutput Yellow "执行: go build -ldflags=`"-s -w`" -o $buildOutput ."
go build -ldflags="-s -w" -o $buildOutput .
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput Red "Go 编译失败"
    Write-ColorOutput Yellow "提示: Wails 应用可能需要 CGO 支持，如果编译失败，请尝试："
    Write-ColorOutput Yellow "  1. 在 macOS 系统上使用 ./script/build-mac.sh 构建"
    Write-ColorOutput Yellow "  2. 或使用 GitHub Actions 等 CI/CD 服务在 macOS runner 上构建"
    exit 1
}

# 创建 .app 包结构
Write-ColorOutput Green "创建 Mac 应用包结构..."
$appPath = "build\bin\$outputFilename.app"
$contentsPath = "$appPath\Contents"
$macOSPath = "$contentsPath\MacOS"
$resourcesPath = "$contentsPath\Resources"

# 创建目录结构
New-Item -ItemType Directory -Force -Path $macOSPath | Out-Null
New-Item -ItemType Directory -Force -Path $resourcesPath | Out-Null

# 移动二进制文件到 MacOS 目录
Move-Item -Force $buildOutput "$macOSPath\$outputFilename"

# 生成 Info.plist
Write-ColorOutput Green "生成 Info.plist..."
$infoPlistTemplate = Get-Content "build\darwin\Info.plist" -Raw

# 替换模板变量
$infoPlist = $infoPlistTemplate `
    -replace '\{\{\.Info\.ProductName\}\}', $productName `
    -replace '\{\{\.OutputFilename\}\}', $outputFilename `
    -replace '\{\{\.Name\}\}', $appName `
    -replace '\{\{\.Info\.ProductVersion\}\}', $productVersion `
    -replace '\{\{\.Info\.Comments\}\}', $comments `
    -replace '\{\{\.Info\.Copyright\}\}', $copyright `
    -replace '\{\{if \.Info\.FileAssociations\}\}.*?\{\{end\}\}', '' `
    -replace '\{\{if \.Info\.Protocols\}\}.*?\{\{end\}\}', ''

# 保存 Info.plist
$infoPlist | Out-File -FilePath "$contentsPath\Info.plist" -Encoding UTF8 -NoNewline

# 复制图标（如果存在）
if (Test-Path "build\appicon.png") {
    Write-ColorOutput Yellow "复制应用图标..."
    Copy-Item "build\appicon.png" "$resourcesPath\iconfile.png"
}

# 注意: 前端资源已通过 go:embed 嵌入到二进制文件中，无需单独复制

# 设置可执行权限（在 Windows 上这个操作会被忽略，但在 Mac 上需要）
Write-ColorOutput Green "设置文件权限..."

# 显示构建结果
Write-ColorOutput Green "✓ 构建成功！"
Write-ColorOutput Green "应用包位置: $appPath"

# 获取应用大小
$appSize = (Get-ChildItem -Recurse $appPath | Measure-Object -Property Length -Sum).Sum
$appSizeMB = [math]::Round($appSize / 1MB, 2)
Write-ColorOutput Green "应用大小: $appSizeMB MB"

Write-ColorOutput Yellow ""
Write-ColorOutput Yellow "注意:"
Write-ColorOutput Yellow "1. 此应用包未经过代码签名，在 Mac 上首次运行可能需要右键 -> 打开"
Write-ColorOutput Yellow "2. 如需代码签名，请在 macOS 系统上使用开发者证书进行签名"
Write-ColorOutput Yellow "3. 建议在 macOS 系统上测试应用是否正常运行"

Write-ColorOutput Green "完成！"

