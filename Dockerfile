FROM docker:20.10.6-dind
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
  apk update && \
  apk add curl
RUN curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.14.0/kind-linux-amd64 && \
  chmod +x ./kind && \
  mv ./kind /usr/local/bin/kind

ENV CLUSTER_NAME=kind
ENV KUBECONFIG=/var/run/host.config

ADD hack .
ADD config .

ENTRYPOINT dockerd
