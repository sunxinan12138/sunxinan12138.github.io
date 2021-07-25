---
title: 我的hexo博客搭建配置更改
author: 熙男
date: 2021-07-25 17:25:08
categories:
tags:
---

# 从0开始搭建hexo博客(win10)

## 基本安装

> 安装node.js [Node.js官网下载地址](https://nodejs.org/en/)
>
> 安装git [git官方下载地址](https://git-scm.com/downloads)
>
> 在git/gitee 新建库并且以你的名字命名 git:yourName.github.io gitee:yourName
>
> 安装hexo$ npm install -g hexo-cli win会有警告 忽略就好
>
> 新建: (**找到你的文件夹**)执行 hexo init $ cd $ npm install
>
> 配置:
>
> > 可以参考 [这里](https://hexo.io/zh-cn/docs/configuration)
> >
> > 
> >
> > 
> >
> > ```
> > 建议配置:
> > **url**: https://gitee.com/xxx/xxx.git 你的博客访问地址
> > **per_page**:改为6的倍数 6,12,18
> >  **# Site** 此处 有更多关于首页配置
> > **title**: 博客名字
> > ```

hexo的目录配置





markdown

```markdown
|-- demo//项目跟目录名
    |-- .gitignore//git时忽略的文件或目录
    |-- package-lock.json
    |-- package.json//应用程序的信息
    |-- _config.yml//网站的配置信息
    |-- scaffolds//模板文件夹，Hexo的模板是指在新建的markdown文件中默认填充的内容。
    |   |-- draft.md
    |   |-- page.md
    |   |-- post.md//博文模板
    |-- source//资源文件夹，存放用户资源
    |   |-- _posts//博文目录
    |       |-- hello-world.md//博文
    |-- themes//主题文件夹，Hexo 会根据主题来生成静态页面
        |-- landscape.//默认主题
```

## 配置git和gitee库

1. 首先你要有这两个仓库

2. 修改[^ _config.yml ] 此文件的配置

   

   

   ```
   deploy:
   type: 'git'
   repo:
      github: https://github.com/xxxx/xxxx.github.io.git
      gitee: https://gitee.com/xxxx/xxxx.git
   branch: master
   ```

3. 在执行 hexo d 就能在你的链接访问啦

4. 提示

   ：gitee要启动一下gitee Pages

   自你的库-服务- gitee pages

   每次更新后要重新更新一下gitee Pages

   ## 基本语句

   - 执行 hexo server == hexo s 默认为 http://localhost:4000/
   - - -p 选项，指定服务器端口，默认为 4000
   - - -i 选项，指定服务器 IP 地址，默认为 0.0.0.0
   - - -s 选项，静态模式 ，仅提供 public 文件夹中的文件并禁用文件监视
   - hexo generate 命令用于生成静态文件，一般可以简写为 hexo g
   - hexo d 发布到 git/gitee库
   - **说明** ：部署前需要修改 _config.yml 配置文件，下面以 git/gitee 为例进行
   - hexo clean 命令用于清理缓存文件，是一个比较常用的命令
   - 根目录命令行输入hexo new <模板> <文章名> 新建博客
   - 末班在scaffold文件夹下

| 参数  | 功能                         | 路径             |
| :---- | :--------------------------- | :--------------- |
| post  | 新建文章                     | /source/_posts/  |
| draft | 新建草稿                     | /source/_drafts/ |
| page  | 新建页面（标签页，分类页等） | /source/         |

## 主题安装配置

有很多优秀好看的主题 next等 不想折腾就用next吧 用的多排坑的也多

我的是Matery 我的主页下方有下载地址[^ Theme Matery ] 或者戳[这里](https://github.com/blinkfox/hexo-theme-matery)

(下载的主题有说明文档)😜

## 其他
