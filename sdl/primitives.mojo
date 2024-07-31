"""Defines SDL Primitives."""


@value
struct Color:
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8

    fn __init__(inout self, r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 0):
        self.r = r
        self.g = g
        self.b = b
        self.a = a

    fn as_uint32(owned self) -> UInt32:
        return UnsafePointer.address_of(Color(self.b, self.g, self.r, self.a)).bitcast[UInt32]()[]


@value
struct Point:
    var x: Int32
    var y: Int32


@value
struct FPoint:
    var x: Float32
    var y: Float32


@value
struct Rect:
    var x: Int32
    var y: Int32
    var w: Int32
    var h: Int32


@value
struct FRect:
    var x: Float32
    var y: Float32
    var w: Float32
    var h: Float32


@value
struct Vertex:
    """Vertex structure."""

    var position: FPoint
    """Vertex position, in SDL_Renderer coordinates."""

    var color: Color
    """Vertex color."""

    var tex_coord: FPoint
    """Normalized texture coordinates, if needed."""
