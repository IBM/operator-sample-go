FROM docker.io/ubuntu:22.04

RUN apt-get update -qq \
    && apt-get --assume-yes install buildah \
    && apt-get --assume-yes install iptables

# Java
# *********** default-jdk -> openjdk-11-jdk ***************
RUN apt update \
    && apt-get --assume-yes install default-jdk

# *********** Basic tools *************** 
RUN apt-get update \
    && apt-get --assume-yes install curl \
    && apt-get --assume-yes install git-core \
    && apt-get --assume-yes install wget \
    && apt-get --assume-yes install gnupg2 \
    && apt-get --assume-yes install nano \
    && apt-get --assume-yes install apt-utils \
    && apt-get --assume-yes install unzip \
    && apt-get --assume-yes install zip \
    && apt-get --assume-yes install sed \
    && apt-get --assume-yes install jq 
ARG DEBIAN_FRONTEND="noninteractive"
RUN apt-get --assume-yes install postgresql \
    && apt-get --assume-yes install postgresql-contrib \
    && apt-get --assume-yes install original-awk

# Kubernetes
# *********** Kubernetes ***************
RUN apt-get update && apt-get install -y apt-transport-https \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get --assume-yes install kubectl

# *********** IBM Cloud CLI *********** 
RUN  curl -fsSL https://clis.cloud.ibm.com/install/linux | sh \
     && ibmcloud plugin install container-service \
     && ibmcloud plugin install container-registry \
     && ibmcloud plugin install code-engine \
     && ibmcloud plugin install cloud-databases

# *********** operator sdk and go *************** 
RUN mkdir operator-sdk-install
WORKDIR operator-sdk-install
RUN export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac) \
    && export OS=$(uname | awk '{print tolower($0)}') \
    && export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/v1.19.1 \
    && curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH} \
    && chmod +x operator-sdk_${OS}_${ARCH} && mv operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk \

RUN && apt-get --assume-yes install golang \
# RUN curl -LO wget https://golang.org/dl/go1.17.6.linux-amd64.tar.gz \
#     && tar -xzf go1.17.6.linux-amd64.tar.gz -C /usr/local/ \
#     && mv go /usr/local
# installer -pkg go1.17.6.darwin-amd64.pkg -target \
#     && go version \
#    && operator-sdk version

