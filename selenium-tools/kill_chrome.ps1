#@echo off

Write-Host "CAREFUL RUNNING THIS" -ForegroundColor red
Write-Host "               __   " -ForegroundColor red
Write-Host "              / _)  " -ForegroundColor red
Write-Host "     _.----._/ /    " -ForegroundColor red
Write-Host "    /         /     " -ForegroundColor red
Write-Host " __/ (  | (  |      " -ForegroundColor red
Write-Host "/__.-'|_|--|_|      " -ForegroundColor red


Write-Host "Be careful using this script. It will kill your chrome.exe process due to playwright using chrome.exe instead of chromedriver." -ForegroundColor red
Write-Host "if you want to maintain your chrome instances but just want to get rid of the message that brought you to this script." -ForegroundColor red
Write-Host "Instead run 'taskkill /im chromedriver.exe /f' OR run kill_chromedriver.bat instead" -ForegroundColor red
Write-Host "If yes: click type 'Y' or 'Yes'. If no then 'Ctrl + X' out of the script." -ForegroundColor red

Write-Host 'Press any key to continue...';
Write-Host 'To Cancel CTRL + X'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
#set /P id=Are you sure:
taskkill /im chromedriver.exe /f
taskkill /im chrome.exe /f

Write-Host 'All chromedriver.exe and chrome.exe have been killed' -ForegroundColor green