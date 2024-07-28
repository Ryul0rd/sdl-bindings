var _rotozoom_surface = _sdl_gfx.get_function[
    fn(UnsafePointer[C_Surface], Float64, Float64, Int32) -> UnsafePointer[C_Surface]
]('rotozoomSurface')
fn rotozoom_surface(source: Surface, angle: Float64, zoom: Float64, smooth: Bool) -> Surface:
    var new_surface_ptr = _rotozoom_surface(source._c_surface_ptr, angle, zoom, Int32(smooth))
    return Surface(new_surface_ptr)
