#!/bin/bash
#部署日志
LOG_PATH=/var/log/deploy
[ ! -d "$LOG_PATH" ] && mkdir -p ${LOG_PATH}
NOW_DATE=`date "+%Y-%m-%d"`
LOG_NAME=${LOG_PATH}/${NOW_DATE}.log

date "+%Y-%m-%d %H:%M:%S">>${LOG_NAME}
echo "${USER}进入脚本" >> ${LOG_NAME}

# 一些环境变量的检测和设置
# 变量设置，后期可以外部扩展
GIT_BRANCH=$1
GIT_REPO=$2
GIT_REPO_NAME=$3
GIT_EMAIL="ahmerry@qq.com"
GIT_NAME="ahmerry"
RSA="-----BEGIN RSA PRIVATE KEY-----
-----END RSA PRIVATE KEY-----"
ALIYUN=""
RSA_PUB=""

[ -z "$WORKDIR" ] && WORKDIR=/var
[ -z "$WEB_DIR" ] && WEB_DIR=${WORKDIR}/www
[ -z "$IS_LOCAL" ] && IS_LOCAL=0
#开发环境，不再继续
[ "$IS_LOCAL" = 1 ] && exit 0
[ -z "$APP_DIR" ] && APP_DIR=${WEB_DIR}/"$GIT_REPO_NAME"
[ ! -d "$APP_DIR" ] && mkdir -p ${APP_DIR}
BRANCH_DIR=${APP_DIR}
#chown www.www ${APP_DIR} -R
#[ -z "$BRANCH_DIR" ] && BRANCH_DIR=${APP_DIR}/${GIT_BRANCH}
#echo "$BRANCH_DIR">>${LOG_NAME}

# 开始服务器部署逻辑
# 新机器初始化密钥
if [ ! -z "$RSA" ] && [ ! -f ~/.ssh/id_rsa ]; then
    echo "初始化机器">>${LOG_NAME}
    [ ! -d ~/.ssh ] && mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    #这里linux只需要私钥，而mac下需要公钥私钥
    #echo "$RSA_PUB" > ~/.ssh/id_rsa.pub
    echo "$RSA" > ~/.ssh/id_rsa
    echo "$ALIYUN" >> ~/.ssh/known_hosts
    chmod 644 ~/.ssh/*
    chmod 600 ~/.ssh/id_rsa

    [ ! -z "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL"
    [ ! -z "$GIT_NAME" ] && git config --global user.name "$GIT_NAME"
fi

# 更新代码
if [ ! -d "${BRANCH_DIR}/.git" ]; then
    #新部署
    echo "开始部署" >> ${LOG_NAME}
    if [ ! -z "$GIT_REPO" ]; then
        echo "开始克隆" >> ${LOG_NAME}
        if [ -z "$BRANCH_DIR" ]; then
            rm -rf ${BRANCH_DIR}/*
        fi
        cd ${BRANCH_DIR}
        # 很懵逼，为什么git clone的信息是在stderr里，而不是stdout
        LOG1=$(git clone -b ${GIT_BRANCH} ${GIT_REPO} ./ 2>&1)
        echo "$LOG1" >> ${LOG_NAME}
    fi
else
    #已部署过
    echo "开始更新" >> ${LOG_NAME}
    [ -z "$GIT_BRANCH" ] && GIT_BRANCH="develop"
    GIT_PULL_BRANCH="git pull origin ${GIT_BRANCH}"
    cd ${BRANCH_DIR}
    GIT_RESULT=`${GIT_PULL_BRANCH}`
    echo "$GIT_RESULT">>${LOG_NAME}
    # `echo ${#XX}`打印出XX的长度
    if [ 25 -eq `echo ${#GIT_RESULT}` ]; then
        git reset --hard HEAD
        "执行了reset">>${LOG_NAME}
        GIT_RESULT=`${GIT_PULL_BRANCH}`
        echo "$GIT_RESULT">>${LOG_NAME}
    fi
fi

echo -e "end\n" >> ${LOG_NAME}

#把目录归属
#chown www.www ${BRANCH_DIR} -R
