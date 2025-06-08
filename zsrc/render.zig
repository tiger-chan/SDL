const video = @import("video.zig");
const c_rect = @import("rect.zig");
const c_WindowFlags = video.c_WindowFlags;
const WindowFlags = video.WindowFlags;
const Window = video.Window;
const Surface = @import("surface.zig").Surface;
const FRect = @import("rect.zig").FRect;

pub const Renderer = opaque {};
pub const Texture = opaque {};

/// Create a window and default renderer.
///
/// *threadsafety* This function should only be called on the main thread.
pub fn create_window_and_renderer(title: [*:0]const u8, width: u16, height: u16, window_flags: WindowFlags) ?struct { window: *Window, renderer: *Renderer } {
    var window: *Window = undefined;
    var renderer: *Renderer = undefined;
    if (SDL_CreateWindowAndRenderer(title, @intCast(width), @intCast(height), window_flags.to_int(), &window, &renderer)) {
        return .{
            .window = window,
            .renderer = renderer,
        };
    } else {
        return null;
    }
}

/// Destroy the rendering context for a window and free all associated
/// textures.
///
/// This should be called before destroying the associated window.
///
/// *threadsafety* This function should only be called on the main thread.
pub fn destroy(renderer: *Renderer) void {
    SDL_DestroyRenderer(renderer);
}

/// Set the color used for drawing operations.
///
/// Set the color for drawing or filling rectangles, lines, and points, and for
/// sdl.render.clear().
///
/// *param* renderer the rendering context.
/// *param* r the red value used to draw on the rendering target.
/// *param* g the green value used to draw on the rendering target.
/// *param* b the blue value used to draw on the rendering target.
/// *param* a the alpha value used to draw on the rendering target; usually
///          `sdl.ALPHA_OPAQUE` (255). Use sdl.render.draw_blend_mode() to
///          specify how the alpha channel is used.
/// *returns* true on success or false on failure; call sdl.err.get() for more
///          information.
///
/// *threadsafety* This function should only be called on the main thread.
pub fn draw_color(renderer: *Renderer, r: u8, g: u8, b: u8, a: u8) bool {
    return SDL_SetRenderDrawColor(renderer, r, g, b, a);
}

/// Clear the current rendering target with the drawing color.
///
/// This function clears the entire rendering target, ignoring the viewport and
/// the clip rectangle. Note, that clearing will also set/fill all pixels of
/// the rendering target to current renderer draw color, so make sure to invoke
/// sdl.render.draw_color() when needed.
///
/// *param* renderer the rendering context.
/// *returns* true on success or false on failure; call sdl.err.get() for more
///          information.
///
/// *threadsafety* This function should only be called on the main thread.
pub fn clear(renderer: *Renderer) bool {
    return SDL_RenderClear(renderer);
}

/// Fill a rectangle on the current rendering target with the drawing color at
/// subpixel precision.
///
/// *param* renderer the renderer which should fill a rectangle.
/// *param* rect a pointer to the destination rectangle, or NULL for the entire
///             rendering target.
/// *returns* true on success or false on failure; call sdl.err.get() for more
///          information.
///
/// *threadsafety* This function should only be called on the main thread.
pub fn fill_rect(renderer: *Renderer, rect: *const c_rect.FRect) bool {
    return SDL_RenderFillRect(renderer, rect);
}

/// Update the screen with any rendering performed since the previous call.
///
/// SDL's rendering functions operate on a backbuffer; that is, calling a
/// rendering function such as sdl.render.line() does not directly put a line on
/// the screen, but rather updates the backbuffer. As such, you compose your
/// entire scene and *present* the composed backbuffer to the screen as a
/// complete picture.
///
/// Therefore, when using SDL's rendering API, one does all drawing intended
/// for the frame, and then calls this function once per frame to present the
/// final drawing to the user.
///
/// The backbuffer should be considered invalidated after each present; do not
/// assume that previous contents will exist between frames. You are strongly
/// encouraged to call sdl.render.clear() to initialize the backbuffer before
/// starting each new frame's drawing, even if you plan to overwrite every
/// pixel.
///
/// Please note, that in case of rendering to a texture - there is **no need**
/// to call `SDL_RenderPresent` after drawing needed objects to a texture, and
/// should not be done; you are only required to change back the rendering
/// target to default via `SDL_SetRenderTarget(renderer, NULL)` afterwards, as
/// textures by themselves do not have a concept of backbuffers. Calling
/// SDL_RenderPresent while rendering to a texture will still update the screen
/// with any current drawing that has been done _to the window itself_.
///
/// *param* renderer the rendering context.
/// *returns* true on success or false on failure; call sdl.err.get() for more
///          information.
///
/// *threadsafety* This function should only be called on the main thread.
pub fn present(renderer: *Renderer) bool {
    return SDL_RenderPresent(renderer);
}

/// Create a texture from an existing surface.
///
/// The surface is not modified or freed by this function.
///
/// The SDL_TextureAccess hint for the created texture is
/// `SDL_TEXTUREACCESS_STATIC`.
///
/// The pixel format of the created texture may be different from the pixel
/// format of the surface, and can be queried using the
/// SDL_PROP_TEXTURE_FORMAT_NUMBER property.
///
/// *param* renderer the rendering context.
/// *param* surface the SDL_Surface structure containing pixel data used to fill
///                the texture.
/// *returns* the created texture or NULL on failure; call sdl.err.get() for
///          more information.
///
/// *threadsafety* This function should only be called on the main thread.
pub fn create_texture_from_surface(renderer: *Renderer, surface: *Surface) ?*Texture {
    return SDL_CreateTextureFromSurface(renderer, surface);
}

