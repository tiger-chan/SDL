const std = @import("std");
const se = @import("events.zig");

pub const AppResult = enum {
    /// Value that requests that the app continue from the main callbacks.
    Continue,
    /// Value that requests termination with success from the main callbacks.
    Success,
    /// Value that requests termination with error from the main callbacks.
    Failure,
};

/// Initialization flags for SDL_Init and/or SDL_InitSubSystem
///
/// These are the flags which may be passed to SDL_Init(). You should specify
/// the subsystems which you will be using in your application.
///     Audio = 0x00000010,
///     Video = 0x00000020,
///     Joystick = 0x00000200,
///     Haptic = 0x00001000,
///     Gamepad = 0x00002000,
///     Events = 0x00004000,
///     Sensor = 0x00008000,
///     Camera = 0x00010000,
pub const InitFlags = packed struct(u32) {
    _pad1: u4 = 0,
    /// `Audio` implies `Events`
    audio: bool = false,
    /// `Video` implies `Events`, should be initialized on the main thread
    video: bool = false,
    _pad2: u3 = 0,
    /// `Joystick` implies `Events`, should be initialized on the same thread
    /// as Video on Windows if you don't set SDL_HINT_JOYSTICK_THREAD */
    joystick: bool = false,
    _pad3: u2 = 0,
    haptic: bool = false,
    /// `Gamepad` implies `Joystick`
    gamepad: bool = false,
    events: bool = false,
    /// `Sensor` implies `Events`
    sensor: bool = false,
    /// `Camera` implies `Events`
    camera: bool = false,
    _pad4: u15 = 0,

    pub fn to_int(self: InitFlags) u32 {
        return @bitCast(self);
    }

    pub fn from(flags: u32) InitFlags {
        return @bitCast(flags);
    }
};
const c_InitFlags = u32;

pub const c_AppResult = c_int;
pub const AppInit_fn = fn (appstate: *?*anyopaque, argc: c_int, argv: [*]const [*:0]u8) callconv(.c) c_AppResult;
pub const AppIterate_fn = fn (appstate: ?*anyopaque) callconv(.c) c_AppResult;
pub const AppEvent_fn = fn (appstate: ?*anyopaque, event: *se.Event) callconv(.c) c_AppResult;
pub const AppQuit_fn = fn (appstate: ?*anyopaque, result: c_AppResult) callconv(.c) void;

extern fn SDL_SetAppMetadata(appname: ?[*:0]const u8, appversion: ?[*:0]const u8, appidentifier: ?[*:0]const u8) callconv(.c) bool;
extern fn SDL_SetAppMetadataProperty(name: ?[*:0]const u8, value: ?[*:0]const u8) callconv(.c) bool;
extern fn SDL_GetAppMetadataProperty(name: [*:0]const u8) callconv(.c) [*:0]const u8;

extern fn SDL_Init(flags: c_InitFlags) bool;

/// Initialize the SDL library.
///
/// SDL_Init() simply forwards to calling SDL_InitSubSystem(). Therefore, the
/// two may be used interchangeably. Though for readability of your code
/// SDL_InitSubSystem() might be preferred.
///
/// The file I/O (for example: SDL_IOFromFile) and threading (SDL_CreateThread)
/// subsystems are initialized by default. Message boxes
/// (SDL_ShowSimpleMessageBox) also attempt to work without initializing the
/// video subsystem, in hopes of being useful in showing an error dialog when
/// SDL_Init fails. You must specifically initialize other subsystems if you
/// use them in your application.
///
/// Logging (such as SDL_Log) works without initialization, too.
///
/// `flags` may be any of the following OR'd together:
///
/// - `audio`: audio subsystem; automatically initializes the events
///   subsystem
/// - `video`: video subsystem; automatically initializes the events
///   subsystem, should be initialized on the main thread.
/// - `joystick`: joystick subsystem; automatically initializes the
///   events subsystem
/// - `haptic`: haptic (force feedback) subsystem
/// - `gamepad`: gamepad subsystem; automatically initializes the
///   joystick subsystem
/// - `events`: events subsystem
/// - `sensor`: sensor subsystem; automatically initializes the events
///   subsystem
/// - `camera`: camera subsystem; automatically initializes the events
///   subsystem
///
/// Subsystem initialization is ref-counted, you must call SDL_QuitSubSystem()
/// for each SDL_InitSubSystem() to correctly shutdown a subsystem manually (or
/// call SDL_Quit() to force shutdown). If a subsystem is already loaded then
/// this call will increase the ref-count and return.
///
/// Consider reporting some basic metadata about your application before
/// calling SDL_Init, using either SDL_SetAppMetadata() or
/// SDL_SetAppMetadataProperty().
pub fn init(flags: InitFlags) bool {
    return SDL_Init(flags.to_int());
}

