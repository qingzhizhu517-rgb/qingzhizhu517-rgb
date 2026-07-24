# 🚀 快速启动指南

## ✅ 已修复的问题

1. ✅ **去掉了动态内容说明部分**
2. ✅ **修复了 About Me 显示** - 改成普通文本而不是代码块
3. ✅ **移除了有问题的波浪横幅** - 使用更可靠的方案
4. ✅ **保留了所有动态特性**

## 🐍 如何显示贪吃蛇动画

贪吃蛇动画需要通过 GitHub Actions 自动生成。请按照以下步骤操作：

### 步骤 1：配置 GitHub Token

1. 访问：https://github.com/settings/tokens
2. 点击 **Generate new token** → **Generate new token (classic)**
3. 填写 Note：`GitHub Profile`
4. 勾选以下权限：
   - ✅ **repo** (Full control of private repositories)
   - ✅ **workflow** (Update GitHub Action workflows)
   - ✅ **read:user** (Read all user profile data)
5. 点击 **Generate token**
6. **复制生成的 token**（注意：只会显示一次！）

### 步骤 2：配置仓库 Secrets

1. 访问你的仓库：https://github.com/qingzhizhu517-rgb/qingzhizhu517-rgb
2. 点击 **Settings** 标签
3. 在左侧菜单点击 **Secrets and variables** → **Actions**
4. 点击 **New repository secret**
5. 填写：
   - **Name**: `METRICS_TOKEN`
   - **Secret**: 粘贴刚才生成的 token
6. 点击 **Add secret**

### 步骤 3：运行 GitHub Actions

1. 点击仓库的 **Actions** 标签
2. 你会看到三个工作流：
   - **Generate Snake Animation** - 贪吃蛇动画
   - **GitHub Metrics** - 详细统计
   - **GitHub-Profile-3D-Contrib** - 3D 贡献图
3. 逐个点击每个工作流：
   - 点击工作流名称
   - 点击 **Run workflow** 按钮
   - 选择 **main** 分支
   - 点击 **Run workflow**
4. 等待所有工作流运行完成（通常需要 2-5 分钟）

### 步骤 4：查看效果

1. 刷新你的个人主页：https://github.com/qingzhizhu517-rgb
2. 贪吃蛇动画现在应该显示了！

## 📊 当前已显示的内容

### ✅ 立即显示（无需配置）
- 个人头像
- 打字机动画
- 技能徽章
- GitHub Stats 统计卡片
- Streak Stats 连续贡献
- GitHub Trophy 成就奖杯
- Activity Graph 活动图
- 访客计数器
- Star History 图表

### ⏳ 需要运行 GitHub Actions
- 🐍 贡献蛇动画（贪吃蛇）
- 📊 GitHub Metrics 详细统计
- 🌟 3D 贡献图

## 🔄 自动更新

所有动态内容都会自动更新：
- **贡献蛇**: 每 12 小时更新一次
- **GitHub Metrics**: 每天更新一次
- **3D 贡献图**: 每天更新一次

## ❓ 常见问题

### Q: 为什么 GitHub Stats 显示 0？
A: GitHub 需要一些时间来索引你的活动。请等待 24 小时后再次查看。

### Q: 为什么某些图片不显示？
A: 可能的原因：
1. 服务暂时不可用（等待几分钟后重试）
2. 需要运行 GitHub Actions（按照上述步骤操作）
3. 浏览器缓存问题（尝试清除缓存或使用隐身模式）

### Q: 如何自定义样式？
A: 编辑 `README.md` 文件：
1. 修改打字机动画文字（第 20 行）
2. 修改技能表格（第 45-80 行）
3. 修改联系方式（第 180-195 行）

## 📚 更多资源

- [GitHub Profile README 生成器](https://rahuldkjain.github.io/gh-profile-readme-generator/)
- [Shields.io 徽章生成器](https://shields.io/)
- [GitHub Readme Stats](https://github.com/anuraghazra/github-readme-stats)
- [GitHub Readme Streak Stats](https://github.com/DenverCoder1/github-readme-streak-stats)
- [GitHub Profile Trophy](https://github.com/ryo-ma/github-profile-trophy)

---

🎉 **恭喜！你的 GitHub 个人主页已经准备就绪！**

访问：https://github.com/qingzhizhu517-rgb