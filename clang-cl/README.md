# Cross-compiling chemfiles for *-pc-windows-msvc ABI

This folder contains the code used to cross-compile chemfiles from Linux to one
of the `*-pc-windows-msvc` target, using
[clang-cl](https://clang.llvm.org/docs/MSVCCompatibility.html) as the
cross-compiler.

Step 1: build the core image, containing the compiler, CMake and the Windows SDK

```bash
docker -t clang-cl:x86_64-pc-windows-msvc clang-cl/x86_64-pc-windows-msvc

# on macOS with lima
lima nerdctl build --platform=amd64 -t clang-cl:x86_64-pc-windows-msvc clang-cl/x86_64-pc-windows-msvc
```

Step 2: build chemfiles

```bash
docker -t chemfiles-build --build-arg="TARGET=x86_64-pc-windows-msvc" clang-cl/chemfiles

# on macOS with lima & nerdctl
lima nerdctl build --platform=amd64 -t chemfiles-build --build-arg="TARGET=x86_64-pc-windows-msvc" clang-cl/chemfiles
```


Step 3: extract the resulting tarballs

```bash
mkdir products
docker run --rm -it -v$(pwd)/products:/output chemfiles-build

# on macOS with lima & nerdctl
mkdir products
lima nerdctl run --platform=amd64 --rm -it -v$(pwd)/products:/output chemfiles-build
```
