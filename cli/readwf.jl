using Pkg

if Base.identify_package("WaveformListener") isa Nothing
    Pkg.activate( joinpath(@__DIR__), ".." )
end

using WaveformListener, ArgParse, Dates

ap_settings = ArgParseSettings()
@add_arg_table! ap_settings begin
    "--max-colour-delta"
        help = "Maximum colour difference allowed for a pixel to be counted as part of the waveform. Try increasing if the waveform is not read in whole"
        arg_type = Float64
        default = 0.24
    "--quiet", "-q"
        help = "Turn off printing"
        action = :store_true
    "--output", "-o"
        help = "Path to the output audio file"
    "img_file"
        help = "Path to the waveform image file"
        arg_type = AbstractString
        required = true
    "r"
        help = "Red value of the waveform colour (0~255)"
        arg_type = Int
        required = true
    "g"
        help = "Green value of the waveform colour (0~255)"
        arg_type = Int
        required = true
    "b"
        help = "Blue value of the waveform colour (0~255)"
        arg_type = Int
        required = true
    "dur"
        help = "Duration of the sound in seconds"
        arg_type = Float64
        required = true
end

cli_args = parse_args(ap_settings)

WaveformListener._verbose = !cli_args["quiet"]

img_file = cli_args["img_file"]
if !isfile(img_file)
    println(stderr, "No such file: ", img_file)
    exit(1)
end

output_file = cli_args["output"] isa Nothing ? "wfsound_" * Dates.format(now(), "yyyymmdd_HH_MM_SS_sss") * ".wav" : cli_args["output"]
endswith(output_file, ".wav") || (output_file *= ".wav")

restrict(val) = val > 255 ? 255 : val < 0 ? 0 : val
r = restrict(cli_args["r"])
g = restrict(cli_args["g"])
b = restrict(cli_args["b"])

opt = Options(r, g, b, cli_args["dur"])
opt.c_threshold = cli_args["max-colour-delta"]

img2audio(img_file, output_file, opt)
