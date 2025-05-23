pub const Id = u32;

/// Scroll direction types for the Scroll event
pub const WheelDirection = enum(i32) {
    /// The scroll direction is normal
    Normal,
    /// The scroll direction is flipped / natural
    Flipped,
};

/// A bitmask of pressed mouse buttons, as reported by sdl.get_state, etc.
///
/// - Button 1: Left mouse button
/// - Button 2: Middle mouse button
/// - Button 3: Right mouse button
/// - Button 4: Side mouse button 1
/// - Button 5: Side mouse button 2
pub const ButtonFlags = u32;

pub const LEFT = 1;
pub const MIDDLE = 2;
pub const RIGHT = 3;
pub const X1 = 4;
pub const X2 = 5;

pub const LMASK = button_mask(LEFT);
pub const MMASK = button_mask(MIDDLE);
pub const RMASK = button_mask(RIGHT);
pub const X1MASK = button_mask(X1);
pub const X2MASK = button_mask(X2);

pub fn button_mask(idx: anytype) u32 {
    return 1 << (idx - 1);
}

extern fn SDL_GetMouseState(x: *f32, y: *f32) callconv(.c) ButtonFlags;
extern fn SDL_GetGlobalMouseState(x: *f32, y: *f32) callconv(.c) ButtonFlags;

/// Query SDL's cache for the synchronous mouse button state and the
/// window-relative SDL-cursor position.
///
/// This function returns the cached synchronous state as SDL understands it
/// from the last pump of the event queue.
///
/// To query the platform for immediate asynchronous state, use
/// sdl.global.get_state().
///
/// Passing non-NULL pointers to `x` or `y` will write the destination with
/// respective x or y coordinates relative to the focused window.
///
/// In Relative Mode, the SDL-cursor's position usually contradicts the
/// platform-cursor's position as manually calculated from
/// sdl.global.get_state() and SDL_GetWindowPosition.
pub fn get_state() struct { x: f32, y: f32, flags: ButtonFlags } {
    var x = 0.0;
    var y = 0.0;
    const flags = SDL_GetMouseState(&x, &y);
    return .{ .x = x, .y = y, .flags = flags };
}

pub const global = struct {
    /// Query the platform for the asynchronous mouse button state and the
    /// desktop-relative platform-cursor position.
    ///
    /// This function immediately queries the platform for the most recent
    /// asynchronous state, more costly than retrieving SDL's cached state in
    /// sdl.get_state().
    ///
    /// Passing non-NULL pointers to `x` or `y` will write the destination with
    /// respective x or y coordinates relative to the desktop.
    ///
    /// In Relative Mode, the platform-cursor's position usually contradicts the
    /// SDL-cursor's position as manually calculated from sdl.get_state() and
    /// SDL_GetWindowPosition.
    ///
    /// This function can be useful if you need to track the mouse outside of a
    /// specific window and sdl.capture() doesn't fit your needs. For example,
    /// it could be useful if you need to track the mouse while dragging a window,
    /// where coordinates relative to a window might not be in sync at all times.
    ///
    /// *threadsafety* This function should only be called on the main thread.
    pub fn get_state() struct { x: f32, y: f32, flags: ButtonFlags } {
        var x = 0.0;
        var y = 0.0;
        const flags = SDL_GetGlobalMouseState(&x, &y);
        return .{ .x = x, .y = y, .flags = flags };
    }
};
