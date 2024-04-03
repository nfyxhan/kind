#!/bin/sh
DIR=$(cd "$(dirname "$0")";pwd)

CLUSTER_NAME=${CLUSTER_NAME:-kind}
CONFIG_TEMPLATE=${DIR}/../config/config.yaml
CONFIG_FILE=${DIR}/../config/${CLUSTER_NAME}.yaml
cp -f ${CONFIG_TEMPLATE} ${CONFIG_FILE}
REGISTRY=registry.cn-hangzhou.aliyuncs.com

haslogin=""
if [[ -f "${HOME}/.docker/config.json" ]]; then
    haslogin=$(cat ${HOME}/.docker/config.json | grep ${REGISTRY})
fi
if [[ "${haslogin}" == "" ]]; then
    docker login ${REGISTRY}
fi

sed -i s'#kindest-node:.*#kindest-node:'${KINDEST_NODE_VERSION}'#'g ${CONFIG_FILE}

images=`cat ${CONFIG_FILE} | grep image | awk '{print $2}'`
for i in $images ; do
   docker pull $i
done

HOST_IP=$API_SERVER_ADDRESS
if [[ "$HOST_IP" == "" ]] ; then
   HOST_IP=`ip addr|grep eth0 | grep inet | awk '{print $2}'|awk -F '/' '{print $1}'`
fi

sed -i s'#apiServerAddress.*#apiServerAddress: '${HOST_IP}'#'g ${CONFIG_FILE} 

if [[ "$CLUSTER_NAME" != "" ]] ; then
    sed -i s'#name: .*#name: '${CLUSTER_NAME}'#'g ${CONFIG_FILE}
fi

if [[ "$APISERVER_PORT" != "" ]] ; then
    sed -i s'#apiServerPort.*#apiServerPort: '${APISERVER_PORT}'#'g ${CONFIG_FILE}
fi

kind create cluster --config ${CONFIG_FILE} \
   --kubeconfig="${KUBECONFIG}" $@

cat ${KUBECONFIG}
