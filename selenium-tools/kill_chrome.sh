#!/bin/bash

echo -e "\033[31mCAREFUL RUNNING THIS\033[0m"
echo -e "\033[31m               __   \033[0m"
echo -e "\033[31m              / _)  \033[0m"
echo -e "\033[31m     _.----._/ /    \033[0m"
echo -e "\033[31m    /         /     \033[0m"
echo -e "\033[31m __/ (  | (  |      \033[0m"
echo -e "\033[31m/__.-'|_|--|_|      \033[0m"

echo -e "\033[31mBe careful using this script. It will kill your chrome process due to Playwright using chrome instead of chromedriver.\033[0m"
echo -e "\033[31mIf you want to maintain your chrome instances but just want to get rid of the message that brought you to this script,\033[0m"
echo -e "\033[31minstead run 'pkill chromedriver' OR run kill_chromedriver.sh instead.\033[0m"
echo -e "\033[31mIf yes: type 'Y' or 'Yes'. If no then press 'Ctrl + C' to exit the script.\033[0m"

read -n 1 -s -r -p $'Press any key to continue...\nTo Cancel press CTRL + C\n'

pkill -f chromedriver
pkill -f chrome

echo -e "\033[32mAll chromedriver and chrome processes have been killed\033[0m"
