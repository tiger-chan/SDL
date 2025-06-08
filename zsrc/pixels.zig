const endian = @import("builtin").target.cpu.arch.endian();

/// A fully opaque 8-bit alpha value.
pub const ALPHA_OPAQUE = 255;

/// A structure that represents a color as RGBA components.
///
/// The bits of this structure can be directly reinterpreted as an
/// integer-packed color which uses the SDL_PIXELFORMAT_RGBA32 format
/// (SDL_PIXELFORMAT_ABGR8888 on little-endian systems and
/// SDL_PIXELFORMAT_RGBA8888 on big-endian systems).
pub const Color = extern struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,
    a: u8 = 0,

    pub fn rgb(r: u8, g: u8, b: u8) Color {
        return .{
            .r = r,
            .g = g,
            .b = b,
            .a = ALPHA_OPAQUE,
        };
    }

    pub fn rgba(r: u8, g: u8, b: u8, a: u8) Color {
        return .{
            .r = r,
            .g = g,
            .b = b,
            .a = a,
        };
    }
};

/// The bits of this structure can be directly reinterpreted as a float-packed
/// color which uses the SDL_PIXELFORMAT_RGBA128_FLOAT format
pub const FColor = extern struct {
    r: f32 = 0,
    g: f32 = 0,
    b: f32 = 0,
    a: f32 = 0,

    pub fn rgb(r: f32, g: f32, b: f32) FColor {
        return .{
            .r = r,
            .g = g,
            .b = b,
            .a = 1.0,
        };
    }

    pub fn rgba(r: f32, g: f32, b: f32, a: f32) FColor {
        return .{
            .r = r,
            .g = g,
            .b = b,
            .a = a,
        };
    }
};

