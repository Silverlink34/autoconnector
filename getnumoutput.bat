@echo off
for /f "delims=1234567890:" %%p in ('findstr "1:" tmp\numberedlist') do echo %%p