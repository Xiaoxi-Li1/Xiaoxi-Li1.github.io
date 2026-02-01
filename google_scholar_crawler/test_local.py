"""
本地测试脚本 - 用于测试生成包含 first_author_citations 和 github_stars 的数据
"""
import json
import requests
import os

def calculate_first_author_citations(publications):
    """计算一作论文的总引用"""
    first_author_ids = [
        'XDljV4YAAAAJ:YsMSGLbcyi4C',  # Search-o1
        'XDljV4YAAAAJ:qjMakFHDy7sC',  # From Matching to Generation
        'XDljV4YAAAAJ:LkGwnXOMwfcC',  # WebThinker
        'XDljV4YAAAAJ:W7OEmFMy1HYC',  # RetroLLM
        'XDljV4YAAAAJ:IjCSPb-OGe4C',  # CorpusLM
        'XDljV4YAAAAJ:9yKSN-GCB0IC',  # UniGen
        'XDljV4YAAAAJ:QIV2ME_5wuYC',  # DeepAgent
    ]
    
    total = 0
    for pub_id in first_author_ids:
        if pub_id in publications:
            citations = publications[pub_id].get('num_citations', 0)
            total += citations
            print(f"  {pub_id}: {citations} citations")
    
    return total

def get_github_stars(username='sunnynexus'):
    """获取GitHub总星数"""
    try:
        headers = {}
        github_token = os.environ.get('GITHUB_TOKEN', '')
        if github_token:
            headers['Authorization'] = f'token {github_token}'
        
        repos_url = f'https://api.github.com/users/{username}/repos?per_page=100'
        response = requests.get(repos_url, headers=headers)
        
        if response.status_code == 200:
            repos = response.json()
            total_stars = 0
            
            print(f"\n仓库星标统计:")
            for repo in repos:
                stars = repo.get('stargazers_count', 0)
                if stars > 0:  # 只显示有星标的仓库
                    print(f"  {repo['name']}: {stars} stars")
                total_stars += stars
            
            # 处理分页（如果有超过100个仓库）
            page = 2
            while len(repos) == 100:
                response = requests.get(f'{repos_url}&page={page}', headers=headers)
                if response.status_code == 200:
                    new_repos = response.json()
                    if not new_repos:
                        break
                    repos.extend(new_repos)
                    for repo in new_repos:
                        stars = repo.get('stargazers_count', 0)
                        if stars > 0:
                            print(f"  {repo['name']}: {stars} stars")
                        total_stars += stars
                    page += 1
                else:
                    break
            
            return total_stars
        else:
            print(f"Failed to fetch GitHub data: {response.status_code}")
            return 0
    except Exception as e:
        print(f"Error: {e}")
        return 0

if __name__ == '__main__':
    # 从用户提供的示例数据中读取
    print("=" * 60)
    print("测试计算一作引用和GitHub星数")
    print("=" * 60)
    
    # 示例数据（来自用户提供的JSON）
    sample_publications = {
        "XDljV4YAAAAJ:YsMSGLbcyi4C": {"num_citations": 322},  # Search-o1
        "XDljV4YAAAAJ:qjMakFHDy7sC": {"num_citations": 173},  # Survey
        "XDljV4YAAAAJ:LkGwnXOMwfcC": {"num_citations": 170},  # WebThinker
        "XDljV4YAAAAJ:W7OEmFMy1HYC": {"num_citations": 18},   # RetroLLM
        "XDljV4YAAAAJ:IjCSPb-OGe4C": {"num_citations": 35},   # CorpusLM
        "XDljV4YAAAAJ:9yKSN-GCB0IC": {"num_citations": 49},   # UniGen
        "XDljV4YAAAAJ:QIV2ME_5wuYC": {"num_citations": 12},   # DeepAgent
    }
    
    print("\n1. 计算一作论文引用:")
    first_author_cites = calculate_first_author_citations(sample_publications)
    print(f"\n一作论文总引用: {first_author_cites}")
    
    print("\n2. 获取GitHub总星数:")
    github_stars = get_github_stars('sunnynexus')
    print(f"\nGitHub总星数: {github_stars}")
    
    print("\n" + "=" * 60)
    print("生成测试数据文件...")
    
    # 生成测试数据
    test_data = {
        "citedby": 1163,
        "first_author_citations": first_author_cites,
        "github_stars": github_stars,
        "publications": sample_publications,
    }
    
    os.makedirs('results', exist_ok=True)
    with open('results/gs_data_test.json', 'w', encoding='utf-8') as f:
        json.dump(test_data, f, ensure_ascii=False, indent=2)
    
    print(f"测试数据已保存到: results/gs_data_test.json")
    print("\n你可以手动将此文件推送到 google-scholar-stats 分支来测试效果")
    print("=" * 60)

