FROM debian:bookworm-slim AS builder

RUN set -x \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates tzdata autoconf automake autotools-dev curl \
        python3 python3-pip python3-tomli libmpc-dev libmpfr-dev libgmp-dev \
        gawk build-essential bison flex texinfo gperf libtool patchutils bc \
        zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && echo 'Asia/Tokyo' > /etc/timezone

ENV BUILDDIR=/build
ENV RISCV=/opt/riscv

WORKDIR ${BUILDDIR}

RUN set -x \
    && mkdir riscv-gnu-toolchain \
    && cd riscv-gnu-toolchain \
    && git init \
    && git remote add origin https://github.com/riscv-collab/riscv-gnu-toolchain \
    && git fetch --depth 1 origin 6da3855437e8ab7a8272400287186d5242610172 \
    && git checkout FETCH_HEAD

WORKDIR ${BUILDDIR}/riscv-gnu-toolchain

# Our targets are unknown-linux-gnu-* and unknown-elf-*.
# `--disable-multilib` avoids the use of C extension.
RUN set -x \
    && mkdir build32 \
    && cd build32 \
    && ../configure \
        --prefix=${RISCV}/rv32 \
        --with-arch=rv32imafd_zifencei \
        --with-cmodel=medany \
        --disable-multilib \
    && make linux -j$(nproc) \
    && make       -j$(nproc) \
    && make install

RUN set -x \
    && mkdir build64 \
    && cd build64 \
    && ../configure \
        --prefix=${RISCV}/rv64 \
        --with-arch=rv64imafd_zifencei \
        --with-abi=lp64d \
        --with-cmodel=medany \
        --disable-multilib \
    && make linux -j$(nproc) \
    && make       -j$(nproc) \
    && make install


FROM debian:bookworm-slim

COPY --from=builder ${RISCV} ${RISCV}

ENV PATH=${RISCV}/rv32/bin:${RISCV}/rv64/bin:${PATH}
