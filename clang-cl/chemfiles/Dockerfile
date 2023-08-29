ARG TARGET=x86_64-pc-windows-msvc
FROM clang-cl:$TARGET

ARG TARGET
ENV TARGET=$TARGET

ENV CHEMFILES_VERSION=0.10.4

ENV SHARED_INSTALL_DIR=/chemfiles-shared.v$CHEMFILES_VERSION.$TARGET
ENV STATIC_INSTALL_DIR=/chemfiles-static.v$CHEMFILES_VERSION.$TARGET


RUN curl --fail -L https://github.com/chemfiles/chemfiles/releases/download/$CHEMFILES_VERSION/chemfiles-$CHEMFILES_VERSION.tar.gz | tar -xzv

# configure the build for the shared version of the libraries
RUN set -eux; \
    cd chemfiles-$CHEMFILES_VERSION; \
    cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$SHARED_INSTALL_DIR \
        -DBUILD_SHARED_LIBS=ON .

# we can only patch after configuring the build, since the file is stored inside
# a tarball
COPY lzma_tuklib_integer.patch .

# Patch the code & run the build
RUN set -eux; \
    cd chemfiles-$CHEMFILES_VERSION; \
    patch -p1 /lzma_tuklib_integer.patch; \
    cmake --build . --config Release --parallel 4 --target install

# also include the license file, similar to whatr BinaryBuilder.jl does
RUN set -eux; \
    mkdir -p $SHARED_INSTALL_DIR/share/licenses/Chemfiles; \
    cp chemfiles-$CHEMFILES_VERSION/LICENSE $SHARED_INSTALL_DIR/share/licenses/Chemfiles/

# create the tarball for the shared build
RUN set -eux; \
    find $SHARED_INSTALL_DIR -printf "%P\n" | tar cf $SHARED_INSTALL_DIR.tar --no-recursion -C $SHARED_INSTALL_DIR -T - ; \
    gzip -9 $SHARED_INSTALL_DIR.tar

# ============================================================================ #

# Build the static version of the libraries
RUN set -eux; \
    cd chemfiles-$CHEMFILES_VERSION; \
    cmake -DCMAKE_INSTALL_PREFIX=$STATIC_INSTALL_DIR \
          -DBUILD_SHARED_LIBS=OFF .; \
    cmake --build . --config Release --parallel 4 --target install

RUN set -eux; \
    mkdir -p $STATIC_INSTALL_DIR/share/licenses/Chemfiles; \
    cp chemfiles-$CHEMFILES_VERSION/LICENSE $STATIC_INSTALL_DIR/share/licenses/Chemfiles/

# create the tarball for the static build
RUN set -eux; \
    find $STATIC_INSTALL_DIR -printf "%P\n" | tar cf $STATIC_INSTALL_DIR.tar --no-recursion -C $STATIC_INSTALL_DIR -T - ; \
    gzip -9 $STATIC_INSTALL_DIR.tar

# ============================================================================ #

CMD cp $SHARED_INSTALL_DIR.tar.gz $STATIC_INSTALL_DIR.tar.gz /output
