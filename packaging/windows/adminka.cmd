@echo off
setlocal DisableDelayedExpansion
set "RUBYOPT="
set "RUBYLIB="
set "GEM_HOME="
set "GEM_PATH="
"%~dp0runtime\bin\ruby.exe" -EUTF-8:UTF-8 "%~dp0adminka.rb" %*
exit /b %errorlevel%
