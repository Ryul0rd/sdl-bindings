"""## SDL Bindings

A package for SDL bindings and wrappers for use in Mojo.
"""

from .window import Window
from .surface import Surface
from .render import Renderer, RendererFlags
from .texture import Texture, TextureAccess, BlendMode, ScaleMode
from .primitives import Color, Point, FPoint, Rect, FRect, Vertex
from .pixel import Pixels, SurfacePixelFormat, TexturePixelFormat
from .events import *
from .keys import Keys, KeyCode, get_keyboard_state
from .mouse import get_mouse_state, get_cursor_position
from .time import Clock, delay
from .opengl import gl_create_context, gl_delete_context
from .ttf import *
from .gfx import *
from .img import *
from .mix import *


import sys

var _sdl = sys.ffi.DLHandle("/lib/x86_64-linux-gnu/libSDL2-2.0.so")


var _init = _sdl.get_function[fn (flags: UInt32) -> Int32]("SDL_Init")


fn sdl_init(
    timer: Bool = False,
    audio: Bool = False,
    video: Bool = False,
    joystick: Bool = False,
    haptic: Bool = False,
    gamecontroller: Bool = False,
    events: Bool = False,
    everything: Bool = False,
) raises:
    var flags: UInt32 = 0
    flags |= 0x00000001 * timer
    flags |= 0x00000010 * audio
    flags |= 0x00000020 * video
    flags |= 0x00000200 * joystick
    flags |= 0x00001000 * haptic
    flags |= 0x00002000 * gamecontroller
    flags |= 0x00004000 * events
    flags |= 0x0000FFFF * everything
    # this flag is ignored
    # flags |= 0x00100000 * no_parachute
    if _init(flags) != 0:
        raise Error("Could not initialize SDL")


var _quit = _sdl.get_function[fn () -> None]("SDL_Quit")


fn sdl_quit():
    _quit()


var _get_error = _sdl.get_function[fn () -> UnsafePointer[UInt8]]("SDL_GetError")


fn get_error() -> String:
    return StringRef(_get_error())
