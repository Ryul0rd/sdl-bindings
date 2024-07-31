"""Defines an SDL Surface."""

from .utils import opt2ptr


struct Surface:
    var _surface_ptr: UnsafePointer[_Surface]

    fn __init__(inout self, width: Int32, height: Int32, color: Optional[Color] = None):
        self._surface_ptr = create_rgb_surface(0, width, height, 32, 0, 0, 0, 0)
        if color:
            try:
                self.fill(color.unsafe_value())
            except:
                pass

    fn __init__(inout self, _surface_ptr: UnsafePointer[_Surface]):
        self._surface_ptr = _surface_ptr

    fn __moveinit__(inout self, owned other: Self):
        self._surface_ptr = other._surface_ptr

    fn __del__(owned self):
        free_surface(self._surface_ptr)

    # fn draw_line(self, x1: Int, y1: Int, x2: Int, y2: Int, color: Color = Color(255, 255, 255)):
    #     var

    fn fill(self, color: Color, rect: Optional[Rect] = None) raises:
        var error_code = fill_rect(self._surface_ptr, opt2ptr(rect), color.as_uint32())
        if error_code != 0:
            raise Error("Could not fill rect")

    fn blit(
        self,
        source: Surface,
        source_rect: Optional[Rect],
        destination_rect: Optional[Rect],
    ) raises:
        var error_code = blit_scaled(
            source._surface_ptr,
            opt2ptr(source_rect),
            self._surface_ptr,
            opt2ptr(destination_rect),
        )
        if error_code != 0:
            raise Error("Could not blit surface")

    fn rotozoomed(self, angle: Float64, zoom: Float64, smooth: Bool = False) -> Surface:
        return rotozoom_surface(self, angle, zoom, smooth)

    fn convert(inout self, format: Surface):
        self._surface_ptr = convert_surface(self._surface_ptr, format._surface_ptr[].format, 0)


struct _Surface:
    var flags: UInt32
    var format: UnsafePointer[SurfacePixelFormat]
    var width: Int32
    var height: Int32
    var pitch: Int32
    var pixels: UnsafePointer[UInt32]
    var reserved: UnsafePointer[UInt8]
    var locked: Int32
    var list_blitmap: UnsafePointer[UInt8]
    var clip_rect: Rect
    var map: UnsafePointer[UInt8]
    var refcount: Int32


var _create_rgb_surface = _sdl.get_function[
    fn (UInt32, Int32, Int32, Int32, UInt32, UInt32, UInt32, UInt32) -> UnsafePointer[_Surface]
]("SDL_CreateRGBSurface")


fn create_rgb_surface(
    flags: UInt32,
    width: Int32,
    height: Int32,
    depth: Int32,
    rmask: UInt32,
    gmask: UInt32,
    bmask: UInt32,
    amask: UInt32,
) -> UnsafePointer[_Surface]:
    return _create_rgb_surface(flags, width, height, depth, rmask, gmask, bmask, amask)


var _free_surface = _sdl.get_function[fn (UnsafePointer[_Surface]) -> None]("SDL_FreeSurface")


fn free_surface(surface: UnsafePointer[_Surface]):
    _free_surface(surface)


var _convert_surface = _sdl.get_function[
    fn (
        UnsafePointer[_Surface], UnsafePointer[SurfacePixelFormat], UInt32
    ) -> UnsafePointer[_Surface]
]("SDL_ConvertSurface")


fn convert_surface(
    source: UnsafePointer[_Surface],
    format: UnsafePointer[SurfacePixelFormat],
    flags: UInt32,
) -> UnsafePointer[_Surface]:
    return _convert_surface(source, format, flags)


var _fill_rect = _sdl.get_function[
    fn (UnsafePointer[_Surface], UnsafePointer[Rect], UInt32) -> Int32
]("SDL_FillRect")


fn fill_rect(surface: UnsafePointer[_Surface], rect: UnsafePointer[Rect], color: UInt32) -> Int32:
    return _fill_rect(surface, rect, color)


var _blit_surface = _sdl.get_function[
    fn (
        UnsafePointer[_Surface],
        UnsafePointer[Rect],
        UnsafePointer[_Surface],
        UnsafePointer[Rect],
    ) -> Int32
]("SDL_UpperBlitSurface")


fn blit_surface(
    source_surface: UnsafePointer[_Surface],
    source_rect: UnsafePointer[Rect],
    destination_surface: UnsafePointer[_Surface],
    destination_rect: UnsafePointer[Rect],
) -> Int32:
    return _blit_surface(source_surface, source_rect, destination_surface, destination_rect)


var _blit_scaled = _sdl.get_function[
    fn (
        UnsafePointer[_Surface],
        UnsafePointer[Rect],
        UnsafePointer[_Surface],
        UnsafePointer[Rect],
    ) -> Int32
]("SDL_UpperBlitScaled")


fn blit_scaled(
    source_surface: UnsafePointer[_Surface],
    source_rect: UnsafePointer[Rect],
    destination_surface: UnsafePointer[_Surface],
    destination_rect: UnsafePointer[Rect],
) -> Int32:
    return _blit_scaled(source_surface, source_rect, destination_surface, destination_rect)
