FROM debian:stable

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update \ 
    && apt-get -y upgrade \
    && apt -y --no-install-recommends install curl wget unzip git tar bash lsof software-properties-common ca-certificates openssl figlet \
    && useradd -ms /bin/bash container

WORKDIR /opt

RUN curl \
    -L \
    -o openjdk.tar.gz \
    https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz \
    && mkdir jdk \
    && tar zxf openjdk.tar.gz -C jdk --strip-components=1 \
    && rm -rf openjdk.tar.gz \
    && ln -sf /opt/jdk/bin/* /usr/local/bin/ \
    && rm -rf /var/lib/apt/lists/*

USER container
ENV  USER=container HOME=/home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh
COPY ./install.sh /install.sh

CMD ["/bin/bash", "/entrypoint.sh"]
