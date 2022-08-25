# Note that this script can accept some limited command-line arguments, run
# `julia build_static.jl --help` to see a usage message.
using BinaryBuilder, Pkg

include("config.jl")

# Collection of sources required to complete build
sources = [
    ArchiveSource("https://github.com/chemfiles/chemfiles/archive/$version.tar.gz", chemfiles_sha256),
    DirectorySource("./patches"),
]

# Bash recipe for building across all platforms
script = """
cd \${WORKSPACE}/srcdir/chemfiles-*/
atomic_patch -p1 ${WORKSPACE}/srcdir/arm-musl-endian-detect.patch

mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=\${prefix} \\
      -DCMAKE_TOOLCHAIN_FILE=\${CMAKE_TARGET_TOOLCHAIN} \\
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \\
      -DCMAKE_BUILD_TYPE=Release \\
      -DBUILD_SHARED_LIBS=$(BUILD_SHARED_LIBS ? "ON" : "OFF") \\
      ..
make -j\${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()
# Also build for M1 macs
push!(platforms, Platform("aarch64", "macos"))

# Build the tarballs
build_tarballs(
    ARGS,
    name,
    version,
    sources,
    script,
    platforms,
    Product[],
    Dependency[];
    verbose=true,
    julia_compat="1.6"
)

for path in readdir("products/")
    if BUILD_SHARED_LIBS && startswith(path, "Chemfiles.")
        new_path = replace(path, "Chemfiles." => "chemfiles-shared.")
    elseif !BUILD_SHARED_LIBS && startswith(path, "Chemfiles.")
        new_path = replace(path, "Chemfiles." => "chemfiles-static.")
    else
        continue
    end
    Base.Filesystem.mv(joinpath("products/", path), joinpath("products/", new_path))
end

println("====================================================\n")
println("Done builing chemfiles for all platforms,")
println("make sure to upload everything in products/")
