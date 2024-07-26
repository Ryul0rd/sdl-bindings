"""sdl-bindings."""
from .display import *
from .events import *
from .font import *
from .graphics import *
from .image import *
from .misc import *
from .time import *


from sys import ffi as _ffi
var _sdl = _ffi.DLHandle('/lib/x86_64-linux-gnu/libSDL2-2.0.so')
var _sdl_gfx = _ffi.DLHandle('/lib/x86_64-linux-gnu/libSDL2_gfx-1.0.so.0')
var _sdl_img = _ffi.DLHandle('/lib/x86_64-linux-gnu/libSDL2_image-2.0.so.0')
var _sdl_ttf = _ffi.DLHandle('/lib/x86_64-linux-gnu/libSDL2_ttf-2.0.so.0')
