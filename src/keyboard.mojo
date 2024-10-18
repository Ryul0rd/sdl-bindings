"""Defines SDL Keyboard and Keys."""

from .utils import adr
from ._sdl import _SDL


struct Keyboard[lif: AnyLifetime[False].type]:
    var sdl: Reference[SDL, lif]
    var state: Ptr[UInt8]

    fn __init__(inout self, ref [lif]sdl: SDL):
        self.sdl = sdl
        var numkeys = IntC()
        self.state = sdl._sdl.get_keyboard_state(adr(numkeys))

    fn get_key(self, key: KeyCode) -> Bool:
        return bool(self.state[int(key.value)])


struct Keys:
    alias retvrn = ord("\r")
    alias escape = ord("\x1B")
    alias backspace = ord("\b")
    alias tab = ord("\t")
    alias space = ord(" ")
    alias exclaim = ord("!")
    alias quotedbl = ord('"')
    alias hash = ord("#")
    alias percent = ord("%")
    alias dollar = ord("$")
    alias ampersand = ord("&")
    alias quote = ord("'")
    alias leftparen = ord("(")
    alias rightparen = ord(")")
    alias asterisk = ord("*")
    alias plus = ord("+")
    alias comma = ord(",")
    alias minus = ord("-")
    alias period = ord(".")
    alias slash = ord("/")
    alias n0 = ord("0")
    alias n1 = ord("1")
    alias n2 = ord("2")
    alias n3 = ord("3")
    alias n4 = ord("4")
    alias n5 = ord("5")
    alias n6 = ord("6")
    alias n7 = ord("7")
    alias n8 = ord("8")
    alias n9 = ord("9")
    alias colon = ord(":")
    alias semicolon = ord(";")
    alias less = ord("<")
    alias equals = ord("=")
    alias greater = ord(">")
    alias question = ord("?")
    alias at = ord("@")
    # skip uppercase letters
    alias leftbracket = ord("[")
    alias backslash = ord("\\")
    alias rightbracket = ord("]")
    alias caret = ord("^")
    alias underscore = ord("_")
    alias backquote = ord("`")
    alias a = ord("a")
    alias b = ord("b")
    alias c = ord("c")
    alias d = ord("d")
    alias e = ord("e")
    alias f = ord("f")
    alias g = ord("g")
    alias h = ord("h")
    alias i = ord("i")
    alias j = ord("j")
    alias k = ord("k")
    alias l = ord("l")
    alias m = ord("m")
    alias n = ord("n")
    alias o = ord("o")
    alias p = ord("p")
    alias q = ord("q")
    alias r = ord("r")
    alias s = ord("s")
    alias t = ord("t")
    alias u = ord("u")
    alias v = ord("v")
    alias w = ord("w")
    alias x = ord("x")
    alias y = ord("y")
    alias z = ord("z")


