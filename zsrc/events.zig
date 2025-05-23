const video = @import("video.zig");
const keyboard = @import("keyboard.zig");
const sc = @import("scancode.zig");
const kc = @import("keycode.zig");
const mouse = @import("mouse.zig");
const joystick = @import("joystick.zig");
const audio = @import("audio.zig");
const camera = @import("camera.zig");
const touch = @import("touch.zig");
const power = @import("power.zig");
const pen = @import("pen.zig");
const sensor = @import("sensor.zig");

pub const Event = extern union {
    /// Event type, shared with all events, u32 to cover user events which
    /// are not in the SDL_EventType enumeration
    type: EventType,
    /// Common event data
    common: CommonEvent,
    /// Display event data
    display: DisplayEvent,
    /// Window event data
    window: WindowEvent,
    /// Keyboard device change event data
    kdevice: KeyboardDeviceEvent,
    /// Keyboard event data
    key: KeyboardEvent,
    /// Text editing event data
    edit: TextEditingEvent,
    /// Text editing candidates event data
    edit_candidates: TextEditingCandidatesEvent,
    /// Text input event data
    text: TextInputEvent,
    /// Mouse device change event data
    mdevice: MouseDeviceEvent,
    /// Mouse motion event data
    motion: MouseMotionEvent,
    /// Mouse button event data
    button: MouseButtonEvent,
    /// Mouse wheel event data
    wheel: MouseWheelEvent,
    /// Joystick device change event data
    jdevice: JoyDeviceEvent,
    /// Joystick axis event data
    jaxis: JoyAxisEvent,
    /// Joystick ball event data
    jball: JoyBallEvent,
    /// Joystick hat event data
    jhat: JoyHatEvent,
    /// Joystick button event data
    jbutton: JoyButtonEvent,
    /// Joystick battery event data
    jbattery: JoyBatteryEvent,
    /// Gamepad device event data
    gdevice: GamepadDeviceEvent,
    /// Gamepad axis event data
    gaxis: GamepadAxisEvent,
    /// Gamepad button event data
    gbutton: GamepadButtonEvent,
    /// Gamepad touchpad event data
    gtouchpad: GamepadTouchpadEvent,
    /// Gamepad sensor event data
    gsensor: GamepadSensorEvent,
    /// Audio device event data
    adevice: AudioDeviceEvent,
    /// Camera device event data
    cdevice: CameraDeviceEvent,
    /// Sensor event data
    sensor: SensorEvent,
    /// Quit request event data
    quit: QuitEvent,
    /// Custom event data
    user: UserEvent,
    /// Touch finger event data
    tfinger: TouchFingerEvent,
    /// Pen proximity event data
    pproximity: PenProximityEvent,
    /// Pen tip touching event data
    ptouch: PenTouchEvent,
    /// Pen motion event data
    pmotion: PenMotionEvent,
    /// Pen button event data
    pbutton: PenButtonEvent,
    /// Pen axis event data
    paxis: PenAxisEvent,
    /// Render event data
    render: RenderEvent,
    /// Drag and drop event data
    drop: DropEvent,
    /// Clipboard event data
    clipboard: ClipboardEvent,

    /// This is necessary for ABI compatibility between Visual C++ and GCC.
    /// Visual C++ will respect the push pack pragma and use 52 bytes (size of
    /// SDL_TextEditingEvent, the largest structure for 32-bit and 64-bit
    /// architectures) for this union, and GCC will use the alignment of the
    /// largest datatype within the union, which is 8 bytes on 64-bit
    /// architectures.
    ///
    /// So... we'll add padding to force the size to be the same for both.
    ///
    /// On architectures where pointers are 16 bytes, this needs rounding up to
    /// the next multiple of 16, 64, and on architectures where pointers are
    /// even larger the size of SDL_UserEvent will dominate as being 3 pointers.
    padding: [128]u8,
};

/// Fields shared by every event
pub const CommonEvent = extern struct {
    /// Event type, shared with all events, u32 to cover user events which
    /// are not in the sdl.EventType enumeration
    type: u32,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
};

/// Display state change event data (event.display.*)
pub const DisplayEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The associated display
    displayId: video.DisplayId,
    /// event dependent data
    data1: i32,
    /// event dependent data
    data2: i32,
};

