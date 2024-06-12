FROM docker:20.10.6-dind

arg KINDEST_NODE_VERSION

ENV KINDEST_NODE_VERSION=${KINDEST_NODE_VERSION}
ENV KUBE_VERSION=v1.26.11
ENV CLUSTER_NAME=kind
ENV KUBECONFIG=/var/run/host.config

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
  apk update && \
  apk add curl bash

ADD ./hack/env.sh ./env.sh

# add kind
RUN . ./env.sh && \
  curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.17.0/kind-linux-${RUN_PLATFORM} && \
  chmod +x ./kind && \
  mv ./kind /usr/local/bin/kind
  
# add kubectl
RUN . ./env.sh && \
  curl -Lo ./kubectl https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${RUN_PLATFORM}/kubectl && \
  chmod +x kubectl && \
  mv ./kubectl /usr/local/bin/ && \
  echo 'source <(kubectl completion bash)' >>  ~/.bashrc

WORKDIR /home/workspace

ADD hack hack
ADD config config

ENTRYPOINT ["dockerd-entrypoint.sh"]
