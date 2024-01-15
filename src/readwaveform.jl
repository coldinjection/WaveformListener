using Images, FileIO

const ImgF64 = Array{RGB{Float64},2}

read_waveform(imgfile::AbstractString, waveform_colour::Tuple{Int,Int,Int}, c_threshold::Real=0.24) =
read_waveform(ImgF64(load(imgfile)), waveform_colour, c_threshold)

function read_waveform(img::ImgF64, waveform_colour::Tuple{Int,Int,Int}, c_threshold::Real=0.24)::Vector{Float64}
    height, width = size(img)

    wc = RGB{Float64}(waveform_colour ./ 255...)

    n_samples = 0
    samples = zeros(Int, 2*width)

    maxmax = 1
    minmin = height

    found_waveform = false
    max_prev = Inf
    min_prev = -1.0
    for column in 1:width
        max, min = find_extrema(img, column, height, wc, c_threshold)

        max < 0 && found_waveform && break
        max < 0 && continue
        found_waveform = true

        first, second = max, min
        if max - min_prev > max_prev - min
            # min gets pushed first if the curve tends to rise
            first, second = min, max
        end
        max_prev = max
        min_prev = min

        n_samples += 1
        samples[n_samples] = first
        n_samples += 1
        samples[n_samples] = second

        max > maxmax && (maxmax = max)
        min < minmin && (minmin = min)
    end

    _verbose && println("\033[38;5;84m[INFO]\033[0m Found $(fld(n_samples, 2)) waveform columns from an image of width $width")

    n_samples < 1 && return Vector{Float64}()
    audio_samples = normalise(samples[1:n_samples], maxmax+1, minmin-1)
    # guarantee to always start and end with 0
    return [0f0, audio_samples..., 0f0]
end

@inline function delta_colour(c1::RGB{Float64}, c2::RGB{Float64})
    dc = c1 - c2
    return (dc.r, dc.g, dc.b) .^2 |> sum |> sqrt
end

function find_extrema(img, column, height, wc, c_threshold)
    max = -1
    min = 1
    # iterate from top to bottom (high value to low value)
    for row in 1:height
        if max < 0 && delta_colour(img[row, column], wc) < c_threshold
            max = height - row +1
            continue
        end
        if max > 0 && delta_colour(img[row, column], wc) > c_threshold
            # the previous pixel marks the min, so plus an extra 1, which is +2 
            min = height - row + 2
            break
        end
    end
    return max, min
end

# shift and scale to [-1, 1]
function normalise(samples, maxmax, minmin)::Vector{Float64}
    ave = sum(samples)/length(samples)
    scale = 2/(maxmax-minmin)
    return map(x->(x-ave)*scale, samples)
end
