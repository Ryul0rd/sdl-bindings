"""Defines SDL Primitives."""

from .utils import adr


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
        return adr(Color(self.b, self.g, self.r, self.a)).bitcast[UInt32]()[]


@value
struct DPoint[type: DType]:
    var x: Scalar[type]
    var y: Scalar[type]

    @always_inline("nodebug")
    fn __init__(inout self, x: Scalar, y: Scalar):
        self.x = x.cast[type]()
        self.y = y.cast[type]()

    @always_inline("nodebug")
    fn cast[type: DType](self) -> DPoint[type]:
        return DPoint[type](self.x, self.y)


alias Point = DPoint[DType.int32]
alias FPoint = DPoint[DType.float32]


@value
struct DRect[type: DType]:
    var x: Scalar[type]
    var y: Scalar[type]
    var w: Scalar[type]
    var h: Scalar[type]

    @always_inline("nodebug")
    fn __init__(inout self, x: Scalar, y: Scalar, w: Scalar, h: Scalar):
        self.x = x.cast[type]()
        self.y = y.cast[type]()
        self.w = w.cast[type]()
        self.h = h.cast[type]()

    @always_inline("nodebug")
    fn cast[type: DType](self) -> DRect[type]:
        return DRect[type](self.x, self.y, self.w, self.h)


alias Rect = DRect[DType.int32]
alias FRect = DRect[DType.float32]


@value
struct Vertex:
    """Vertex structure."""

    var position: FPoint
    """Vertex position, in SDL_Renderer coordinates."""

    var color: Color
    """Vertex color."""

    var tex_coord: FPoint
    """Normalized texture coordinates, if needed."""
