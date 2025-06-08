const PixelFormat = @import("pixels.zig").Format;

pub const Surface = opaque {};

/// Free a surface.
///
/// It is safe to pass NULL to this function.
///
/// *param* surface the SDL_Surface to free.
///
/// *threadsafety* No other thread should be using the surface when it is freed.
pub fn destroy(surface: ?*Surface) void {
    SDL_DestroySurface(surface);
}

/// Allocate a new surface with a specific pixel format.
///
/// The pixels of the new surface are initialized to zero.
///
/// *param* width the width of the surface.
/// *param* height the height of the surface.
/// *param* format the sdl.pixels.Format for the new surface's pixel format.
/// *returns* the new SDL_Surface structure that is created or NULL on failure;
///          call sdl.err.get() for more information.
///
/// *threadsafety* It is safe to call this function from any thread.
pub fn create(width: i32, height: i32, format: PixelFormat) ?*Surface {
    return SDL_CreateSurface(width, height, format);
}

/// Allocate a new surface with a specific pixel format and existing pixel
/// data.
///
/// No copy is made of the pixel data. Pixel data is not managed automatically;
/// you must free the surface before you free the pixel data.
///
/// Pitch is the offset in bytes from one row of pixels to the next, e.g.
/// `width*4` for `sdl.pixels.format.RGBA8888`.
///
/// You may pass NULL for pixels and 0 for pitch to create a surface that you
/// will fill in with valid values later.
///
/// *param* width the width of the surface.
/// *param* height the height of the surface.
/// *param* format the SDL_PixelFormat for the new surface's pixel format.
/// *param* pixels a pointer to existing pixel data.
/// *param* pitch the number of bytes between each row, including padding.
/// *returns* the new Surface structure that is created or NULL on failure;
///          call sdl.err.get() for more information.
///
/// *threadsafety* It is safe to call this function from any thread.
pub fn create_from(width: i32, height: i32, format: PixelFormat, pixels: *anyopaque, pitch: i32) ?*Surface {
    return SDL_CreateSurfaceFrom(width, height, format, pixels, pitch);
}

extern fn SDL_CreateSurface(width: i32, height: i32, format: PixelFormat) callconv(.c) ?*Surface;
extern fn SDL_CreateSurfaceFrom(width: i32, height: i32, format: PixelFormat, pixels: *anyopaque, pitch: i32) callconv(.c) ?*Surface;
extern fn SDL_DestroySurface(surface: ?*Surface) callconv(.c) void;
