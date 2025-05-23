pub const Window = opaque {};

pub const DisplayId = u32;
pub const WindowId = u32;

/// The flags on a window.
///
/// These cover a lot of true/false, or on/off, window state. Some of it is
/// immutable after being set through SDL_CreateWindow(), some of it can be
/// changed on existing windows by the app, and some of it might be altered by
/// the user or system outside of the app's control.
pub const WindowFlags = packed struct(u64) {
    /// (0x0000000000000001) window is in fullscreen mode
    fullscreen: bool = false,
    /// (0x0000000000000002) window usable with OpenGL context
    opengl: bool = false,
    /// (0x0000000000000004) window is occluded
    occluded: bool = false,
    /// (0x0000000000000008) window is neither mapped onto the desktop nor shown in the taskbar/dock/window list; SDL_ShowWindow() is required for it to become visible
    hidden: bool = false,
    /// (0x0000000000000010) no window decoration
    borderless: bool = false,
    /// (0x0000000000000020) window can be resized
    resizable: bool = false,
    /// (0x0000000000000040) window is minimized
    minimized: bool = false,
    /// (0x0000000000000080) window is maximized
    maximized: bool = false,
    /// (0x0000000000000100) window has grabbed mouse input
    mouse_grabbed: bool = false,
    /// (0x0000000000000200) window has input focus
    input_focus: bool = false,
    /// (0x0000000000000400) window has mouse focus
    mouse_focus: bool = false,
    /// (0x0000000000000800) window not created by SDL
    external: bool = false,
    /// (0x0000000000001000) window is modal
    modal: bool = false,
    /// (0x0000000000002000) window uses high pixel density back buffer if possible
    high_pixel_density: bool = false,
    /// (0x0000000000004000) window has mouse captured (unrelated to MOUSE_GRABBED)
    mouse_capture: bool = false,
    /// (0x0000000000008000) window has relative mode enabled
    mouse_relative_mode: bool = false,
    /// (0x0000000000010000) window should always be above others
    always_on_top: bool = false,
    /// (0x0000000000020000) window should be treated as a utility window, not showing in the task bar and window list
    utility: bool = false,
    /// (0x0000000000040000) window should be treated as a tooltip and does not get mouse or keyboard focus, requires a parent window
    tooltip: bool = false,
    /// (0x0000000000080000) window should be treated as a popup menu, requires a parent window
    popup_menu: bool = false,
    /// (0x0000000000100000) window has grabbed keyboard input
    keyboard_grabbed: bool = false,
    /// (0x0000000010000000) window usable for Vulkan surface
    vulkan: bool = false,
    /// (0x0000000020000000) window usable for Metal view
    metal: bool = false,
    /// (0x0000000040000000) window with transparent buffer
    transparent: bool = false,
    /// (0x0000000080000000) window should not be focusable
    not_focusable: bool = false,

    _pad1: u39 = 0,

    pub fn to_int(self: WindowFlags) u64 {
        return @bitCast(self);
    }

    pub fn from(flags: u64) WindowFlags {
        return @bitCast(flags);
    }
};

pub const c_WindowFlags = u64;

/// Destroy a window.
///
/// Any child windows owned by the window will be recursively destroyed as
/// well.
///
/// Note that on some platforms, the visible window may not actually be removed
/// from the screen until the SDL event loop is pumped again, even though the
/// SDL_Window is no longer valid after this call.
///
/// *threadsafety* This function should only be called on the main thread.
extern fn SDL_DestroyWindow(window: *Window) callconv(.c) void;

pub fn destroy_window(window: *Window) void {
    SDL_DestroyWindow(window);
}
