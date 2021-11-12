# Prebuilt versions of chemfiles library

This repository contains the code required to create the pre-built distributions
of the chemfiles library, using [BinaryBuilder](https://docs.binarybuilder.org/).

## Usage

Install a recent version of Julia, then install BinaryBuilder with `julia -e
'using Pkg; Pkg.add("BinaryBuilder")'`. Then you can run the different scripts
in this repo:

```bash
# Build chemfiles as a static library
julia build-static.jl
# Build chemfiles as a shared library
julia build-shared.jl

# Generate the code used by the rust crate "chemfiles-sys" to download prebuilt
# libraries
julia create-rust-hash.jl
```
