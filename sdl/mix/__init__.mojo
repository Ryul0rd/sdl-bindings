"""Defines SDL_mix bindings and wrappers for use in Mojo."""

from .sound import *

var _sdl_mix = sys.ffi.DLHandle("/lib/x86_64-linux-gnu/libSDL2_mixer-2.0.so.0")
