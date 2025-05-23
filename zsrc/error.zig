extern fn SDL_GetError() [*:0]const u8;
extern fn SDL_ClearError() bool;

/// Retrieve a message about the last error that occurred on the current
/// thread.
///
/// It is possible for multiple errors to occur before calling SDL_GetError().
/// Only the last error is returned.
///
/// The message is only applicable when an SDL function has signaled an error.
/// You must check the return values of SDL function calls to determine when to
/// appropriately call sdl.err.get(). You should *not* use the results of
/// sdl.err.get() to decide if an error has occurred! Sometimes SDL will set
/// an error string even when reporting success.
///
/// SDL will *not* clear the error string for successful API calls. You *must*
/// check return values for failure cases before you can assume the error
/// string applies.
///
/// Error strings are set per-thread, so an error set in a different thread
/// will not interfere with the current thread's operation.
///
/// The returned value is a thread-local string which will remain valid until
/// the current thread's error string is changed. The caller should make a copy
/// if the value is needed after the next SDL API call.
pub fn get() [*:0]const u8 {
    return SDL_GetError();
}

/// Clear any previous error message for this thread.
pub fn clear() bool {
    return SDL_ClearError();
}
