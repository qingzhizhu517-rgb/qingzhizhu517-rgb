# Aohs GitHub 个人主页升级设计

- 日期：2026-08-28
- 状态：已完成口头设计确认，等待书面复核
- 实施对象：GitHub Profile README 仓库 `qingzhizhu517-rgb/qingzhizhu517-rgb`

## 1. 背景

当前个人主页由根目录 `README.md` 直接驱动，不是 GitHub Pages 网站。现有内容以第三方统计卡、徽章和模板化文案为主，真实项目与个人能力缺少证据链。Stats、Top Languages、Trophy 和 Activity Graph 当前已无法回显；仓库还包含误合并的嵌套副本、过期部署文档、无关脚本和错误联系信息。

本次升级将主页从“动态组件集合”重构为 `Aohs Digital Lab`：用真实项目、可验证的架构图和清晰的技术叙事展示 Java / 全栈产品开发与 AI 应用集成能力。

## 2. 目标与受众

### 2.1 首要受众

- 招聘方与面试官
- 开源开发者与潜在合作方
- 个人博客和社交访客

阅读优先级以求职和技术能力判断为主，同时保留鲜明的个人品牌。

### 2.2 成功标准

访客应能在首屏五秒内确认：

1. 主页品牌是 `Aohs`，GitHub 账号是 `@qingzhizhu517-rgb`。
2. 核心定位是 Java / 全栈产品开发，AI 应用集成是明确亮点。
3. 作者能够独立完成复杂业务系统、交互型产品、移动应用和数字人文项目。
4. 所有主要图片与动态内容均可稳定回显。

完整阅读后，访客应能通过项目证据理解技术能力，并可直接访问 GitHub、个人站或发送邮件。

## 3. 已确认的个人信息

- 主品牌：`Aohs`
- 次级账号标识：`@qingzhizhu517-rgb`
- 定位：Java / 全栈产品开发者，专注 AI 应用集成
- 当前阶段：不公开求职、在校或就业状态
- 地点：`Shandong, China`，仅展示一次
- 个人站：`https://aohs.top/`
- 公开邮箱：`qingzhizhu517@gmail.com`
- 项目归属：四个精选项目均为独立设计与开发
- 内容语言：中文为主，保留必要英文品牌与技术表达

## 4. 品牌与视觉方向

### 4.1 核心方向

采用用户选定的 `Aohs Digital Lab` 方向。页面应有实验室和独立数字产品品牌感，但不能牺牲招聘阅读效率。

核心文案：

> **Engineering systems. Designing experiences.**<br>
> 把复杂需求做成真正可用的产品。

### 4.2 色彩与风格

- 主背景：深石墨色，不使用大面积渐变
- 主强调色：珊瑚粉
- 辅助色：青绿
- 少量强调：暖黄
- 内容背景与文字保持高对比度
- 不使用通用科技光效、装饰性粒子、紫蓝渐变或无关库存图片

### 4.3 首屏资产

创建一个本地托管的横幅位图，用真实项目视觉与确定性排版形成 `Aohs Digital Lab` 品牌头图。横幅不依赖第三方生成服务，不把关键定位只写进图片；README 中仍提供等价文本，保证可访问性和搜索可读性。

头像作为次级识别元素保留。不得依赖 GitHub 会清理的 `border-radius` 内联样式来保证圆形效果。

### 4.4 GitHub 渲染约束

- 页面使用 GitHub 支持的 Markdown 和有限 HTML
- 不依赖自定义 CSS、JavaScript、iframe 或不受支持的 SVG 交互
- 采用单列主结构，避免双列表格在移动端压缩或横向滚动
- 所有固定视觉资产设置合理宽度，并提供准确 `alt` 文本
- 重要信息不能只存在于图片中

## 5. 页面信息结构

README 按以下顺序组织：

1. 品牌横幅与首屏定位
2. 简短的“关于我”
3. 解决问题的三类能力
4. 四个精选项目
5. 核心技术与正在探索方向
6. `Contribution Lab`
7. 联系方式

不设置单独的访客计数、奖杯、Star 历史或模板式 Fun Fact 区域。

## 6. 首屏设计

首屏包含：

- `Aohs` 主品牌
- `@qingzhizhu517-rgb` 次级标识
- 英文品牌句与中文价值主张
- `Java / 全栈产品开发 · AI 应用集成`
- `Shandong, China`
- GitHub、`aohs.top` 和邮箱入口

删除以下现有元素：

- Typing SVG 打字动画
- Followers 和 Stars 徽章
- 重复出现的身份、技术方向与地点
- 仅链接回当前页面的 GitHub 联系按钮

## 7. 个人叙事与能力分组

### 7.1 关于我

采用以下已确认文案：

> 我是 Aohs，一名以 Java 为核心的全栈产品开发者。我喜欢把规则复杂的业务、富有表达力的交互，以及 AI 能力，收敛为可部署、可维护的真实产品。

