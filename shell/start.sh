#!/bin/bash
# 自动下载openapi
#[ ! -d /var/www/openapi.a.com ] && bash /shell/deploy.sh develop git@github.com:war1644/openapi.a.com.git openapi.a.com
# root 启动php-fpm
php-fpm7 -R
#
tail -f /dev/null