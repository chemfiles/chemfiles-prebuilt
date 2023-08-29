# Docker image to cross-compiler chemfiles to x86_64-pc-windows-msvc using
# clang-cl as the compiler.
#
# Inspired by https://jake-shadle.github.io/xwin/, but without the Rust part
FROM docker.io/library/ubuntu:20.04

RUN apt-get update && apt-get install -y curl gnupg2 tar patch

# add cmake APT
RUN set -eux; \
    curl --fail https://apt.kitware.com/keys/kitware-archive-latest.asc | apt-key add -; \
    echo 'deb https://apt.kitware.com/ubuntu/ focal main' > /etc/apt/sources.list.d/kitware.list; \
    apt-get update && apt-get install -y cmake

# add llvm APT
RUN set -eux; \
    curl --fail https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -; \
    echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-16 main" > /etc/apt/sources.list.d/llvm.list

# Install llvm
RUN set -eux; \
    # Skipping all of the "recommended" cruft reduces total images size by ~300MiB
    apt-get update && apt-get install --no-install-recommends -y clang-16 llvm-16 lld-16; \
    ln -s clang-16 /usr/bin/clang; \
    ln -s clang /usr/bin/clang++; \
    ln -s clang-16 /usr/bin/clang-cl; \
    ln -s llvm-ar-16 /usr/bin/llvm-lib


# Download Windows SDK
ENV XWIN_ACCEPT_LICENSE=true
RUN set -eux; \
    xwin_version="0.2.14"; \
    xwin_prefix="xwin-$xwin_version-x86_64-unknown-linux-musl"; \
    curl --fail -L https://github.com/Jake-Shadle/xwin/releases/download/$xwin_version/$xwin_prefix.tar.gz | tar -C /bin -xzv --strip-components=1 $xwin_prefix/xwin; \
    xwin --arch x86_64 -L debug unpack; \
    xwin --arch x86_64 -L debug splat --output /xwin; \
    rm -rf .xwin-cache /bin/xwin


COPY Windows-Clang-cl.toolchain.cmake .
ENV CMAKE_TOOLCHAIN_FILE=/Windows-Clang-cl.toolchain.cmake