pub const app_metadata = struct {
    pub const NAME_STRING = "SDL.app.metadata.name";
    pub const VERSION_STRING = "SDL.app.metadata.version";
    pub const IDENTIFIER_STRING = "SDL.app.metadata.identifier";
    pub const CREATOR_STRING = "SDL.app.metadata.creator";
    pub const COPYRIGHT_STRING = "SDL.app.metadata.copyright";
    pub const URL_STRING = "SDL.app.metadata.url";
    pub const TYPE_STRING = "SDL.app.metadata.type";

    /// Specify basic metadata about your app.
    ///
    /// You can optionally provide metadata about your app to SDL. This is not
    /// required, but strongly encouraged.
    ///
    /// There are several locations where SDL can make use of metadata (an "About"
    /// box in the macOS menu bar, the name of the app can be shown on some audio
    /// mixers, etc). Any piece of metadata can be left as NULL, if a specific
    /// detail doesn't make sense for the app.
    ///
    /// This function should be called as early as possible, before SDL_Init.
    /// Multiple calls to this function are allowed, but various state might not
    /// change once it has been set up with a previous call to this function.
    ///
    /// Passing a NULL removes any previous metadata.
    pub fn set(name: ?[*:0]const u8, version: ?[*:0]const u8, identifier: ?[*:0]const u8) bool {
        return SDL_SetAppMetadata(name, version, identifier);
    }

    /// Specify metadata about your app through a set of properties.
    ///
    /// You can optionally provide metadata about your app to SDL. This is not
    /// required, but strongly encouraged.
    ///
    /// There are several locations where SDL can make use of metadata (an "About"
    /// box in the macOS menu bar, the name of the app can be shown on some audio
    /// mixers, etc). Any piece of metadata can be left out, if a specific detail
    /// doesn't make sense for the app.
    ///
    /// This function should be called as early as possible, before sdl init.
    /// Multiple calls to this function are allowed, but various state might not
    /// change once it has been set up with a previous call to this function.
    ///
    /// Once set, this metadata can be read using get_property().
    ///
    /// These are the supported properties:
    ///
    /// - `NAME_STRING`: The human-readable name of the
    ///   application, like "My Game 2: Bad Guy's Revenge!". This will show up
    ///   anywhere the OS shows the name of the application separately from window
    ///   titles, such as volume control applets, etc. This defaults to "SDL
    ///   Application".
    /// - `VERSION_STRING`: The version of the app that is
    ///   running; there are no rules on format, so "1.0.3beta2" and "April 22nd,
    ///   2024" and a git hash are all valid options. This has no default.
    /// - `IDENTIFIER_STRING`: A unique string that
    ///   identifies this app. This must be in reverse-domain format, like
    ///   "com.example.mygame2". This string is used by desktop compositors to
    ///   identify and group windows together, as well as match applications with
    ///   associated desktop settings and icons. If you plan to package your
    ///   application in a container such as Flatpak, the app ID should match the
    ///   name of your Flatpak container as well. This has no default.
    /// - `CREATOR_STRING`: The human-readable name of the
    ///   creator/developer/maker of this app, like "MojoWorkshop, LLC"
    /// - `COPYRIGHT_STRING`: The human-readable copyright notice, like
    ///   "Copyright (c) 2024 MojoWorkshop, LLC" or whatnot. Keep this to one
    ///    line, don't paste a copy of a whole software license in here. This
    ///    has no default.
    /// - `URL_STRING`: A URL to the app on the web.
    ///    Maybe a product page, or a storefront, or even a GitHub repository,
    ///    for user's further information This has no default.
    /// - `TYPE_STRING`: The type of application this is.
    ///   Currently this string can be "game" for a video game, "mediaplayer"
    ///   for a media player, or generically "application" if nothing else
    ///   applies. Future versions of SDL might add new types. This defaults to
    ///   "application".
    pub fn set_property(name: [*:0]const u8, value: ?[*:0]const u8) bool {
        return SDL_SetAppMetadataProperty(name, value);
    }

    /// Get metadata about your app.
    ///
    /// This returns metadata previously set using set() or set_property(). See
    /// set_property() for the list of available properties and their meanings.
    pub fn get_property(name: [*:0]const u8) [*:0]const u8 {
        return SDL_GetAppMetadataProperty(name);
    }
};
