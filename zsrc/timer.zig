/// Get the number of milliseconds since SDL library initialization.
///
/// *threadsafety* It is safe to call this function from any thread.
extern fn SDL_GetTicks() callconv(.c) u64;

pub fn get_ticks() u64 {
    return SDL_GetTicks();
}
