pub const video = @import("video.zig");
pub const c_rect = @import("rect.zig");
const c_WindowFlags = video.c_WindowFlags;
const WindowFlags = video.WindowFlags;
const Window = video.Window;

pub const Renderer = opaque {};

extern fn SDL_CreateWindowAndRenderer(title: [*:0]const u8, width: c_int, height: c_int, window_flags: c_WindowFlags, window: **Window, renderer: **Renderer) callconv(.c) bool;
extern fn SDL_DestroyRenderer(renderer: *Renderer) callconv(.c) void;
extern fn SDL_SetRenderDrawColor(renderer: *Renderer, r: u8, g: u8, b: u8, a: u8) callconv(.c) bool;
extern fn SDL_RenderFillRect(renderer: *Renderer, rect: *const c_rect.FRect) callconv(.c) bool;
extern fn SDL_RenderClear(renderer: *Renderer) callconv(.c) bool;
extern fn SDL_RenderPresent(renderer: *Renderer) callconv(.c) bool;

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
