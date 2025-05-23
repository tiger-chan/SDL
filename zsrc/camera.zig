/// This is a unique Id for a camera device for the time it is connected to the
/// system, and is never reused for the lifetime of the application.
///
/// If the device is disconnected and reconnected, it will get a new Id.
///
/// The value 0 is an invalid Id.
pub const Id = u32;