/// Window state change event data (event.window.*)
pub const WindowEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The associated window
    windowId: video.WindowId,
    /// event dependent data
    data1: i32,
    /// event dependent data
    data2: i32,
};

/// Keyboard device event structure (event.kdevice.*)
pub const KeyboardDeviceEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The keyboard instance id
    which: keyboard.KeyboardId,
};

/// Keyboard button event structure (event.key.*)
///
/// The `key` is the base SDL_Keycode generated by pressing the `scancode`
/// using the current keyboard layout, applying any options specified in
/// SDL_HINT_KEYCODE_OPTIONS. You can get the SDL_Keycode corresponding to the
/// event scancode and modifiers directly from the keyboard layout, bypassing
/// SDL_HINT_KEYCODE_OPTIONS, by calling SDL_GetKeyFromScancode().
pub const KeyboardEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window with keyboard focus, if any
    windowId: video.WindowId,
    /// The keyboard instance id, or 0 if unknown or virtual
    which: keyboard.KeyboardId,
    /// SDL physical key code
    scancode: sc.Scancode,
    /// SDL virtual key code
    key: kc.Keycode,
    /// current key modifiers
    mod: kc.Keymod,
    /// The platform dependent scancode for this event
    raw: u16,
    /// true if the key is pressed
    down: bool,
    /// true if this is a key repeat
    repeat: bool,
};

/// Keyboard text editing event structure (event.edit.*)
///
/// The start cursor is the position, in UTF-8 characters, where new typing
/// will be inserted into the editing text. The length is the number of UTF-8
/// characters that will be replaced by new typing.
pub const TextEditingEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window with keyboard focus, if any
    windowId: video.WindowId,
    /// The editing text
    text: [*:0]const u8,
    /// The start cursor of selected editing text, or -1 if not set
    start: i32,
    /// The length of selected editing text, or -1 if not set
    length: i32,
};

/// Keyboard IME candidates event structure (event.edit_candidates.*)
pub const TextEditingCandidatesEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window with keyboard focus, if any
    windowId: video.WindowId,
    /// The list of candidates, or NULL if there are no candidates available
    candidates: ?[*]const [*:0]const u8,
    /// The number of strings in `candidates`
    num_candidates: i32,
    /// The index of the selected candidate, or -1 if no candidate is selected
    selected_candidate: i32,
    /// true if the list is horizontal, false if it's vertical
    horizontal: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

/// Keyboard text input event structure (event.text.*)
///
/// This event will never be delivered unless text input is enabled by calling
/// sdl.start_text_input(). Text input is disabled by default!
const TextInputEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window with keyboard focus, if any
    windowId: video.WindowId,
    /// The input text, UTF-8 encoded
    text: [*:0]const u8,
};

/// Mouse device event structure (event.mdevice.*)
const MouseDeviceEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The mouse instance id
    which: mouse.Id,
};

/// Mouse motion event structure (event.motion.*)
const MouseMotionEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window with mouse focus, if any
    windowId: video.WindowId,
    /// The mouse instance id in relative mode, SDL_TOUCH_MOUSEID for touch events, or 0
    which: mouse.Id,
    /// The current button state
    state: mouse.ButtonFlags,
    /// X coordinate, relative to window
    x: f32,
    /// Y coordinate, relative to window
    y: f32,
    /// The relative motion in the X direction
    xrel: f32,
    /// The relative motion in the Y direction
    yrel: f32,
};

/// Mouse button event structure (event.button.*)
const MouseButtonEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window with mouse focus, if any
    windowId: video.WindowId,
    /// The mouse instance id in relative mode, SDL_TOUCH_MOUSEID for touch events, or 0
    which: mouse.Id,
    /// The mouse button index
    button: u8,
    /// true if the button is pressed
    down: bool,
    /// 1 for single-click, 2 for double-click, etc.
    clicks: u8,
    padding: u8,
    /// X coordinate, relative to window
    x: f32,
    /// Y coordinate, relative to window
    y: f32,
};

