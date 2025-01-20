"""Defines SDL_img bindings and wrappers for use in Mojo."""

from sys import DLHandle, os_is_macos, os_is_linux
from collections import Optional
from .._sdl import SDL_Fn
from ..surface import _Surface
from builtin.constrained import constrained


struct _IMG:
    """Raw bindings to sdl_img."""

    var _handle: DLHandle
    var error: SDL_Error

    var _img_init: SDL_Fn["IMG_Init", fn (Int32) -> Int32]
    var _img_quit: SDL_Fn["IMG_Quit", fn () -> NoneType]
    var _img_load: SDL_Fn["IMG_Load", fn (Ptr[CharC]) -> Ptr[_Surface]]

    fn __init__(inout self, error: SDL_Error):
        @parameter
        if os_is_macos():
            self._handle = DLHandle(".magic/envs/default/lib/libSDL2_image.dylib")
        elif os_is_linux():
            self._handle = DLHandle(".magic/envs/default/lib/libSDL2_image.so")
        else:
            constrained[False, "OS is not supported"]()
            self._handle = utils._uninit[DLHandle]()

        self.error = error
        self._img_init = self._handle
        self._img_quit = self._handle
        self._img_load = self._handle

    @always_inline
    fn init(self, flags: Int32) raises:
        _ = self._img_init.call(flags)
        # self.error.if_code(self._img_init.call(flags), "Could not initialize sdl_img")

    @always_inline
    fn quit(self):
        self._img_quit.call()

    @always_inline
    fn load_image(self, file: Ptr[CharC]) raises -> Ptr[_Surface]:
        return self.error.if_null(self._img_load.call(file), "Could not load image")
