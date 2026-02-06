FROM ubuntu:22.04 AS base

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config libproj-dev libgdal-dev libxerces-c-dev \
    build-essential cmake \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/micmac/MMVII/bin:$PATH"

FROM base AS debug

RUN apt-get update && apt-get install -y --no-install-recommends \ 
    bash-completion \    
    ccache \
    doxygen \
    gdb \
    git \
    python-is-python3 \
    qtbase5-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . /opt/micmac/
WORKDIR /opt/micmac/MMVII/build

RUN cmake \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_BUILD_TYPE=Debug \
    -G Ninja \
    -DvMMVII_BUILD=ON \
    ..

RUN cmake --build . -j$(nproc) --target rebuild 

WORKDIR /opt/micmac/MMVII/
RUN doxygen Doxyfile

CMD ["sleep", "infinity"]

FROM base AS release

COPY . /opt/micmac/
WORKDIR /opt/micmac/MMVII/build

RUN cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=g++ \
    -G Ninja \
    ..

RUN cmake --build . -j$(nproc) -v

CMD ["sleep", "infinity"]