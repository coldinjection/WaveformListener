# WaveformListener

This package is a tool to restore sound from waveform images.

The general procedure is:
1. Find the max and min points of each column of waveform pixles
2. Upsample to a higher sample rate (44.1kHz by default) by 3rd-order spline interpolation given the condition that the derivative at all the max and min points is 0
3. Apply a lowpass filter to reduce the frequencies that are impossible to be restored from the waveform image.

## Command line usage

```
julia <path/to/the/project>/cli/readwf.jl [OPTIONS]... IMAGE_FILE R G B DURATION

positional arguments:
  IMAGE_FILE           Path to the waveform image file
  R                    Red value of the waveform colour (0~255)
  G                    Green value of the waveform colour (0~255)
  B                    Blue value of the waveform colour (0~255)
  DURATION             Duration of the sound in seconds

options:
  --max-colour-delta MAX-COLOUR-DELTA
                        Maximum colour difference allowed for a pixel to be counted
                        as part of the waveform. Try increasing if the waveform is
                        not read in whole

  -o, --output OUTPUT_FILE
                        Path to the output audio file

  -q, --quiet           Turn off printing
```

### Examples:

Assuming the current path is the project home path

`julia ./cli/readwf.jl ./examples/eg1.png 59 153 105 0.692`

The above will generate a WAV file at the current path

Or you can specify the output file path (and the project environment):

`julia --project=. ./cli/readwf.jl -o ./examples/eg1.wav ./examples/eg1.png 59 153 105 0.692`