/// Mouse wheel event structure (event.wheel.*)
const MouseWheelEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window with mouse focus, if any
    windowId: video.WindowId,
    /// The mouse instance id in relative mode or 0
    which: mouse.Id,
    /// The amount scrolled horizontally, positive to the right and negative to the left
    x: f32,
    /// The amount scrolled vertically, positive away from the user and negative toward the user
    y: f32,
    /// Set to one of the SDL_MOUSEWHEEL_* defines. When FLIPPED the values in X and Y will be opposite. Multiply by -1 to change them back
    direction: mouse.WheelDirection,
    /// X coordinate, relative to window
    mouse_x: f32,
    /// Y coordinate, relative to window
    mouse_y: f32,
    /// The amount scrolled horizontally, accumulated to whole scroll "ticks" (added in 3.2.12)
    integer_x: i32,
    /// The amount scrolled vertically, accumulated to whole scroll "ticks" (added in 3.2.12)
    integer_y: i32,
};

/// Joystick axis motion event structure (event.jaxis.*)
const JoyAxisEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The joystick instance id
    which: joystick.Id,
    axis: u8,
    padding1: u8,
    padding2: u8,
    padding3: u8,
    /// The axis value (range: -32768 to 32767)
    value: i16,
    padding4: u16,
};

/// Joystick trackball motion event structure (event.jball.*)
const JoyBallEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The joystick instance id
    which: joystick.Id,
    ball: u8,
    padding1: u8,
    padding2: u8,
    padding3: u8,
    /// The relative motion in the X direction
    xrel: i16,
    /// The relative motion in the Y direction
    yrel: i16,
};

/// Joystick hat position change event structure (event.jhat.*)
const JoyHatEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The joystick instance id
    which: joystick.Id,
    hat: u8,
    /// The hat position value.
    /// Note that zero means the POV is centered.
    value: joystick.Hat,
    padding1: u8,
    padding2: u8,
};

/// Joystick button event structure (event.jbutton.*)
const JoyButtonEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The joystick instance id
    which: joystick.Id,
    button: u8,
    /// true if the button is pressed
    down: bool,
    padding1: u8,
    padding2: u8,
};

/// Joystick device event structure (event.jdevice.*)
///
/// SDL will send JOYSTICK_ADDED events for devices that are already plugged in
/// during SDL_Init.
const JoyDeviceEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The joystick instance id
    which: joystick.Id,
};

/// Joystick battery level change event structure (event.jbattery.*)
const JoyBatteryEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The joystick instance id
    which: joystick.Id,
    /// The joystick battery state
    state: power.State,
    /// The joystick battery percent charge remaining
    percent: i32,
};

/// Gamepad axis motion event structure (event.gaxis.*)
const GamepadAxisEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The joystick instance id
    which: joystick.Id,
    /// The gamepad axis (SDL_GamepadAxis)
    axis: u8,
    padding1: u8,
    padding2: u8,
    padding3: u8,
    /// The axis value (range: -32768 to 32767)
    value: i16,
    padding4: u16,
};

/// Gamepad button event structure (event.gbutton.*)
const GamepadButtonEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The joystick instance id
    which: joystick.Id,
    /// The gamepad button (SDL_GamepadButton)
    button: u8,
    /// true if the button is pressed
    down: bool,
    padding1: u8,
    padding2: u8,
};

/// Gamepad device event structure (event.gdevice.*)
///
/// Joysticks that are supported gamepads receive both an SDL_JoyDeviceEvent
/// and an SDL_GamepadDeviceEvent.
///
/// SDL will send GAMEPAD_ADDED events for joysticks that are already plugged
/// in during SDL_Init() and are recognized as gamepads. It will also send
/// events for joysticks that get gamepad mappings at runtime.
const GamepadDeviceEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The joystick instance id
    which: joystick.Id,
};

/// Gamepad touchpad event structure (event.gtouchpad.*)
const GamepadTouchpadEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The joystick instance id
    which: joystick.Id,
    /// The index of the touchpad
    touchpad: i32,
    /// The index of the finger on the touchpad
    finger: i32,
    /// Normalized in the range 0...1 with 0 being on the left
    x: f32,
    /// Normalized in the range 0...1 with 0 being at the top
    y: f32,
    /// Normalized in the range 0...1
    pressure: f32,
};

/// Gamepad sensor event structure (event.gsensor.*)
const GamepadSensorEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The joystick instance id
    which: joystick.Id,
    /// The type of the sensor, one of the values of SDL_SensorType
    sensor: i32,
    /// Up to 3 values from the sensor, as defined in SDL_sensor.h
    data: [3]f32,
    /// The timestamp of the sensor reading in nanoseconds, not necessarily synchronized with the system clock
    sensor_timestamp: u64,
};

