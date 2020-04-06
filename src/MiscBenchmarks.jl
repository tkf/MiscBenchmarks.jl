module MiscBenchmarks

using SIMD

function compress_scalar!(dest, pred, src)
    j = firstindex(dest)
    @inbounds for i in eachindex(dest, src, pred)
        if pred[i]
            dest[j] = src[i]
            j += 1
        end
    end
    return dest
end

function compress_simd!(dest, pred, src, ::Val{N} = Val(4)) where {N}
    @assert axes(dest) == axes(src) == axes(pred)
    simd_bound = lastindex(src) - N + 1
    i = firstindex(src)
    j = firstindex(dest)
    pdest = pointer(dest)
    psrc = pointer(src)
    ppred = pointer(pred)
    # lanes = VecRange{N}(0)
    @inbounds while i <= simd_bound
        # mask = pred[lanes + i]
        # vstorec(src[lanes + i], dest, j, mask)
        x = vload(Vec{N,eltype(src)}, psrc + sizeof(eltype(src)) * (i - 1))
        mask = vload(Vec{N,Bool}, ppred + sizeof(eltype(ppred)) * (i - 1))
        vstorec(x, pdest + sizeof(eltype(dest)) * (j - 1), mask)
        j += sum(mask)
        i += N
    end
    @inbounds while i <= lastindex(src)
        if pred[i]
            dest[j] = src[i]
            j += 1
        end
        i += 1
    end
    return dest
end

end # module
