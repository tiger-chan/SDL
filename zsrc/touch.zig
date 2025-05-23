/// A unique Id for a touch device.
///
/// This Id is valid for the time the device is connected to the system, and is
/// never reused for the lifetime of the application.
///
/// The value 0 is an invalid Id.
pub const Id = u64;

/// A unique Id for a single finger on a touch device.
///
/// This Id is valid for the time the finger (stylus, etc) is touching and will
/// be unique for all fingers currently in contact, so this Id tracks the
/// lifetime of a single continuous touch. This value may represent an index, a
/// pointer, or some other unique Id, depending on the platform.
///
/// The value 0 is an invalid Id.
pub const FingerId = u64;
