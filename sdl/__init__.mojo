"""sdl-bindings."""
from .display import Window, Surface, Color, Rect
from .events import
    event_list,
    QuitEvent,
    WindowEvent,
    KeyDownEvent,
    KeyUpEvent,
    TextEditingEvent,
    TextInputEvent,
    KeyMapChangedEvent,
    MouseMotionEvent,
    MouseButtonEvent
from .font import ttf_init, ttf_quit, Font
from .graphics import rotozoom_surface
from .image import img_init, img_quit, load_image
from .misc import sdl_init, sdl_quit
from .time import Clock
import .keys


from sys import ffi as _ffi
var _sdl = _ffi.DLHandle('/lib/x86_64-linux-gnu/libSDL2-2.0.so')
var _sdl_gfx = _ffi.DLHandle('/lib/x86_64-linux-gnu/libSDL2_gfx-1.0.so.0')
var _sdl_img = _ffi.DLHandle('/lib/x86_64-linux-gnu/libSDL2_image-2.0.so.0')
var _sdl_ttf = _ffi.DLHandle('/lib/x86_64-linux-gnu/libSDL2_ttf-2.0.so.0')
