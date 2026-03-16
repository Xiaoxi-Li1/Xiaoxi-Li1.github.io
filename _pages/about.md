---
permalink: /
title: ""
excerpt: ""
author_profile: true
redirect_from: 
  - /about/
  - /about.html
---

<style>
  /* Remove underline from all links on this page */
  .page__content a,
  .page__content a:hover,
  .page__content a:focus,
  .page__content a:visited {
    text-decoration: none;
  }

  /* Inline toggle for long author lists */
  .author-more {
    display: inline;
  }
  .author-more .author-toggle {
    display: none;
  }
  .author-more .more-label,
  .author-more .author-rest {
    color: #888;
    text-decoration: underline dotted;
    text-underline-offset: 2px;
  }
  .author-more .more-label {
    display: inline;
    margin: 0;
    cursor: pointer;
  }
  .author-more .author-rest {
    display: none;
    margin: 0;
    cursor: pointer;
  }
  .author-more .author-toggle:checked + .more-label {
    display: none;
  }
  .author-more .author-toggle:checked ~ .author-rest {
    display: inline;
  }

  .paper-card {
    display: flex;
    align-items: flex-start;
    gap: 1.5rem;
    padding: 1.25rem 0;
    border-bottom: 1px solid #ececec;
  }
  .paper-card:first-of-type {
    padding-top: 0.5rem;
  }
  .paper-card__image {
    flex: 0 0 min(42%, 380px);
    max-width: 380px;
  }
  .paper-card__thumb {
    position: relative;
  }
  .paper-card__image a {
    display: block;
  }
  .paper-card__image img {
    display: block;
    width: 100%;
    height: auto;
    border: 1px solid #ddd;
    border-radius: 4px;
    background: #fff;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  }
  .paper-card__badge {
    position: absolute;
    top: -10px;
    left: -10px;
    z-index: 1;
    padding: 0.28rem 0.75rem;
    border-radius: 0;
    color: #fff;
    font-size: 0.78em;
    font-weight: 700;
    line-height: 1.2;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
  }
  .paper-card__badge--venue {
    background: #113fa8;
  }
  .paper-card__badge--preprint {
    background: #666;
  }
  .paper-card__content {
    flex: 1 1 auto;
    min-width: 0;
  }
  .paper-card__title {
    margin: 0 0 0.35rem;
    font-size: 1.05em;
    line-height: 1.45;
  }
  .paper-card__meta,
  .paper-card__venue,
  .paper-card__links {
    font-size: 0.93em;
    line-height: 1.7;
  }
  .paper-card__links {
    margin-top: 0.2rem;
  }
  .paper-card__highlights {
    margin: 0.55rem 0 0;
    padding-left: 1.2rem;
    font-size: 0.95em;
    color: #444;
  }
  .paper-card__highlights li {
    margin-bottom: 0.35rem;
  }
  @media (max-width: 900px) {
    .paper-card {
      flex-direction: column;
      gap: 1rem;
    }
    .paper-card__image {
      flex-basis: auto;
      max-width: 100%;
      width: 100%;
    }
  }
</style>

<span class='anchor' id='about-me'></span>
# About me
I am currently a 3rd year PhD student at the [Gaoling School of Artificial Intelligence](https://ai.ruc.edu.cn/), [Renmin University of China](https://www.ruc.edu.cn/), mentored by Prof. [Zhicheng Dou](http://playbigdata.ruc.edu.cn/dou). I earned my bachelor's degree (2019-2023) at [Nankai University](https://www.nankai.edu.cn/).

I'm currently a RedStar research intern focusing on foundation agent research at Xiaohongshu Inc. I have published 10+ papers in top-tier AI conferences and journals (7 first-author papers), including NeurIPS, ICLR, ACL, EMNLP, AAAI, SIGIR, WWW, and TOIS. 
**Citations:** <a href='https://scholar.google.com/citations?user=XDljV4YAAAAJ'><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data.json&query=%24.citedby&label=Citations&color=white&logo=Google%20Scholar&style=flat-square&labelColor=white&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a> <a href='https://scholar.google.com/citations?user=XDljV4YAAAAJ'><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data.json&query=%24.first_author_citations&label=First-author%20Citations&color=white&logo=Google%20Scholar&style=flat-square&labelColor=white&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a>; 
**Project Stars:** <a href='https://github.com/sunnynexus'><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data.json&query=%24.github_stars_k&label=Project%20Stars&color=white&logo=GitHub&style=flat-square&labelColor=white&logoColor=black&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a> <a href='https://github.com/sunnynexus'><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data.json&query=%24.first_author_repo_stars_k&label=First-author%20Project%20Stars&color=white&logo=GitHub&style=flat-square&labelColor=white&logoColor=black&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a>

**Research Interests：**
- **Omni-Modal Agents:** Building real-world omni-modal AI assistants ([OmniGAIA](https://arxiv.org/abs/2602.22897), [OmniAtlas](https://arxiv.org/abs/2602.22897));
- **Foundation Agents:** Developing general-purpose agentic LLMs ([DeepAgent](https://arxiv.org/abs/2510.21618), [AEPO](https://arxiv.org/abs/2510.14545), [Tool-Star](https://arxiv.org/abs/2505.16410));
- **Deep Research:** Enhancing long-horizon reasoning with web information seeking ([WebThinker](https://arxiv.org/abs/2504.21776), [Search-o1](https://arxiv.org/abs/2501.05366), [HiRA](https://arxiv.org/abs/2507.02652));
- **Retrieval-Augmented LLMs:** Improving large language models with knowledge retrieval ([RetroLLM](https://aclanthology.org/2025.acl-long.819/), [CorpusLM](https://dl.acm.org/doi/abs/10.1145/3626772.3657778), [UniGen](https://ojs.aaai.org/index.php/AAAI/article/download/28714/29380)).



<!-- - Research Focus: 
  - <span style="font-size: 0.9em;">Retrieval-Augmented LLM: [UniGen](https://ojs.aaai.org/index.php/AAAI/article/download/28714/29380), [CorpusLM](https://dl.acm.org/doi/abs/10.1145/3626772.3657778), [RetroLLM](https://aclanthology.org/2025.acl-long.819/)</span>
  - <span style="font-size: 0.9em;">Deep Research Agent: [Search-o1](https://arxiv.org/abs/2501.05366), [WebThinker](https://arxiv.org/abs/2504.21776)</span>
  - <span style="font-size: 0.9em;">General Reasoning Agent: [DeepAgent](https://arxiv.org/abs/2510.21618)</span> -->

<!-- <a href='https://scholar.google.com/citations?user=XDljV4YAAAAJ'><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data_shieldsio.json&logo=Google%20Scholar&labelColor=f6f6f6&color=9cf&style=flat&label=citations"></a> -->



# 🔥 News

- *2026.03*: 🎉 [**DeepAgent**](https://arxiv.org/abs/2510.21618) has reached ⭐️ **1k stars**! A General Reasoning Agent with Scalable Toolsets. [[Demo]](https://github.com/RUC-NLPIR/DeepAgent)
- *2026.02*: 🚀 Released [**OmniGAIA**](https://arxiv.org/abs/2602.22897) and [**OmniAtlas**](https://arxiv.org/abs/2602.22897): A benchmark and model series for native omni-modal AI agents. [[Demo]](https://github.com/RUC-NLPIR/OmniGAIA)
- *2026.01*: 🎉 **Two papers** ([**DeepAgent**](https://arxiv.org/abs/2510.21618) and [**AEPO**](https://arxiv.org/abs/2510.14545)) accepted by **WWW 2026**! Looking forward to seeing you in Dubai!
- *2025.09*: 🎉 [**WebThinker**](https://arxiv.org/abs/2504.21776) accepted by **NeurIPS 2025**! (⭐️ **1.2k+ stars**, **100+ citations**). A powerful deep research agent that can think, search, and write autonomously. [[Demo]](https://github.com/RUC-NLPIR/WebThinker)
- *2025.08*: 🎤 [**Search-o1**](https://arxiv.org/abs/2501.05366) selected for **Oral Presentation** at **EMNLP 2025**! (⭐️ **1k+ stars**, **200+ citations**). The first framework that performs interleaved reasoning and web-search for o1-like reasoning models.
- *2025.05*: 🎉 **Four papers** accepted by **ACL 2025**! Looking forward to seeing you in Vienna!
- *2024.03*: 🎤 [**CorpusLM**](https://arxiv.org/abs/2404.14851) selected for **Oral Presentation** at **SIGIR 2024**! A unified LLM for retrieval and QA.
<!-- - *2025.02*: Our survey on Generative Information Retrieval accepted by **ACM TOIS**! See more [details](https://arxiv.org/abs/2404.14851). -->
<!-- - *2023.12*: Our unified generative framework for retrieval and QA has been accepted by AAAI 2024! See more [details](https://ojs.aaai.org/index.php/AAAI/article/download/28714/29380). -->



# 📝 Selected Publications
<!-- \* for corresponding author. -->

<div class="paper-card">
  <div class="paper-card__image">
    <div class="paper-card__thumb">
      <span class="paper-card__badge paper-card__badge--venue">Preprint</span>
      <a href="https://arxiv.org/abs/2602.22897">
        <img src="./images/paper-images/omnigaia_construction.png" alt="OmniGAIA model figure">
      </a>
    </div>
  </div>
  <div class="paper-card__content">
    <p class="paper-card__title"><a href="https://arxiv.org/abs/2602.22897"><strong>OmniGAIA: Towards Native Omni-Modal AI Agents</strong></a></p>
    <div class="paper-card__meta"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> <strong><u>Xiaoxi Li</u></strong>, Wenxiang Jiao, Jiarui Jin, Shijian Wang, Guanting Dong, <span class="author-more"><input type="checkbox" id="author-more-0" class="author-toggle"><label for="author-more-0" class="more-label">6 More Authors</label><label for="author-more-0" class="author-rest"> Jiajie Jin, Hao Wang, Yinuo Wang, Ji-Rong Wen, Yuan Lu, and Zhicheng Dou.</label></span></div>
    <ul class="paper-card__highlights">
      <li>Introduces OmniGAIA, a comprehensive benchmark for evaluating omni-modal agents on complex reasoning and tool-use across videos, images, and audios.</li>
      <li>Presents OmniAtlas, a native omni-modal reasoning agent with active perception and autonomous tool use.</li>
    </ul>
    <!-- <div class="paper-card__venue"><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> Preprint</div> -->
    <div class="paper-card__links"><a href="https://github.com/RUC-NLPIR/OmniGAIA"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/RUC-NLPIR/OmniGAIA?style=flat-square&logo=github&logoColor=black&labelColor=white&color=white&label=Stars&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a></div>
  </div>
</div>

<div class="paper-card">
  <div class="paper-card__image">
    <div class="paper-card__thumb">
      <span class="paper-card__badge paper-card__badge--venue">WWW 2026</span>
      <a href="https://arxiv.org/abs/2510.21618">
        <img src="./images/paper-images/deepagent_framework.png" alt="DeepAgent model figure">
      </a>
    </div>
  </div>
  <div class="paper-card__content">
    <p class="paper-card__title"><a href="https://arxiv.org/abs/2510.21618"><strong>DeepAgent: A General Reasoning Agent with Scalable Toolsets</strong></a></p>
    <div class="paper-card__meta"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> <strong><u>Xiaoxi Li</u></strong>, Wenxiang Jiao, Jiarui Jin, Guanting Dong, Jiajie Jin, <span class="author-more"><input type="checkbox" id="author-more-1" class="author-toggle"><label for="author-more-1" class="more-label">6 More Authors</label><label for="author-more-1" class="author-rest"> Yinuo Wang, Hao Wang, Yutao Zhu, Ji-Rong Wen, Yuan Lu, and Zhicheng Dou.</label></span></div>
    <!-- <div class="paper-card__venue"><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> <strong>WWW 2026</strong></div> -->
    <ul class="paper-card__highlights">
      <li>A general reasoning agent that can autonomously discover and use tools, while compressing memory to support long-horizon interactions.</li>
      <li>Introduces ToolPO, an end-to-end agentic reinforcement learning training strategy that improves overall performance.</li>
    </ul>
    <div class="paper-card__links"><a href="https://github.com/RUC-NLPIR/DeepAgent"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/RUC-NLPIR/DeepAgent?style=flat-square&logo=github&logoColor=black&labelColor=white&color=white&label=Stars&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a></div>
  </div>
</div>

<div class="paper-card">
  <div class="paper-card__image">
    <div class="paper-card__thumb">
      <span class="paper-card__badge paper-card__badge--venue">NeurIPS 2025</span>
      <a href="https://arxiv.org/abs/2504.21776">
        <img src="./images/paper-images/webthinker_framework.png" alt="WebThinker model figure">
      </a>
    </div>
  </div>
  <div class="paper-card__content">
    <p class="paper-card__title"><a href="https://arxiv.org/abs/2504.21776"><strong>WebThinker: Empowering Large Reasoning Models with Deep Research Capability</strong></a></p>
    <div class="paper-card__meta"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> <strong><u>Xiaoxi Li</u></strong>, Jiajie Jin, Guanting Dong, Hongjin Qian, Yutao Zhu, <span class="author-more"><input type="checkbox" id="author-more-2" class="author-toggle"><label for="author-more-2" class="more-label">3 More Authors</label><label for="author-more-2" class="author-rest"> Yongkang Wu, Ji-Rong Wen, and Zhicheng Dou.</label></span></div>
    <!-- <div class="paper-card__venue"><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> <strong>NeurIPS 2025 <span style="color: #c00000;">(<a href="https://www.paperdigest.org/digest/?topic=nips&year=2025" style="color: #c00000;">Most Influential NeurIPS 2025 Papers -- Top 13/5827</a>)</span></strong></div> -->
    <div class="paper-card__venue"><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> <strong> <span style="color: #c00000;"><a href="https://www.paperdigest.org/digest/?topic=nips&year=2025" style="color: #c00000;">Most Influential NeurIPS 2025 Papers -- Top 13/5827</a></span></strong></div>
    <ul class="paper-card__highlights">
      <li>An reasoning agent designed to autonomously search, deeply explore web pages, and draft research reports, all within its thinking process.</li>
      <!-- <li>Moving away from traditional agents that follow a predefined workflow, WebThinker enables the large reasoning model itself to perform actions on its own during thinking, achieving end-to-end task execution in a single generation.</li> -->
    </ul>
    <div class="paper-card__links"><a href="https://github.com/RUC-NLPIR/WebThinker"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/RUC-NLPIR/WebThinker?style=flat-square&logo=github&logoColor=black&labelColor=white&color=white&label=Stars&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a> <a href='https://scholar.google.com/scholar?oi=bibs&hl=en&cites=2494358555732420670'><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data.json&query=%24.publications.%5B%27XDljV4YAAAAJ%3ALkGwnXOMwfcC%27%5D.num_citations&label=Citations&color=white&logo=Google%20Scholar&style=flat-square&labelColor=white" style="border: 1px solid #ccc; border-radius: 4px;"></a></div>
  </div>
</div>

<div class="paper-card">
  <div class="paper-card__image">
    <div class="paper-card__thumb">
      <span class="paper-card__badge paper-card__badge--venue">EMNLP 2025 (Oral)</span>
      <a href="https://arxiv.org/abs/2501.05366">
        <img src="./images/paper-images/search-o1.png" alt="Search-o1 model figure">
      </a>
    </div>
  </div>
  <div class="paper-card__content">
    <p class="paper-card__title"><a href="https://arxiv.org/abs/2501.05366"><strong>Search-o1: Agentic Search-Enhanced Large Reasoning Models</strong></a></p>
    <div class="paper-card__meta"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> <strong><u>Xiaoxi Li</u></strong>, Guanting Dong, Jiajie Jin, Yuyao Zhang, Yujia Zhou, <span class="author-more"><input type="checkbox" id="author-more-3" class="author-toggle"><label for="author-more-3" class="more-label">3 More Authors</label><label for="author-more-3" class="author-rest"> Yutao Zhu, Peitian Zhang, and Zhicheng Dou.</label></span></div>
    <div class="paper-card__venue"><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> <strong><span style="color: #c00000;"></span> <span style="color: #c00000;"><a href="https://www.paperdigest.org/digest/?topic=emnlp&year=2025" style="color: #c00000;">Most Influential EMNLP 2025 Papers -- Top 2/3228</a></span></strong></div>
    <ul class="paper-card__highlights">
      <li>The first framework that enables o1-style reasoning models to actively search for and consult external information when they encounter missing or unfamiliar knowledge.</li>
    </ul>
    <div class="paper-card__links"><a href="https://github.com/sunnynexus/Search-o1"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/sunnynexus/Search-o1?style=flat-square&logo=github&logoColor=black&labelColor=white&color=white&label=Stars&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a> <a href='https://scholar.google.com/scholar?oi=bibs&hl=zh-CN&cites=283590861766656057,11110584847133377481,17334087535406948909,9262350589272652662'><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data.json&query=%24.publications.%5B%27XDljV4YAAAAJ%3AYsMSGLbcyi4C%27%5D.num_citations&label=Citations&color=white&logo=Google%20Scholar&style=flat-square&labelColor=white" style="border: 1px solid #ccc; border-radius: 4px;"></a></div>
  </div>
</div>

- [**RetroLLM: Empowering Large Language Models to Retrieve Fine-grained Evidence within Generation**](https://aclanthology.org/2025.acl-long.819/) \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> **<u>Xiaoxi Li</u>**, Jiajie Jin, Yujia Zhou, Yongkang Wu, Zhonghua Li, <span class="author-more"><input type="checkbox" id="author-more-4" class="author-toggle"><label for="author-more-4" class="more-label">2 More Authors</label><label for="author-more-4" class="author-rest"> Qi Ye and Zhicheng Dou.</label></span></span>\
<span style="font-size: 0.93em; "><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> **ACL 2025 Main**</span>\
<a href="https://github.com/sunnynexus/RetroLLM"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/sunnynexus/RetroLLM?style=flat-square&logo=github&logoColor=black&labelColor=white&color=white&label=Stars&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a>
- [**From Matching to Generation: A Survey on Generative Information Retrieval**](https://dl.acm.org/doi/10.1145/3722552) \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> **<u>Xiaoxi Li</u>**, Jiajie Jin, Yujia Zhou, Yuyao Zhang, Peitian Zhang, <span class="author-more"><input type="checkbox" id="author-more-5" class="author-toggle"><label for="author-more-5" class="more-label">2 More Authors</label><label for="author-more-5" class="author-rest"> Yutao Zhu and Zhicheng Dou.</label></span></span>\
<span style="font-size: 0.93em; "><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> **TOIS 2025 <span style="color: #c00000;">(JCR Q1, IF=9.1) (<a href="https://www.paperdigest.org/2025/09/most-influential-arxiv-information-retrieval-papers-2025-09-version/" style="color: #c00000;">Most Influential arXiv IR Papers in 2024 -- Top 11/All</a>)</span>**</span>\
<a href="https://github.com/RUC-NLPIR/GenIR-Survey"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/RUC-NLPIR/GenIR-Survey?style=flat-square&logo=github&logoColor=black&labelColor=white&color=white&label=Stars&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a> <a href='https://scholar.google.com/scholar?oi=bibs&hl=en&cites=1433442328918110034'><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data.json&query=%24.publications.%5B%27XDljV4YAAAAJ%3AqjMakFHDy7sC%27%5D.num_citations&label=Citations&color=white&logo=Google%20Scholar&style=flat-square&labelColor=white" style="border: 1px solid #ccc; border-radius: 4px;"></a>
- [**CorpusLM: Towards a Unified Language Model on Corpus for Knowledge-intensive Tasks**](https://dl.acm.org/doi/abs/10.1145/3626772.3657778) \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> **<u>Xiaoxi Li</u>**, Zhicheng Dou, Yujia Zhou, Fangchao Liu.</span>\
<span style="font-size: 0.93em; "><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> **SIGIR 2024 <span style="color: #c00000;">(Oral)</span>**</span>\
<a href='https://scholar.google.com/scholar?oi=bibs&hl=en&cites=15744127386164548655,16522243399981860431'><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data.json&query=%24.publications.%5B%27XDljV4YAAAAJ%3AIjCSPb-OGe4C%27%5D.num_citations&label=Citations&color=white&logo=Google%20Scholar&style=flat-square&labelColor=white" style="border: 1px solid #ccc; border-radius: 4px;"></a>
- [**UniGen: A Unified Generative Framework for Retrieval and Question Answering with Large Language Models**](https://ojs.aaai.org/index.php/AAAI/article/download/28714/29380) \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> **<u>Xiaoxi Li</u>**, Yujia Zhou, Zhicheng Dou.</span>\
<span style="font-size: 0.93em; "><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> **AAAI 2024**</span>\
<a href='https://scholar.google.com/scholar?oi=bibs&hl=en&cites=5058310051629328060'><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data.json&query=%24.publications.%5B%27XDljV4YAAAAJ%3A9yKSN-GCB0IC%27%5D.num_citations&label=Citations&color=white&logo=Google%20Scholar&style=flat-square&labelColor=white" style="border: 1px solid #ccc; border-radius: 4px;"></a>
- [**Hierarchical Document Refinement for Long-context Retrieval-augmented Generation**](https://aclanthology.org/2025.acl-long.176/)  \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> Jiajie Jin, **<u>Xiaoxi Li</u>**, Guanting Dong, Yuyao Zhang, Yutao Zhu, <span class="author-more"><input type="checkbox" id="author-more-6" class="author-toggle"><label for="author-more-6" class="more-label">4 More Authors</label><label for="author-more-6" class="author-rest"> Yongkang Wu, Zhonghua Li, Qi Ye, and Zhicheng Dou.</label></span></span>\
<span style="font-size: 0.93em; "><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> **ACL 2025 Main <span style="color: #c00000;">(Oral)</span>**</span>\
<a href="https://github.com/ignorejjj/LongRefiner"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/ignorejjj/LongRefiner?style=flat-square&logo=github&logoColor=black&labelColor=white&color=white& label=Stars&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a>
- [**RAG-Critic: Leveraging Automated Critic-Guided Agentic Workflow for Retrieval Augmented Generation**](https://aclanthology.org/2025.acl-long.179/)  \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> Guanting Dong, Jiajie Jin, **<u>Xiaoxi Li</u>**, Yutao Zhu, Zhicheng Dou, <span class="author-more"><input type="checkbox" id="author-more-7" class="author-toggle"><label for="author-more-7" class="more-label">1 More Author</label><label for="author-more-7" class="author-rest"> Ji-Rong Wen.</label></span></span>\
<span style="font-size: 0.93em; "><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> **ACL 2025 Main**</span>
- [**Agentic Entropy-Balanced Policy Optimization**](https://arxiv.org/abs/2510.14545) \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> Guanting Dong, Licheng Bao, Zhongyuan Wang, Kangzhi Zhao, **<u>Xiaoxi Li</u>**, <span class="author-more"><input type="checkbox" id="author-more-8" class="author-toggle"><label for="author-more-8" class="more-label">9 More Authors</label><label for="author-more-8" class="author-rest"> Jiajie Jin, Jinghan Yang, Hangyu Mao, Fuzheng Zhang, Kun Gai, Guorui Zhou, Yutao Zhu, Ji-Rong Wen, and Zhicheng Dou.</label></span></span>\
<span style="font-size: 0.93em; "><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> **WWW 2026**</span>\
<a href="https://github.com/dongguanting/ARPO"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/dongguanting/ARPO?style=flat-square&logo=github&logoColor=black&labelColor=white&color=white&label=Stars&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a>
- [**HiRA: A Hierarchical Reasoning Framework for Decoupled Planning and Execution in Deep Search**](https://arxiv.org/abs/2507.02652) \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> Jiajie Jin, **<u>Xiaoxi Li</u>**, Guanting Dong, Yuyao Zhang, Yutao Zhu, <span class="author-more"><input type="checkbox" id="author-more-9" class="author-toggle"><label for="author-more-9" class="more-label">3 More Authors</label><label for="author-more-9" class="author-rest"> Yang Zhao, Hongjin Qian, and Zhicheng Dou.</label></span></span>\
<span style="font-size: 0.93em;"><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> Preprint. Under review.</span>\
<a href="https://github.com/ignorejjj/HiRA"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/RUC-NLPIR/HiRA?style=flat-square&logo=github&logoColor=black&labelColor=white&color=white&label=Stars&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a>
- [**Tool-Star: Empowering LLM-Brained Multi-Tool Reasoner via Reinforcement Learning**](https://arxiv.org/abs/2505.16410) \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> Guanting Dong, Yifei Chen, **<u>Xiaoxi Li</u>**, Jiajie Jin, Hongjin Qian, <span class="author-more"><input type="checkbox" id="author-more-10" class="author-toggle"><label for="author-more-10" class="more-label">5 More Authors</label><label for="author-more-10" class="author-rest"> Yutao Zhu, Hangyu Mao, Guorui Zhou, Zhicheng Dou, and Ji-Rong Wen.</label></span></span>\
<span style="font-size: 0.93em;"><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> Preprint. Under review.</span>\
<a href="https://github.com/dongguanting/Tool-Star"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/dongguanting/Tool-Star?style=flat-square&logo=github&logoColor=black&labelColor=white&color=white&label=Stars&cacheSeconds=10" style="border: 1px solid #ccc; border-radius: 4px;"></a> <a href='https://scholar.google.com/scholar?oi=bibs&hl=zh-CN&cites=11602636321899326654'><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data.json&query=%24.publications.%5B%27XDljV4YAAAAJ%3AhqOjcs7Dif8C%27%5D.num_citations&label=Citations&color=white&logo=Google%20Scholar&style=flat-square&labelColor=white" style="border: 1px solid #ccc; border-radius: 4px;"></a>


<!-- ## As a Co-author -->

<!-- - [**Neuro-Symbolic Query Compiler**](https://aclanthology.org/2025.findings-acl.628/)  \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> Yuyao Zhang, Zhicheng Dou, **Xiaoxi Li**, Jiajie Jin, Yongkang Wu, Zhonghua Li, Qi Ye, and Ji-Rong Wen.</span>\
<span style="font-size: 0.93em;"><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> **ACL 2025 Main (Findings)**</span>
- [**Descriptive and Discriminative Document Identifiers for Generative Retrieval**](https://doi.org/10.1609/aaai.v39i11.33253)  \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> Jiehan Cheng, Zhicheng Dou, Yutao Zhu, and **Xiaoxi Li**.</span>\
<span style="font-size: 0.93em;"><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> **AAAI 2025**</span>
- [**A Survey of Conversational Search**](https://arxiv.org/pdf/2410.15576) \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> Fengran Mo, Kelong Mao, Ziliang Zhao, Hongjin Qian, Haonan Chen, Yiruo Cheng, **Xiaoxi Li**, Yutao Zhu, Zhicheng Dou, and Jian-Yun Nie.</span>\
<span style="font-size: 0.93em;"><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> **TOIS 2025**</span>\
<a href='https://scholar.google.com/scholar?oi=bibs&hl=en&cites=645244174191248292'><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data.json&query=%24.publications.%5B%27XDljV4YAAAAJ%3AY0pCki6q_DkC%27%5D.num_citations&label=Citations&color=white&logo=Google%20Scholar&style=flat-square&labelColor=white" style="border: 1px solid #ccc; border-radius: 4px;"></a> -->

<!-- ### 2024
- [**Trustworthiness in retrieval-augmented generation systems: A survey**](https://arxiv.org/abs/2409.10102) \
<span style="font-size: 0.93em;"><img src="./images/logo-author.png" style="width: 1em; position: relative; top: -0.1em;"> Yujia Zhou, Yan Liu, **Xiaoxi Li**, Jiajie Jin, Hongjin Qian, Zheng Liu, Chaozhuo Li, Zhicheng Dou, Tsung-Yi Ho, Philip S Yu.</span>\
<span style="font-size: 0.93em;"><img src="./images/logo-venue.png" style="width: 0.975em; position: relative; top: -0.115em; margin-left: 0.005em;"> Preprint. Under review.</span>\
<a href='https://scholar.google.com/scholar?oi=bibs&hl=en&cites=8987613846345750009'><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FXiaoxi-Li1%2FXiaoxi-Li1.github.io%2Fgoogle-scholar-stats%2Fgs_data.json&query=%24.publications.%5B%27XDljV4YAAAAJ%3ATyk-4Ss8FVUC%27%5D.num_citations&label=Citations&color=white&logo=Google%20Scholar&style=flat-square&labelColor=white" style="border: 1px solid #ccc; border-radius: 4px;"></a> -->



# 💻 Experiences
- 2025.06 - Present | <img src="./images/xiaohongshu.png" style="width: 1em; position: relative; top: -0.1em; margin-left: 0.15em;"> Xiaohongshu, Central Platform Algorithm Team  
  Research Intern on Foundation Agents (<span style="color: #c00000;">**RedStar**</span> Program)  
  Mentors: Wenxiang Jiao, Yuan Lu
<!-- - 2025.06 - Present, <img src="./images/xiaohongshu.png" style="width: 1.8em; position: relative; top: -0.06em;"> <span style="color:#ff2442;">**REDstar**</span> Research Intern, Xiaohongshu Inc. <br> <span style="font-size: 0.93em; margin-left: 1.4em; display: inline-block; margin-top: 0.3em;">- Research Direction: Agentic AI, LLM Reasoning, Deep Research</span> -->
<!-- <span style="color:#ff2442;">**REDstar**</span> -->


# 📖 Educations
- 2023.09 - Present | <img src="./images/ruc_logo.png" style="width: 1em; position: relative; top: -0.1em; margin-left: 0.15em;"> Ph.D. in Artificial Intelligence  
  Gaoling School of Artificial Intelligence, Renmin University of China
- 2019.09 - 2023.06 | <img src="./images/nku_logo.png" style="width: 1em; position: relative; top: -0.1em; margin-left: 0.13em;"> B.Sc. in Intelligence Science and Technology  
  College of Artificial Intelligence, Nankai University
<img src="https://visitor-badge.laobi.icu/badge?page_id=https://xiaoxi-li1.github.io/" align="bottom" style="opacity: 0;"/>
<!-- <img src="https://visitor-badge.laobi.icu/badge?page_id=https://xiaoxi-li1.github.io/" align="bottom" style="opacity: 0;"/> -->

<!-- https://scholar.google.com/citations?user=XDljV4YAAAAJ -->
<!-- # Experiences
- *2021.12 - 2022.12*, Research Intern, Poisson Lab, Huawei <img src="./images/huawei.png" style="width: 4em;">. Supervised by [Xinyu Zhang](https://scholar.google.com/citations?user=W_WZEQEAAAAJ)
- *2018.8 - 2019.6*, Research Intern, XiaoIce, Microsoft Asia <img src="./images/microsoft.png" style="width: 4em;">. Supervised by [Ruihua Song](https://www.microsoft.com/en-us/research/people/rsong/)  
- *2016.9 - 2019.6*, Research Assistant, Beijing Key Lab of Big Data Management and Analysis Methods. Supervised by [Zhicheng Dou](http://playbigdata.ruc.edu.cn/dou) and [Ji-Rong Wen](https://scholar.google.com/citations?user=tbxCHJgAAAAJ)
- *2016.6 - 2016.9*, Software Engineer, Infosys Technology Limited <img src="./images/Infosys.png" style="width: 3em;">. Supervised by [Anjaneyulu Pasala](https://in.linkedin.com/in/anjaneyulupasala) -->

# 🎤 Invited Talks
- *2025.04*: "WebThinker: Empowering Large Reasoning Models with Deep Research Capability", MLNLP Community.


# 📚 Academic Services
<!-- - AC/SPC: ACL Rolling Review -->
- PC Member: ACL Rolling Review, ICML, ICLR, SIGIR, AAAI
- Journal Reviewer: Computing Surveys, TOIS


<hr style="margin-top: 2em;">

<div id="footer" style="text-align: center; font-size: 0.9em; color: #666;">
  <div id="footer-text"></div>

  &copy; 2025 Xiaoxi Li
  <!-- <br><br> -->

  <script type='text/javascript' id='clustrmaps' src='//cdn.clustrmaps.com/map_v2.js?cl=ffffff&w=0&t=m&d=jb32gKOvN2D_KtQxr8tDG9K_TxMJ3WoBGbSkT1RoI5A'></script>
</div>

<script async src="//busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js"></script>
