#########################################################################
# File Name: check_google.sh
# Author: Gaox
# Mail: gaox1993@mail.ustc.edu.cn
# Created Time: 2017年08月13日 星期日 15时29分31秒
# Version: 1.0
#########################################################################
#!/bin/bash

##############################################
#              Google Check                  #
##############################################
timeout=5
target=www.google.com.sg

# 检查是否安装curl
which curl > /dev/null 2>&1
if [ ! $? -eq 0  ]
then
sudo apt-get install curl
if [ $? -ne 0 ]
then
echo -e "\033[31m* Error notice:"
echo -e "    curl couldn't be installed. Please install it manually.\033[0m"
echo
exit 1
fi

clear
fi

OPT=true

while $OPT
do
  # 网络测试
  ret_code=`curl -I -s --connect-timeout $timeout $target -w %{http_code} | tail -n1`

  if [ $ret_code -ne 200 ]
  then
    NetWork=1  # network fail
    #notify-send ["Googlr Network"] "Google fail"
    zenity --error --timeout=30 --text "Google Failed."
  else
    notify-send ["Googlr Network"] "Google ok"
    #zenity --error --timeout=30 --text "Google OK."

  fi
  sleep 15
done
