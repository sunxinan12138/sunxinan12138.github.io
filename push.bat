@echo off
@title push
@REM echo \&echo
:: 添加-提交-提交git的backup
cd /d %~dp0
git add -v .
git commit -m "auto 提交文件"
git push backup
:: 编译hexo 部署到git和gitee
pause