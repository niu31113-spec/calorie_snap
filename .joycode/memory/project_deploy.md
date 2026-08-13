---
name: 公网部署方式(GitHub Pages)
description: '热量拍 calorie_snap 已部署到 GitHub Pages 公网,自动化流程与访问地址'
type: project
---

热量拍(calorie_snap)已成功部署到 GitHub Pages 公网,电脑和手机浏览器均可访问。

**关键事实:**
- GitHub 仓库: niu31113-spec/calorie_snap (Public), 用户名 niu31113-spec
- 公网访问地址: https://niu31113-spec.github.io/calorie_snap/ (永久在线,无需开本地电脑)
- 部署方式: GitHub Actions 自动构建(.github/workflows/deploy.yml),push 到 main 分支即自动编译 Flutter Web 并发布
- 构建参数: flutter build web --release --base-href "/calorie_snap/" (base-href 必须与仓库名一致,否则白屏/404)
- Pages 来源(Source)已设为 GitHub Actions

**How to apply:** 后续改代码只需 git push origin main,GitHub 自动重新构建部署,约2~4分钟生效。手机若白屏用无痕模式绕缓存。