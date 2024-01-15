using FFTW

function upsample(old_samples::Vector{T}, n_new_samples, interpolator) where T <: Number
    n_old_samples = length(old_samples)
    n_segs = n_old_samples - 1
    n_samples_per_seg = round(Int, n_new_samples/n_segs)
    if n_samples_per_seg < 2
        _verbose && println(stderr, "\033[38;5;124m[ERROR]\033[0m Number of new samples is too small, won't interpolate")
        return old_samples
    end

    xs = collect(range(0, 1, n_samples_per_seg + 1))[1:end-1]
    n_new_samples = n_samples_per_seg * n_segs + 1
    up_factor = n_new_samples/n_old_samples
    new_samples = zeros(T, n_new_samples)

    _verbose && println("\033[38;5;84m[INFO]\033[0m Upsampling from $n_old_samples samples to $n_new_samples (up_factor=$up_factor)")
    _verbose && up_factor > 8 && println("\033[38;5;214m[WARNING]\033[0m up_factor is too large! ")

    ith_sample = 1
    for i in 1:n_segs
        ys = map(interpolate(interpolator, old_samples[i], old_samples[i+1]), xs)
        copyto!(new_samples, ith_sample, ys, 1, n_samples_per_seg)
        ith_sample += n_samples_per_seg
    end
    new_samples[end] = old_samples[end]

    # lowpass_fcutoff = 1/2 * 1/up_factor
    return equalise(new_samples, lowpass_3rd_order_decay(1 / (2 * up_factor)))
end

# frequency in terms of 1/n_samples_per_period at position `idx` in an FFT vector with length `window_length`
freq_discrete(idx::Int, window_length::Int)::Float64 = idx-1 > window_length/2 ? 1 - (idx-1)/window_length : (idx-1)/window_length

function equalise(audio_samples, scaling_func)
    fs = fft(audio_samples)
    wl = length(fs)
    for i = 1:wl
        fs[i] *= scaling_func(freq_discrete(i, wl))
    end
    return real.(ifft(fs))
end

lowpass_hard(fcutoff) = f -> f < fcutoff ? 1 : 0

function lowpass_3rd_order_decay(fcutoff)
    f_from = fcutoff
    f_to   = fcutoff * 1.5 # + around 7 semitones
    return f -> f <= f_from ? 1 : f >= f_to ? 0 : interpolate(_3rd_order_intp, f_from, f_to, (f-f_from)/(f_to-f_from))
end

function ft_upsample(old_samples::Vector{T}, new_length::Integer) where T <: Number
    old_length = length(old_samples)
    if new_length <= old_length
        _verbose && println(stderr, "\033[38;5;124m[ERROR]\033[0m Number of new samples is too small, won't upsample")
        return old_samples
    end
    fs = fft(old_samples)
    copylen = 1 + fld(old_length, 2)
    new_fs = zeros(eltype(fs), new_length)
    copyto!(new_fs, 1, fs, 1, copylen)
    return real.(ifft(new_fs)) .* (new_length/copylen)
end