### 7.2 能力分组

不再按“语言 / IDE / 框架”堆叠徽章，改为按解决的问题分组：

1. **业务系统**：Java、Spring Boot、Vue、MySQL、Redis；重点描述规则计算、审批流程、数据导入和报表能力。
2. **交互产品**：TypeScript、Next.js、Three.js、GSAP、Cloudflare；重点描述响应式体验、三维交互与边缘部署。
3. **移动端与 AI 集成**：Kotlin、Jetpack Compose、Room、Gemini API；重点描述移动端状态管理、本地存储和在线 AI 能力降级。

### 7.3 正在探索

单独标注：

`Spring AI · RAG · LLM 应用架构`

PyTorch、TensorFlow、LangChain、OpenAI 等缺少公开项目证明的技术不再暗示为熟练能力。IDE 不作为技术能力展示。

## 8. 精选项目

项目统一说明为独立设计与开发。每个项目采用单列项目故事，内容固定为：

- 项目解决的问题
- 关键实现或技术决策
- 精简技术栈
- 仓库链接；存在可用线上地址时增加演示链接
- 一张最能证明项目价值的视觉资产

不得编造用户量、商业结果、性能数字或团队职责。

### 8.1 WFIT Workload

- 项目：潍坊理工教学工作量智能化管理系统
- 证明重点：复杂业务规则与 Java 后端能力
- 可公开事实：G1-G11 共 11 类工作量计算、Excel 导入、教师申报、三级审批、绩效酬金和报表导出
- 技术：Java 17、Spring Boot、Vue 3、MySQL、Redis、Apache POI
- 视觉形式：基于真实代码与 README 生成系统架构和业务流程图，展示“输入 -> 策略计算 -> 审批 -> 报表”的核心链路

### 8.2 Aohs Space

- 项目：交互型个人数字空间
- 证明重点：前端工程、三维交互、动画与部署能力
- 可公开事实：Next.js 15、Three.js、GSAP、Matter.js、中英文支持、Cloudflare Workers 部署
- 技术：TypeScript、Next.js、React、Three.js、GSAP、Cloudflare Workers
- 视觉形式：真实站点截图；该项目的价值本身是视觉与交互体验
- 链接：仓库与 `https://aohs.top/`

### 8.3 黄河文学景观

- 项目：数字人文视域下黄河流域（山东段）文学景观与教学应用
- 证明重点：技术、人文内容和多前端形态的结合
- 可公开事实：文学人物、诗文、地域景观、非遗与教学内容；仓库包含展示端、管理端、后端和数据可视化端
- 技术：Java 17、Spring Boot 3.2、MyBatis-Plus、MySQL、Vue 3、Three.js、GSAP、ECharts；数据可视化端另使用 React 19
- 视觉形式：生成内容关系与技术亮点图，说明地域、人物、诗文、景观、文化资源和教学交互之间的连接；可使用真实素材作为辅助，但不以单一页面截图代表整个项目

### 8.4 Pet Market

- 项目：宠物集市与品种百科 Android 应用
- 证明重点：Kotlin 移动端与 AI 能力集成
- 可公开事实：宠物浏览、品种百科、收藏、Gemini AI 顾问、离线本地知识库降级
- 技术：Kotlin、Jetpack Compose、Room、Retrofit、Gemini API
- 视觉形式：真实移动端截图与技术流程图组合，展示“用户问题 -> Gemini API -> 离线或失败时本地知识库”的降级路径

## 9. 项目视觉资产规则

- 截图从作者自己的公开仓库或在线项目获取，并复制到本仓库本地保存
- 架构图和技术亮点图必须基于可验证的代码结构、配置或 README
- 图表使用与主品牌一致的石墨、珊瑚粉、青绿和暖黄色，但项目内容本身保持可区分
- 图片不得用纯装饰性 AI 插画替代真实项目证据
- 架构图中的关键信息同时以正文说明，避免只靠图内小字
- 优先使用经过压缩的 WebP 或 PNG；GitHub 兼容性优先于文件体积极限优化

资产路径固定为：

- `assets/brand/aohs-header.webp`
- `assets/projects/wfit-system.webp`
- `assets/projects/aohs-space.webp`
- `assets/projects/sjg-content-map.webp`
- `assets/projects/pet-market-ai.webp`

如单个项目需要补充第二张原始截图，只能放在同一 `assets/projects/` 目录，并采用项目名前缀命名。

## 10. Contribution Lab

动态区域只保留两项：

1. 用户选定的 `profile-night-green.svg` 3D 贡献图
2. 贡献蛇，使用 `<picture>` 根据浅色或深色偏好加载对应 SVG

删除以下模块：

- GitHub Stats
- Top Languages
- Streak Stats
- GitHub Trophy
- Activity Graph
- Visitor Count
- Star History
- GitHub Metrics

这些模块存在失效、第三方服务不稳定、信息价值低或模板感过强的问题。

