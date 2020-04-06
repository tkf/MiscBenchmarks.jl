module BenchCompressstore

using BenchmarkTools
using MiscBenchmarks: compress_scalar!, compress_simd!

suite = BenchmarkGroup()

for n in [2^10, 2^15, 2^20]
    src = randn(n)
    pred = Vector{Bool}(src .> 0)
    dest = zero(src)

    s1 = suite[:n => n] = BenchmarkGroup()
    s1["scalar"] = @benchmarkable compress_scalar!($dest, $pred, $src)
    s1["simd"] = @benchmarkable compress_simd!($dest, $pred, $src)
end

end  # module
BenchCompressstore.suite
