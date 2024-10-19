"""## SDL Bindings

A package for SDL bindings and wrappers for use in Mojo.
"""

from ._sdl import SDL
from .error import SDL_Error
from .window import Window, WindowFlags, DisplayMode, FlashOperation
from .surface import Surface
from .render import Renderer, RendererFlags, RendererInfo, RendererFlip
from .texture import Texture, TextureAccess, BlendMode, ScaleMode
from .primitives import Color, DPoint, Point, FPoint, DRect, Rect, FRect, Vertex
from .pixel import Pixels, Palette, SurfacePixelFormat, TexturePixelFormat
from .events import Event, QuitEvent, WindowEvent, KeyDownEvent, KeyUpEvent
from .keyboard import Keyboard, Keys, KeyCode
from .mouse import Mouse
from .time import Clock

# from .opengl import gl_create_context, gl_delete_context


# TODO: Pointer indirection and overall layout can be fixed once we have either
#       top level vars which work from a .mojopkg, or builtin c interop.


alias error_level = 2
"""Define the amount of error handling you want.

`0`: No error handling  
`1`: Fast error handling  
`2`: Verbose error handling  
"""


alias Ptr = UnsafePointer
alias UIntC = UInt32
alias IntC = Int32
alias CharC = UInt8
alias BoolC = Bool
