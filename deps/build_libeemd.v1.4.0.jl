using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libeemd"], :libeemd),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/felixcremer/LibeemdBuilder/releases/download/v1.4"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/libeemd.v1.4.0.aarch64-linux-gnu.tar.gz", "c7dae22715da03bc4fb12ad78670ecf0f0ca1737990fd324135f4052813c3b77"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/libeemd.v1.4.0.aarch64-linux-musl.tar.gz", "0122a3acb48935b613c129adb3c379f054d7932a137980464620b37e44cbe09a"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/libeemd.v1.4.0.arm-linux-gnueabihf.tar.gz", "a9728a0bd44ac6961cb6a4fbc389586daa18fbf8083d630450c61ad34678f6e7"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/libeemd.v1.4.0.arm-linux-musleabihf.tar.gz", "41ddfb2e989d1f31a88631dae44dff063da44b3a3a7ff5121e168736f6a5f257"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/libeemd.v1.4.0.i686-linux-gnu.tar.gz", "ed053105a002a39597895ba65b4d215ded4ed3fd06fe4ce4d97dda10a0aeeb69"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/libeemd.v1.4.0.i686-linux-musl.tar.gz", "e35c160a827259c326f2ecf774ae0a53ddf26693fb7fe7b9f080078e42f526e1"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/libeemd.v1.4.0.powerpc64le-linux-gnu.tar.gz", "a11f64c7886d530f2e3878a9b6b678356efcf4b40f14bc5086b692d2679e9579"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/libeemd.v1.4.0.x86_64-linux-gnu.tar.gz", "b53ef4a03a5331ad0ee963ee8a9d3b0a31f3d2836fc51f517e272c3932729592"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/libeemd.v1.4.0.x86_64-linux-musl.tar.gz", "fd013f641e550dbb3efe1a2f0a23a2a81356012f7a7b8eaf0c07a7fbada5de78"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
