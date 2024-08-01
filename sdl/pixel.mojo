"""Defines an SDL Pixel Format."""


@value
struct Pixels:
    var _ptr: UnsafePointer[NoneType]
    var pitch: Int


struct _Palette:
    pass


struct SurfacePixelFormat:
    var format: UInt32
    var palette: UnsafePointer[_Palette]
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
    var next: UnsafePointer[SurfacePixelFormat]


struct TexturePixelFormat:
    alias RGBA8888: UInt32 = 373694468
