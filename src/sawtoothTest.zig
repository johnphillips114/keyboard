const std = @import("std");
const pa = @import("portaudio");

pub const SawData = struct {
    left_phase: f32 = 0.0,
    right_phase: f32 = 0.0,
};

/// Called by the PortAudio engine when audio is needed. Same rules as in C:
/// no allocation, no blocking, no printing in here.
pub fn sawCallback(
    input_buffer: ?*const anyopaque,
    output_buffer: ?*anyopaque,
    frames_per_buffer: c_ulong,
    time_info: [*c]const pa.PaStreamCallbackTimeInfo,
    status_flags: pa.PaStreamCallbackFlags,
    user_data: ?*anyopaque,
) callconv(.c) c_int {
    _ = input_buffer;
    _ = time_info;
    _ = status_flags;

    // Recover our typed pointers from the anyopaque ones.
    const data: *SawData = @ptrCast(@alignCast(user_data.?));
    const out: [*]f32 = @ptrCast(@alignCast(output_buffer.?));

    var i: usize = 0;
    while (i < frames_per_buffer) : (i += 1) {
        out[2 * i] = data.left_phase; // left
        out[2 * i + 1] = data.right_phase; // right

        // Simple sawtooth ranging between -1.0 and 1.0.
        data.left_phase += 0.01;
        if (data.left_phase >= 1.0) data.left_phase -= 2.0;

        // Higher pitch on the right so the channels are distinguishable.
        data.right_phase += 0.03;
        if (data.right_phase >= 1.0) data.right_phase -= 2.0;
    }
    return pa.paContinue;
}