/// Audio device event structure (event.adevice.*)
const AudioDeviceEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// SDL_AudioDeviceID for the device being added or removed or changing
    which: audio.DeviceId,
    /// false if a playback device, true if a recording device.
    recording: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

/// Camera device event structure (event.cdevice.*)
const CameraDeviceEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// sdl.camera.Id for the device being added or removed or changing
    which: camera.Id,
};

/// Renderer event structure (event.render.*)
const RenderEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window containing the renderer in question.
    windowId: video.WindowId,
};

/// Touch finger event structure (event.tfinger.*)
///
/// Coordinates in this event are normalized. `x` and `y` are normalized to a
/// range between 0.0f and 1.0f, relative to the window, so (0,0) is the top
/// left and (1,1) is the bottom right. Delta coordinates `dx` and `dy` are
/// normalized in the ranges of -1.0f (traversed all the way from the bottom or
/// right to all the way up or left) to 1.0f (traversed all the way from the
/// top or left to all the way down or right).
///
/// Note that while the coordinates are _normalized_, they are not _clamped_,
/// which means in some circumstances you can get a value outside of this
/// range. For example, a renderer using logical presentation might give a
/// negative value when the touch is in the letterboxing. Some platforms might
/// report a touch outside of the window, which will also be outside of the
/// range.
const TouchFingerEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The touch device id
    touchId: touch.Id,
    fingerId: touch.FingerId,
    /// Normalized in the range 0...1
    x: f32,
    /// Normalized in the range 0...1
    y: f32,
    /// Normalized in the range -1...1
    dx: f32,
    /// Normalized in the range -1...1
    dy: f32,
    /// Normalized in the range 0...1
    pressure: f32,
    /// The window underneath the finger, if any
    windowId: video.WindowId,
};

/// Pressure-sensitive pen proximity event structure (event.pmotion.*)
///
/// When a pen becomes visible to the system (it is close enough to a tablet,
/// etc), SDL will send an SDL_EVENT_PEN_PROXIMITY_IN event with the new pen's
/// ID. This ID is valid until the pen leaves proximity again (has been removed
/// from the tablet's area, the tablet has been unplugged, etc). If the same
/// pen reenters proximity again, it will be given a new ID.
///
/// Note that "proximity" means "close enough for the tablet to know the tool
/// is there." The pen touching and lifting off from the tablet while not
/// leaving the area are handled by SDL_EVENT_PEN_DOWN and SDL_EVENT_PEN_UP.
const PenProximityEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window with pen focus, if any
    windowId: video.WindowId,
    /// The pen instance id
    which: pen.Id,
};

/// Pressure-sensitive pen motion event structure (event.pmotion.*)
///
/// Depending on the hardware, you may get motion events when the pen is not
/// touching a tablet, for tracking a pen even when it isn't drawing. You
/// should listen for SDL_EVENT_PEN_DOWN and SDL_EVENT_PEN_UP events, or check
/// `pen_state & SDL_PEN_INPUT_DOWN` to decide if a pen is "drawing" when
/// dealing with pen motion.
const PenMotionEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window with pen focus, if any
    windowId: video.WindowId,
    /// The pen instance id
    which: pen.Id,
    /// Complete pen input state at time of event
    pen_state: pen.InputFlags,
    /// X coordinate, relative to window
    x: f32,
    /// Y coordinate, relative to window
    y: f32,
};

/// Pressure-sensitive pen touched event structure (event.ptouch.*)
///
/// These events come when a pen touches a surface (a tablet, etc), or lifts
/// off from one.
const PenTouchEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window with pen focus, if any
    windowId: video.WindowId,
    /// The pen instance id
    which: pen.Id,
    /// Complete pen input state at time of event
    pen_state: pen.InputFlags,
    /// X coordinate, relative to window
    x: f32,
    /// Y coordinate, relative to window
    y: f32,
    /// true if eraser end is used (not all pens support this).
    eraser: bool,
    /// true if the pen is touching or false if the pen is lifted off
    down: bool,
};

