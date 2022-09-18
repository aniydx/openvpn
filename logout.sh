#!/bin/sh
echo "`date '+%F %H:%M:%S'` User ${common_name} IP ${trusted_ip} is logged off" >> /etc/openvpn/`date '+%Y%m%d'`_logout.log

UserName=${common_name}
UserIPS=${trusted_ip}

url="https://oapi.dingtalk.com/robot/send?access_token=693ba78d9d1b62c04cfd60cd63a3b0c37478f98a9da0078e1eafd490942d6193"

curl -XPOST -s -L $url -H "Content-Type:application/json" -H "charset:utf-8"  -d "
    {
    \"msgtype\": \"text\", 
    \"text\": {
             \"content\": \"test OpenVPN下线提示: \n用户: ${UserName} 退出登录!!!\nIP: ${UserIPS}\"
             },
     'at': {
              'isAtAll': false
             }
}"