@value
@register_passable("trivial")
struct KeyCode:
    var value: IntC

    alias UNKNOWN = 0

    alias A = 4
    alias B = 5
    alias C = 6
    alias D = 7
    alias E = 8
    alias F = 9
    alias G = 10
    alias H = 11
    alias I = 12
    alias J = 13
    alias K = 14
    alias L = 15
    alias M = 16
    alias N = 17
    alias O = 18
    alias P = 19
    alias Q = 20
    alias R = 21
    alias S = 22
    alias T = 23
    alias U = 24
    alias V = 25
    alias W = 26
    alias X = 27
    alias Y = 28
    alias Z = 29

    alias _1 = 30
    alias _2 = 31
    alias _3 = 32
    alias _4 = 33
    alias _5 = 34
    alias _6 = 35
    alias _7 = 36
    alias _8 = 37
    alias _9 = 38
    alias _0 = 39

    alias RETURN = 40
    alias ESCAPE = 41
    alias BACKSPACE = 42
    alias TAB = 43
    alias SPACE = 44

    alias MINUS = 45
    alias EQUALS = 46
    alias LEFTBRACKET = 47
    alias RIGHTBRACKET = 48
    alias BACKSLASH = 49
    """Located at the lower left of the return
    key on ISO keyboards and at the right end
    of the QWERTY row on ANSI keyboards.
    Produces REVERSE SOLIDUS (backslash) and
    VERTICAL LINE in a US layout, REVERSE
    SOLIDUS and VERTICAL LINE in a UK Mac
    layout, NUMBER SIGN and TILDE in a UK
    Windows layout, DOLLAR SIGN and POUND SIGN
    in a Swiss German layout, NUMBER SIGN and
    APOSTROPHE in a German layout, GRAVE
    ACCENT and POUND SIGN in a French Mac
    layout, and ASTERISK and MICRO SIGN in a
    French Windows layout."""
    alias NONUSHASH = 50
    """ISO USB keyboards actually use this code
    instead of 49 for the same key, but all
    OSes I've seen treat the two codes
    identically. So, as an implementor, unless
    your keyboard generates both of those
    codes and your OS treats them differently,
    you should generate SDL_SCANCODE_BACKSLASH
    instead of this code. As a user, you
    should not rely on this code because SDL
    will never generate it with most (all?)
    keyboards."""
    alias SEMICOLON = 51
    alias APOSTROPHE = 52
    alias GRAVE = 53
    """Located in the top left corner (on both ANSI
    and ISO keyboards). Produces GRAVE ACCENT and
    TILDE in a US Windows layout and in US and UK
    Mac layouts on ANSI keyboards, GRAVE ACCENT
    and NOT SIGN in a UK Windows layout, SECTION
    SIGN and PLUS-MINUS SIGN in US and UK Mac
    layouts on ISO keyboards, SECTION SIGN and
    DEGREE SIGN in a Swiss German layout (Mac:
    only on ISO keyboards), CIRCUMFLEX ACCENT and
    DEGREE SIGN in a German layout (Mac: only on
    ISO keyboards), SUPERSCRIPT TWO and TILDE in a
    French Windows layout, COMMERCIAL AT and
    NUMBER SIGN in a French Mac layout on ISO
    keyboards, and LESS-THAN SIGN and GREATER-THAN
    SIGN in a Swiss German, German, or French Mac
    layout on ANSI keyboards."""
    alias COMMA = 54
    alias PERIOD = 55
    alias SLASH = 56

    alias CAPSLOCK = 57

    alias F1 = 58
    alias F2 = 59
    alias F3 = 60
    alias F4 = 61
    alias F5 = 62
    alias F6 = 63
    alias F7 = 64
    alias F8 = 65
    alias F9 = 66
    alias F10 = 67
    alias F11 = 68
    alias F12 = 69

    alias PRINTSCREEN = 70
    alias SCROLLLOCK = 71
    alias PAUSE = 72
    alias INSERT = 73
    """insert on PC, help on some Mac keyboards (but does send code 73, not 117)."""
    alias HOME = 74
    alias PAGEUP = 75
    alias DELETE = 76
    alias END = 77
    alias PAGEDOWN = 78
    alias RIGHT = 79
    alias LEFT = 80
    alias DOWN = 81
    alias UP = 82

    alias NUMLOCKCLEAR = 83
    """num lock on PC, clear on Mac keyboards."""
    alias KP_DIVIDE = 84
    alias KP_MULTIPLY = 85
    alias KP_MINUS = 86
    alias KP_PLUS = 87
    alias KP_ENTER = 88
    alias KP_1 = 89
    alias KP_2 = 90
    alias KP_3 = 91
    alias KP_4 = 92
    alias KP_5 = 93
    alias KP_6 = 94
    alias KP_7 = 95
    alias KP_8 = 96
    alias KP_9 = 97
    alias KP_0 = 98
    alias KP_PERIOD = 99

    alias NONUSBACKSLASH = 100
    """This is the additional key that ISO
    keyboards have over ANSI ones,
    located between left shift and Y.
    Produces GRAVE ACCENT and TILDE in a
    US or UK Mac layout, REVERSE SOLIDUS
    (backslash) and VERTICAL LINE in a
    US or UK Windows layout, and
    LESS-THAN SIGN and GREATER-THAN SIGN
    in a Swiss German, German, or French
    layout."""
    alias APPLICATION = 101
    """Windows contextual menu, compose."""
    alias POWER = 102
    """The USB document says this is a status flag, not a physical key - but some Mac keyboards do have a power key."""
    alias KP_EQUALS = 103
    alias F13 = 104
    alias F14 = 105
    alias F15 = 106
    alias F16 = 107
    alias F17 = 108
    alias F18 = 109
    alias F19 = 110
    alias F20 = 111
    alias F21 = 112
    alias F22 = 113
    alias F23 = 114
    alias F24 = 115
    alias EXECUTE = 116
    alias HELP = 117
    """Integrated Help Center."""
    alias MENU = 118
    """Menu (show menu)."""
    alias SELECT = 119
    alias STOP = 120
    """Stop."""
    alias AGAIN = 121
    """Redo/Repeat."""
    alias UNDO = 122
    """Undo."""
    alias CUT = 123
    """Cut."""
    alias COPY = 124
    """Copy."""
    alias PASTE = 125
    """Paste."""
    alias FIND = 126
    """Find."""
    alias MUTE = 127
    alias VOLUMEUP = 128
    alias VOLUMEDOWN = 129
    alias LOCKINGCAPSLOCK = 130
    """Possibly useless."""
    alias LOCKINGNUMLOCK = 131
    """Possibly useless."""
    alias LOCKINGSCROLLLOCK = 132
    """Possibly useless."""
    alias KP_COMMA = 133
    alias KP_EQUALSAS400 = 134

    alias INTERNATIONAL1 = 135
    """used on Asian keyboards, see footnotes in USB doc."""
    alias INTERNATIONAL2 = 136
    alias INTERNATIONAL3 = 137
    """Yen."""
    alias INTERNATIONAL4 = 138
    alias INTERNATIONAL5 = 139
    alias INTERNATIONAL6 = 140
    alias INTERNATIONAL7 = 141
    alias INTERNATIONAL8 = 142
    alias INTERNATIONAL9 = 143
    alias LANG1 = 144
    """Hangul/English toggle."""
    alias LANG2 = 145
    """Hanja conversion."""
    alias LANG3 = 146
    """Katakana."""
    alias LANG4 = 147
    """Hiragana."""
    alias LANG5 = 148
    """Zenkaku/Hankaku."""
    alias LANG6 = 149
    """Reserved."""
    alias LANG7 = 150
    """Reserved."""
    alias LANG8 = 151
    """Reserved."""
    alias LANG9 = 152
    """Reserved."""

    alias ALTERASE = 153
    """Erase-Eaze."""
    alias SYSREQ = 154
    alias CANCEL = 155
    """Cancel."""
    alias CLEAR = 156
    alias PRIOR = 157
    alias RETURN2 = 158
    alias SEPARATOR = 159
    alias OUT = 160
    alias OPER = 161
    alias CLEARAGAIN = 162
    alias CRSEL = 163
    alias EXSEL = 164

    alias KP_00 = 176
    alias KP_000 = 177
    alias THOUSANDSSEPARATOR = 178
    alias DECIMALSEPARATOR = 179
    alias CURRENCYUNIT = 180
    alias CURRENCYSUBUNIT = 181
    alias KP_LEFTPAREN = 182
    alias KP_RIGHTPAREN = 183
    alias KP_LEFTBRACE = 184
    alias KP_RIGHTBRACE = 185
    alias KP_TAB = 186
    alias KP_BACKSPACE = 187
    alias KP_A = 188
    alias KP_B = 189
    alias KP_C = 190
    alias KP_D = 191
    alias KP_E = 192
    alias KP_F = 193
    alias KP_XOR = 194
    alias KP_POWER = 195
    alias KP_PERCENT = 196
    alias KP_LESS = 197
    alias KP_GREATER = 198
    alias KP_AMPERSAND = 199
    alias KP_DBLAMPERSAND = 200
    alias KP_VERTICALBAR = 201
    alias KP_DBLVERTICALBAR = 202
    alias KP_COLON = 203
    alias KP_HASH = 204
    alias KP_SPACE = 205
    alias KP_AT = 206
    alias KP_EXCLAM = 207
    alias KP_MEMSTORE = 208
    alias KP_MEMRECALL = 209
    alias KP_MEMCLEAR = 210
    alias KP_MEMADD = 211
    alias KP_MEMSUBTRACT = 212
    alias KP_MEMMULTIPLY = 213
    alias KP_MEMDIVIDE = 214
    alias KP_PLUSMINUS = 215
    alias KP_CLEAR = 216
    alias KP_CLEARENTRY = 217
    alias KP_BINARY = 218
    alias KP_OCTAL = 219
    alias KP_DECIMAL = 220
    alias KP_HEXADECIMAL = 221

    alias LCTRL = 224
    alias LSHIFT = 225
    alias LALT = 226
    """alt, option."""
    alias LGUI = 227
    """windows, command (apple), meta."""
    alias RCTRL = 228
    alias RSHIFT = 229
    alias RALT = 230
    """alt gr, option."""
    alias RGUI = 231
    """windows, command (apple), meta"""

    alias MODE = 257

    # These values are mapped from usage page 0x0C (USB consumer page).
    # See https://usb.org/sites/default/files/hut1_2.pdf

    alias AUDIONEXT = 258
    alias AUDIOPREV = 259
    alias AUDIOSTOP = 260
    alias AUDIOPLAY = 261
    alias AUDIOMUTE = 262
    alias MEDIASELECT = 263
    alias WWW = 264
    """Internet Browser."""
    alias MAIL = 265
    alias CALCULATOR = 266
    """Calculator"""
    alias COMPUTER = 267
    alias AC_SEARCH = 268
    """Search."""
    alias AC_HOME = 269
    """Home."""
    alias AC_BACK = 270
    """Back."""
    alias AC_FORWARD = 271
    """Forward."""
    alias AC_STOP = 272
    """Stop."""
    alias AC_REFRESH = 273
    """Refresh."""
    alias AC_BOOKMARKS = 274
    """Bookmarks."""

    # thank you Christian Walther

    alias BRIGHTNESSDOWN = 275
    alias BRIGHTNESSUP = 276
    alias DISPLAYSWITCH = 277
    """display mirroring/dual display switch, video mode switch."""

    alias KBDILLUMTOGGLE = 278
    alias KBDILLUMDOWN = 279
    alias KBDILLUMUP = 280
    alias EJECT = 281
    alias SLEEP = 282
    """System Sleep"""

    alias APP1 = 283
    alias APP2 = 284

    # Media keys
    # These values are mapped from usage page 0x0C (USB consumer page).

    alias AUDIOREWIND = 285
    alias AUDIOFASTFORWARD = 286

    # Mobile keys
    # These are values that are often used on mobile phones.

    alias SOFTLEFT = 287
    """Usually situated below the display on phones and used as a multi-function feature key for selecting a software defined function shown on the bottom left of the display."""

    alias SOFTRIGHT = 288
    """Usually situated below the display on phones and used as a multi-function feature key for selecting a software defined function shown on the bottom right of the display."""

    alias CALL = 289
    """Used for accepting phone calls."""

    alias ENDCALL = 290
    """Used for rejecting phone calls."""

    # Add any other keys here.

    alias NUM_SCANCODES = 512
    """not a key, just marks the number of scancodes for array bounds."""
