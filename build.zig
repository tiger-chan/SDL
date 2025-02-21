// © 2024 Carl Åstholm
// SPDX-License-Identifier: MIT

const std = @import("std");

pub const version: std.SemanticVersion = .{ .major = 3, .minor = 2, .patch = 4 };
const formatted_version = std.fmt.comptimePrint("SDL-{}", .{version});
pub const vendor_info = "https://github.com/castholm/SDL 0.1.5";
pub const revision = formatted_version ++ " (" ++ vendor_info ++ ")";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const preferred_link_mode = b.option(
        std.builtin.LinkMode,
        "preferred_link_mode",
        "Prefer building SDL as a statically or dynamically linked library (default: static)",
    ) orelse .static;
    const install_build_config_h = b.option(
        bool,
        "install_build_config_h",
        "Additionally install 'SDL_build_config.h' when installing SDL (default: false)",
    ) orelse false;

    var windows = false;
    var linux = false;
    var macos = false;
    var lazy_linux_deps_dep: ?*std.Build.Dependency = null;
    var lazy_linux_deps_values: ?LinuxDepsValues = null;
    switch (target.result.os.tag) {
        .windows => {
            windows = true;
        },
        .linux => {
            linux = true;
            if (b.lazyImport(@This(), "sdl_linux_deps")) |build_zig| {
                lazy_linux_deps_dep = b.dependencyFromBuildZig(build_zig, .{});
                lazy_linux_deps_values = LinuxDepsValues.fromBuildZig(build_zig);
            }
        },
        .macos => {
            macos = true;
        },
        else => {},
    }

    const build_config_h: *std.Build.Step.ConfigHeader = build_config_h: {
        const cpu = target.result.cpu;
        const x86 = cpu.arch.isX86();
        const arm = if (@hasDecl(@TypeOf(cpu.arch), "isArm")) cpu.arch.isArm() else cpu.arch.isArmOrThumb(); // Zig 0.13.0 compat
        const aarch64 = cpu.arch.isAARCH64();
        const loongarch = cpu.arch == .loongarch32 or cpu.arch == .loongarch64;
        break :build_config_h b.addConfigHeader(.{
            .style = .{ .cmake = b.path("include/build_config/SDL_build_config.h.cmake") },
            .include_path = "SDL_build_config.h",
        }, .{
            .HAVE_GCC_ATOMICS = windows or linux or macos,
            .HAVE_GCC_SYNC_LOCK_TEST_AND_SET = false,
            .SDL_DISABLE_ALLOCA = false,
            .HAVE_FLOAT_H = windows or linux or macos,
            .HAVE_STDARG_H = windows or linux or macos,
            .HAVE_STDDEF_H = windows or linux or macos,
            .HAVE_STDINT_H = windows or linux or macos,
            .HAVE_LIBC = windows or linux or macos,
            .HAVE_ALLOCA_H = linux or macos,
            .HAVE_ICONV_H = linux or macos,
            .HAVE_INTTYPES_H = windows or linux or macos,
            .HAVE_LIMITS_H = windows or linux or macos,
            .HAVE_MALLOC_H = windows or linux,
            .HAVE_MATH_H = windows or linux or macos,
            .HAVE_MEMORY_H = windows or linux or macos,
            .HAVE_SIGNAL_H = windows or linux or macos,
            .HAVE_STDIO_H = windows or linux or macos,
            .HAVE_STDLIB_H = windows or linux or macos,
            .HAVE_STRINGS_H = windows or linux or macos,
            .HAVE_STRING_H = windows or linux or macos,
            .HAVE_SYS_TYPES_H = windows or linux or macos,
            .HAVE_WCHAR_H = windows or linux or macos,
            .HAVE_PTHREAD_NP_H = false,
            .HAVE_DLOPEN = linux or macos,
            .HAVE_MALLOC = windows or linux or macos,
            .HAVE_FDATASYNC = linux,
            .HAVE_GETENV = windows or linux or macos,
            .HAVE_GETHOSTNAME = linux or macos,
            .HAVE_SETENV = linux or macos,
            .HAVE_PUTENV = windows or linux or macos,
            .HAVE_UNSETENV = linux or macos,
            .HAVE_ABS = windows or linux or macos,
            .HAVE_BCOPY = linux or macos,
            .HAVE_MEMSET = windows or linux or macos,
            .HAVE_MEMCPY = windows or linux or macos,
            .HAVE_MEMMOVE = windows or linux or macos,
            .HAVE_MEMCMP = windows or linux or macos,
            .HAVE_WCSLEN = windows or linux or macos,
            .HAVE_WCSNLEN = windows or linux or macos,
            .HAVE_WCSLCPY = macos,
            .HAVE_WCSLCAT = macos,
            .HAVE_WCSSTR = windows or linux or macos,
            .HAVE_WCSCMP = windows or linux or macos,
            .HAVE_WCSNCMP = windows or linux or macos,
            .HAVE_WCSTOL = windows or linux or macos,
            .HAVE_STRLEN = windows or linux or macos,
            .HAVE_STRNLEN = windows or linux or macos,
            .HAVE_STRLCPY = macos,
            .HAVE_STRLCAT = macos,
            .HAVE_STRPBRK = windows or linux or macos,
            .HAVE__STRREV = windows,
            .HAVE_INDEX = linux or macos,
            .HAVE_RINDEX = linux or macos,
            .HAVE_STRCHR = windows or linux or macos,
            .HAVE_STRRCHR = windows or linux or macos,
            .HAVE_STRSTR = windows or linux or macos,
            .HAVE_STRNSTR = macos,
            .HAVE_STRTOK_R = windows or linux or macos,
            .HAVE_ITOA = windows,
            .HAVE__LTOA = windows,
            .HAVE__UITOA = false,
            .HAVE__ULTOA = windows,
            .HAVE_STRTOL = windows or linux or macos,
            .HAVE_STRTOUL = windows or linux or macos,
            .HAVE__I64TOA = windows,
            .HAVE__UI64TOA = windows,
            .HAVE_STRTOLL = windows or linux or macos,
            .HAVE_STRTOULL = windows or linux or macos,
            .HAVE_STRTOD = windows or linux or macos,
            .HAVE_ATOI = windows or linux or macos,
            .HAVE_ATOF = windows or linux or macos,
            .HAVE_STRCMP = windows or linux or macos,
            .HAVE_STRNCMP = windows or linux or macos,
            .HAVE_VSSCANF = windows or linux or macos,
            .HAVE_VSNPRINTF = windows or linux or macos,
            .HAVE_ACOS = windows or linux or macos,
            .HAVE_ACOSF = windows or linux or macos,
            .HAVE_ASIN = windows or linux or macos,
            .HAVE_ASINF = windows or linux or macos,
            .HAVE_ATAN = windows or linux or macos,
            .HAVE_ATANF = windows or linux or macos,
            .HAVE_ATAN2 = windows or linux or macos,
            .HAVE_ATAN2F = windows or linux or macos,
            .HAVE_CEIL = windows or linux or macos,
            .HAVE_CEILF = windows or linux or macos,
            .HAVE_COPYSIGN = windows or linux or macos,
            .HAVE_COPYSIGNF = windows or linux or macos,
            .HAVE__COPYSIGN = windows,
            .HAVE_COS = windows or linux or macos,
            .HAVE_COSF = windows or linux or macos,
            .HAVE_EXP = windows or linux or macos,
            .HAVE_EXPF = windows or linux or macos,
            .HAVE_FABS = windows or linux or macos,
            .HAVE_FABSF = windows or linux or macos,
            .HAVE_FLOOR = windows or linux or macos,
            .HAVE_FLOORF = windows or linux or macos,
            .HAVE_FMOD = windows or linux or macos,
            .HAVE_FMODF = windows or linux or macos,
            .HAVE_ISINF = windows or linux or macos,
            .HAVE_ISINFF = linux,
            .HAVE_ISINF_FLOAT_MACRO = windows or linux or macos,
            .HAVE_ISNAN = windows or linux or macos,
            .HAVE_ISNANF = linux,
            .HAVE_ISNAN_FLOAT_MACRO = windows or linux or macos,
            .HAVE_LOG = windows or linux or macos,
            .HAVE_LOGF = windows or linux or macos,
            .HAVE_LOG10 = windows or linux or macos,
            .HAVE_LOG10F = windows or linux or macos,
            .HAVE_LROUND = windows or linux or macos,
            .HAVE_LROUNDF = windows or linux or macos,
            .HAVE_MODF = windows or linux or macos,
            .HAVE_MODFF = windows or linux or macos,
            .HAVE_POW = windows or linux or macos,
            .HAVE_POWF = windows or linux or macos,
            .HAVE_ROUND = windows or linux or macos,
            .HAVE_ROUNDF = windows or linux or macos,
            .HAVE_SCALBN = windows or linux or macos,
            .HAVE_SCALBNF = windows or linux or macos,
            .HAVE_SIN = windows or linux or macos,
            .HAVE_SINF = windows or linux or macos,
            .HAVE_SQRT = windows or linux or macos,
            .HAVE_SQRTF = windows or linux or macos,
            .HAVE_TAN = windows or linux or macos,
            .HAVE_TANF = windows or linux or macos,
            .HAVE_TRUNC = windows or linux or macos,
            .HAVE_TRUNCF = windows or linux or macos,
            .HAVE__FSEEKI64 = windows,
            .HAVE_FOPEN64 = windows or linux,
            .HAVE_FSEEKO = windows or linux or macos,
            .HAVE_FSEEKO64 = windows or linux,
            .HAVE_MEMFD_CREATE = linux,
            .HAVE_POSIX_FALLOCATE = linux,
            .HAVE_SIGACTION = linux or macos,
            .HAVE_SA_SIGACTION = linux or macos,
            .HAVE_ST_MTIM = linux,
            .HAVE_SETJMP = linux or macos,
            .HAVE_NANOSLEEP = linux or macos,
            .HAVE_GMTIME_R = linux or macos,
            .HAVE_LOCALTIME_R = linux or macos,
            .HAVE_NL_LANGINFO = linux or macos,
            .HAVE_SYSCONF = linux or macos,
            .HAVE_SYSCTLBYNAME = macos,
            .HAVE_CLOCK_GETTIME = linux,
            .HAVE_GETPAGESIZE = linux or macos,
            .HAVE_ICONV = linux,
            .SDL_USE_LIBICONV = false,
            .HAVE_PTHREAD_SETNAME_NP = linux or macos,
            .HAVE_PTHREAD_SET_NAME_NP = false,
            .HAVE_SEM_TIMEDWAIT = linux,
            .HAVE_GETAUXVAL = linux,
            .HAVE_ELF_AUX_INFO = false,
            .HAVE_POLL = linux or macos,
            .HAVE__EXIT = windows or linux or macos,
            .HAVE_DBUS_DBUS_H = linux,
            .HAVE_FCITX = linux,
            .HAVE_IBUS_IBUS_H = linux,
            .HAVE_INOTIFY_INIT1 = linux,
            .HAVE_INOTIFY = linux,
            .HAVE_LIBUSB = linux,
            .HAVE_O_CLOEXEC = linux or macos,
            .HAVE_LINUX_INPUT_H = linux,
            .HAVE_LIBUDEV_H = linux,
            .HAVE_LIBDECOR_H = linux,
            .HAVE_LIBURING_H = linux,
            .HAVE_DDRAW_H = windows,
            .HAVE_DSOUND_H = windows,
            .HAVE_DINPUT_H = windows,
            .HAVE_XINPUT_H = windows,
            .HAVE_WINDOWS_GAMING_INPUT_H = false,
            .HAVE_GAMEINPUT_H = false,
            .HAVE_DXGI_H = windows,
            .HAVE_DXGI1_6_H = windows,
            .HAVE_MMDEVICEAPI_H = windows,
            .HAVE_TPCSHRD_H = windows,
            .HAVE_ROAPI_H = windows,
            .HAVE_SHELLSCALINGAPI_H = windows,
            .USE_POSIX_SPAWN = false,
            .SDL_DEFAULT_ASSERT_LEVEL_CONFIGURED = false,
            .SDL_DEFAULT_ASSERT_LEVEL = null,
            .SDL_AUDIO_DISABLED = false,
            .SDL_VIDEO_DISABLED = false,
            .SDL_GPU_DISABLED = false,
            .SDL_RENDER_DISABLED = false,
            .SDL_CAMERA_DISABLED = false,
            .SDL_JOYSTICK_DISABLED = false,
            .SDL_HAPTIC_DISABLED = false,
            .SDL_HIDAPI_DISABLED = false,
            .SDL_POWER_DISABLED = false,
            .SDL_SENSOR_DISABLED = false,
            .SDL_DIALOG_DISABLED = false,
            .SDL_THREADS_DISABLED = false,
            .SDL_AUDIO_DRIVER_ALSA = linux,
            .SDL_AUDIO_DRIVER_ALSA_DYNAMIC = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.alsa_soname}) else "",
            .SDL_AUDIO_DRIVER_OPENSLES = false,
            .SDL_AUDIO_DRIVER_AAUDIO = false,
            .SDL_AUDIO_DRIVER_COREAUDIO = macos,
            .SDL_AUDIO_DRIVER_DISK = windows or linux or macos,
            .SDL_AUDIO_DRIVER_DSOUND = windows,
            .SDL_AUDIO_DRIVER_DUMMY = windows or linux or macos,
            .SDL_AUDIO_DRIVER_EMSCRIPTEN = false,
            .SDL_AUDIO_DRIVER_HAIKU = false,
            .SDL_AUDIO_DRIVER_JACK = linux,
            .SDL_AUDIO_DRIVER_JACK_DYNAMIC = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.jack_soname}) else "",
            .SDL_AUDIO_DRIVER_NETBSD = false,
            .SDL_AUDIO_DRIVER_OSS = false,
            .SDL_AUDIO_DRIVER_PIPEWIRE = linux,
            .SDL_AUDIO_DRIVER_PIPEWIRE_DYNAMIC = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.pipewire_soname}) else "",
            .SDL_AUDIO_DRIVER_PULSEAUDIO = linux,
            .SDL_AUDIO_DRIVER_PULSEAUDIO_DYNAMIC = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.pulseaudio_soname}) else "",
            .SDL_AUDIO_DRIVER_SNDIO = linux,
            .SDL_AUDIO_DRIVER_SNDIO_DYNAMIC = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.sndio_soname}) else "",
            .SDL_AUDIO_DRIVER_WASAPI = windows,
            .SDL_AUDIO_DRIVER_VITA = false,
            .SDL_AUDIO_DRIVER_PSP = false,
            .SDL_AUDIO_DRIVER_PS2 = false,
            .SDL_AUDIO_DRIVER_N3DS = false,
            .SDL_AUDIO_DRIVER_QNX = false,
            .SDL_INPUT_LINUXEV = linux,
            .SDL_INPUT_LINUXKD = linux,
            .SDL_INPUT_FBSDKBIO = false,
            .SDL_INPUT_WSCONS = false,
            .SDL_HAVE_MACHINE_JOYSTICK_H = false,
            .SDL_JOYSTICK_ANDROID = false,
            .SDL_JOYSTICK_DINPUT = windows,
            .SDL_JOYSTICK_DUMMY = false,
            .SDL_JOYSTICK_EMSCRIPTEN = false,
            .SDL_JOYSTICK_GAMEINPUT = false,
            .SDL_JOYSTICK_HAIKU = false,
            .SDL_JOYSTICK_HIDAPI = windows or linux or macos,
            .SDL_JOYSTICK_IOKIT = macos,
            .SDL_JOYSTICK_LINUX = linux,
            .SDL_JOYSTICK_MFI = macos,
            .SDL_JOYSTICK_N3DS = false,
            .SDL_JOYSTICK_PS2 = false,
            .SDL_JOYSTICK_PSP = false,
            .SDL_JOYSTICK_RAWINPUT = windows,
            .SDL_JOYSTICK_USBHID = false,
            .SDL_JOYSTICK_VIRTUAL = windows or linux or macos,
            .SDL_JOYSTICK_VITA = false,
            .SDL_JOYSTICK_WGI = false,
            .SDL_JOYSTICK_XINPUT = windows,
            .SDL_HAPTIC_DUMMY = false,
            .SDL_HAPTIC_LINUX = linux,
            .SDL_HAPTIC_IOKIT = macos,
            .SDL_HAPTIC_DINPUT = windows,
            .SDL_HAPTIC_ANDROID = false,
            .SDL_LIBUSB_DYNAMIC = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.libusb_soname}) else "",
            .SDL_UDEV_DYNAMIC = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.libudev_soname}) else "",
            .SDL_PROCESS_DUMMY = false,
            .SDL_PROCESS_POSIX = linux or macos,
            .SDL_PROCESS_WINDOWS = windows,
            .SDL_SENSOR_ANDROID = false,
            .SDL_SENSOR_COREMOTION = false,
            .SDL_SENSOR_WINDOWS = windows,
            .SDL_SENSOR_DUMMY = linux or macos,
            .SDL_SENSOR_VITA = false,
            .SDL_SENSOR_N3DS = false,
            .SDL_LOADSO_DLOPEN = linux or macos,
            .SDL_LOADSO_DUMMY = false,
            .SDL_LOADSO_WINDOWS = windows,
            .SDL_THREAD_GENERIC_COND_SUFFIX = windows,
            .SDL_THREAD_GENERIC_RWLOCK_SUFFIX = windows,
            .SDL_THREAD_PTHREAD = linux or macos,
            .SDL_THREAD_PTHREAD_RECURSIVE_MUTEX = linux or macos,
            .SDL_THREAD_PTHREAD_RECURSIVE_MUTEX_NP = false,
            .SDL_THREAD_WINDOWS = windows,
            .SDL_THREAD_VITA = false,
            .SDL_THREAD_PSP = false,
            .SDL_THREAD_PS2 = false,
            .SDL_THREAD_N3DS = false,
            .SDL_TIME_UNIX = linux or macos,
            .SDL_TIME_WINDOWS = windows,
            .SDL_TIME_VITA = false,
            .SDL_TIME_PSP = false,
            .SDL_TIME_PS2 = false,
            .SDL_TIME_N3DS = false,
            .SDL_TIMER_HAIKU = false,
            .SDL_TIMER_UNIX = linux or macos,
            .SDL_TIMER_WINDOWS = windows,
            .SDL_TIMER_VITA = false,
            .SDL_TIMER_PSP = false,
            .SDL_TIMER_PS2 = false,
            .SDL_TIMER_N3DS = false,
            .SDL_VIDEO_DRIVER_ANDROID = false,
            .SDL_VIDEO_DRIVER_COCOA = macos,
            .SDL_VIDEO_DRIVER_DUMMY = windows or linux or macos,
            .SDL_VIDEO_DRIVER_EMSCRIPTEN = false,
            .SDL_VIDEO_DRIVER_HAIKU = false,
            .SDL_VIDEO_DRIVER_KMSDRM = linux,
            .SDL_VIDEO_DRIVER_KMSDRM_DYNAMIC = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.drm_soname}) else "",
            .SDL_VIDEO_DRIVER_KMSDRM_DYNAMIC_GBM = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.gbm_soname}) else "",
            .SDL_VIDEO_DRIVER_N3DS = false,
            .SDL_VIDEO_DRIVER_OFFSCREEN = windows or linux or macos,
            .SDL_VIDEO_DRIVER_PS2 = false,
            .SDL_VIDEO_DRIVER_PSP = false,
            .SDL_VIDEO_DRIVER_RISCOS = false,
            .SDL_VIDEO_DRIVER_ROCKCHIP = false,
            .SDL_VIDEO_DRIVER_RPI = false,
            .SDL_VIDEO_DRIVER_UIKIT = false,
            .SDL_VIDEO_DRIVER_VITA = false,
            .SDL_VIDEO_DRIVER_VIVANTE = false,
            .SDL_VIDEO_DRIVER_VIVANTE_VDK = false,
            .SDL_VIDEO_DRIVER_OPENVR = false,
            .SDL_VIDEO_DRIVER_WAYLAND = linux,
            .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.wayland_client_soname}) else "",
            .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_CURSOR = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.wayland_cursor_soname}) else "",
            .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_EGL = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.wayland_egl_soname}) else "",
            .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_LIBDECOR = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.libdecor_soname}) else "",
            .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_XKBCOMMON = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.xkbcommon_soname}) else "",
            .SDL_VIDEO_DRIVER_WINDOWS = windows,
            .SDL_VIDEO_DRIVER_X11 = linux,
            .SDL_VIDEO_DRIVER_X11_DYNAMIC = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.x11_soname}) else "",
            .SDL_VIDEO_DRIVER_X11_DYNAMIC_XCURSOR = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.xcursor_soname}) else "",
            .SDL_VIDEO_DRIVER_X11_DYNAMIC_XEXT = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.xext_soname}) else "",
            .SDL_VIDEO_DRIVER_X11_DYNAMIC_XFIXES = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.xfixes_soname}) else "",
            .SDL_VIDEO_DRIVER_X11_DYNAMIC_XINPUT2 = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.xi_soname}) else "",
            .SDL_VIDEO_DRIVER_X11_DYNAMIC_XRANDR = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.xrandr_soname}) else "",
            .SDL_VIDEO_DRIVER_X11_DYNAMIC_XSS = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.xss_soname}) else "",
            .SDL_VIDEO_DRIVER_X11_HAS_XKBLOOKUPKEYSYM = linux,
            .SDL_VIDEO_DRIVER_X11_SUPPORTS_GENERIC_EVENTS = linux,
            .SDL_VIDEO_DRIVER_X11_XCURSOR = linux,
            .SDL_VIDEO_DRIVER_X11_XDBE = linux,
            .SDL_VIDEO_DRIVER_X11_XFIXES = linux,
            .SDL_VIDEO_DRIVER_X11_XINPUT2 = linux,
            .SDL_VIDEO_DRIVER_X11_XINPUT2_SUPPORTS_MULTITOUCH = linux,
            .SDL_VIDEO_DRIVER_X11_XRANDR = linux,
            .SDL_VIDEO_DRIVER_X11_XSCRNSAVER = linux,
            .SDL_VIDEO_DRIVER_X11_XSHAPE = linux,
            .SDL_VIDEO_DRIVER_X11_XSYNC = linux,
            .SDL_VIDEO_DRIVER_QNX = false,
            .SDL_VIDEO_RENDER_D3D = windows,
            .SDL_VIDEO_RENDER_D3D11 = windows,
            .SDL_VIDEO_RENDER_D3D12 = windows,
            .SDL_VIDEO_RENDER_GPU = windows or linux or macos,
            .SDL_VIDEO_RENDER_METAL = macos,
            .SDL_VIDEO_RENDER_VULKAN = windows or linux or macos,
            .SDL_VIDEO_RENDER_OGL = windows or linux or macos,
            .SDL_VIDEO_RENDER_OGL_ES2 = windows or linux or macos,
            .SDL_VIDEO_RENDER_PS2 = false,
            .SDL_VIDEO_RENDER_PSP = false,
            .SDL_VIDEO_RENDER_VITA_GXM = false,
            .SDL_VIDEO_OPENGL = windows or linux or macos,
            .SDL_VIDEO_OPENGL_ES = linux,
            .SDL_VIDEO_OPENGL_ES2 = windows or linux or macos,
            .SDL_VIDEO_OPENGL_CGL = macos,
            .SDL_VIDEO_OPENGL_GLX = linux,
            .SDL_VIDEO_OPENGL_WGL = windows,
            .SDL_VIDEO_OPENGL_EGL = windows or linux or macos,
            .SDL_VIDEO_VULKAN = windows or linux or macos,
            .SDL_VIDEO_METAL = macos,
            .SDL_GPU_D3D11 = windows,
            .SDL_GPU_D3D12 = windows,
            .SDL_GPU_VULKAN = windows or linux or macos,
            .SDL_GPU_METAL = macos,
            .SDL_POWER_ANDROID = false,
            .SDL_POWER_LINUX = linux,
            .SDL_POWER_WINDOWS = windows,
            .SDL_POWER_MACOSX = macos,
            .SDL_POWER_UIKIT = false,
            .SDL_POWER_HAIKU = false,
            .SDL_POWER_EMSCRIPTEN = false,
            .SDL_POWER_HARDWIRED = false,
            .SDL_POWER_VITA = false,
            .SDL_POWER_PSP = false,
            .SDL_POWER_N3DS = false,
            .SDL_FILESYSTEM_ANDROID = false,
            .SDL_FILESYSTEM_HAIKU = false,
            .SDL_FILESYSTEM_COCOA = macos,
            .SDL_FILESYSTEM_DUMMY = false,
            .SDL_FILESYSTEM_RISCOS = false,
            .SDL_FILESYSTEM_UNIX = linux,
            .SDL_FILESYSTEM_WINDOWS = windows,
            .SDL_FILESYSTEM_EMSCRIPTEN = false,
            .SDL_FILESYSTEM_VITA = false,
            .SDL_FILESYSTEM_PSP = false,
            .SDL_FILESYSTEM_PS2 = false,
            .SDL_FILESYSTEM_N3DS = false,
            .SDL_STORAGE_STEAM = windows or linux or macos,
            .SDL_FSOPS_POSIX = linux or macos,
            .SDL_FSOPS_WINDOWS = windows,
            .SDL_FSOPS_DUMMY = false,
            .SDL_CAMERA_DRIVER_DUMMY = windows or linux or macos,
            .SDL_CAMERA_DRIVER_DISK = false,
            .SDL_CAMERA_DRIVER_V4L2 = linux,
            .SDL_CAMERA_DRIVER_COREMEDIA = macos,
            .SDL_CAMERA_DRIVER_ANDROID = false,
            .SDL_CAMERA_DRIVER_EMSCRIPTEN = false,
            .SDL_CAMERA_DRIVER_MEDIAFOUNDATION = windows,
            .SDL_CAMERA_DRIVER_PIPEWIRE = linux,
            .SDL_CAMERA_DRIVER_PIPEWIRE_DYNAMIC = if (lazy_linux_deps_values) |x| b.fmt("\"{s}\"", .{x.pipewire_soname}) else "",
            .SDL_CAMERA_DRIVER_VITA = false,
            .SDL_DIALOG_DUMMY = false,
            .SDL_ALTIVEC_BLITTERS = false,
            .DYNAPI_NEEDS_DLOPEN = linux or macos,
            .SDL_USE_IME = linux,
            .SDL_DISABLE_WINDOWS_IME = false,
            .SDL_GDK_TEXTINPUT = false,
            .SDL_IPHONE_KEYBOARD = false,
            .SDL_IPHONE_LAUNCHSCREEN = false,
            .SDL_VIDEO_VITA_PIB = false,
            .SDL_VIDEO_VITA_PVR = false,
            .SDL_VIDEO_VITA_PVR_OGL = false,
            .SDL_LIBDECOR_VERSION_MAJOR = if (lazy_linux_deps_values) |x| @as(i64, @intCast(x.libdecor_version.major)) else null,
            .SDL_LIBDECOR_VERSION_MINOR = if (lazy_linux_deps_values) |x| @as(i64, @intCast(x.libdecor_version.minor)) else null,
            .SDL_LIBDECOR_VERSION_PATCH = if (lazy_linux_deps_values) |x| @as(i64, @intCast(x.libdecor_version.patch)) else null,
            .SDL_DISABLE_SSE = !(x86 and std.Target.x86.featureSetHas(cpu.features, .sse)),
            .SDL_DISABLE_SSE2 = !(x86 and std.Target.x86.featureSetHas(cpu.features, .sse2)),
            .SDL_DISABLE_SSE3 = !(x86 and std.Target.x86.featureSetHas(cpu.features, .sse3)),
            .SDL_DISABLE_SSE4_1 = !(x86 and std.Target.x86.featureSetHas(cpu.features, .sse4_1)),
            .SDL_DISABLE_SSE4_2 = !(x86 and std.Target.x86.featureSetHas(cpu.features, .sse4_2)),
            .SDL_DISABLE_AVX = !(x86 and std.Target.x86.featureSetHas(cpu.features, .avx)),
            .SDL_DISABLE_AVX2 = !(x86 and std.Target.x86.featureSetHas(cpu.features, .avx2)),
            .SDL_DISABLE_AVX512F = !(x86 and std.Target.x86.featureSetHas(cpu.features, .avx512f)),
            .SDL_DISABLE_MMX = !(x86 and std.Target.x86.featureSetHas(cpu.features, .mmx)),
            .SDL_DISABLE_LSX = !(loongarch and std.Target.loongarch.featureSetHas(cpu.features, .lsx)),
            .SDL_DISABLE_LASX = !(loongarch and std.Target.loongarch.featureSetHas(cpu.features, .lasx)),
            .SDL_DISABLE_NEON = !(arm and std.Target.arm.featureSetHas(cpu.features, .neon) or aarch64 and std.Target.aarch64.featureSetHas(cpu.features, .neon)),
        });
    };

    const revision_h = b.addConfigHeader(.{
        .style = .{ .cmake = b.path("include/build_config/SDL_revision.h.cmake") },
        .include_path = "SDL3/SDL_revision.h",
    }, .{
        .SDL_VENDOR_INFO = vendor_info,
        .SDL_REVISION = formatted_version,
    });

    const common_c_flags = .{
        "-Wall",
        "-Wundef",
        "-Wfloat-conversion",
        "-fno-strict-aliasing",
        "-Wshadow",
        "-Wno-unused-local-typedefs",
        "-Wimplicit-fallthrough",
    };

    const sdl_uclibc_lib = b.addStaticLibrary(.{
        .name = "SDL_uclib",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const sdl_uclibc_mod = rootModulePtr(sdl_uclibc_lib);

    sdl_uclibc_mod.addCMacro("USING_GENERATED_CONFIG_H", "1");

    sdl_uclibc_mod.addConfigHeader(build_config_h);
    sdl_uclibc_mod.addConfigHeader(revision_h);
    sdl_uclibc_mod.addIncludePath(b.path("include"));
    sdl_uclibc_mod.addIncludePath(b.path("src"));

    sdl_uclibc_mod.addCSourceFiles(.{
        .flags = &(common_c_flags ++ .{
            "-fvisibility=hidden",
        }),
        .files = &.{
            "src/libm/e_atan2.c",
            "src/libm/e_exp.c",
            "src/libm/e_fmod.c",
            "src/libm/e_log.c",
            "src/libm/e_log10.c",
            "src/libm/e_pow.c",
            "src/libm/e_rem_pio2.c",
            "src/libm/e_sqrt.c",
            "src/libm/k_cos.c",
            "src/libm/k_rem_pio2.c",
            "src/libm/k_sin.c",
            "src/libm/k_tan.c",
            "src/libm/s_atan.c",
            "src/libm/s_copysign.c",
            "src/libm/s_cos.c",
            "src/libm/s_fabs.c",
            "src/libm/s_floor.c",
            "src/libm/s_isinf.c",
            "src/libm/s_isinff.c",
            "src/libm/s_isnan.c",
            "src/libm/s_isnanf.c",
            "src/libm/s_modf.c",
            "src/libm/s_scalbn.c",
            "src/libm/s_sin.c",
            "src/libm/s_tan.c",
        },
    });

    const sdl_lib: *std.Build.Step.Compile = switch (preferred_link_mode) {
        inline else => |x| switch (x) {
            .static => std.Build.addStaticLibrary,
            .dynamic => std.Build.addSharedLibrary,
        }(b, .{
            .name = "SDL3",
            .version = .{
                .major = 0,
                .minor = version.minor,
                .patch = version.patch,
            },
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    };
    const sdl_mod = rootModulePtr(sdl_lib);

    sdl_mod.addCMacro("USING_GENERATED_CONFIG_H", "1");
    sdl_mod.addCMacro("SDL_BUILD_MAJOR_VERSION", std.fmt.comptimePrint("{}", .{version.major}));
    sdl_mod.addCMacro("SDL_BUILD_MINOR_VERSION", std.fmt.comptimePrint("{}", .{version.minor}));
    sdl_mod.addCMacro("SDL_BUILD_MICRO_VERSION", std.fmt.comptimePrint("{}", .{version.patch}));
    switch (sdl_lib.linkage.?) {
        .static => {
            sdl_mod.addCMacro("SDL_STATIC_LIB", "1");
        },
        .dynamic => {
            sdl_mod.addCMacro("DLL_EXPORT", "1");
        },
    }

    sdl_mod.addConfigHeader(build_config_h);
    sdl_mod.addConfigHeader(revision_h);
    sdl_mod.addIncludePath(b.path("include"));
    sdl_mod.addIncludePath(b.path("src"));
    sdl_mod.addSystemIncludePath(b.path("src/video/khronos"));
    if (linux) {
        if (lazy_linux_deps_dep) |dep| {
            sdl_mod.addIncludePath(dep.path("src"));
            sdl_mod.addSystemIncludePath(dep.path("include"));
            if (target.result.cpu.arch == .x86_64 and target.result.abi.isGnu()) {
                sdl_mod.addSystemIncludePath(dep.path("include/x86_64-linux-gnu"));
            }
            if (target.result.cpu.arch == .aarch64 and target.result.abi.isGnu()) {
                sdl_mod.addSystemIncludePath(dep.path("include/aarch64-linux-gnu"));
            }
        }
    }
    if (macos) {
        if (b.sysroot) |sysroot| {
            sdl_mod.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sysroot, "usr/include" }) });
            sdl_mod.addSystemFrameworkPath(.{ .cwd_relative = b.pathJoin(&.{ sysroot, "System/Library/Frameworks" }) });
            sdl_mod.addLibraryPath(.{ .cwd_relative = "/usr/lib" }); // ???
        } else if (!target.query.isNative()) {
            std.log.err("'--sysroot' is required when building for non-native macOS targets", .{});
            std.process.exit(1);
        }
    }

    var sdl_c_flags: std.BoundedArray([]const u8, common_c_flags.len + 4) = .{};
    sdl_c_flags.appendSliceAssumeCapacity(&common_c_flags);
    sdl_c_flags.appendAssumeCapacity("-std=c99");
    if (linux) {
        sdl_c_flags.appendAssumeCapacity("-pthread");
    }
    if (macos) {
        sdl_c_flags.appendAssumeCapacity("-pthread");
        sdl_c_flags.appendAssumeCapacity("-fobjc-arc");
    }
    if (sdl_lib.linkage.? == .dynamic) {
        sdl_c_flags.appendAssumeCapacity("-fvisibility=hidden");
    }

    sdl_mod.addCSourceFiles(.{
        .flags = sdl_c_flags.slice(),
        .files = &.{
            "src/SDL.c",
            "src/SDL_assert.c",
            "src/SDL_error.c",
            "src/SDL_guid.c",
            "src/SDL_hashtable.c",
            "src/SDL_hints.c",
            "src/SDL_list.c",
            "src/SDL_log.c",
            "src/SDL_properties.c",
            "src/SDL_utils.c",
            "src/atomic/SDL_atomic.c",
            "src/atomic/SDL_spinlock.c",
            "src/audio/SDL_audio.c",
            "src/audio/SDL_audiocvt.c",
            "src/audio/SDL_audiodev.c",
            "src/audio/SDL_audioqueue.c",
            "src/audio/SDL_audioresample.c",
            "src/audio/SDL_audiotypecvt.c",
            "src/audio/SDL_mixer.c",
            "src/audio/SDL_wave.c",
            "src/camera/SDL_camera.c",
            "src/core/SDL_core_unsupported.c",
            "src/cpuinfo/SDL_cpuinfo.c",
            "src/dynapi/SDL_dynapi.c",
            "src/events/SDL_categories.c",
            "src/events/SDL_clipboardevents.c",
            "src/events/SDL_displayevents.c",
            "src/events/SDL_dropevents.c",
            "src/events/SDL_events.c",
            "src/events/SDL_keyboard.c",
            "src/events/SDL_keymap.c",
            "src/events/SDL_keysym_to_keycode.c",
            "src/events/SDL_keysym_to_scancode.c",
            "src/events/SDL_mouse.c",
            "src/events/SDL_pen.c",
            "src/events/SDL_quit.c",
            "src/events/SDL_scancode_tables.c",
            "src/events/SDL_touch.c",
            "src/events/SDL_windowevents.c",
            "src/events/imKStoUCS.c",
            "src/filesystem/SDL_filesystem.c",
            "src/gpu/SDL_gpu.c",
            "src/haptic/SDL_haptic.c",
            "src/hidapi/SDL_hidapi.c",
            "src/io/SDL_asyncio.c",
            "src/io/SDL_iostream.c",
            "src/io/generic/SDL_asyncio_generic.c",
            "src/joystick/SDL_gamepad.c",
            "src/joystick/SDL_joystick.c",
            "src/joystick/SDL_steam_virtual_gamepad.c",
            "src/joystick/controller_type.c",
            "src/locale/SDL_locale.c",
            "src/main/SDL_main_callbacks.c",
            "src/main/SDL_runapp.c",
            "src/misc/SDL_url.c",
            "src/power/SDL_power.c",
            "src/render/SDL_d3dmath.c",
            "src/render/SDL_render.c",
            "src/render/SDL_render_unsupported.c",
            "src/render/SDL_yuv_sw.c",
            "src/render/direct3d/SDL_render_d3d.c",
            "src/render/direct3d/SDL_shaders_d3d.c",
            "src/render/direct3d11/SDL_render_d3d11.c",
            "src/render/direct3d11/SDL_shaders_d3d11.c",
            "src/render/direct3d12/SDL_render_d3d12.c",
            "src/render/direct3d12/SDL_shaders_d3d12.c",
            "src/render/gpu/SDL_pipeline_gpu.c",
            "src/render/gpu/SDL_render_gpu.c",
            "src/render/gpu/SDL_shaders_gpu.c",
            "src/render/opengl/SDL_render_gl.c",
            "src/render/opengl/SDL_shaders_gl.c",
            "src/render/opengles2/SDL_render_gles2.c",
            "src/render/opengles2/SDL_shaders_gles2.c",
            "src/render/ps2/SDL_render_ps2.c",
            "src/render/psp/SDL_render_psp.c",
            "src/render/software/SDL_blendfillrect.c",
            "src/render/software/SDL_blendline.c",
            "src/render/software/SDL_blendpoint.c",
            "src/render/software/SDL_drawline.c",
            "src/render/software/SDL_drawpoint.c",
            "src/render/software/SDL_render_sw.c",
            "src/render/software/SDL_rotate.c",
            "src/render/software/SDL_triangle.c",
            "src/render/vitagxm/SDL_render_vita_gxm.c",
            "src/render/vitagxm/SDL_render_vita_gxm_memory.c",
            "src/render/vitagxm/SDL_render_vita_gxm_tools.c",
            "src/render/vulkan/SDL_render_vulkan.c",
            "src/render/vulkan/SDL_shaders_vulkan.c",
            "src/sensor/SDL_sensor.c",
            "src/stdlib/SDL_crc16.c",
            "src/stdlib/SDL_crc32.c",
            "src/stdlib/SDL_getenv.c",
            "src/stdlib/SDL_iconv.c",
            "src/stdlib/SDL_malloc.c",
            "src/stdlib/SDL_memcpy.c",
            "src/stdlib/SDL_memmove.c",
            "src/stdlib/SDL_memset.c",
            "src/stdlib/SDL_mslibc.c",
            "src/stdlib/SDL_murmur3.c",
            "src/stdlib/SDL_qsort.c",
            "src/stdlib/SDL_random.c",
            "src/stdlib/SDL_stdlib.c",
            "src/stdlib/SDL_string.c",
            "src/stdlib/SDL_strtokr.c",
            "src/storage/SDL_storage.c",
            "src/thread/SDL_thread.c",
            "src/time/SDL_time.c",
            "src/timer/SDL_timer.c",
            "src/video/SDL_RLEaccel.c",
            "src/video/SDL_blit.c",
            "src/video/SDL_blit_0.c",
            "src/video/SDL_blit_1.c",
            "src/video/SDL_blit_A.c",
            "src/video/SDL_blit_N.c",
            "src/video/SDL_blit_auto.c",
            "src/video/SDL_blit_copy.c",
            "src/video/SDL_blit_slow.c",
            "src/video/SDL_bmp.c",
            "src/video/SDL_clipboard.c",
            "src/video/SDL_egl.c",
            "src/video/SDL_fillrect.c",
            "src/video/SDL_pixels.c",
            "src/video/SDL_rect.c",
            "src/video/SDL_stretch.c",
            "src/video/SDL_surface.c",
            "src/video/SDL_video.c",
            "src/video/SDL_video_unsupported.c",
            "src/video/SDL_vulkan_utils.c",
            "src/video/SDL_yuv.c",
            "src/video/yuv2rgb/yuv_rgb_lsx.c",
            "src/video/yuv2rgb/yuv_rgb_sse.c",
            "src/video/yuv2rgb/yuv_rgb_std.c",
            "src/dialog/SDL_dialog.c",
            "src/process/SDL_process.c",
            "src/tray/SDL_tray_utils.c",
        },
    });
    if (windows) {
        sdl_mod.addCSourceFiles(.{
            .flags = sdl_c_flags.slice(),
            .files = &.{
                "src/audio/dummy/SDL_dummyaudio.c",
                "src/audio/disk/SDL_diskaudio.c",
                "src/camera/dummy/SDL_camera_dummy.c",
                "src/joystick/virtual/SDL_virtualjoystick.c",
                "src/video/dummy/SDL_nullevents.c",
                "src/video/dummy/SDL_nullframebuffer.c",
                "src/video/dummy/SDL_nullvideo.c",
                "src/core/windows/SDL_hid.c",
                "src/core/windows/SDL_immdevice.c",
                "src/core/windows/SDL_windows.c",
                "src/core/windows/SDL_xinput.c",
                "src/core/windows/pch.c",
                "src/main/windows/SDL_sysmain_runapp.c",
                "src/io/windows/SDL_asyncio_windows_ioring.c",
                "src/misc/windows/SDL_sysurl.c",
                "src/audio/directsound/SDL_directsound.c",
                "src/audio/wasapi/SDL_wasapi.c",
                "src/video/windows/SDL_surface_utils.c",
                "src/video/windows/SDL_windowsclipboard.c",
                "src/video/windows/SDL_windowsevents.c",
                "src/video/windows/SDL_windowsframebuffer.c",
                "src/video/windows/SDL_windowsgameinput.c",
                "src/video/windows/SDL_windowskeyboard.c",
                "src/video/windows/SDL_windowsmessagebox.c",
                "src/video/windows/SDL_windowsmodes.c",
                "src/video/windows/SDL_windowsmouse.c",
                "src/video/windows/SDL_windowsopengl.c",
                "src/video/windows/SDL_windowsopengles.c",
                "src/video/windows/SDL_windowsrawinput.c",
                "src/video/windows/SDL_windowsshape.c",
                "src/video/windows/SDL_windowsvideo.c",
                "src/video/windows/SDL_windowsvulkan.c",
                "src/video/windows/SDL_windowswindow.c",
                "src/thread/generic/SDL_syscond.c",
                "src/thread/generic/SDL_sysrwlock.c",
                "src/thread/windows/SDL_syscond_cv.c",
                "src/thread/windows/SDL_sysmutex.c",
                "src/thread/windows/SDL_sysrwlock_srw.c",
                "src/thread/windows/SDL_syssem.c",
                "src/thread/windows/SDL_systhread.c",
                "src/thread/windows/SDL_systls.c",
                "src/sensor/windows/SDL_windowssensor.c",
                "src/power/windows/SDL_syspower.c",
                "src/locale/windows/SDL_syslocale.c",
                "src/filesystem/windows/SDL_sysfilesystem.c",
                "src/filesystem/windows/SDL_sysfsops.c",
                "src/storage/generic/SDL_genericstorage.c",
                "src/storage/steam/SDL_steamstorage.c",
                "src/time/windows/SDL_systime.c",
                "src/timer/windows/SDL_systimer.c",
                "src/loadso/windows/SDL_sysloadso.c",
                "src/core/windows/SDL_hid.c",
                "src/core/windows/SDL_immdevice.c",
                "src/core/windows/SDL_windows.c",
                "src/core/windows/SDL_xinput.c",
                "src/core/windows/pch.c",
                "src/tray/windows/SDL_tray.c",
                "src/joystick/hidapi/SDL_hidapi_combined.c",
                "src/joystick/hidapi/SDL_hidapi_gamecube.c",
                "src/joystick/hidapi/SDL_hidapi_luna.c",
                "src/joystick/hidapi/SDL_hidapi_ps3.c",
                "src/joystick/hidapi/SDL_hidapi_ps4.c",
                "src/joystick/hidapi/SDL_hidapi_ps5.c",
                "src/joystick/hidapi/SDL_hidapi_rumble.c",
                "src/joystick/hidapi/SDL_hidapi_shield.c",
                "src/joystick/hidapi/SDL_hidapi_stadia.c",
                "src/joystick/hidapi/SDL_hidapi_steam.c",
                "src/joystick/hidapi/SDL_hidapi_steam_hori.c",
                "src/joystick/hidapi/SDL_hidapi_steamdeck.c",
                "src/joystick/hidapi/SDL_hidapi_switch.c",
                "src/joystick/hidapi/SDL_hidapi_wii.c",
                "src/joystick/hidapi/SDL_hidapi_xbox360.c",
                "src/joystick/hidapi/SDL_hidapi_xbox360w.c",
                "src/joystick/hidapi/SDL_hidapi_xboxone.c",
                "src/joystick/hidapi/SDL_hidapijoystick.c",
                "src/joystick/windows/SDL_dinputjoystick.c",
                "src/joystick/windows/SDL_rawinputjoystick.c",
                "src/joystick/windows/SDL_windows_gaming_input.c",
                "src/joystick/windows/SDL_windowsjoystick.c",
                "src/joystick/windows/SDL_xinputjoystick.c",
                "src/haptic/windows/SDL_dinputhaptic.c",
                "src/haptic/windows/SDL_windowshaptic.c",
                "src/camera/mediafoundation/SDL_camera_mediafoundation.c",
                "src/dialog/SDL_dialog_utils.c",
                "src/dialog/windows/SDL_windowsdialog.c",
                "src/process/windows/SDL_windowsprocess.c",
                "src/video/offscreen/SDL_offscreenevents.c",
                "src/video/offscreen/SDL_offscreenframebuffer.c",
                "src/video/offscreen/SDL_offscreenopengles.c",
                "src/video/offscreen/SDL_offscreenvideo.c",
                "src/video/offscreen/SDL_offscreenvulkan.c",
                "src/video/offscreen/SDL_offscreenwindow.c",
                "src/gpu/d3d12/SDL_gpu_d3d12.c",
                "src/gpu/vulkan/SDL_gpu_vulkan.c",
                "src/main/generic/SDL_sysmain_callbacks.c",
            },
        });
        if (sdl_lib.linkage.? == .dynamic) {
            sdl_mod.addWin32ResourceFile(.{ .file = b.path("src/core/windows/version.rc") });
        }
    }
    if (linux) {
        sdl_mod.addCSourceFiles(.{
            .flags = sdl_c_flags.slice(),
            .files = &.{
                "src/audio/dummy/SDL_dummyaudio.c",
                "src/audio/disk/SDL_diskaudio.c",
                "src/camera/dummy/SDL_camera_dummy.c",
                "src/loadso/dlopen/SDL_sysloadso.c",
                "src/joystick/virtual/SDL_virtualjoystick.c",
                "src/video/dummy/SDL_nullevents.c",
                "src/video/dummy/SDL_nullframebuffer.c",
                "src/video/dummy/SDL_nullvideo.c",
                "src/audio/alsa/SDL_alsa_audio.c",
                "src/audio/jack/SDL_jackaudio.c",
                "src/audio/pipewire/SDL_pipewire.c",
                "src/camera/pipewire/SDL_camera_pipewire.c",
                "src/audio/pulseaudio/SDL_pulseaudio.c",
                "src/audio/sndio/SDL_sndioaudio.c",
                "src/video/x11/SDL_x11clipboard.c",
                "src/video/x11/SDL_x11dyn.c",
                "src/video/x11/SDL_x11events.c",
                "src/video/x11/SDL_x11framebuffer.c",
                "src/video/x11/SDL_x11keyboard.c",
                "src/video/x11/SDL_x11messagebox.c",
                "src/video/x11/SDL_x11modes.c",
                "src/video/x11/SDL_x11mouse.c",
                "src/video/x11/SDL_x11opengl.c",
                "src/video/x11/SDL_x11opengles.c",
                "src/video/x11/SDL_x11pen.c",
                "src/video/x11/SDL_x11settings.c",
                "src/video/x11/SDL_x11shape.c",
                "src/video/x11/SDL_x11touch.c",
                "src/video/x11/SDL_x11video.c",
                "src/video/x11/SDL_x11vulkan.c",
                "src/video/x11/SDL_x11window.c",
                "src/video/x11/SDL_x11xfixes.c",
                "src/video/x11/SDL_x11xinput2.c",
                "src/video/x11/SDL_x11xsync.c",
                "src/video/x11/edid-parse.c",
                "src/video/x11/xsettings-client.c",
                "src/video/kmsdrm/SDL_kmsdrmdyn.c",
                "src/video/kmsdrm/SDL_kmsdrmevents.c",
                "src/video/kmsdrm/SDL_kmsdrmmouse.c",
                "src/video/kmsdrm/SDL_kmsdrmopengles.c",
                "src/video/kmsdrm/SDL_kmsdrmvideo.c",
                "src/video/kmsdrm/SDL_kmsdrmvulkan.c",
                "src/video/wayland/SDL_waylandclipboard.c",
                "src/video/wayland/SDL_waylanddatamanager.c",
                "src/video/wayland/SDL_waylanddyn.c",
                "src/video/wayland/SDL_waylandevents.c",
                "src/video/wayland/SDL_waylandkeyboard.c",
                "src/video/wayland/SDL_waylandmessagebox.c",
                "src/video/wayland/SDL_waylandmouse.c",
                "src/video/wayland/SDL_waylandopengles.c",
                "src/video/wayland/SDL_waylandshmbuffer.c",
                "src/video/wayland/SDL_waylandvideo.c",
                "src/video/wayland/SDL_waylandvulkan.c",
                "src/video/wayland/SDL_waylandwindow.c",
                "src/tray/unix/SDL_tray.c",
                "src/core/unix/SDL_appid.c",
                "src/core/unix/SDL_poll.c",
                "src/camera/v4l2/SDL_camera_v4l2.c",
                "src/haptic/linux/SDL_syshaptic.c",
                "src/core/linux/SDL_dbus.c",
                "src/core/linux/SDL_system_theme.c",
                "src/core/linux/SDL_ime.c",
                "src/core/linux/SDL_ibus.c",
                "src/core/linux/SDL_fcitx.c",
                "src/core/linux/SDL_udev.c",
                "src/core/linux/SDL_evdev.c",
                "src/core/linux/SDL_evdev_kbd.c",
                "src/io/io_uring/SDL_asyncio_liburing.c",
                "src/core/linux/SDL_evdev_capabilities.c",
                "src/core/linux/SDL_threadprio.c",
                "src/joystick/hidapi/SDL_hidapi_combined.c",
                "src/joystick/hidapi/SDL_hidapi_gamecube.c",
                "src/joystick/hidapi/SDL_hidapi_luna.c",
                "src/joystick/hidapi/SDL_hidapi_ps3.c",
                "src/joystick/hidapi/SDL_hidapi_ps4.c",
                "src/joystick/hidapi/SDL_hidapi_ps5.c",
                "src/joystick/hidapi/SDL_hidapi_rumble.c",
                "src/joystick/hidapi/SDL_hidapi_shield.c",
                "src/joystick/hidapi/SDL_hidapi_stadia.c",
                "src/joystick/hidapi/SDL_hidapi_steam.c",
                "src/joystick/hidapi/SDL_hidapi_steam_hori.c",
                "src/joystick/hidapi/SDL_hidapi_steamdeck.c",
                "src/joystick/hidapi/SDL_hidapi_switch.c",
                "src/joystick/hidapi/SDL_hidapi_wii.c",
                "src/joystick/hidapi/SDL_hidapi_xbox360.c",
                "src/joystick/hidapi/SDL_hidapi_xbox360w.c",
                "src/joystick/hidapi/SDL_hidapi_xboxone.c",
                "src/joystick/hidapi/SDL_hidapijoystick.c",
                "src/joystick/linux/SDL_sysjoystick.c",
                "src/thread/pthread/SDL_systhread.c",
                "src/thread/pthread/SDL_sysmutex.c",
                "src/thread/pthread/SDL_syscond.c",
                "src/thread/pthread/SDL_sysrwlock.c",
                "src/thread/pthread/SDL_systls.c",
                "src/thread/pthread/SDL_syssem.c",
                "src/misc/unix/SDL_sysurl.c",
                "src/power/linux/SDL_syspower.c",
                "src/locale/unix/SDL_syslocale.c",
                "src/filesystem/unix/SDL_sysfilesystem.c",
                "src/storage/generic/SDL_genericstorage.c",
                "src/storage/steam/SDL_steamstorage.c",
                "src/filesystem/posix/SDL_sysfsops.c",
                "src/time/unix/SDL_systime.c",
                "src/timer/unix/SDL_systimer.c",
                "src/dialog/SDL_dialog_utils.c",
                "src/dialog/unix/SDL_unixdialog.c",
                "src/dialog/unix/SDL_portaldialog.c",
                "src/dialog/unix/SDL_zenitydialog.c",
                "src/process/posix/SDL_posixprocess.c",
                "src/video/offscreen/SDL_offscreenevents.c",
                "src/video/offscreen/SDL_offscreenframebuffer.c",
                "src/video/offscreen/SDL_offscreenopengles.c",
                "src/video/offscreen/SDL_offscreenvideo.c",
                "src/video/offscreen/SDL_offscreenvulkan.c",
                "src/video/offscreen/SDL_offscreenwindow.c",
                "src/gpu/vulkan/SDL_gpu_vulkan.c",
                "src/sensor/dummy/SDL_dummysensor.c",
                "src/main/generic/SDL_sysmain_callbacks.c",
            },
        });
        if (lazy_linux_deps_dep) |sysroot_dep| {
            sdl_mod.addCSourceFiles(.{
                .flags = sdl_c_flags.slice(),
                .root = sysroot_dep.path("."),
                .files = lazy_linux_deps_values.?.wayland_c_files,
            });
        }
    }
    if (macos) {
        sdl_mod.addCSourceFiles(.{
            .flags = sdl_c_flags.slice(),
            .files = &.{
                "src/audio/dummy/SDL_dummyaudio.c",
                "src/audio/disk/SDL_diskaudio.c",
                "src/camera/dummy/SDL_camera_dummy.c",
                "src/loadso/dlopen/SDL_sysloadso.c",
                "src/joystick/virtual/SDL_virtualjoystick.c",
                "src/video/dummy/SDL_nullevents.c",
                "src/video/dummy/SDL_nullframebuffer.c",
                "src/video/dummy/SDL_nullvideo.c",
                "src/camera/coremedia/SDL_camera_coremedia.m",
                "src/misc/macos/SDL_sysurl.m",
                "src/audio/coreaudio/SDL_coreaudio.m",
                "src/joystick/hidapi/SDL_hidapi_combined.c",
                "src/joystick/hidapi/SDL_hidapi_gamecube.c",
                "src/joystick/hidapi/SDL_hidapi_luna.c",
                "src/joystick/hidapi/SDL_hidapi_ps3.c",
                "src/joystick/hidapi/SDL_hidapi_ps4.c",
                "src/joystick/hidapi/SDL_hidapi_ps5.c",
                "src/joystick/hidapi/SDL_hidapi_rumble.c",
                "src/joystick/hidapi/SDL_hidapi_shield.c",
                "src/joystick/hidapi/SDL_hidapi_stadia.c",
                "src/joystick/hidapi/SDL_hidapi_steam.c",
                "src/joystick/hidapi/SDL_hidapi_steam_hori.c",
                "src/joystick/hidapi/SDL_hidapi_steamdeck.c",
                "src/joystick/hidapi/SDL_hidapi_switch.c",
                "src/joystick/hidapi/SDL_hidapi_wii.c",
                "src/joystick/hidapi/SDL_hidapi_xbox360.c",
                "src/joystick/hidapi/SDL_hidapi_xbox360w.c",
                "src/joystick/hidapi/SDL_hidapi_xboxone.c",
                "src/joystick/hidapi/SDL_hidapijoystick.c",
                "src/joystick/apple/SDL_mfijoystick.m",
                "src/joystick/darwin/SDL_iokitjoystick.c",
                "src/haptic/darwin/SDL_syshaptic.c",
                "src/power/macos/SDL_syspower.c",
                "src/locale/macos/SDL_syslocale.m",
                "src/time/unix/SDL_systime.c",
                "src/timer/unix/SDL_systimer.c",
                "src/filesystem/cocoa/SDL_sysfilesystem.m",
                "src/storage/generic/SDL_genericstorage.c",
                "src/storage/steam/SDL_steamstorage.c",
                "src/filesystem/posix/SDL_sysfsops.c",
                "src/video/cocoa/SDL_cocoaclipboard.m",
                "src/video/cocoa/SDL_cocoaevents.m",
                "src/video/cocoa/SDL_cocoakeyboard.m",
                "src/video/cocoa/SDL_cocoamessagebox.m",
                "src/video/cocoa/SDL_cocoametalview.m",
                "src/video/cocoa/SDL_cocoamodes.m",
                "src/video/cocoa/SDL_cocoamouse.m",
                "src/video/cocoa/SDL_cocoaopengl.m",
                "src/video/cocoa/SDL_cocoaopengles.m",
                "src/video/cocoa/SDL_cocoapen.m",
                "src/video/cocoa/SDL_cocoashape.m",
                "src/video/cocoa/SDL_cocoavideo.m",
                "src/video/cocoa/SDL_cocoavulkan.m",
                "src/video/cocoa/SDL_cocoawindow.m",
                "src/render/metal/SDL_render_metal.m",
                "src/gpu/metal/SDL_gpu_metal.m",
                "src/tray/cocoa/SDL_tray.m",
                "src/thread/pthread/SDL_systhread.c",
                "src/thread/pthread/SDL_sysmutex.c",
                "src/thread/pthread/SDL_syscond.c",
                "src/thread/pthread/SDL_sysrwlock.c",
                "src/thread/pthread/SDL_systls.c",
                "src/thread/pthread/SDL_syssem.c",
                "src/dialog/SDL_dialog_utils.c",
                "src/dialog/cocoa/SDL_cocoadialog.m",
                "src/process/posix/SDL_posixprocess.c",
                "src/video/offscreen/SDL_offscreenevents.c",
                "src/video/offscreen/SDL_offscreenframebuffer.c",
                "src/video/offscreen/SDL_offscreenopengles.c",
                "src/video/offscreen/SDL_offscreenvideo.c",
                "src/video/offscreen/SDL_offscreenvulkan.c",
                "src/video/offscreen/SDL_offscreenwindow.c",
                "src/gpu/vulkan/SDL_gpu_vulkan.c",
                "src/sensor/dummy/SDL_dummysensor.c",
                "src/main/generic/SDL_sysmain_callbacks.c",
            },
        });
    }

    if (sdl_lib.linkage.? == .dynamic) {
        sdl_lib.setVersionScript(b.path("src/dynapi/SDL_dynapi.sym"));
        sdl_lib.linker_allow_undefined_version = true;
    }

    sdl_mod.linkLibrary(sdl_uclibc_lib);
    if (windows) {
        sdl_mod.linkSystemLibrary("m", .{});
        sdl_mod.linkSystemLibrary("kernel32", .{});
        sdl_mod.linkSystemLibrary("user32", .{});
        sdl_mod.linkSystemLibrary("gdi32", .{});
        sdl_mod.linkSystemLibrary("winmm", .{});
        sdl_mod.linkSystemLibrary("imm32", .{});
        sdl_mod.linkSystemLibrary("ole32", .{});
        sdl_mod.linkSystemLibrary("oleaut32", .{});
        sdl_mod.linkSystemLibrary("version", .{});
        sdl_mod.linkSystemLibrary("uuid", .{});
        sdl_mod.linkSystemLibrary("advapi32", .{});
        sdl_mod.linkSystemLibrary("setupapi", .{});
        sdl_mod.linkSystemLibrary("shell32", .{});
        sdl_mod.linkSystemLibrary("dinput8", .{});
    }
    if (linux) {
        sdl_mod.linkSystemLibrary("m", .{});
        sdl_mod.linkSystemLibrary("pthread", .{});
    }
    if (macos) {
        sdl_mod.linkSystemLibrary("m", .{});
        sdl_mod.linkSystemLibrary("pthread", .{});
        sdl_mod.linkFramework("CoreMedia", .{});
        sdl_mod.linkFramework("CoreVideo", .{});
        sdl_mod.linkFramework("Cocoa", .{});
        sdl_mod.linkFramework("UniformTypeIdentifiers", .{ .weak = true });
        sdl_mod.linkFramework("IOKit", .{});
        sdl_mod.linkFramework("ForceFeedback", .{});
        sdl_mod.linkFramework("Carbon", .{});
        sdl_mod.linkFramework("CoreAudio", .{});
        sdl_mod.linkFramework("AudioToolbox", .{});
        sdl_mod.linkFramework("AVFoundation", .{});
        sdl_mod.linkFramework("Foundation", .{});
        sdl_mod.linkFramework("GameController", .{});
        sdl_mod.linkFramework("Metal", .{});
        sdl_mod.linkFramework("QuartzCore", .{});
        sdl_mod.linkFramework("CoreHaptics", .{ .weak = true });
    }

    sdl_lib.installHeadersDirectory(b.path("include/SDL3"), "SDL3", .{
        .exclude_extensions = &.{
            "SDL_revision.h",
            "SDL_test.h",
            "SDL_test_assert.h",
            "SDL_test_common.h",
            "SDL_test_compare.h",
            "SDL_test_crc32.h",
            "SDL_test_font.h",
            "SDL_test_fuzzer.h",
            "SDL_test_harness.h",
            "SDL_test_log.h",
            "SDL_test_md5.h",
            "SDL_test_memory.h",
        },
    });
    sdl_lib.installConfigHeader(revision_h);
    if (install_build_config_h) {
        sdl_lib.installConfigHeader(build_config_h);
    }

    const install_sdl_lib = b.addInstallArtifact(sdl_lib, .{
        // Zig 0.12.1 compat
        .dest_dir = if (sdl_lib.producesImplib()) .{ .override = .bin } else .default,
        .implib_dir = if (sdl_lib.producesImplib()) .{ .override = .lib } else .default,
    });

    const install_sdl = b.step("install_sdl", "Install SDL");
    install_sdl.dependOn(&install_sdl_lib.step);

    b.getInstallStep().dependOn(&install_sdl_lib.step);

    const sdl_test_lib = b.addStaticLibrary(.{
        .name = "SDL3_test",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const sdl_test_mod = rootModulePtr(sdl_test_lib);

    sdl_test_mod.addConfigHeader(build_config_h);
    sdl_test_mod.addConfigHeader(revision_h);
    sdl_test_mod.addIncludePath(b.path("include"));

    sdl_test_mod.addCSourceFiles(.{
        .flags = &common_c_flags,
        .files = &.{
            "src/test/SDL_test_assert.c",
            "src/test/SDL_test_common.c",
            "src/test/SDL_test_compare.c",
            "src/test/SDL_test_crc32.c",
            "src/test/SDL_test_font.c",
            "src/test/SDL_test_fuzzer.c",
            "src/test/SDL_test_harness.c",
            "src/test/SDL_test_log.c",
            "src/test/SDL_test_md5.c",
            "src/test/SDL_test_memory.c",
        },
    });

    sdl_test_lib.installHeadersDirectory(b.path("include/SDL3"), "SDL3", .{
        .include_extensions = &.{
            "SDL_test.h",
            "SDL_test_assert.h",
            "SDL_test_common.h",
            "SDL_test_compare.h",
            "SDL_test_crc32.h",
            "SDL_test_font.h",
            "SDL_test_fuzzer.h",
            "SDL_test_harness.h",
            "SDL_test_log.h",
            "SDL_test_md5.h",
            "SDL_test_memory.h",
        },
    });

    const install_sdl_test_lib = b.addInstallArtifact(sdl_test_lib, .{});

    const install_sdl_test = b.step("install_sdl_test", "Install SDL_test");
    install_sdl_test.dependOn(&install_sdl_test_lib.step);

    b.getInstallStep().dependOn(&install_sdl_test_lib.step);
}

const LinuxDepsValues = struct {
    wayland_client_soname: []const u8,
    wayland_cursor_soname: []const u8,
    wayland_egl_soname: []const u8,
    wayland_c_files: []const []const u8,
    libdecor_soname: []const u8,
    libdecor_version: std.SemanticVersion,
    xkbcommon_soname: []const u8,
    x11_soname: []const u8,
    xcursor_soname: []const u8,
    xext_soname: []const u8,
    xfixes_soname: []const u8,
    xi_soname: []const u8,
    xrandr_soname: []const u8,
    xss_soname: []const u8,
    drm_soname: []const u8,
    gbm_soname: []const u8,
    pipewire_soname: []const u8,
    pulseaudio_soname: []const u8,
    alsa_soname: []const u8,
    sndio_soname: []const u8,
    jack_soname: []const u8,
    libusb_soname: []const u8,
    libudev_soname: []const u8,

    fn fromBuildZig(comptime build_zig: type) LinuxDepsValues {
        return .{
            .wayland_client_soname = build_zig.wayland_client_soname,
            .wayland_cursor_soname = build_zig.wayland_cursor_soname,
            .wayland_egl_soname = build_zig.wayland_egl_soname,
            .wayland_c_files = &build_zig.wayland_c_files,
            .libdecor_soname = build_zig.libdecor_soname,
            .libdecor_version = build_zig.libdecor_version,
            .xkbcommon_soname = build_zig.xkbcommon_soname,
            .x11_soname = build_zig.x11_soname,
            .xcursor_soname = build_zig.xcursor_soname,
            .xext_soname = build_zig.xext_soname,
            .xfixes_soname = build_zig.xfixes_soname,
            .xi_soname = build_zig.xi_soname,
            .xrandr_soname = build_zig.xrandr_soname,
            .xss_soname = build_zig.xss_soname,
            .drm_soname = build_zig.drm_soname,
            .gbm_soname = build_zig.gbm_soname,
            .pipewire_soname = build_zig.pipewire_soname,
            .pulseaudio_soname = build_zig.pulseaudio_soname,
            .alsa_soname = build_zig.alsa_soname,
            .sndio_soname = build_zig.sndio_soname,
            .jack_soname = build_zig.jack_soname,
            .libusb_soname = build_zig.libusb_soname,
            .libudev_soname = build_zig.libudev_soname,
        };
    }
};

fn rootModulePtr(artifact: *std.Build.Step.Compile) *std.Build.Module {
    const struct_tag = if (@hasField(std.builtin.Type, "Type")) .Struct else .@"struct";
    if (@typeInfo(@TypeOf(artifact.root_module)) == struct_tag) {
        return &artifact.root_module;
    } else {
        return artifact.root_module;
    }
}
