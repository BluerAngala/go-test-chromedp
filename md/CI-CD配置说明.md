# CI/CD 自动构建配置说明

本项目配置了两种 CI/CD 方案，用于自动构建多平台应用。

## 方案一：GitCode CI/CD（GitLab CI）

### 配置文件
- `.gitlab-ci.yml` - GitCode/GitLab CI 配置文件

### 支持的平台
- ✅ **Linux** - 完全支持
- ⚠️ **Windows** - 取决于 GitCode 是否提供 Windows runner
- ❌ **macOS** - GitCode 通常不提供 macOS runner

### 使用方法

1. **推送代码到 GitCode**
   ```bash
   git add .
   git commit -m "Add CI/CD configuration"
   git push origin main
   ```

2. **查看构建状态**
   - 在 GitCode 项目页面，点击 "CI/CD" -> "Pipelines"
   - 查看构建进度和结果

3. **下载构建产物**
   - 构建完成后，在 Pipeline 页面下载 artifacts
   - 或者通过 GitCode API 下载

### 触发条件
- 推送到 `main` 或 `master` 分支
- 创建标签（tags）

### 注意事项
- 如果 GitCode 没有 macOS runner，macOS 构建会失败（已设置 `allow_failure: true`）
- Windows 构建需要 GitCode 提供 Windows runner 或使用 Linux runner 交叉编译

---

## 方案二：GitHub Actions（推荐用于 macOS）

### 配置文件
- `.github/workflows/build.yml` - GitHub Actions 配置文件

### 支持的平台
- ✅ **Windows** - 完全支持
- ✅ **Linux** - 完全支持
- ✅ **macOS** - 完全支持（包括 Intel 和 Apple Silicon）

### 使用方法

1. **在 GitHub 创建仓库**
   - 如果还没有 GitHub 仓库，创建一个新的
   - 或者将 GitCode 仓库镜像到 GitHub

2. **推送代码到 GitHub**
   ```bash
   git remote add github https://github.com/yourusername/yourrepo.git
   git push github main
   ```

3. **查看构建状态**
   - 在 GitHub 项目页面，点击 "Actions" 标签
   - 查看构建进度和结果

4. **下载构建产物**
   - 构建完成后，在 Actions 页面下载 artifacts
   - 或者创建 Release 自动打包所有平台

### 触发条件
- 推送到 `main` 或 `master` 分支
- 创建 Pull Request
- 创建标签（自动创建 Release）
- 手动触发（workflow_dispatch）

### 自动发布
- 当创建 `v*` 格式的标签时（如 `v1.0.0`），会自动创建 GitHub Release
- 所有平台的构建产物会自动附加到 Release

---

## 推荐方案

### 如果使用 GitCode 作为主仓库
1. **Windows/Linux 构建**：使用 GitCode CI/CD
2. **macOS 构建**：使用 GitHub Actions（免费提供 macOS runner）

### 配置步骤

#### 1. 在 GitCode 上启用 CI/CD
- 确保项目已启用 CI/CD 功能
- 检查是否有可用的 runner（Linux、Windows）

#### 2. 在 GitHub 上启用 Actions
- 将代码推送到 GitHub（可以设置为 GitCode 的镜像）
- GitHub Actions 会自动运行

#### 3. 同步两个仓库（可选）
```bash
# 添加两个远程仓库
git remote set-url --add --push origin https://gitcode.net/yourusername/yourrepo.git
git remote set-url --add --push origin https://github.com/yourusername/yourrepo.git

# 推送时自动同步到两个仓库
git push origin main
```

---

## 构建产物说明

### Windows
- `test-chromedp.exe` - 可执行文件
- `test-chromedp.msi` - 安装包（如果配置了）

### Linux
- `test-chromedp` - 可执行文件

### macOS
- `test-chromedp.app` - 应用包
- `test-chromedp.dmg` - 磁盘镜像（如果配置了）

---

## 常见问题

### Q: GitCode 没有 macOS runner 怎么办？
A: 使用 GitHub Actions，它免费提供 macOS runner。

### Q: 如何只构建特定平台？
A: 修改 `.gitlab-ci.yml` 或 `.github/workflows/build.yml`，注释掉不需要的平台。

### Q: 构建失败怎么办？
A: 
1. 检查 runner 是否可用
2. 检查依赖是否正确安装
3. 查看构建日志中的错误信息

### Q: 如何配置代码签名？
A: 需要在 CI/CD 配置中添加签名步骤，并配置相应的证书和密钥。

---

## 更新日志

- 2025-01-XX: 初始配置，支持 Windows、Linux、macOS 构建

