module LibEEMD
using Libdl

const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")

if !isfile(depsjl_path)
    error("LibEEMD not installed properly, run Pkg.build(\"LibEEMD\"), restart Julia and try again")
end
@show depsjl_path
include(depsjl_path)
@show libeemd

function __init__()
    check_deps()
    global libeemd
    global libeemd_open = Libdl.dlopen_e(libeemd)
    @assert libeemd_open != C_NULL "Could not open $libeemd"
end

export emd, eemd, ceemdan

function eemd(ts::AbstractVector{T} where T<:Number,
                num_imfs=emd_num_imfs(ts), ensemble_size=250, noise_strength=0.2,
                S_number=4, num_siftings=50, rng_seed=0)

    eemd_ptr = Libdl.dlsym_e(libeemd_open, :eemd)

    output = zeros(typeof(ts[1]), (size(ts)[1], num_imfs))
    ccall(eemd_ptr, Cint, (Ptr{Cdouble}, Csize_t, Ptr{Cdouble}, Csize_t,
            Cuint, Cdouble, Cuint, Cuint, Culong),
            ts, size(ts)[1], output, num_imfs, ensemble_size, noise_strength,
             S_number, num_siftings, rng_seed)
    output
end



function ceemdan(ts::AbstractVector{T} where T <:Number,
                num_imfs=emd_num_imfs(ts)::Integer, ensemble_size=250, noise_strength=0.2,
                S_number=4, num_siftings=50, rng_seed=0)
    global libeemd
    libeemd_open = Libdl.dlopen_e(libeemd)
    @assert libeemd_open != C_NULL "Could not open $libeemd"
    ceemdan_ptr = Libdl.dlsym_e(libeemd_open, :ceemdan)
    output = zeros(typeof(ts[1]), convert(Dims,(size(ts,1), num_imfs)))
    ccall(ceemdan_ptr, Cint, (Ptr{Cdouble}, Csize_t, Ptr{Cdouble}, Csize_t,
            Cuint, Cdouble, Cuint, Cuint, Culong),
            ts, size(ts)[1], output, num_imfs, ensemble_size, noise_strength,
             S_number, num_siftings, rng_seed)
    output
end


function emd(ts::AbstractVector{T} where T<:Real,
                num_imfs=emd_num_imfs(ts), S_number=4, num_siftings=50, rng_seed=0)
    eemd(ts, num_imfs, 1, 0.0, S_number, num_siftings, rng_seed)
end



function emd_num_imfs(ts::AbstractVector{T} where T<:Real)
    N = size(ts)[1]
    if N == 0
        return 0
    elseif N <= 3
        return 1
    else
        return round(Int, log2(N))
    end
end
end # module
