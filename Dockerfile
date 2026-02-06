FROM ubuntu:25.10 AS base

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config libproj-dev libgdal-dev libxerces-c-dev \
    build-essential cmake \
    ninja-build \
    ccache \
    && rm -rf /var/lib/apt/lists/*

COPY . /opt/micmac/
WORKDIR /opt/micmac/MMVII/build

ARG CMAKE_BUILD_TYPE=Release
ENV CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}

RUN cmake \
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
    -DCMAKE_CXX_COMPILER=g++ \
    -G Ninja \
    ..

CMD ["sleep", "infinity"]