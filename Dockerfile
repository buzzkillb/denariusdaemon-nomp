FROM ubuntu:18.04 as builder
LABEL author="buzzkillb"
RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    automake \
    build-essential \
    libdb++-dev \
    libboost-all-dev \
    libqrencode-dev \
    libminiupnpc-dev \
    libevent-dev \
    autogen \
    automake \
    libtool \
    libcurl4-openssl-dev \
    make \
 && rm -rf /var/lib/apt/lists/*
RUN (wget https://www.openssl.org/source/openssl-1.0.1j.tar.gz && \
    tar -xzvf openssl-1.0.1j.tar.gz && \
    cd openssl-1.0.1j && \
    ./config && \
    make install && \
    ln -sf /usr/local/ssl/bin/openssl `which openssl` && \
    cd ~)
RUN (git clone https://github.com/carsenk/denarius && \
    cd denarius && \
    git checkout master && \
    git pull && \
    cd src && \
    OPENSSL_INCLUDE_PATH=/usr/local/ssl/include OPENSSL_LIB_PATH=/usr/local/ssl/lib make -f makefile.unix)

# final image
FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    automake \
    build-essential \
    libdb++-dev \
    libboost-all-dev \
    libqrencode-dev \
    libminiupnpc-dev \
    libevent-dev \
    libcurl4-openssl-dev \
    libtool \
 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/ssl/bin/openssl /usr/local/ssl/bin/openssl
RUN ln -sf /usr/local/ssl/bin/openssl `which openssl`
COPY --from=builder /denarius/src/denariusd /usr/local/bin/
EXPOSE 33369 9999 32369
CMD ["/bin/bash"]
