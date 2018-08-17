module LibEEMD
using Libdl

export emd, eemd, ceemdan

function eemd(ts::AbstractVector{T} where T<:Number,
                num_imfs=emd_num_imfs(ts), ensemble_size=250, noise_strength=0.2,
                S_number=4, num_siftings=50, rng_seed=0)
    libeemd_path = Libdl.find_library("libeemd", [pwd()])
    libeemd = Libdl.dlopen(libeemd_path)
    eemd_ptr = Libdl.dlsym(libeemd, :eemd)

    output = zeros(typeof(ts[1]), (size(ts)[1], num_imfs))
    ccall(eemd_ptr, Cint, (Ptr{Cdouble}, Csize_t, Ptr{Cdouble}, Csize_t,
            Cuint, Cdouble, Cuint, Cuint, Culong),
            ts, size(ts)[1], output, num_imfs, ensemble_size, noise_strength,
             S_number, num_siftings, rng_seed)
    output
end



function ceemdan(ts::AbstractVector{T} where T <:Number,
                num_imfs=emd_num_imfs(ts), ensemble_size=250, noise_strength=0.2,
                S_number=4, num_siftings=50, rng_seed=0)

    libeemd_path = Libdl.find_library("libeemd", [pwd()])
    libeemd = Libdl.dlopen(libeemd_path)
    ceemdan_ptr = Libdl.dlsym(libeemd, :ceemdan)
    output = zeros(typeof(ts[1]), (size(ts)[1], num_imfs))
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
