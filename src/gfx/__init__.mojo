"""Defines SDL_gfx bindings and wrappers for use in Mojo."""

from sys import DLHandle, os_is_macos, os_is_linux
from collections import Optional
from .._sdl import SDL_Fn
from ..surface import _Surface
from ..render import _Renderer
from builtin.constrained import constrained


struct _GFX:
    """Raw bindings to sdl_gfx."""

    var _handle: DLHandle
    var error: SDL_Error

    var _rotozoom_surface: SDL_Fn[
        "rotozoomSurface",
        fn (UnsafePointer[_Surface], Float64, Float64, Int32) -> UnsafePointer[_Surface],
    ]
    var _circle_color: SDL_Fn[
        "circleColor",
        fn (UnsafePointer[_Renderer], Int16, Int16, Int16, UInt32) -> IntC,
    ]
    var _circle_rgba: SDL_Fn[
        "circleRGBA",
        fn (
            UnsafePointer[_Renderer],
            Int16,
            Int16,
            Int16,
            UInt8,
            UInt8,
            UInt8,
            UInt8,
        ) -> IntC,
    ]

    fn __init__(inout self, error: SDL_Error):
        @parameter
        if os_is_macos():
            self._handle = DLHandle(".magic/envs/default/lib/libSDL2_gfx.dylib")
        elif os_is_linux():
            self._handle = DLHandle(".magic/envs/default/lib/libSDL2_gfx.so")
        else:
            constrained[False, "OS is not supported"]()
            self._handle = utils._uninit[DLHandle]()

        self.error = error
        self._rotozoom_surface = self._handle
        self._circle_color = self._handle
        self._circle_rgba = self._handle

    fn quit(self):
        pass

    @always_inline
    fn rotozoom_surface(self, source: Ptr[_Surface], angle: Float64, zoom: Float64, smooth: Bool) -> Ptr[_Surface]:
        return self._rotozoom_surface.call(source, angle, zoom, Int32(smooth))

    @always_inline
    fn circle_color(
        self,
        renderer: Ptr[_Renderer],
        x: Int16,
        y: Int16,
        rad: Int16,
        color: UInt32,
    ) raises:
        self.error.if_code(
            self._circle_color.call(renderer, x, y, rad, color),
            "Could not draw circle",
        )

    @always_inline
    fn circle_rgba(self, renderer: Ptr[_Renderer], x: Int16, y: Int16, rad: Int16, r: UInt8, g: UInt8, b: UInt8, a: UInt8) raises:
        self.error.if_code(self._circle_rgba.call(renderer, x, y, rad, r, g, b, a), "Could not draw circle")
