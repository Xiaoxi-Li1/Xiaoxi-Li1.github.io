# Google Scholar 数据爬虫

此脚本用于自动爬取 Google Scholar 数据，包括：
- 总引用数 (citedby)
- 一作论文引用数 (first_author_citations)
- GitHub 总星数 (github_stars)
- 各篇论文的详细引用信息

## 环境配置

### 1. 安装依赖

```bash
cd google_scholar_crawler
pip install -r requirements.txt
```

### 2. 设置环境变量

需要设置以下环境变量：

```bash
export GOOGLE_SCHOLAR_ID="XDljV4YAAAAJ"  # 你的 Google Scholar ID
export GITHUB_USERNAME="sunnynexus"       # 你的 GitHub 用户名
export GITHUB_TOKEN="your_github_token"   # (可选) GitHub Token，用于避免 API 速率限制
```

## 本地测试

### 快速测试计算逻辑

运行测试脚本，验证计算是否正确：

```bash
cd google_scholar_crawler
python test_local.py
```

这将显示：
- 每篇一作论文的引用数
- 一作论文总引用数
- 每个 GitHub 仓库的星数
- GitHub 总星数

### 完整运行爬虫

```bash
cd google_scholar_crawler
export GOOGLE_SCHOLAR_ID="XDljV4YAAAAJ"
export GITHUB_USERNAME="sunnynexus"
python main.py
```

生成的数据将保存在 `results/gs_data.json`

## GitHub Actions 自动更新

此项目配置了 GitHub Actions，会：
- 每天自动运行一次（UTC 00:00）
- 自动爬取最新数据
- 将结果推送到 `google-scholar-stats` 分支

### 配置 Secrets

在 GitHub 仓库设置中添加以下 Secret：
- `GOOGLE_SCHOLAR_ID`: 你的 Google Scholar ID

`GITHUB_TOKEN` 会自动提供，无需手动配置。

## 手动触发更新

如果你想立即更新数据，可以：

1. 在 GitHub 仓库页面，进入 Actions 标签
2. 选择 "Get Citation Data" workflow
3. 点击 "Run workflow" 按钮

## 更新一作论文列表

如果你发表了新的一作论文，需要更新 `main.py` 中的 `first_author_ids` 列表：

```python
first_author_ids = [
    'XDljV4YAAAAJ:YsMSGLbcyi4C',  # Search-o1
    'XDljV4YAAAAJ:qjMakFHDy7sC',  # From Matching to Generation
    'XDljV4YAAAAJ:LkGwnXOMwfcC',  # WebThinker
    'XDljV4YAAAAJ:W7OEmFMy1HYC',  # RetroLLM
    'XDljV4YAAAAJ:IjCSPb-OGe4C',  # CorpusLM
    'XDljV4YAAAAJ:9yKSN-GCB0IC',  # UniGen
    'XDljV4YAAAAJ:QIV2ME_5wuYC',  # DeepAgent
    # 在这里添加新的论文 ID
]
```

## 数据格式

生成的 `gs_data.json` 包含以下字段：

```json
{
  "citedby": 1163,                    // 总引用数
  "first_author_citations": 779,      // 一作论文总引用
  "github_stars": 1500,               // GitHub 总星数
  "publications": {                   // 各篇论文详情
    "XDljV4YAAAAJ:...": {
      "num_citations": 322,
      ...
    }
  }
}
```

## 故障排除

### GitHub API 速率限制

如果遇到 GitHub API 速率限制（未认证时每小时60次请求），可以：

1. 创建 GitHub Personal Access Token
2. 设置 `GITHUB_TOKEN` 环境变量
3. 这样速率限制会提升到每小时 5000 次

### Google Scholar 代理问题

如果遇到 Google Scholar 访问问题，脚本使用了免费代理。如果仍有问题：

1. 检查网络连接
2. 尝试使用 VPN
3. 考虑使用付费代理服务

## 许可证

MIT

