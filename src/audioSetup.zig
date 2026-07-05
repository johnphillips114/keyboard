const std = @import("std");
const pa = @import("portaudio");

pub fn findOutputDevice(name: []const u8) ?pa.PaDeviceIndex {
    const count = pa.Pa_GetDeviceCount();
    var i: pa.PaDeviceIndex = 0;
    while (i < count) : (i += 1) {
        const info = pa.Pa_GetDeviceInfo(i);
        if (info == null or info.*.maxOutputChannels < 2) continue;
        const dev_name = std.mem.span(info.*.name); // C string -> Zig slice
        if (std.mem.eql(u8, dev_name, name)) return i;
    }
    return null;
}
