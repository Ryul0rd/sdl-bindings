from ..surface import _Surface
from ..render import _Renderer


var _rotozoom_surface = _sdl_gfx.get_function[
    fn (UnsafePointer[_Surface], Float64, Float64, Int32) -> UnsafePointer[_Surface]
]("rotozoomSurface")


fn rotozoom_surface(source: Surface, angle: Float64, zoom: Float64, smooth: Bool) -> Surface:
    var new_surface_ptr = _rotozoom_surface(source._surface_ptr, angle, zoom, Int32(smooth))
    return Surface(new_surface_ptr)


var _circle_color = _sdl_gfx.get_function[
    fn (UnsafePointer[_Renderer], Int16, Int16, Int16, UInt32) -> Int
]("circleColor")


fn circle_color(
    _renderer_ptr: UnsafePointer[_Renderer], x: Int16, y: Int16, rad: Int16, color: UInt32
) raises:
    if _circle_color(_renderer_ptr, x, y, rad, color) < 0:
        raise get_error()


var _circle_rgba = _sdl_gfx.get_function[
    fn (UnsafePointer[_Renderer], Int16, Int16, Int16, UInt8, UInt8, UInt8, UInt8) -> Int
]("circleRGBA")


fn circle_rgba(
    _renderer_ptr: UnsafePointer[_Renderer],
    x: Int16,
    y: Int16,
    rad: Int16,
    r: UInt8,
    g: UInt8,
    b: UInt8,
    a: UInt8,
) raises:
    if _circle_rgba(_renderer_ptr, x, y, rad, r, g, b, a) < 0:
        raise get_error()
