const core = @import("core.zig");
const c_events = @import("events.zig");
const c_init = @import("init.zig");
const c_scancode = @import("scancode.zig");
const c_timer = @import("timer.zig");
const c_video = @import("video.zig");

pub const joystick = @import("joystick.zig");

pub const run_app = core.run_app;

pub const err = @import("error.zig");

pub const AppResult = c_init.AppResult;
pub const InitFlags = c_init.InitFlags;
pub const init = c_init.init;
pub const app_metadata = c_init.app_metadata;

pub const Event = c_events.Event;

pub const Scanecode = c_scancode.Scancode;

pub const scancode = struct {
    pub const COUNT = c_scancode.COUNT;
};

pub const pixels = @import("pixels.zig");
pub const ALPHA_OPAQUE = pixels.ALPHA_OPAQUE;

pub const rect = @import("rect.zig");
pub const Rect = rect.Rect;
pub const FRect = rect.FRect;

pub const create_window_and_renderer = render.create_window_and_renderer;
pub const Renderer = render.Renderer;
pub const render = @import("render.zig");

pub const get_ticks = c_timer.get_ticks;

pub const Window = c_video.Window;
pub const WindowFlags = c_video.WindowFlags;

pub const video = struct {
    pub const destroy_window = c_video.destroy_window;
};