/// Pixel format.
///
/// SDL's pixel formats have the following naming convention:
///
/// - Names with a list of components and a single bit count, such as RGB24 and
///   ABGR32, define a platform-independent encoding into bytes in the order
///   specified. For example, in RGB24 data, each pixel is encoded in 3 bytes
///   (red, green, blue) in that order, and in ABGR32 data, each pixel is
///   encoded in 4 bytes alpha, blue, green, red) in that order. Use these
///   names if the property of a format that is important to you is the order
///   of the bytes in memory or on disk.
/// - Names with a bit count per component, such as ARGB8888 and XRGB1555, are
///   "packed" into an appropriately-sized integer in the platform's native
///   endianness. For example, ARGB8888 is a sequence of 32-bit integers; in
///   each integer, the most significant bits are alpha, and the least
///   significant bits are blue. On a little-endian CPU such as x86, the least
///   significant bits of each integer are arranged first in memory, but on a
///   big-endian CPU such as s390x, the most significant bits are arranged
///   first. Use these names if the property of a format that is important to
///   you is the meaning of each bit position within a native-endianness
///   integer.
/// - In indexed formats such as INDEX4LSB, each pixel is represented by
///   encoding an index into the palette into the indicated number of bits,
///   with multiple pixels packed into each byte if appropriate. In LSB
///   formats, the first (leftmost) pixel is stored in the least-significant
///   bits of the byte; in MSB formats, it's stored in the most-significant
///   bits. INDEX8 does not need LSB/MSB variants, because each pixel exactly
///   fills one byte.
///
/// The 32-bit byte-array encodings such as RGBA32 are aliases for the
/// appropriate 8888 encoding for the current platform. For example, RGBA32 is
/// an alias for ABGR8888 on little-endian CPUs like x86, or an alias for
/// RGBA8888 on big-endian CPUs.
pub const Format = enum(u32) {
    Unknown = 0,
    Index1LSB = 0x11100100,
    // SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX1, SDL_BITMAPORDER_4321, 0, 1, 0),
    Index1MSB = 0x11200100,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX1, SDL_BITMAPORDER_1234, 0, 1, 0),
    Index2LSB = 0x1c100200,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX2, SDL_BITMAPORDER_4321, 0, 2, 0),
    Index2MSB = 0x1c200200,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX2, SDL_BITMAPORDER_1234, 0, 2, 0),
    Index4LSB = 0x12100400,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX4, SDL_BITMAPORDER_4321, 0, 4, 0),
    Index4MSB = 0x12200400,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX4, SDL_BITMAPORDER_1234, 0, 4, 0),
    Index8 = 0x13000801,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX8, 0, 0, 8, 1),
    RGB332 = 0x14110801,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED8, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_332, 8, 1),
    XRGB4444 = 0x15120c02,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_4444, 12, 2),
    XBGR4444 = 0x15520c02,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_4444, 12, 2),
    XRGB1555 = 0x15130f02,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_1555, 15, 2),
    XBGR1555 = 0x15530f02,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_1555, 15, 2),
    ARGB4444 = 0x15321002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_4444, 16, 2),
    RGBA4444 = 0x15421002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_4444, 16, 2),
    ABGR4444 = 0x15721002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_4444, 16, 2),
    BGRA4444 = 0x15821002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_4444, 16, 2),
    ARGB1555 = 0x15331002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_1555, 16, 2),
    RGBA5551 = 0x15441002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_5551, 16, 2),
    ABGR1555 = 0x15731002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_1555, 16, 2),
    BGRA5551 = 0x15841002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_5551, 16, 2),
    RGB565 = 0x15151002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_565, 16, 2),
    BGR565 = 0x15551002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_565, 16, 2),
    RGB24 = 0x17101803,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU8, SDL_ARRAYORDER_RGB, 0, 24, 3),
    BGR24 = 0x17401803,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU8, SDL_ARRAYORDER_BGR, 0, 24, 3),
    XRGB8888 = 0x16161804,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_8888, 24, 4),
    RGBX8888 = 0x16261804,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBX, SDL_PACKEDLAYOUT_8888, 24, 4),
    XBGR8888 = 0x16561804,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_8888, 24, 4),
    BGRX8888 = 0x16661804,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_BGRX, SDL_PACKEDLAYOUT_8888, 24, 4),
    ARGB8888 = 0x16362004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_8888, 32, 4),
    RGBA8888 = 0x16462004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_8888, 32, 4),
    ABGR8888 = 0x16762004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_8888, 32, 4),
    BGRA8888 = 0x16862004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_8888, 32, 4),
    XRGB2101010 = 0x16172004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_2101010, 32, 4),
    XBGR2101010 = 0x16572004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_2101010, 32, 4),
    ARGB2101010 = 0x16372004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_2101010, 32, 4),
    ABGR2101010 = 0x16772004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_2101010, 32, 4),
    RGB48 = 0x18103006,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_RGB, 0, 48, 6),
    BGR48 = 0x18403006,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_BGR, 0, 48, 6),
    RGBA64 = 0x18204008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_RGBA, 0, 64, 8),
    ARGB64 = 0x18304008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_ARGB, 0, 64, 8),
    BGRA64 = 0x18504008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_BGRA, 0, 64, 8),
    ABGR64 = 0x18604008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_ABGR, 0, 64, 8),
    RGB48_F32 = 0x1a103006,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_RGB, 0, 48, 6),
    BGR48_F32 = 0x1a403006,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_BGR, 0, 48, 6),
    RGBA64_F32 = 0x1a204008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_RGBA, 0, 64, 8),
    ARGB64_F32 = 0x1a304008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_ARGB, 0, 64, 8),
    BGRA64_F32 = 0x1a504008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_BGRA, 0, 64, 8),
    ABGR64_F32 = 0x1a604008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_ABGR, 0, 64, 8),
    RGB96_F32 = 0x1b10600c,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_RGB, 0, 96, 12),
    BGR96_F32 = 0x1b40600c,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_BGR, 0, 96, 12),
    RGBA128_F32 = 0x1b208010,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_RGBA, 0, 128, 16),
    ARGB128_F32 = 0x1b308010,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_ARGB, 0, 128, 16),
    BGRA128_F32 = 0x1b508010,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_BGRA, 0, 128, 16),
    ABGR128_F32 = 0x1b608010,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_ABGR, 0, 128, 16),
    /// Planar mode: Y + V + U  (3 planes)
    YV12 = 0x32315659,
    /// SDL_DEFINE_PIXELFOURCC('Y', 'V', '1', '2'),
    /// Planar mode: Y + U + V  (3 planes)
    IYUV = 0x56555949,
    /// SDL_DEFINE_PIXELFOURCC('I', 'Y', 'U', 'V'),
    /// Packed mode: Y0+U0+Y1+V0 (1 plane)
    YUY2 = 0x32595559,
    /// SDL_DEFINE_PIXELFOURCC('Y', 'U', 'Y', '2'),
    /// Packed mode: U0+Y0+V0+Y1 (1 plane)
    UYVY = 0x59565955,
    /// SDL_DEFINE_PIXELFOURCC('U', 'Y', 'V', 'Y'),
    /// Packed mode: Y0+V0+Y1+U0 (1 plane)
    YVYU = 0x55595659,
    /// SDL_DEFINE_PIXELFOURCC('Y', 'V', 'Y', 'U'),
    /// Planar mode: Y + U/V interleaved  (2 planes)
    NV12 = 0x3231564e,
    /// SDL_DEFINE_PIXELFOURCC('N', 'V', '1', '2'),
    /// Planar mode: Y + V/U interleaved  (2 planes)
    NV21 = 0x3132564e,
    /// SDL_DEFINE_PIXELFOURCC('N', 'V', '2', '1'),
    /// Planar mode: Y + U/V interleaved  (2 planes)
    P010 = 0x30313050,
    /// SDL_DEFINE_PIXELFOURCC('P', '0', '1', '0'),
    /// Android video texture format
    EXTERNAL_OES = 0x2053454f,
    /// SDL_DEFINE_PIXELFOURCC('O', 'E', 'S', ' ')
    /// Motion JPEG
    MJPG = 0x47504a4d,
    // SDL_DEFINE_PIXELFOURCC('M', 'J', 'P', 'G')
};

// Aliases for RGBA byte arrays of color data, for the current platform
pub const RGBA32: Format = if (endian == .big) .RGBA8888 else .ABGR8888;
pub const ARGB32: Format = if (endian == .big) .ARGB8888 else .BGRA8888;
pub const BGRA32: Format = if (endian == .big) .BGRA8888 else .ARGB8888;
pub const ABGR32: Format = if (endian == .big) .ABGR8888 else .RGBA8888;
pub const RGBX32: Format = if (endian == .big) .RGBX8888 else .XBGR8888;
pub const XRGB32: Format = if (endian == .big) .XRGB8888 else .BGRX8888;
pub const BGRX32: Format = if (endian == .big) .BGRX8888 else .XRGB8888;
pub const XBGR32: Format = if (endian == .big) .XBGR8888 else .RGBX8888;
