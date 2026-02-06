FROM ubuntu:22.04 AS base

ARG MICMAC_DIR=/opt/micmac
ENV MICMAC_DIR=${MICMAC_DIR}

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config libproj-dev libgdal-dev libxerces-c-dev \
    build-essential cmake \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="${MICMAC_DIR}/MMVII/bin:$PATH"

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

COPY . ${MICMAC_DIR}/
WORKDIR ${MICMAC_DIR}/MMVII/build

RUN cmake \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_BUILD_TYPE=Debug \
    -G Ninja \
    -DvMMVII_BUILD=ON \
    ..

RUN cmake --build . -j$(nproc) --target rebuild 

WORKDIR ${MICMAC_DIR}/MMVII/
RUN doxygen Doxyfile

CMD ["sleep", "infinity"]

FROM base AS release

COPY . ${MICMAC_DIR}/
WORKDIR ${MICMAC_DIR}/MMVII/build

RUN cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=g++ \
    -G Ninja \
    ..

RUN cmake --build . -j$(nproc) -v

CMD ["sleep", "infinity"]