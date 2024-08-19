"""Defines SDL_img bindings and wrappers for use in Mojo."""

from sys.ffi import DLHandle
from .._sdl import SDL_Fn, _SDL
from ..surface import _Surface


struct _IMG:
    var _handle: DLHandle
    var error: SDL_Error

    var _img_init: SDL_Fn["IMG_Init", fn (Int32) -> Int32]
    var _img_quit: SDL_Fn["IMG_Quit", fn () -> NoneType]
    var _img_load: SDL_Fn["IMG_Load", fn (Ptr[CharC]) -> Ptr[_Surface]]

    fn __init__(inout self, error: SDL_Error, jpeg: Bool = True, png: Bool = True, tif: Bool = False, webp: Bool = False) raises:
        self._handle = DLHandle("/lib/x86_64-linux-gnu/libSDL2_image-2.0.so.0")
        self.error = error
        self._img_init = self._handle
        self._img_quit = self._handle
        self._img_load = self._handle
        var flags: Int32 = 0
        flags |= 0x00000001 * jpeg
        flags |= 0x00000002 * png
        flags |= 0x00000004 * tif
        flags |= 0x00000008 * webp
        self.init(flags)

    fn __del__(owned self):
        self.quit()

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