/// Get the output size in pixels of a rendering context.
///
/// This returns the true output size in pixels, ignoring any render targets or
/// logical size and presentation.
///
/// For the output size of the current rendering target, with logical size
/// adjustments, use sdl.render.current_output_size() instead.
///
/// *param* renderer the rendering context.
/// *param* w a pointer filled in with the width in pixels.
/// *param* h a pointer filled in with the height in pixels.
/// *returns* height and width on success or null on failure; call sdl.err.get() for more
///          information.
///
/// *threadsafety* This function should only be called on the main thread.
pub fn output_size(renderer: *Renderer) ?struct { w: i32, h: i32 } {
    var w: i32 = undefined;
    var h: i32 = undefined;
    if (SDL_GetRenderOutputSize(renderer, &w, &h)) {
        return .{ .w = w, .h = h };
    }
    return null;
}

/// Get the current output size in pixels of a rendering context.
///
/// If a rendering target is active, this will return the size of the rendering
/// target in pixels, otherwise return the value of sdl.render.output_size().
///
/// Rendering target or not, the output will be adjusted by the current logical
/// presentation state, dictated by SDL_SetRenderLogicalPresentation().
///
/// *param* renderer the rendering context.
/// *param* w a pointer filled in with the current width.
/// *param* h a pointer filled in with the current height.
/// *returns* height and width on success or null on failure; call sdl.err.get() for more
///          information.
///
/// *threadsafety* This function should only be called on the main thread.
pub fn current_output_size(renderer: *Renderer) ?struct { w: i32, h: i32 } {
    var w: i32 = undefined;
    var h: i32 = undefined;
    if (SDL_GetCurrentRenderOutputSize(renderer, &w, &h)) {
        return .{ .w = w, .h = h };
    }
    return null;
}

/// Set the drawing scale for rendering on the current target.
///
/// The drawing coordinates are scaled by the x/y scaling factors before they
/// are used by the renderer. This allows resolution independent drawing with a
/// single coordinate system.
///
/// If this results in scaling or subpixel drawing by the rendering backend, it
/// will be handled using the appropriate quality hints. For best results use
/// integer scaling factors.
///
/// Each render target has its own scale. This function sets the scale for the
/// current render target.
///
/// *param* renderer the rendering context.
/// *param* scaleX the horizontal scaling factor.
/// *param* scaleY the vertical scaling factor.
/// *returns* true on success or false on failure; call sdl.err.get() for more
///          information.
///
/// *threadsafety* This function should only be called on the main thread.
pub fn set_scale(renderer: *Renderer, scale_x: f32, scale_y: f32) bool {
    return SDL_SetRenderScale(renderer, scale_x, scale_y);
}

/// Get the size of a texture, as floating point values.
///
/// *param* texture the texture to query.
/// *param* w a pointer filled in with the width of the texture in pixels. This
///          argument can be NULL if you don't need this information.
/// *param* h a pointer filled in with the height of the texture in pixels. This
///          argument can be NULL if you don't need this information.
/// *returns* true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// *threadsafety* This function should only be called on the main thread.
pub fn texture_size(t: *Texture) ?struct { w: f32, h: f32 } {
    var w: f32 = undefined;
    var h: f32 = undefined;
    if (SDL_GetTextureSize(t, &w, &h)) {
        return .{ .w = w, .h = h };
    }
    return null;
}

/// Copy a portion of the texture to the current rendering target at subpixel
/// precision.
///
/// *param* renderer the renderer which should copy parts of a texture.
/// *param* texture the source texture.
/// *param* srcrect a pointer to the source rectangle, or NULL for the entire
///                texture.
/// *param* dstrect a pointer to the destination rectangle, or NULL for the
///                entire rendering target.
/// *returns* true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// *threadsafety* This function should only be called on the main thread.
pub fn texture(renderer: *Renderer, t: *Texture, src_rect: ?*const FRect, dst_rect: ?*const FRect) bool {
    return SDL_RenderTexture(renderer, t, src_rect, dst_rect);
}

extern fn SDL_CreateWindowAndRenderer(title: [*:0]const u8, width: c_int, height: c_int, window_flags: c_WindowFlags, window: **Window, renderer: **Renderer) callconv(.c) bool;
extern fn SDL_DestroyRenderer(renderer: *Renderer) callconv(.c) void;
extern fn SDL_SetRenderDrawColor(renderer: *Renderer, r: u8, g: u8, b: u8, a: u8) callconv(.c) bool;
extern fn SDL_RenderClear(renderer: *Renderer) callconv(.c) bool;
extern fn SDL_RenderFillRect(renderer: *Renderer, rect: *const c_rect.FRect) callconv(.c) bool;
extern fn SDL_RenderPresent(renderer: *Renderer) callconv(.c) bool;
extern fn SDL_RenderTexture(renderer: *Renderer, t: *Texture, src_rect: ?*const FRect, dst_rect: ?*const FRect) bool;
extern fn SDL_CreateTextureFromSurface(renderer: *Renderer, surface: *Surface) callconv(.c) ?*Texture;
extern fn SDL_GetCurrentRenderOutputSize(renderer: *Renderer, w: *i32, h: *i32) bool;
extern fn SDL_GetRenderOutputSize(renderer: *Renderer, w: *i32, h: *i32) callconv(.c) bool;
extern fn SDL_GetTextureSize(texture: *Texture, w: *f32, h: *f32) callconv(.c) bool;
extern fn SDL_SetRenderScale(renderer: *Renderer, scale_x: f32, scale_y: f32) callconv(.c) bool;
