# 🚀 GitHub 个人主页部署指南

## 📁 文件结构

```
qingzhizhu517-rgb/
├── README.md                              # 个人主页主文件
├── LICENSE                                # MIT 许可证
├── .gitignore                             # Git 忽略文件
├── DEPLOYMENT.md                          # 本部署说明
├── github-metrics.svg                     # GitHub Metrics 占位符
├── assets/
│   └── wave.svg                          # 动态波浪横幅
├── profile-3d-contrib/
│   └── profile-green-animate.svg         # 3D 贡献图占位符
└── .github/
    └── workflows/
        ├── grid-snake.yml                # 贡献蛇动画工作流
        ├── Metrics.yml                   # GitHub Metrics 工作流
        └── profile-3d.yml                # 3D 贡献图工作流
```

## 🎯 部署步骤

### 第一步：创建 GitHub 仓库

1. 访问 https://github.com/new
2. 仓库名称必须与你的用户名完全一致：`qingzhizhu517-rgb`
3. 选择 Public
4. 点击 Create repository

### 第二步：上传文件

#### 方法 1：使用 Git 命令行

```bash
# 1. 克隆仓库
git clone https://github.com/qingzhizhu517-rgb/qingzhizhu517-rgb.git
cd qingzhizhu517-rgb

# 2. 复制所有文件到仓库目录
# 将 qingzhizhu517-rgb 目录中的所有文件复制到克隆的仓库中

# 3. 添加文件
git add .

# 4. 提交
git commit -m "🎉 Initialize GitHub profile"

# 5. 推送
git push origin main
```

#### 方法 2：使用 GitHub Web 界面

1. 访问你的仓库页面
2. 点击 "Add file" → "Upload files"
3. 拖拽所有文件到上传区域
4. 点击 "Commit changes"

### 第三步：配置 GitHub Secrets（重要！）

为了使 GitHub Actions 正常工作，你需要配置以下 Secrets：

#### 1. METRICS_TOKEN（用于 GitHub Metrics）

1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token" → "Generate new token (classic)"
3. 填写 Note：`GitHub Metrics`
4. 选择权限：
   - ✅ `repo` (Full control of private repositories)
   - ✅ `read:user` (Read all user profile data)
   - ✅ `read:org` (Read organization data)
5. 点击 "Generate token"
6. 复制生成的 token

然后配置到仓库 Secrets：

1. 访问你的仓库页面
2. 点击 Settings → Secrets and variables → Actions
3. 点击 "New repository secret"
4. Name: `METRICS_TOKEN`
5. Secret: 粘贴刚才生成的 token
6. 点击 "Add secret"

### 第四步：启用 GitHub Actions

1. 访问你的仓库页面
2. 点击 "Actions" 标签
3. 如果看到提示，点击 "I understand my workflows, go ahead and enable them"
4. 点击左侧的 "Generate Snake Animation"
5. 点击 "Run workflow" → "Run workflow"（手动触发一次）
6. 对其他两个工作流重复此操作

### 第五步：等待并查看效果

1. 等待所有工作流运行完成（通常需要几分钟）
2. 刷新你的个人主页：https://github.com/qingzhizhu517-rgb
3. 你应该能看到所有样式效果了！

## 🎨 样式说明

### ✅ 已包含的样式

1. **动态波浪横幅** - 带有渐变色和动画效果
2. **打字机动画** - 多行文字逐字显示
3. **技能徽章** - 彩色技术栈展示
4. **GitHub 统计卡片** - 个人统计数据
5. **连续贡献统计** - 连续贡献天数
6. **贡献蛇动画** - 贪蛇吃贡献格子
7. **GitHub Trophy** - 成就奖杯
8. **活动图** - 贡献活动可视化
9. **3D 贡献图** - 等距视角的贡献格子
10. **GitHub Metrics** - 详细统计面板
11. **访客计数器** - 实时访问统计
12. **Star 历史** - Star 增长图表

### 🔄 自动更新

所有动态内容都会通过 GitHub Actions 自动更新：
- **贡献蛇**：每 12 小时更新一次
- **GitHub Metrics**：每天更新一次
- **3D 贡献图**：每天更新一次

## 🛠️ 自定义修改

### 修改个人信息

编辑 `README.md` 文件：

1. 修改打字机动画文字（第 20 行）
2. 修改技能表格（第 45-80 行）
3. 修改联系方式（第 180-195 行）

### 修改颜色主题

1. 波浪横幅：编辑 `assets/wave.svg` 中的颜色值
2. 统计卡片：修改 README.md 中的 `theme=radical` 为其他主题：
   - `default`
   - `radical`
   - `merko`
   - `gruvbox`
   - `tokyonight`
   - `onedark`
   - `cobalt`
   - `synthwave`

### 添加更多样式

参考 BEPb 的原始仓库：https://github.com/BEPb/BEPb

## ❓ 常见问题

### Q: 为什么我的统计卡片显示 0？
A: GitHub 需要一些时间来索引你的活动。请等待 24 小时后再次查看。

### Q: 为什么 3D 贡献图没有显示？
A: 确保你已经：
1. 配置了 `METRICS_TOKEN` Secret
2. 手动运行了 `profile-3d.yml` 工作流
3. 等待工作流运行完成

### Q: 如何修改访客计数器？
A: 访客计数器使用 `profile-counter.glitch.me` 服务，会自动统计访问次数。

### Q: 如何添加更多徽章？
A: 访问 https://shields.io/ 创建自定义徽章。

## 📚 参考资源

- [GitHub Profile README 生成器](https://rahuldkjain.github.io/gh-profile-readme-generator/)
- [Shields.io 徽章生成器](https://shields.io/)
- [GitHub Readme Stats](https://github.com/anuraghazra/github-readme-stats)
- [GitHub Readme Streak Stats](https://github.com/DenverCoder1/github-readme-streak-stats)
- [GitHub Profile Trophy](https://github.com/ryo-ma/github-profile-trophy)
- [Lowlighter Metrics](https://github.com/lowlighter/metrics)
- [GitHub Profile 3D Contrib](https://github.com/yoshi389111/github-profile-3d-contrib)
- [Platane Snake](https://github.com/Platane/snk)

---

🎉 **恭喜！你的 GitHub 个人主页已经准备就绪！**

如果遇到问题，请查看 GitHub Actions 的运行日志或参考上述资源。