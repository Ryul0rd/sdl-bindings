"""Defines SDL_ttf bindings and wrappers for use in Mojo."""

from .font import *

var _sdl_ttf = sys.ffi.DLHandle("/lib/x86_64-linux-gnu/libSDL2_ttf-2.0.so.0")
