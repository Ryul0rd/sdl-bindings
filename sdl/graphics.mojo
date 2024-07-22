from sys import ffi
from .display import Surface, C_Surface


var path = '/lib/x86_64-linux-gnu/libSDL2_gfx-1.0.so.0'
var sdl = ffi.DLHandle(path)


var _rotozoom_surface = sdl.get_function[
    fn(UnsafePointer[C_Surface], Float64, Float64, Int32) -> UnsafePointer[C_Surface]
]('rotozoomSurface')
fn rotozoom_surface(source: Surface, angle: Float64, zoom: Float64, smooth: Bool) -> Surface:
    var new_surface_ptr = _rotozoom_surface(source._c_surface_ptr, angle, zoom, smooth)
    return Surface(new_surface_ptr)