## 11. 工作流设计

### 11.1 贡献蛇

- 保留定时和手动触发，移除每次 `main` push 都运行的触发条件
- 使用 `GITHUB_TOKEN` 和最小的 `contents: write` 权限
- 使用 `Platane/snk@v3` 生成 SVG，并使用 `peaceiris/actions-gh-pages@v4` 发布到 `output` 分支
- 实施时将上述已审核版本解析并固定到具体 commit SHA，不使用浮动 `latest` 或未审查的分支引用
- 生成失败时不删除 `output` 分支上一版素材

### 11.2 3D 贡献图

- 保留定时和手动触发
- 明确声明 `contents: write`
- 使用 GitHub Actions 机器人提交身份，移除 `your-email@example.com`
- 使用 `GITHUB_TOKEN`，不要求额外的高权限 PAT
- 使用已验证的 `yoshi389111/github-profile-3d-contrib@0.6.0`，实施时固定到对应 commit SHA
- 生成后只保留 `profile-night-green.svg`，删除未展示变体
- 仅在文件真实变化时提交，避免空提交和不必要噪声
- 提交信息包含跳过无关工作流的标记，避免触发循环

### 11.3 Metrics

删除 `.github/workflows/Metrics.yml` 与 `github-metrics.svg`。该文件当前包含可见错误，根 README 也未使用它。

## 12. 仓库清理范围

保留：

- `README.md`
- `LICENSE`
- 精简后的 `.gitignore`
- 两个有效工作流
- 选定的 3D 贡献图
- 新建的品牌与项目素材目录
- 有效的验证脚本和设计/实施文档

删除或替换：

- 误合并的 `qingzhizhu517-rgb/` 嵌套副本
- `simple_interest.sh`
- 已被跟踪的 `.DS_Store`
- `SOLUTION.md`
- `QUICK-START.md`
- `RETRY-GUIDE.md`
- `TROUBLESHOOTING.md`
- `IMAGE-FIX-GUIDE.md`
- `DEPLOYMENT.md`
- 模板化且包含错误邮箱的 `CODE_OF_CONDUCT.md`
- 与个人主页目标不匹配的 `CONTRIBUTING.md`
- 失效的 `test-urls.sh`；如需要，以结构清晰、带超时和内容类型检查的新验证脚本替代
- 未展示的 3D 贡献图变体
- Metrics 工作流与生成文件

`.gitignore` 增加 `.superpowers/` 和 `.DS_Store`，防止本地设计稿与系统文件再次进入版本控制。

新的验证脚本路径固定为 `scripts/check-profile.sh`，用于本地资产、必要外链和内容类型检查。

## 13. 联系方式

页面底部提供三个明确入口：

- GitHub：`https://github.com/qingzhizhu517-rgb`
- Website：`https://aohs.top/`
- Email：`mailto:qingzhizhu517@gmail.com`

联系方式不使用无意义的自链接，不添加未经确认的 LinkedIn、Twitter 或其他平台。

## 14. 错误处理与稳定性

- 主要品牌和项目素材本地托管，避免第三方图床成为单点故障
- 动态工作流失败时保留最后成功生成的资产
- 外部链接仅保留 GitHub、个人站、邮箱和项目仓库等必要入口
- README 不显示工作流生成文件中的错误文本或占位数据
- GitHub 不支持的样式必须有自然降级，页面在禁用图片时仍能通过文字理解

## 15. 验证方案

实施完成后至少执行：

1. 检查 Git 工作区，仅包含本次范围内的改动。
2. 运行 Markdown、HTML 标签、YAML 和 Shell 语法检查。
3. 验证所有本地图片存在、格式正确、文件大小合理。
4. 使用带超时的 GET 请求验证外部链接状态和图片内容类型，不使用容易误判的纯 HEAD 检查。
5. 通过 GitHub Markdown 渲染方式生成预览，在桌面和移动宽度下检查文字、图片、表格和链接是否溢出或重叠。
6. 检查浅色与深色模式下的对比度，确认贡献蛇正确切换。
7. 检查工作流最小权限、固定版本、无变化不提交和失败保留旧资产的行为。
8. 推送后观察两个工作流，并复核 GitHub 个人主页的实际渲染结果。

## 16. 非目标

- 不新建 GitHub Pages 站点
- 不重做 `aohs.top`
- 不添加未经验证的职业经历、熟练度、用户量或项目成果
- 不用更多统计卡来制造内容量
- 不为每个项目强制使用同一种图片形式
- 不保留仅因“以前存在”而没有实际价值的仓库文件

## 17. 最终交付

- 一份重写后的根 `README.md`
- 一个本地品牌横幅
- 四个项目的截图、架构图或技术亮点图
- 一个精简、稳定的 `Contribution Lab`
- 两个修正后的 GitHub Actions 工作流
- 清理后的仓库结构
- 一套可重复运行的验证流程
