"""Defines an SDL Pixel Format."""


@value
struct Pixels:
    var _ptr: Ptr[NoneType]
    var pitch: IntC


struct Palette:
    var ncolors: IntC
    """The number of colors in the palette."""
    var colors: Ptr[Color]
    """An array of SDL_Color structures representing the palette."""
    var version: UInt32
    """Incrementally tracks changes to the palette (internal use)."""
    var refcount: IntC
    """Reference count (internal use)."""


struct SurfacePixelFormat:
    var format: UInt32
    var palette: Ptr[Palette]
    var bits_per_pixel: UInt8
    var bytes_per_pixel: UInt8
    var padding: UInt16
    var rmask: UInt32
    var gmask: UInt32
    var bmask: UInt32
    var amask: UInt32
    var rloss: UInt8
    var gloss: UInt8
    var bloss: UInt8
    var aloss: UInt8
    var rshift: UInt8
    var gshift: UInt8
    var bshift: UInt8
    var ashift: UInt8
    var refcount: Int32
    var next: Ptr[SurfacePixelFormat]


struct TexturePixelFormat:
    alias RGBA8888: UInt32 = 373694468
