FROM registry.cn-beijing.aliyuncs.com/dxq_docker/nginx
LABEL author=ahmerry@qq.com

# PHP 镜像
RUN apk update && apk upgrade -a
RUN apk add --no-cache php7-fpm php7-common php7-pdo php7-pdo_mysql php7-curl php7-redis php7-gd php7-openssl php7-json php7-pear php7-phar php7-zip php7-zlib php7-iconv php7-posix php7-pcntl php7-mysqli php7-simplexml php7-dom php7-mbstring php7-xmlwriter php7-tokenizer php7-pecl-xdebug && \
# composer 中国镜像
    php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    # 设置中国镜像源
    composer config -g repo.packagist composer https://packagist.phpcomposer.com

#开放端口
EXPOSE 9000 9001
#外部配置
COPY php_config/conf /etc/php7/
COPY shell /shell

# 健康检查 --interval检查的间隔 超时timeout retries失败次数
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD ps -a | grep php || exit 1
# 启动
CMD ["/shell/start.sh"]
