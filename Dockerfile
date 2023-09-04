FROM docker:20.10.6-dind

ENV KUBE_VERSION=v1.24.15
ENV CLUSTER_NAME=kind
ENV KUBECONFIG=/var/run/host.config

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
  apk update && \
  apk add curl bash

# add kind
RUN curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.19.0/kind-linux-amd64 && \
  chmod +x ./kind && \
  mv ./kind /usr/local/bin/kind
  
# add kubectl
RUN curl -Lo ./kubectl https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl && \
  chmod +x kubectl && \
  mv ./kubectl /usr/local/bin/ && \
  echo 'source <(kubectl completion bash)' >>  ~/.bashrc

WORKDIR /home/workspace

ADD hack hack
ADD config config

ENTRYPOINT ["dockerd-entrypoint.sh"]
