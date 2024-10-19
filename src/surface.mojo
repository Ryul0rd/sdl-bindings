"""Defines an SDL Surface."""

from collections import Optional
from .utils import adr, opt2ptr
from ._sdl import _SDL


struct Surface[lif: AnyLifetime[False].type]:
    """A higher level wrapper around an SDL_Surface."""

    var sdl: Reference[SDL, lif]
    var _surface_ptr: Ptr[_Surface]

    fn __init__(inout self, ref [lif]sdl: SDL, width: Int32, height: Int32) raises:
        self.sdl = sdl
        self._surface_ptr = sdl._sdl.create_rgb_surface(0, width, height, 32, 0, 0, 0, 0)

    fn __init__(inout self, ref [lif]sdl: SDL, width: Int32, height: Int32, color: Color) raises:
        self = Self(sdl, width, height)
        self.fill(color)

    fn __init__(
        inout self,
        ref [lif]sdl: SDL,
        _surface_ptr: Ptr[_Surface] = Ptr[_Surface](),
    ):
        self.sdl = sdl
        self._surface_ptr = _surface_ptr

    fn __moveinit__(inout self, owned other: Self):
        self.sdl = other.sdl
        self._surface_ptr = other._surface_ptr

    fn __del__(owned self):
        self.sdl[]._sdl.free_surface(self._surface_ptr)

    fn lock(self) raises:
        self.sdl[]._sdl.lock_surface(self._surface_ptr)

    fn unlock(self):
        self.sdl[]._sdl.unlock_surface(self._surface_ptr)

    fn fill(self, color: Color, rect: Rect) raises:
        self.sdl[]._sdl.fill_rect(self._surface_ptr, adr(rect), color.as_uint32())

    fn fill(self, color: Color) raises:
        self.sdl[]._sdl.fill_rect(self._surface_ptr, Ptr[Rect](), color.as_uint32())

    fn blit(
        self,
        source: Surface,
        source_rect: Optional[Rect],
        destination_rect: Optional[Rect],
    ) raises:
        self.sdl[]._sdl.upper_blit_scaled(
            source._surface_ptr,
            opt2ptr(source_rect),
            self._surface_ptr,
            opt2ptr(destination_rect),
        )

    fn rotozoomed(self, angle: Float64, zoom: Float64, smooth: Bool = False) -> Surface[lif]:
        return Surface(
            self.sdl[],
            self.sdl[].gfx.rotozoom_surface(self._surface_ptr, angle, zoom, smooth),
        )

    fn convert(inout self, format: Surface):
        self._surface_ptr = self.sdl[]._sdl._convert_surface.call(self._surface_ptr, format._surface_ptr[].format, 0)


struct _Surface:
    var flags: UInt32
    var format: Ptr[SurfacePixelFormat]
    var width: Int32
    var height: Int32
    var pitch: Int32
    var pixels: Ptr[UInt32]
    var reserved: Ptr[UInt8]
    var locked: Int32
    var list_blitmap: Ptr[UInt8]
    var clip_rect: Rect
    var map: Ptr[UInt8]
    var refcount: Int32
