const si = @import("init.zig");
const se = @import("events.zig");

const Main_fn = *const fn (argc: c_int, argv: ?*[:0]u8) callconv(.c) c_int;
extern fn SDL_RunApp(argc: c_int, argv: *const [*:0]u8, main: Main_fn, reserved: ?[*]anyopaque) callconv(.c) c_int;
extern fn SDL_EnterAppMainCallbacks(argc: c_int, argv: *const [*:0]u8, appinit: *const si.AppInit_fn, appiter: *const si.AppIterate_fn, appevent: *const si.AppEvent_fn, appquit: *const si.AppQuit_fn) callconv(.c) c_int;

fn Api(comptime App: type) type {
    if (!@hasDecl(App, "iter")) {
        @compileError("App must have \"pub fn iter(appstate: ?*anyopaque) sdl.init.AppResult\"");
    }
    if (!@hasDecl(App, "on_init")) {
        @compileError("App must have \"pub fn on_init(appstate: *?*anyopaque, args: [][:0]u8) i32\"");
    }
    if (!@hasDecl(App, "on_event")) {
        @compileError("App must have \"pub fn on_event(appstate: ?*anyopaque, event: *sdl.events.Event) sdl.init.AppResult\"");
    }
    if (!@hasDecl(App, "on_quit")) {
        @compileError("App must have \"pub fn on_quit(appstate: ?*anyopaque, result: sdl.init.AppResult) void\"");
    }
    if (!@hasDecl(App, "AppState")) {
        @compileError("App must have \"pub const AppState = ;\"");
    }

    return struct {
        const Self = @This();
        const AppState = App.AppState;

        fn start(args: [][:0]u8) c_int {
            return SDL_EnterAppMainCallbacks(@intCast(args.len), @ptrCast(args), Self.on_init, Self.on_iter, Self.on_event, Self.on_quit);
        }

        fn on_init(appstate: *?*anyopaque, argc: c_int, argv: [*]const [*:0]u8) callconv(.c) c_int {
            const len: usize = @intCast(argc);
            const state: *?*Self.AppState = @ptrCast(appstate);
            return @intFromEnum(App.on_init(state, argv[0..len]));
        }

        fn on_event(appstate: ?*anyopaque, event: *se.Event) callconv(.c) si.c_AppResult {
            const state: ?*Self.AppState = if (appstate) |as| @alignCast(@ptrCast(as)) else null;
            return @intFromEnum(App.on_event(state, event));
        }

        fn on_quit(appstate: ?*anyopaque, result: si.c_AppResult) callconv(.c) void {
            const state: ?*Self.AppState = if (appstate) |as| @alignCast(@ptrCast(as)) else null;
            App.on_quit(state, @enumFromInt(result));
        }

        fn on_iter(appstate: ?*anyopaque) callconv(.c) si.c_AppResult {
            const state: ?*Self.AppState = if (appstate) |as| @alignCast(@ptrCast(as)) else null;
            return @intFromEnum(App.iter(state));
        }
    };
}

/// Initializes and launches an SDL application
///
/// returns the return value from mainFunction: 0 on success, otherwise
/// failure; sdl.err.get() might have more information on the failure.
///
/// *threadsafety* Generally this is called once, near startup, from the
/// process's initial thread.
/// ```zig
/// const App = struct {
///     pub const AppState = struct { };
///     pub fn on_init(appstate: *?*anyopaque, args: []const [*:0]u8) sdl.AppResult {
///         _ = appstate;
///         _ = args;
///         std.debug.print("App.on_init\n", .{});
///         return .Success;
///     }
///
///     pub fn iter(appstate: ?*anyopaque) sdl.AppResult {
///         _ = appstate;
///         std.debug.print("App.iter\n", .{});
///         return .Success;
///     }
///
///     pub fn on_event(appstate: ?*anyopaque, event: *sdl.events.Event) sdl.AppResult {
///         _ = appstate;
///         _ = event;
///         std.debug.print("App.on_event\n", .{});
///         return .Failure;
///     }
///
///     pub fn on_quit(appstate: ?*anyopaque, result: sdl.AppResult) void {
///         _ = appstate;
///         _ = result;
///         std.debug.print("App.quit\n", .{});
///     }
/// };
///
/// pub fn main() {
///    const allocator = std.heap.page_allocator;
///    const args = try std.process.argsAlloc(allocator);
///     if (sdl.run_app(args, App) != 0) @panic("Failed to start the application");
/// }
/// ```
pub fn run_app(args: [][:0]u8, comptime app: type) i32 {
    const api = Api(app);
    const res = api.start(args);
    return @intCast(res);
}
