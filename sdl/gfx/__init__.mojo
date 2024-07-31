"""Defines SDL_gfx bindings and wrappers for use in Mojo."""

from .graphics import *

var _sdl_gfx = sys.ffi.DLHandle("/lib/x86_64-linux-gnu/libSDL2_gfx-1.0.so.0")
