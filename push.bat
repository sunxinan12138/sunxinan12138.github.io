@echo off
@title push
@REM echo \&echo
:: 添加-提交-提交git的backup
cd /d %~dp0
git add -v .
git commit -m "auto push File"
git push origin backup
:: 编译hexo 部署到git和gitee
@REM hexo g
@REM hexo s
pause