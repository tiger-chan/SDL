pub const io = struct {
    /// The read/write operation structure.
    ///
    /// This operates as an opaque handle. There are several APIs to create various
    /// types of I/O streams, or an app can supply an SDL_IOStreamInterface to
    /// SDL_OpenIO() to provide their own stream implementation behind this
    /// struct's abstract interface.
    pub const Stream = opaque {};

    /// SDL_IOStream status, set by a read or write operation.
    pub const Status = enum(u8) {
        /// Everything is ready (no errors and not EOF).
        Ready,
        /// Read or write I/O error
        Error,
        /// End of file
        Eof,
        /// Non blocking I/O, not ready
        NotReady,
        /// Tried to write a read-only buffer
        ReadOnly,
        /// Tried to read a write-only buffer
        WriteOnly,
    };

    /// Use this function to prepare a read-only memory buffer for use with
    /// SDL_IOStream.
    ///
    /// This function sets up an SDL_IOStream struct based on a memory area of a
    /// certain size. It assumes the memory area is not writable.
    ///
    /// Attempting to write to this SDL_IOStream stream will report an error
    /// without writing to the memory buffer.
    ///
    /// This memory buffer is not copied by the SDL_IOStream; the pointer you
    /// provide must remain valid until you close the stream. Closing the stream
    /// will not free the original buffer.
    ///
    /// If you need to write to a memory buffer, you should use SDL_IOFromMem()
    /// with a writable buffer of memory instead.
    ///
    /// The following properties will be set at creation time by SDL:
    ///
    /// - `SDL_PROP_IOSTREAM_MEMORY_POINTER`: this will be the `mem` parameter that
    ///   was passed to this function.
    /// - `SDL_PROP_IOSTREAM_MEMORY_SIZE_NUMBER`: this will be the `size` parameter
    ///   that was passed to this function.
    ///
    /// *param* mem a pointer to a read-only buffer to feed an SDL_IOStream stream.
    /// *param* size the buffer size, in bytes.
    /// *returns* a pointer to a new SDL_IOStream structure or NULL on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// *threadsafety* It is safe to call this function from any thread.
    pub fn from_const_mem(mem: []const u8) ?*Stream {
        return SDL_IOFromConstMem(@ptrCast(mem.ptr), mem.len);
    }

    /// Close and free an allocated SDL_IOStream structure.
    ///
    /// sdl.io.close() closes and cleans up the IOStream stream. It releases any
    /// resources used by the stream and frees the IOStream itself. This
    /// returns true on success, or false if the stream failed to flush to its
    /// output (e.g. to disk).
    ///
    /// Note that if this fails to flush the stream for any reason, this function
    /// reports an error, but the IOStream is still invalid once this function
    /// returns.
    ///
    /// This call flushes any buffered writes to the operating system, but there
    /// are no guarantees that those writes have gone to physical media; they might
    /// be in the OS's file cache, waiting to go to disk later. If it's absolutely
    /// crucial that writes go to disk immediately, so they are definitely stored
    /// even if the power fails before the file cache would have caught up, one
    /// should call sdl.io.flush() before closing. Note that flushing takes time and
    /// makes the system and your app operate less efficiently, so do so sparingly.
    ///
    /// *param* context IOStream structure to close.
    /// *returns* true on success or false on failure; call sdl.err.get() for more
    ///          information.
    ///
    /// *threadsafety* This function is not thread safe.
    pub fn close(context: *Stream) bool {
        return SDL_CloseIO(context);
    }

    /// Flush any buffered data in the stream.
    ///
    /// This function makes sure that any buffered data is written to the stream.
    /// Normally this isn't necessary but if the stream is a pipe or socket it
    /// guarantees that any pending data is sent.
    ///
    /// *param* context SDL_IOStream structure to flush.
    /// *returns* true on success or false on failure; call SDL_GetError() for more
    ///          information.
    ///
    /// *threadsafety* This function is not thread safe.
    pub fn flush(context: *Stream) bool {
        return SDL_FlushIO(context);
    }

    /// Write to an SDL_IOStream data stream.
    ///
    /// This function writes exactly `size` bytes from the area pointed at by `ptr`
    /// to the stream. If this fails for any reason, it'll return less than `size`
    /// to demonstrate how far the write progressed. On success, it returns `size`.
    ///
    /// On error, this function still attempts to write as much as possible, so it
    /// might return a positive value less than the requested write size.
    ///
    /// The caller can use SDL_GetIOStatus() to determine if the problem is
    /// recoverable, such as a non-blocking write that can simply be retried later,
    /// or a fatal error.
    ///
    /// *param* context a pointer to an SDL_IOStream structure.
    /// *param* buf a pointer to a buffer containing data to write.
    /// *returns* the number of bytes written, which will be less than `size` on
    ///          failure; call sdl.err.get() for more information.
    ///
    /// *threadsafety* This function is not thread safe.
    pub fn write(context: *Stream, buf: *[]u8) usize {
        return SDL_WriteIO(context, @ptrCast(buf.ptr), buf.len);
    }

    /// Query the stream status of an SDL_IOStream.
    ///
    /// This information can be useful to decide if a short read or write was due
    /// to an error, an EOF, or a non-blocking operation that isn't yet ready to
    /// complete.
    ///
    /// An SDL_IOStream's status is only expected to change after a SDL_ReadIO or
    /// SDL_WriteIO call; don't expect it to change if you just call this query
    /// function in a tight loop.
    ///
    /// *param* context the SDL_IOStream to query.
    /// *returns* an SDL_IOStatus enum with the current state.
    ///
    /// *threadsafety* This function is not thread safe.
    pub fn status(context: *Stream) Status {
        return SDL_GetIOStatus(context);
    }
};

extern fn SDL_CloseIO(context: *io.Stream) callconv(.c) bool;
extern fn SDL_IOFromConstMem(mem: *const anyopaque, size: usize) callconv(.c) ?*io.Stream;
extern fn SDL_FlushIO(context: *io.Stream) callconv(.c) bool;
extern fn SDL_WriteIO(context: *io.Stream, ptr: *const anyopaque, size: usize) callconv(.c) usize;
extern fn SDL_GetIOStatus(context: *io.Stream) io.Status;
