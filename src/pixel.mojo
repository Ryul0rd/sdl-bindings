"""Defines an SDL Pixel Format."""

from sys.info import is_big_endian


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


@value
@register_passable("trivial")
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


@value
@register_passable("trivial")
struct TexturePixelFormat:
    alias RGBA8888: UInt32 = 0x16462004
    alias ABGR8888: UInt32 = 0x16762004
    alias RGBA32: UInt32 = Self.RGBA8888 if is_big_endian() else Self.ABGR8888
    alias RGB24: UInt32 = 0x17101803
