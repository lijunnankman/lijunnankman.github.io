# 个人主页编辑与发布

本机源码目录：`E:\person\_page`。请在这里修改和运行脚本。

本项目基于 [xi-xiaoran.github.io](https://github.com/xi-xiaoran/xi-xiaoran.github.io) 的页面结构改造，保留原项目的 [MIT 许可证](LICENSE)。页面已调整为以实习经历和项目为主，并预留 1 篇已录用、2 篇在投论文的位置。所有示例内容都需要由你手动替换或删除。

## 修改内容

用 VS Code 打开这个文件夹，主要编辑以下文件：

| 文件 | 填写内容 |
| --- | --- |
| `_config.yml` | 网页标题（姓名）和一句简介；`url` 已设置为你的 GitHub Pages 地址 |
| `_data/profile.yml` | 身份、机构、城市、邮箱、社交链接、头像和简历路径 |
| `_data/home_industry.yml` | 实习或工作经历；复制一个 `- start:` 区块可增加一段经历 |
| `_data/home_projects.yml` | 项目；复制一个 `- title:` 区块可增加一个项目 |
| `_data/home_publications.yml` | 论文；保留真实的 1 篇已录用和 2 篇在投，按实际情况增删 |
| `_data/home_academic.yml` | 教育背景 |
| `_data/navigation.yml` | 顶部导航的名称和顺序 |

数据文件使用 YAML 格式。缩进请用空格，不要用 Tab；含有冒号的句子请放在英文双引号里。可将不想展示的项目从 `items:` 下删除，并保留 `items: []`。空链接请写成 `""`，页面会自动隐藏按钮。网页源代码通常不用修改。

头像可替换 `images/avatar.svg`，也可以在 `images/` 放一张自己的照片，然后修改 `_data/profile.yml` 中的 `avatar`，例如 `"/images/me.jpg"`。简历 PDF 放在 `files/`，并将 `cv` 改成 `"/files/resume.pdf"`。单位标志或论文配图也可以放在 `images/`，再填写对应的 `company_logo`、`logo`、`school_logo` 或 `figure` 路径；不需要图片就留空。

论文的 `status` 可以填写 `"Accepted"` 或 `"Under Review"`。在投论文的 `venue` 建议留空，等有正式结果再填。只有公开可访问的论文或代码才填写 `paper_link`、`code_link`。

## 本地预览

双击 **`Preview.cmd`**，浏览器会打开 `http://127.0.0.1:4000/`。编辑 YAML 后刷新网页即可看到更新。预览窗口保持打开；按 `Ctrl+C` 可停止。本机已安装 Jekyll，站点已通过构建检查。

## 一键上传

1. 可以先直接发布当前占位内容，之后再逐步替换。每次上传的内容都会公开显示。
2. 双击 **`Publish.cmd`**。首次运行会打开浏览器，让你登录 GitHub；请使用 `lijunnankman` 账号。
3. 脚本会自动构建站点、提交文件、创建公开仓库 `lijunnankman/lijunnankman.github.io`（如果还没有）、推送 `main` 分支，并启用 GitHub Pages。
4. 稍等几分钟，访问 <https://lijunnankman.github.io/>。以后每次修改完，再双击 `Publish.cmd` 即可更新。

如果发布中途报错，窗口会保留错误信息；按提示修正后重新双击即可。GitHub 仓库会公开，所以不要把未公开的论文稿件、私人文件或密钥放进此文件夹。

`.gitignore` 已排除 Jekyll 生成的 `_site/`、缓存、依赖、编辑器临时文件、系统文件和本地 `.env` 文件。`_data/`、`assets/`、`images/`、`files/` 等网页需要的内容会照常上传。
