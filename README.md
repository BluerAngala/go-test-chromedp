# 浏览器自动化测试工具

基于 Wails + Vue 3 + chromedp 开发的浏览器自动化测试桌面应用。

## 项目简介

这是一个功能完整的浏览器自动化测试工具，提供了可视化的界面来执行常见的浏览器自动化操作，包括页面截图、元素操作、JavaScript 执行等功能。

## 技术栈

- **后端**: Go 1.24 + Wails v2
- **前端**: Vue 3 + UnoCSS
- **浏览器自动化**: chromedp

## 主要功能

- 📸 **页面截图**: 访问指定 URL 并保存页面截图
- 🖱️ **点击元素**: 通过 ID 或 CSS 选择器点击页面元素
- ⌨️ **输入文本**: 在指定输入框中输入文本内容
- ⚡ **执行 JavaScript**: 在页面中执行自定义 JavaScript 代码
- 📄 **获取页面标题**: 获取当前页面的标题
- 📝 **获取元素文本**: 提取指定元素的文本内容
- ⏳ **等待元素出现**: 等待指定元素在页面中出现
- 🎭 **有头/无头模式**: 支持切换浏览器显示模式

## 开发环境要求

- Go 1.24 或更高版本
- Node.js 和 npm
- Wails CLI（通过 `go install github.com/wailsapp/wails/v2/cmd/wails@latest` 安装）

## 快速开始

### 安装依赖

```bash
# 安装 Go 依赖
go mod download

# 安装前端依赖
cd frontend
npm install
cd ..
```

### 开发模式

在项目根目录运行：

```bash
wails dev
```

这将启动开发服务器，支持前端热重载。开发服务器会在 http://localhost:34115 运行，你可以在浏览器中访问并调用 Go 方法进行调试。

### 构建应用

#### Windows 平台

构建生产版本：

```bash
wails build
```

构建完成后，可执行文件将位于 `build/bin/` 目录下。

#### Mac 平台

##### 方式一：在 Windows 上交叉编译（推荐）

可以在 Windows 系统上直接构建 Mac 版本：

```powershell
# 构建 Mac 版本 (默认 amd64)
.\script\build-mac.ps1

# 清理后构建
.\script\build-mac.ps1 -Clean

# 构建 ARM64 版本（Apple Silicon）
.\script\build-mac.ps1 -Arch arm64

# 构建 AMD64 版本（Intel Mac）
.\script\build-mac.ps1 -Arch amd64
```

**注意事项**:
- 构建的应用包未经过代码签名，在 Mac 上首次运行可能需要右键 -> 打开
- 建议在 macOS 系统上测试应用是否正常运行
- 如需代码签名，请在 macOS 系统上使用开发者证书进行签名

##### 方式二：在 macOS 系统上构建

使用构建脚本（推荐）：

```bash
# 构建发布版本
./script/build-mac.sh

# 清理后构建
./script/build-mac.sh --clean

# 构建开发版本
./script/build-mac.sh --dev
```

或直接使用 wails 命令：

```bash
# 构建生产版本
wails build

# 构建开发版本
wails build -dev
```

**Mac 构建要求**:
- 需要安装 Xcode Command Line Tools: `xcode-select --install`
- 如需代码签名，需要配置开发者证书

构建完成后，应用包将位于 `build/bin/test-chromedp.app`。

## CI/CD 自动构建

项目已配置 CI/CD，支持自动构建多平台版本。

### GitCode CI/CD（GitLab CI）
- 配置文件：`.gitlab-ci.yml`
- 支持平台：Linux、Windows（如果 GitCode 提供 runner）
- 使用方法：推送代码到 GitCode，自动触发构建

### GitHub Actions（推荐用于 macOS）
- 配置文件：`.github/workflows/build.yml`
- 支持平台：Windows、Linux、macOS（包括 Intel 和 Apple Silicon）
- 使用方法：推送代码到 GitHub，自动触发构建

详细说明请查看：[CI/CD 配置说明](md/CI-CD配置说明.md)

## 项目配置

可以通过编辑 `wails.json` 文件来配置项目设置。更多信息请参考：
https://wails.io/docs/reference/project-config

## 项目结构

```
.
├── app.go              # 主要业务逻辑（chromedp 自动化功能）
├── main.go             # 应用入口
├── wails.json          # Wails 项目配置
├── frontend/           # 前端代码
│   ├── src/
│   │   ├── App.vue     # 主应用组件
│   │   └── ...
│   └── package.json
└── build/              # 构建输出目录
```

## 使用说明

1. 启动应用后，在界面中配置相应的参数（URL、选择器等）
2. 选择是否启用无头模式（默认启用，不显示浏览器窗口）
3. 点击对应的功能按钮执行操作
4. 查看执行结果

## 注意事项

- 首次运行需要下载 Chrome/Chromium 浏览器（chromedp 会自动处理）
- 无头模式适合后台自动化任务，有头模式适合调试和观察
- 所有操作默认超时时间为 30 秒
