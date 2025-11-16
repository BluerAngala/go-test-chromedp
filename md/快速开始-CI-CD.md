# CI/CD 快速开始指南

## 一、GitCode CI/CD 使用

### 1. 推送代码到 GitCode

```bash
# 如果还没有 GitCode 仓库
git remote add gitcode https://gitcode.net/yourusername/yourrepo.git

# 推送代码
git add .
git commit -m "Add CI/CD configuration"
git push gitcode main
```

### 2. 查看构建状态

1. 登录 GitCode
2. 进入项目页面
3. 点击左侧菜单 "CI/CD" -> "Pipelines"
4. 查看构建进度

### 3. 下载构建产物

- 构建完成后，在 Pipeline 详情页面
- 点击 "Browse" 或 "Download" 下载 artifacts
- 构建产物会保留 1 周

### 4. 支持的平台

- ✅ **Linux** - 完全支持
- ⚠️ **Windows** - 如果 GitCode 提供 Windows runner
- ❌ **macOS** - GitCode 通常不提供（使用 GitHub Actions）

---

## 二、GitHub Actions 使用（推荐用于 macOS）

### 1. 创建 GitHub 仓库

如果还没有 GitHub 仓库：
1. 登录 GitHub
2. 创建新仓库
3. 复制仓库地址

### 2. 推送代码到 GitHub

```bash
# 添加 GitHub 远程仓库
git remote add github https://github.com/yourusername/yourrepo.git

# 推送代码
git push github main
```

### 3. 查看构建状态

1. 登录 GitHub
2. 进入项目页面
3. 点击 "Actions" 标签
4. 查看构建进度和结果

### 4. 下载构建产物

- 构建完成后，在 Actions 页面
- 点击对应的 workflow run
- 在 "Artifacts" 部分下载

### 5. 自动发布

创建标签时自动创建 Release：

```bash
# 创建标签
git tag v1.0.0
git push github v1.0.0

# GitHub Actions 会自动：
# 1. 构建所有平台
# 2. 创建 Release
# 3. 上传所有构建产物
```

---

## 三、同时使用两个平台（推荐）

### 配置双远程仓库

```bash
# 添加两个远程仓库
git remote set-url --add --push origin https://gitcode.net/yourusername/yourrepo.git
git remote set-url --add --push origin https://github.com/yourusername/yourrepo.git

# 一次推送，同步到两个平台
git push origin main
```

### 分工建议

- **GitCode**: 用于 Windows/Linux 构建（如果支持）
- **GitHub**: 用于 macOS 构建（免费提供 macOS runner）

---

## 四、常见问题

### Q: GitCode 构建失败怎么办？

1. **检查 runner 是否可用**
   - 进入项目设置 -> CI/CD -> Runners
   - 查看是否有可用的 runner

2. **检查构建日志**
   - 在 Pipeline 页面查看详细错误信息
   - 常见问题：
     - 缺少依赖
     - 环境变量未设置
     - 权限问题

3. **测试本地构建**
   ```bash
   # 确保本地可以构建
   wails build
   ```

### Q: 如何只构建特定平台？

编辑 `.gitlab-ci.yml` 或 `.github/workflows/build.yml`，注释掉不需要的 job。

### Q: 构建产物在哪里？

- **GitCode**: Pipeline 页面 -> Artifacts
- **GitHub**: Actions 页面 -> Artifacts 或 Releases

### Q: 如何配置代码签名？

需要在 CI/CD 配置中添加签名步骤，并配置相应的证书和密钥（作为 CI/CD 变量）。

---

## 五、下一步

- 查看详细配置说明：[CI/CD 配置说明](CI-CD配置说明.md)
- 自定义构建流程：编辑 `.gitlab-ci.yml` 或 `.github/workflows/build.yml`

