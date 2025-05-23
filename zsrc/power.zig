const std = @import("std");
/// The basic state for the system's power supply.
///
/// These are results returned by sdl.get_info().
pub const State = enum(u32) {
    ///error determining power status
    Error = std.math.maxInt(u32),
    ///cannot determine power status
    Unknown = 0,
    ///Not plugged in, running on the battery
    OnBattery,
    ///Plugged in, no battery available
    NoBattery,
    ///Plugged in, charging battery
    Charging,
    ///Plugged in, battery charged
    Charged,
};
