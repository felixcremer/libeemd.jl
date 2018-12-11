using LibEEMD
using Random
using Test

@testset "eemd" begin
    ts = rand(100)
    @test size(eemd(ts)) == (100,7)
end

@testset "ceemdan" begin
    ts = rand(100)
    imfs = ceemdan(ts)
    @test sum(imfs, dims=2) ≈ ts
    @test size(imfs) == (100,7)
end

@testset "emd" begin
    ts = rand(100)
    imfs = emd(ts)
    @test sum(imfs, dims=2) ≈ ts
    @test size(imfs) == (100,7)
end
