# 更新指南 - 添加一作引用和GitHub星数显示

## 📋 已完成的修改

我已经完成了以下修改：

### 1. ✅ 更新了 `_pages/about.md`
在第15行添加了动态显示徽章：
- 📊 总引用数（Citations）
- 📝 一作引用数（First-author）  
- ⭐ GitHub 总星数（GitHub Stars）

### 2. ✅ 更新了 `google_scholar_crawler/main.py`
添加了自动计算功能：
- 计算7篇一作论文的总引用数
- 通过 GitHub API 获取所有仓库的总星数

### 3. ✅ 更新了 GitHub Actions 配置
- 添加了 `GITHUB_USERNAME` 和 `GITHUB_TOKEN` 环境变量
- 每天自动运行并更新数据

### 4. ✅ 创建了测试脚本
- `test_local.py` - 本地测试计算逻辑
- `run_test.bat` - Windows 快速运行脚本
- `README.md` - 详细使用说明

## 🚀 快速开始

### 方案 A: 本地测试（推荐，立即查看效果）

1. **运行测试脚本**（Windows）：
   ```cmd
   cd google_scholar_crawler
   run_test.bat
   ```

   或者（手动运行）：
   ```bash
   cd google_scholar_crawler
   pip install -r requirements.txt
   python test_local.py
   ```

2. **查看计算结果**：
   - 会显示每篇一作论文的引用数
   - 会显示每个 GitHub 仓库的星数
   - 生成 `results/gs_data_test.json` 文件

3. **当前预计数据**（基于你提供的信息）：
   - 总引用：**1163**
   - 一作引用：**779** (Search-o1: 322 + Survey: 173 + WebThinker: 170 + RetroLLM: 18 + CorpusLM: 35 + UniGen: 49 + DeepAgent: 12)
   - GitHub 星数：需要运行脚本实时获取

### 方案 B: 完整更新（需要 Google Scholar 访问）

1. **设置环境变量**：
   ```cmd
   set GOOGLE_SCHOLAR_ID=XDljV4YAAAAJ
   set GITHUB_USERNAME=sunnynexus
   ```

2. **运行完整脚本**：
   ```bash
   cd google_scholar_crawler
   python main.py
   ```

3. **手动推送到 google-scholar-stats 分支**：
   ```bash
   cd results
   git init
   git add gs_data.json
   git commit -m "Update with first-author citations and GitHub stars"
   git push https://github.com/Xiaoxi-Li1/Xiaoxi-Li1.github.io.git HEAD:google-scholar-stats --force
   ```

### 方案 C: GitHub Actions 自动更新（最简单）

1. **手动触发 GitHub Action**：
   - 访问: https://github.com/Xiaoxi-Li1/Xiaoxi-Li1.github.io/actions
   - 选择 "Get Citation Data" workflow
   - 点击 "Run workflow" 按钮

2. **等待几分钟**，数据会自动更新到 `google-scholar-stats` 分支

3. **刷新你的个人主页**，徽章应该就能显示了

## 🔍 验证效果

更新后，访问你的个人主页应该会看到：

```
I'm currently a REDstar research intern... My research has received 
[1163 Citations] ([779 First-author]) and [XX GitHub Stars].
```

徽章会是可点击的链接，分别链接到：
- Google Scholar 主页（前两个徽章）
- GitHub 主页（第三个徽章）

## 🔧 如果徽章不显示

### 可能的原因：

1. **数据还未生成**：`gs_data.json` 中还没有 `first_author_citations` 和 `github_stars` 字段
   - 解决：运行上述任何一个方案更新数据

2. **shields.io 缓存**：徽章服务器可能缓存了旧数据
   - 解决：等待几分钟，或者在 URL 后添加 `?v=2` 强制刷新

3. **JSON 路径错误**：确认 `google-scholar-stats` 分支存在且包含更新的数据
   - 解决：访问 https://raw.githubusercontent.com/Xiaoxi-Li1/Xiaoxi-Li1.github.io/google-scholar-stats/gs_data.json
   - 检查是否包含 `first_author_citations` 和 `github_stars` 字段

## 📝 后续维护

### 发表新的一作论文时

编辑 `google_scholar_crawler/main.py`，在 `first_author_ids` 列表中添加新论文的 ID：

```python
first_author_ids = [
    'XDljV4YAAAAJ:YsMSGLbcyi4C',  # Search-o1
    # ... 其他论文
    'XDljV4YAAAAJ:NEW_PAPER_ID',   # 新论文标题
]
```

### 自动更新

GitHub Actions 会每天自动运行（UTC 00:00，北京时间 08:00），无需手动操作。

## ❓ 需要帮助

如果遇到问题：

1. 检查 `google_scholar_crawler/README.md` 详细文档
2. 运行 `test_local.py` 验证计算逻辑
3. 查看 GitHub Actions 运行日志

---

**祝使用愉快！** 🎉

