#!/bin/bash

# 测试所有图片 URL 是否可访问

echo "🔍 Testing all image URLs..."
echo ""

# 测试第三方服务 URL
urls=(
  "https://avatars.githubusercontent.com/u/251833761?v=4"
  "https://img.shields.io/github/followers/qingzhizhu517-rgb?label=Followers&style=social"
  "https://img.shields.io/github/stars/qingzhizhu517-rgb?label=Stars&style=social"
  "https://readme-typing-svg.herokuapp.com?color=%2336BCF7&center=true&vCenter=true&width=600&lines=test"
  "https://img.shields.io/badge/-Java-007396?style=flat&logo=openjdk&logoColor=white"
  "https://github-readme-stats.vercel.app/api?username=qingzhizhu517-rgb&show_icons=true&theme=radical"
  "https://github-readme-stats.vercel.app/api/top-langs/?username=qingzhizhu517-rgb&theme=radical&layout=compact"
  "https://github-readme-streak-stats.herokuapp.com/?user=qingzhizhu517-rgb&theme=radical"
  "https://github-profile-trophy.vercel.app/?username=qingzhizhu517-rgb&theme=radical"
  "https://github-readme-activity-graph.vercel.app/graph?username=qingzhizhu517-rgb&theme=redical"
  "https://profile-counter.glitch.me/qingzhizhu517-rgb/count.svg"
  "https://komarev.com/ghpvc/?username=qingzhizhu517-rgb&color=blue&style=flat"
  "https://api.star-history.com/svg?repos=qingzhizhu517-rgb/qingzhizhu517-rgb&type=Date"
)

for url in "${urls[@]}"; do
  # 提取域名
  domain=$(echo "$url" | awk -F/ '{print $3}')

  # 测试 URL
  if curl --output /dev/null --silent --head --fail "$url"; then
    echo "✅ $domain"
  else
    echo "❌ $domain - Failed to load"
  fi
done

echo ""
echo "📝 Note: Some URLs may return 404 if the GitHub Actions haven't been run yet."
echo "   This is normal for:"
echo "   - Contribution Snake (output branch)"
echo "   - GitHub Metrics (needs METRICS_TOKEN)"
echo "   - 3D Contribution Graph (needs GitHub Actions)"
echo ""
echo "🔗 Local files that should always work:"
echo "   - ./assets/wave.svg"
echo "   - ./profile-3d-contrib/profile-green-animate.svg"
echo "   - ./github-metrics.svg"