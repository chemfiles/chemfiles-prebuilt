using SHA

include("config.jl")

# BinaryBuilder => Rust target triple name matching
RUST_TRIPLES = Dict(
    "i686-linux-gnu" => "i686-unknown-linux-gnu",
    "x86_64-linux-gnu" => "x86_64-unknown-linux-gnu",
    "aarch64-linux-gnu" => "aarch64-unknown-linux-gnu",
    "armv7l-linux-gnueabihf" => "armv7-unknown-linux-gnueabihf",
    "powerpc64le-linux-gnu" => "powerpc64le-unknown-linux-gnu",
    "i686-linux-musl" => "i686-unknown-linux-musl",
    "x86_64-linux-musl" => "x86_64-unknown-linux-musl",
    "aarch64-linux-musl" => "aarch64-unknown-linux-musl" ,
    "armv7l-linux-musleabihf" => "armv7-unknown-linux-musleabihf",
    "x86_64-apple-darwin" => "x86_64-apple-darwin",
    "aarch64-apple-darwin" => "aarch64-apple-darwin",
    "x86_64-unknown-freebsd" => "x86_64-unknown-freebsd",
    "i686-w64-mingw32" => "i686-pc-windows-gnu",
    "x86_64-w64-mingw32" => "x86_64-pc-windows-gnu",
)

prebuilt = []
prefix = "chemfiles-static.v$version."
suffix = ".tar.gz"
for path in readdir("products/")
    if !startswith(path, "chemfiles-static")
        continue
    end

    julia_triple = path[length(prefix) + 1:end - length(suffix)]

    fd = open(joinpath("products/", path))
    sha = bytes2hex(sha256(fd))
    close(fd)

    push!(prebuilt, (RUST_TRIPLES[julia_triple], julia_triple, sha))
end

open("prebuilt.rs", "w") do fd
    println(fd, "/// Get the julia triple & sha256 corresponding to the prebuilt libchemfiles")
    println(fd, "/// for a given rust triple, if it exists")
    println(fd, "pub fn get_prebuilt_info(target: &str) -> Option<(&'static str, &'static str)> {")
    println(fd, "    match target {")
    for (rust_triple, julia_triple, sha) in prebuilt
        println(fd, "        \"$rust_triple\" => Some((\"$julia_triple\", \"$sha\")),")
    end
    println(fd, "        _ => None,")
    println(fd, "    }")
    println(fd, "}")
end

println("====================================================\n")
println("Done generating prebuilt.rs")
