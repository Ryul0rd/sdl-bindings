"""Defines SDL_img bindings and wrappers for use in Mojo."""

from .image import *

var _sdl_img = sys.ffi.DLHandle("/lib/x86_64-linux-gnu/libSDL2_image-2.0.so.0")
