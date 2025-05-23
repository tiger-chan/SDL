pub const c_Scancode = c_int;

pub const Scancode = enum(u16) {
    Unknown = 0,

    A = 4,
    B = 5,
    C = 6,
    D = 7,
    E = 8,
    F = 9,
    G = 10,
    H = 11,
    I = 12,
    J = 13,
    K = 14,
    L = 15,
    M = 16,
    N = 17,
    O = 18,
    P = 19,
    Q = 20,
    R = 21,
    S = 22,
    T = 23,
    U = 24,
    V = 25,
    W = 26,
    X = 27,
    Y = 28,
    Z = 29,

    Num1 = 30,
    Num2 = 31,
    Num3 = 32,
    Num4 = 33,
    Num5 = 34,
    Num6 = 35,
    Num7 = 36,
    Num8 = 37,
    Num9 = 38,
    Num0 = 39,

    RETURN = 40,
    ESCAPE = 41,
    BACKSPACE = 42,
    TAB = 43,
    SPACE = 44,

    MINUS = 45,
    EQUALS = 46,
    LeftBracket = 47,
    RightBracket = 48,
    /// Located at the lower left of the return key on ISO keyboards and at the
    /// right end of the QWERTY row on ANSI keyboards. Produces REVERSE SOLIDUS
    /// (backslash) and VERTICAL LINE in a US layout, REVERSE SOLIDUS and
    /// VERTICAL LINE in a UK Mac layout, NUMBER SIGN and TILDE in a UK Windows
    /// layout, DOLLAR SIGN and POUND SIGN in a Swiss German layout, NUMBER
    /// SIGN and APOSTROPHE in a German layout, GRAVE ACCENT and POUND SIGN in
    /// a French Mac layout, and ASTERISK and MICRO SIGN in a French Windows
    /// layout.
    Backslash = 49,
    /// ISO USB keyboards actually use this code instead of 49 for the same
    /// key, but all OSes I've seen treat the two codes identically. So, as an
    /// implementor, unless your keyboard generates both of those codes and
    /// your OS treats them differently, you should generate BACKSLASH instead
    /// of this code. As a user, you should not rely on this code because SDL
    /// will never generate it with most (all?) keyboards.
    Nonushash = 50,
    Semicolon = 51,
    Apostrophe = 52,
    /// Located in the top left corner (on both ANSI and ISO keyboards).
    /// Produces GRAVE ACCENT and TILDE in a US Windows layout and in US and UK
    /// Mac layouts on ANSI keyboards, GRAVE ACCENT and NOT SIGN in a UK
    /// Windows layout, SECTION SIGN and PLUS-MINUS SIGN in US and UK Mac
    /// layouts on ISO keyboards, SECTION SIGN and DEGREE SIGN in a Swiss
    /// German layout (Mac: only on ISO keyboards), CIRCUMFLEX ACCENT and
    /// DEGREE SIGN in a German layout (Mac: only on ISO keyboards),
    /// SUPERSCRIPT TWO and TILDE in a French Windows layout, COMMERCIAL AT and
    /// NUMBER SIGN in a French Mac layout on ISO keyboards, and LESS-THAN SIGN
    /// and GREATER-THAN SIGN in a Swiss German, German, or French Mac layout
    /// on ANSI keyboards.
    Grave = 53,
    Comma = 54,
    Period = 55,
    Slash = 56,

    Capslock = 57,

    F1 = 58,
    F2 = 59,
    F3 = 60,
    F4 = 61,
    F5 = 62,
    F6 = 63,
    F7 = 64,
    F8 = 65,
    F9 = 66,
    F10 = 67,
    F11 = 68,
    F12 = 69,

    Printscreen = 70,
    Scrolllock = 71,
    Pause = 72,
    /// insert on PC, help on some Mac keyboards (but does send code 73, not
    /// 117)
    Insert = 73,
    Home = 74,
    Pageup = 75,
    Delete = 76,
    End = 77,
    Pagedown = 78,
    Right = 79,
    Left = 80,
    Down = 81,
    Up = 82,

    /// num lock on PC, clear on Mac keyboards
    Numlockclear = 83,
    KP_Divide = 84,
    KP_Multiply = 85,
    KP_Minus = 86,
    KP_Plus = 87,
    KP_Enter = 88,
    KP_1 = 89,
    KP_2 = 90,
    KP_3 = 91,
    KP_4 = 92,
    KP_5 = 93,
    KP_6 = 94,
    KP_7 = 95,
    KP_8 = 96,
    KP_9 = 97,
    KP_0 = 98,
    KP_PERIOD = 99,

    /// This is the additional key that ISO keyboards have over ANSI ones,
    /// located between left shift and Y. Produces GRAVE ACCENT and TILDE in a
    /// US or UK Mac layout, REVERSE SOLIDUS (backslash) and VERTICAL LINE in a
    /// US or UK Windows layout, and LESS-THAN SIGN and GREATER-THAN SIGN in a
    /// Swiss German, German, or French layout.
    NonUsBackslash = 100,
    /// windows contextual menu, compose
    Application = 101,
    /// The USB document says this is a status flag, not a physical key - but
    /// some Mac keyboards do have a power key.
    Power = 102,
    KP_Equals = 103,
    F13 = 104,
    F14 = 105,
    F15 = 106,
    F16 = 107,
    F17 = 108,
    F18 = 109,
    F19 = 110,
    F20 = 111,
    F21 = 112,
    F22 = 113,
    F23 = 114,
    F24 = 115,
    Execute = 116,
    /// AL Integrated Help Center
    Help = 117,
    /// Menu (show menu)
    Menu = 118,
    Select = 119,
    /// AC Stop
    Stop = 120,
    /// AC Redo/Repeat
    Again = 121,
    /// AC Undo
    Undo = 122,
    /// AC Cut
    Cut = 123,
    /// AC Copy
    Copy = 124,
    /// AC Paste
    Paste = 125,
    /// AC Find
    Find = 126,
    Mute = 127,
    Volumeup = 128,
    Volumedown = 129,

    KP_Comma = 133,
    KP_Equalsas400 = 134,

    /// used on Asian keyboards, see footnotes in USB doc
    International1 = 135,
    International2 = 136,
    /// Yen
    International3 = 137,
    International4 = 138,
    International5 = 139,
    International6 = 140,
    International7 = 141,
    International8 = 142,
    International9 = 143,
    /// Hangul/English toggle
    Lang1 = 144,
    /// Hanja conversion
    Lang2 = 145,
    /// Katakana
    Lang3 = 146,
    /// Hiragana
    Lang4 = 147,
    /// Zenkaku/Hankaku
    Lang5 = 148,
    /// reserved
    Lang6 = 149,
    /// reserved
    Lang7 = 150,
    /// reserved
    Lang8 = 151,
    /// reserved
    Lang9 = 152,

    /// Erase-Eaze
    Alterase = 153,
    Sysreq = 154,
    /// AC Cancel
    Cancel = 155,
    Clear = 156,
    Prior = 157,
    Return2 = 158,
    Separator = 159,
    Out = 160,
    Oper = 161,
    ClearAgain = 162,
    Crsel = 163,
    Exsel = 164,

    KP_00 = 176,
    KP_000 = 177,
    ThousandsSeparator = 178,
    DecimalSeparator = 179,
    CurrencyUnit = 180,
    CurrencySubunit = 181,
    KP_LeftParen = 182,
    KP_RightParen = 183,
    KP_LeftBrace = 184,
    KP_RightBrace = 185,
    KP_Tab = 186,
    KP_Backspace = 187,
    KP_A = 188,
    KP_B = 189,
    KP_C = 190,
    KP_D = 191,
    KP_E = 192,
    KP_F = 193,
    KP_Xor = 194,
    KP_Power = 195,
    KP_Percent = 196,
    KP_Less = 197,
    KP_Greater = 198,
    KP_Ampersand = 199,
    KP_DblAmpersand = 200,
    KP_VerticalBar = 201,
    KP_DblVerticalBar = 202,
    KP_Colon = 203,
    KP_Hash = 204,
    KP_Space = 205,
    KP_At = 206,
    KP_Exclam = 207,
    KP_MemStore = 208,
    KP_MemRecall = 209,
    KP_MemClear = 210,
    KP_MemAdd = 211,
    KP_MemSubtract = 212,
    KP_MemMultiply = 213,
    KP_MemDivide = 214,
    KP_Plusminus = 215,
    KP_Clear = 216,
    KP_Clearentry = 217,
    KP_Binary = 218,
    KP_Octal = 219,
    KP_Decimal = 220,
    KP_Hexadecimal = 221,

    LCtrl = 224,
    LShift = 225,
    /// alt, option
    LAlt = 226,
    /// windows, command (apple), meta
    LGui = 227,
    RCtrl = 228,
    RShift = 229,
    /// alt gr, option
    RAlt = 230,
    /// windows, command (apple), meta
    RGui = 231,

    /// I'm not sure if this is really not covered by any of the above, but
    /// since there's a special SDL_KMOD_MODE for it I'm adding it here
    Mode = 257,
    /// Sleep
    Sleep = 258,
    /// Wake
    Wake = 259,

    /// Channel Increment
    ChannelIncrement = 260,
    /// Channel Decrement
    ChannelDecrement = 261,

    /// Play
    MediaPlay = 262,
    /// Pause
    MediaPause = 263,
    /// Record
    MediaRecord = 264,
    /// Fast Forward
    MediaFast_forward = 265,
    /// Rewind
    MediaRewind = 266,
    /// Next Track
    MediaNext_track = 267,
    /// Previous Track
    MediaPrevious_track = 268,
    /// Stop
    MediaStop = 269,
    /// Eject
    MediaEject = 270,
    /// Play / Pause
    MediaPlay_pause = 271,
    /// Media Select
    MediaSelect = 272,

    /// AC New
    AC_New = 273,
    /// AC Open
    AC_Open = 274,
    /// AC Close
    AC_Close = 275,
    /// AC Exit
    AC_Exit = 276,
    /// AC Save
    AC_Save = 277,
    /// AC Print
    AC_Print = 278,
    /// AC Properties
    AC_Properties = 279,

    /// AC Search
    AC_Search = 280,
    /// AC Home
    AC_Home = 281,
    /// AC Back
    AC_Back = 282,
    /// AC Forward
    AC_Forward = 283,
    /// AC Stop
    AC_Stop = 284,
    /// AC Refresh
    AC_Refresh = 285,
    /// AC Bookmarks
    AC_Bookmarks = 286,

    /// Usually situated below the display on phones and used as a
    /// multi-function feature key for selecting a software defined function
    /// shown on the bottom left of the display.
    SoftLeft = 287,
    /// Usually situated below the display on phones and used as a
    /// multi-function feature key for selecting a software defined function
    /// shown on the bottom right of the display.
    SoftRight = 288,
    /// Used for accepting phone calls.
    Call = 289,
    /// Used for rejecting phone calls.
    Endcall = 290,

    /// 400-500 reserved for dynamic keycodes
    Reserved = 400,
};

/// not a key, just marks the number of scancodes for array bounds
pub const COUNT: usize = 512;