/// Pressure-sensitive pen button event structure (event.pbutton.*)
///
/// This is for buttons on the pen itself that the user might click. The pen
/// itself pressing down to draw triggers a SDL_EVENT_PEN_DOWN event instead.
const PenButtonEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window with mouse focus, if any
    windowId: video.WindowId,
    /// The pen instance id
    which: pen.Id,
    /// Complete pen input state at time of event
    pen_state: pen.InputFlags,
    /// X coordinate, relative to window
    x: f32,
    /// Y coordinate, relative to window
    y: f32,
    /// The pen button index (first button is 1).
    button: u8,
    /// true if the button is pressed
    down: bool,
};

/// Pressure-sensitive pen pressure / angle event structure (event.paxis.*)
///
/// You might get some of these events even if the pen isn't touching the
/// tablet.
const PenAxisEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window with pen focus, if any
    windowId: video.WindowId,
    /// The pen instance id
    which: pen.Id,
    /// Complete pen input state at time of event
    pen_state: pen.InputFlags,
    /// X coordinate, relative to window
    x: f32,
    /// Y coordinate, relative to window
    y: f32,
    /// Axis that has changed
    axis: pen.Axis,
    /// New value of axis
    value: f32,
};

/// An event used to drop text or request a file open by the system
/// (event.drop.*)
const DropEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The window that was dropped on, if any
    windowId: video.WindowId,
    /// X coordinate, relative to window (not on begin)
    x: f32,
    /// Y coordinate, relative to window (not on begin)
    y: f32,
    /// The source app that sent this drop event, or NULL if that isn't available
    source: ?[*:0]const u8,
    /// The text for SDL_EVENT_DROP_TEXT and the file name for SDL_EVENT_DROP_FILE, NULL for other events
    data: ?[*:0]const u8,
};

/// An event triggered when the clipboard contents have changed
/// (event.clipboard.*)
const ClipboardEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// are we owning the clipboard (internal update)
    owner: bool,
    /// number of mime types
    num_mime_types: i32,
    /// current mime types
    mime_types: ?[*]const [*:0]const u8,
};

/// Sensor event structure (event.sensor.*)
const SensorEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The instance ID of the sensor
    which: sensor.Id,
    /// Up to 6 values from the sensor - additional values can be queried using SDL_GetSensorData()
    data: [6]f32,
    /// The timestamp of the sensor reading in nanoseconds, not necessarily synchronized with the system clock
    sensor_timestamp: u64,
};

/// The "quit requested" event
const QuitEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
};

/// A user-defined event type (event.user.*)
///
/// This event is unique; it is never created by SDL, but only by the
/// application. The event can be pushed onto the event queue using
/// SDL_PushEvent(). The contents of the structure members are completely up to
/// the programmer; the only requirement is that '''type''' is a value obtained
/// from SDL_RegisterEvents().
const UserEvent = extern struct {
    type: EventType,
    reserved: u32,
    /// In nanoseconds, populated using sdl.ticks_ns()
    timestamp: u64,
    /// The associated window if any
    windowId: video.WindowId,
    /// User defined event code
    code: i32,
    /// User defined data pointer
    data1: ?*anyopaque,
    /// User defined data pointer
    data2: ?*anyopaque,
};

