module WaveformListener

export read_waveform, upsample, ft_upsample, delta_colour, Options, listen_waveform, save_audio_samples, img2audio

include("interpolation.jl")
include("readwaveform.jl")
include("upsample.jl")

using SampledSignals, LibSndFile

_verbose::Bool = true

mutable struct Options
    waveform_colour::Tuple{Int, Int, Int}
    c_threshold::Float64
    interpolator::Function
    duration::Float64
    to_sample_rate::Float64
end

Options(r::Int, g::Int, b::Int, duration) = Options(
    (r, g, b),
    0.24,
    _3rd_order_intp,
    duration,
    44100
)

listen_waveform(imgfile::AbstractString, options::Options) = listen_waveform(ImgF64(load(imgfile)), options)
function listen_waveform(img::ImgF64, options::Options)
    img_samples = read_waveform(img, options.waveform_colour, options.c_threshold)
    return upsample(img_samples, options.duration*options.to_sample_rate, options.interpolator)
end

function save_audio_samples(output_file, audio_samples, samplerate=44100.0)
    output_dir = dirname(output_file)
    isdir(output_dir) || mkpath(output_dir)
    save(output_file, SampleBuf(audio_samples, Float64(samplerate)))
end

img2audio(imgfile::AbstractString, output_file::AbstractString, options::Options) = img2audio(ImgF64(load(imgfile)), output_file, options)
img2audio(img::ImgF64, output_file::AbstractString, options::Options) = save_audio_samples(output_file, listen_waveform(img, options), options.to_sample_rate)

end
