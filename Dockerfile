FROM node:12 AS base

# Essentials
RUN apt-get update

ENV DEBIAN_FRONTEND=noninteractive
ENV INST apt-get install -y

RUN $INST build-essential
RUN $INST python3 python3-pip python3-dev
RUN $INST curl
RUN $INST git

# Prepare AppImage Stuff
WORKDIR /
ENV APPDIR /AppDir
RUN mkdir -p ${APPDIR}/usr

# Tool Dependencies
RUN $INST clang bison flex libreadline-dev gawk tcl-dev libffi-dev \
    graphviz xdot pkg-config libboost-all-dev zlib1g-dev \
    libftdi-dev qt5-default libeigen3-dev

RUN pip3 install cmake

# Yosys
RUN git clone https://github.com/yosyshq/yosys
WORKDIR /yosys
RUN git checkout d6d5c2ef342240bd8adb925055667d140cb8dd29
RUN make -j$(nproc)
RUN env PREFIX=${APPDIR}/usr make install
WORKDIR /

# Icestorm
RUN git clone https://github.com/yosyshq/icestorm
WORKDIR /icestorm
RUN git checkout c495861c19bd0976c88d4964f912abe76f3901c3
RUN make -j$(nproc)
RUN env PREFIX=${APPDIR}/usr make install
WORKDIR /

# NextPNR
RUN git clone https://github.com/yosyshq/nextpnr
WORKDIR /nextpnr
RUN git checkout 7b1df27c1a75c64e14e50d5f435287ca184425ab
RUN git submodule update --init
RUN cmake . -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=${APPDIR}/usr -DICESTORM_INSTALL_PREFIX=${APPDIR}/usr
RUN make -j$(nproc)
RUN env PREFIX=${APPDIR}/usr make install
WORKDIR /

#----
FROM base AS Tarball
RUN $INST pv
RUN tar -cf /icestorm.tar -C /AppDir ./usr
RUN pv -f /icestorm.tar | xz > icestorm.tar.xz
