const std = @import("std");
const pa = @import("portaudio");

pub fn main() !void {
    const err = pa.Pa_Initialize();
    if (err != pa.paNoError) return error.PaInitFailed;
    defer _ = pa.Pa_Terminate();

    std.debug.print("PortAudio version: {s}\n", .{pa.Pa_GetVersionText()});
}
