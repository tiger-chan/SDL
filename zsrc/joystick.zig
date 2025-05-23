pub const Joystick = opaque {};

/// This is a unique Id for a joystick for the time it is connected to the
/// system, and is never reused for the lifetime of the application.
///
/// If the joystick is disconnected and reconnected, it will get a new Id.
///
/// The value 0 is an invalid Id.
pub const Id = u32;

pub const Hat = enum(u8) {
    Centered = 0x0,
    Up = 0x01,
    Right = 0x02,
    Down = 0x04,
    Left = 0x08,
    RightUp = 0x02 | 0x01,
    RightDown = 0x02 | 0x04,
    LeftUp = 0x08 | 0x01,
    LeftDown = 0x08 | 0x04,
    _,

    pub fn contains(self: Hat, rhs: Hat) bool {
        const raw = @intFromEnum(self);
        const rhs_raw = @intFromEnum(rhs);
        return (raw & rhs_raw) == rhs_raw;
    }
};

extern fn SDL_OpenJoystick(instance_id: Id) callconv(.c) ?*Joystick;
extern fn SDL_CloseJoystick(joystick: *Joystick) callconv(.c) void;
extern fn SDL_GetJoystickID(joystick: *Joystick) callconv(.c) Id;

/// Open a joystick for use.
///
/// The joystick subsystem must be initialized before a joystick can be opened
/// for use.
///
/// returns a joystick identifier or NULL on failure; call sdl.err.get() for
/// more information.
pub fn open(instance_id: Id) ?*Joystick {
    return SDL_OpenJoystick(instance_id);
}

/// Close a joystick previously opened with sdl.joystick.open().
pub fn close(joystick: *Joystick) void {
    SDL_CloseJoystick(joystick);
}

/// Get the instance Id of an opened joystick.
pub fn get_id(joystick: *Joystick) Id {
    return SDL_GetJoystickID(joystick);
}
