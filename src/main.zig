const std = @import("std");
const pa = @import("portaudio");
const st = @import("sawtoothTest.zig");
const setup = @import("audioSetup.zig");

pub fn main() !void {
    if (pa.Pa_Initialize() != pa.paNoError) return error.PaInitFailed;
    defer _ = pa.Pa_Terminate();

    var data = st.SawData{};
    var stream: ?*pa.PaStream = null;

    const device = setup.findPreferredOutput();

    var out_params = pa.PaStreamParameters{
        .device = device,
        .channelCount = 2,
        .sampleFormat = pa.paFloat32,
        .suggestedLatency = pa.Pa_GetDeviceInfo(device).*.defaultLowOutputLatency,
        .hostApiSpecificStreamInfo = null,
    };

    if (pa.Pa_OpenStream(
        &stream,
        null,
        &out_params,
        44100,
        256,
        pa.paClipOff,
        st.sawCallback,
        &data,
    ) != pa.paNoError) return error.OpenStreamFailed;

    if (pa.Pa_StartStream(stream) != pa.paNoError) return error.StartStreamFailed;
    pa.Pa_Sleep(3 * 1000);
    _ = pa.Pa_StopStream(stream);
}
