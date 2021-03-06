#!/bin/bash
# EMC2 build script for Ubuntu & Debian 9 v.3 (c) Decker (and webworker)
# modified for CHIPS by Duke Leto

berkeleydb() {
    CHIPS_ROOT=$(pwd)
    CHIPS_PREFIX="${CHIPS_ROOT}/db4"
    mkdir -p $CHIPS_PREFIX
    wget -N 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
    echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef db-4.8.30.NC.tar.gz' | sha256sum -c
    tar -xzvf db-4.8.30.NC.tar.gz
    if [ -f /etc/debian_version ]; then
        DEBIAN_VERSION=$(cat /etc/debian_version)
        DEBIAN_VERSION_10=${DEBIAN_VERSION%.*}
        if [ "$DEBIAN_VERSION_10" = "10" ] || [ "$DEBIAN_VERSION" = "bullseye/sid" ]; then
            #https://www.fsanmartin.co/compiling-berkeley-db-4-8-30-in-ubuntu-19/
            sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' db-4.8.30.NC/dbinc/atomic.h
        fi
    fi
    cd db-4.8.30.NC/build_unix/
    ../dist/configure -enable-cxx -disable-shared -with-pic -prefix=$CHIPS_PREFIX
    make install
    cd $CHIPS_ROOT
}

buildchips () {
    git pull
    make clean
    ./autogen.sh
    ./configure LDFLAGS="-L${CHIPS_PREFIX}/lib/" CPPFLAGS="-I${CHIPS_PREFIX}/include/" --with-gui=no --disable-tests --disable-bench --without-miniupnpc --enable-experimental-asm --enable-static --disable-shared
    make -j$(nproc)
}

berkeleydb
buildchips
echo "Done building CHIPS!"
