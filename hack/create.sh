#!/bin/sh
DIR=$(cd "$(dirname "$0")";pwd)

CONFIG_FILE=${DIR}/../config/config.yaml
REGISTRY=registry.cn-hangzhou.aliyuncs.com/nfyxhan
docker login $REGISTRY
images=`cat ${CONFIG_FILE} | grep image | awk '{print $2}'`
for i in $images ; do
   docker pull $i
done

HOST_IP=`ip addr|grep eth0 | grep inet | awk '{print $2}'|awk -F '/' '{print $1}'`

sed -i s'#apiServerAddress.*#apiServerAddress: '${HOST_IP}'#'g ${CONFIG_FILE} 

kind create cluster --config ${CONFIG_FILE} \
   --kubeconfig="${KUBECONFIG}" $@

cat ${KUBECONFIG}
