FROM ubuntu:22.04 AS base

ARG MICMAC_DIR=/opt/micmac
ENV MICMAC_DIR=${MICMAC_DIR}

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config libproj-dev libgdal-dev libxerces-c-dev \
    build-essential cmake \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="${MICMAC_DIR}/MMVII/bin:$PATH"

FROM base AS dev

RUN apt-get update && apt-get install -y --no-install-recommends \ 
    bash-completion \    
    ccache \
    doxygen \
    gdb \
    git \
    graphviz \
    python-is-python3 \
    qtbase5-dev \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apt-get update && apt-get install -y --no-install-recommends sudo \
    && groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]

FROM dev AS debug

COPY . ${MICMAC_DIR}/
WORKDIR ${MICMAC_DIR}/MMVII/build

# prepare and compile
RUN cmake \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_BUILD_TYPE=Debug \
    -G Ninja \
    -DvMMVII_BUILD=ON \
    ..

RUN cmake --build . -j$(nproc) --target rebuild

# HTML docs
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

RUN cmake --build . -j$(nproc) --target rebuild

CMD ["sleep", "infinity"]