const EventType = enum(u32) {
    /// Unused (do not remove)
    First = 0,

    /// Application events
    /// User-requested quit
    Quit = 0x100,

    // These application events have special meaning on iOS and Android, see
    // README-ios.md and README-android.md for details

    /// The application is being terminated by the OS. This event must be
    /// handled in a callback set with SDL_AddEventWatch(). Called on iOS in
    /// applicationWillTerminate() Called on Android in onDestroy()
    Terminating,
    /// The application is low on memory, free memory if possible. This event
    /// must be handled in a callback set with SDL_AddEventWatch(). Called on
    /// iOS in applicationDidReceiveMemoryWarning() Called on Android in
    /// onTrimMemory()
    LowMemory,
    /// The application is about to enter the background. This event must be
    /// handled in a callback set with SDL_AddEventWatch(). Called on iOS in
    /// applicationWillResignActive() Called on Android in onPause()
    WillEnterBackground,
    /// The application did enter the background and may not get CPU for some
    /// time. This event must be handled in a callback set with
    /// SDL_AddEventWatch(). Called on iOS in applicationDidEnterBackground()
    /// Called on Android in onPause()
    DidEnterBackground,
    /// The application is about to enter the foreground. This event must be
    /// handled in a callback set with SDL_AddEventWatch(). Called on iOS in
    /// applicationWillEnterForeground() Called on Android in onResume()
    WillEnterForeground,
    /// The application is now interactive. This event must be handled in a
    /// callback set with SDL_AddEventWatch(). Called on iOS in
    /// applicationDidBecomeActive() Called on Android in onResume()
    DidEnterForeground,

    /// The user's locale preferences have changed.
    LocaleChanged,

    /// The system theme changed
    SystemThemeChanged,

    // Display events
    // 0x150 was SDL_DISPLAYEVENT, reserve the number for sdl2-compat

    /// Display orientation has changed to data1
    DisplayOrientation = 0x151,
    /// Display has been added to the system
    DisplayAdded,
    /// Display has been removed from the system
    DisplayRemoved,
    /// Display has changed position
    DisplayMoved,
    /// Display has changed desktop mode
    DisplayDesktopModeChanged,
    /// Display has changed current mode
    DisplayCurrentModeChanged,
    /// Display has changed content scale
    DisplayContentScaleChanged,
    // DisplayFirst = DisplayOrientation,
    // DisplayLast = DisplayContentScaleChanged,

    // Window events
    // 0x200 was SDL_WINDOWEVENT, reserve the number for sdl2-compat
    // 0x201 was SDL_SYSWMEVENT, reserve the number for sdl2-compat

    /// Window has been shown
    WindowShown = 0x202,
    /// Window has been hidden
    WindowHidden,
    /// Window has been exposed and should be redrawn, and can be redrawn
    /// directly from event watchers for this event
    WindowExposed,
    /// Window has been moved to data1, data2
    WindowMoved,
    /// Window has been resized to data1xdata2
    WindowResized,
    /// The pixel size of the window has changed to data1xdata2
    WindowPixelSizeChanged,
    /// The pixel size of a Metal view associated with the window has changed
    WindowMetalViewResized,
    /// Window has been minimized
    WindowMinimized,
    /// Window has been maximized
    WindowMaximized,
    /// Window has been restored to normal size and position
    WindowRestored,
    /// Window has gained mouse focus
    WindowMouseEnter,
    /// Window has lost mouse focus
    WindowMouseLeave,
    /// Window has gained keyboard focus
    WindowFocusGained,
    /// Window has lost keyboard focus
    WindowFocusLost,
    /// The window manager requests that the window be closed
    WindowCloseRequested,
    /// Window had a hit test that wasn't SDL_HITTEST_NORMAL
    WindowHitTest,
    /// The ICC profile of the window's display has changed
    WindowIccprofChanged,
    /// Window has been moved to display data1
    WindowDisplayChanged,
    /// Window display scale has been changed
    WindowDisplayScaleChanged,
    /// The window safe area has been changed
    WindowSafeAreaChanged,
    /// The window has been occluded
    WindowOccluded,
    /// The window has entered fullscreen mode
    WindowEnterFullscreen,
    /// The window has left fullscreen mode
    WindowLeaveFullscreen,
    /// The window with the associated ID is being or has been destroyed. If
    /// this message is being handled in an event watcher, the window handle is
    /// still valid and can still be used to retrieve any properties associated
    /// with the window. Otherwise, the handle has already been destroyed and
    /// all resources associated with it are invalid
    WindowDestroyed,
    /// Window HDR properties have changed
    WindowHdrStateChanged,
    // WindowFirst = WindowShown,
    // WindowLast = WindowHdrStateChanged,

    // Keyboard events

    /// Key pressed
    KeyDown = 0x300,
    /// Key released
    KeyUp,
    /// Keyboard text editing (composition)
    TextEditing,
    /// Keyboard text input
    TextInput,
    /// Keymap changed due to a system event such as an input language or keyboard layout change.
    KeymapChanged,
    /// A new keyboard has been inserted into the system
    KeyboardAdded,
    /// A keyboard has been removed
    KeyboardRemoved,
    /// Keyboard text editing candidates
    TextEditingCandidates,

    // Mouse events

    /// Mouse moved
    MouseMotion = 0x400,
    /// Mouse button pressed
    MouseButtonDown,
    /// Mouse button released
    MouseButtonUp,
    /// Mouse wheel motion
    MouseWheel,
    /// A new mouse has been inserted into the system
    MouseAdded,
    /// A mouse has been removed
    MouseRemoved,

    // Joystick events

    /// Joystick axis motion
    JoystickAxisMotion = 0x600,
    /// Joystick trackball motion
    JoystickBallMotion,
    /// Joystick hat position change
    JoystickHatMotion,
    /// Joystick button pressed
    JoystickButtonDown,
    /// Joystick button released
    JoystickButtonUp,
    /// A new joystick has been inserted into the system
    JoystickAdded,
    /// An opened joystick has been removed
    JoystickRemoved,
    /// Joystick battery level change
    JoystickBatteryUpdated,
    /// Joystick update is complete
    JoystickUpdateComplete,

    // Gamepad events

    /// Gamepad axis motion
    GamepadAxisMotion = 0x650,
    /// Gamepad button pressed
    GamepadButtonDown,
    /// Gamepad button released
    GamepadButtonUp,
    /// A new gamepad has been inserted into the system
    GamepadAdded,
    /// A gamepad has been removed
    GamepadRemoved,
    /// The gamepad mapping was updated
    GamepadRemapped,
    /// Gamepad touchpad was touched
    GamepadTouchpadDown,
    /// Gamepad touchpad finger was moved
    GamepadTouchpadMotion,
    /// Gamepad touchpad finger was lifted
    GamepadTouchpadUp,
    /// Gamepad sensor was updated
    GamepadSensorUpdate,
    /// Gamepad update is complete
    GamepadUpdateComplete,
    /// Gamepad Steam handle has changed
    GamepadSteamHandleUpdated,

    // Touch events

    FingerDown = 0x700,
    FingerUp,
    FingerMotion,
    FingerCanceled,

    // 0x800, 0x801, and 0x802 were the Gesture events from SDL2. Do not reuse
    // these values! sdl2-compat needs them!
    // Clipboard events

    /// The clipboard or primary selection changed
    ClipboardUpdate = 0x900,

    // Drag and drop events

    /// The system requests a file open
    DropFile = 0x1000,
    /// text/plain drag-and-drop event
    DropText,
    /// A new set of drops is beginning (NULL filename)
    DropBegin,
    /// Current set of drops is now complete (NULL filename)
    DropComplete,
    /// Position while moving over the window
    DropPosition,

    // Audio hotplug events

    /// A new audio device is available
    AudioDeviceAdded = 0x1100,
    /// An audio device has been removed.
    AudioDeviceRemoved,
    /// An audio device's format has been changed by the system.
    AudioDeviceFormatChanged,

    // Sensor events

    /// A sensor was updated
    SensorUpdate = 0x1200,

    // Pressure-sensitive pen events

    /// Pressure-sensitive pen has become available
    PenProximityIn = 0x1300,
    /// Pressure-sensitive pen has become unavailable
    PenProximityOut,
    /// Pressure-sensitive pen touched drawing surface
    PenDown,
    /// Pressure-sensitive pen stopped touching drawing surface
    PenUp,
    /// Pressure-sensitive pen button pressed
    PenButtonDown,
    /// Pressure-sensitive pen button released
    PenButtonUp,
    /// Pressure-sensitive pen is moving on the tablet
    PenMotion,
    /// Pressure-sensitive pen angle/pressure/etc changed
    PenAxis,

    // Camera hotplug events

    /// A new camera device is available
    CameraDeviceAdded = 0x1400,
    /// A camera device has been removed.
    CameraDeviceRemoved,
    /// A camera device has been approved for use by the user.
    CameraDeviceApproved,
    /// A camera device has been denied for use by the user.
    CameraDeviceDenied,

    // Render events

    /// The render targets have been reset and their contents need to be
    /// updated
    RenderTargetsReset = 0x2000,
    /// The device has been reset and all textures need to be recreated
    RenderDeviceReset,
    /// The device has been lost and can't be recovered.
    RenderDeviceLost,

    /// Reserved events for private platforms
    Private0 = 0x4000,
    Private1,
    Private2,
    Private3,

    // Internal events

    /// Signals the end of an event poll cycle
    PollSentinel = 0x7f00,

    /// Events SDL_EVENT_USER through SDL_EVENT_LAST are for your use, and
    /// should be allocated with SDL_RegisterEvents()
    User = 0x8000,

    /// This last event is only for bounding internal arrays
    Last = 0xffff,

    /// This just makes sure the enum is the size of Uint32
    EnumPadding = 0x7FFFFFFF,
    _,
};
