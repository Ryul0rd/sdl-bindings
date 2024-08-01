"""Defines an SDL Window."""

from .surface import _Surface
from .render import _Renderer


struct Window:
    var _window_ptr: UnsafePointer[_Window]
    var surface: Surface

    fn __init__(
        inout self,
        name: String,
        width: Int32,
        height: Int32,
        xpos: Optional[Int32] = None,
        ypos: Optional[Int32] = None,
        xcenter: Bool = False,
        ycenter: Bool = False,
        fullscreen: Bool = False,
        opengl: Bool = False,
        shown: Bool = False,
        hidden: Bool = False,
        borderless: Bool = False,
        resizable: Bool = False,
        minimized: Bool = False,
        maximized: Bool = False,
        input_grabbed: Bool = False,
        allow_highdpi: Bool = False,
    ) raises:
        if xpos and xcenter:
            raise Error("Expected only one of `xpos` or `xcenter` but got both")
        if ypos and ycenter:
            raise Error("Expected only one of `ypos` or `ycenter` but got both")
        var x = xpos.or_else(WINDOWPOS_CENTERED if xcenter else WINDOWPOS_UNDEFINED)
        var y = ypos.or_else(WINDOWPOS_CENTERED if ycenter else WINDOWPOS_UNDEFINED)
        var flags: UInt32 = 0
        flags |= WindowFlags.FULLSCREEN * fullscreen
        flags |= WindowFlags.OPENGL * opengl
        flags |= WindowFlags.SHOWN * shown
        flags |= WindowFlags.HIDDEN * hidden
        flags |= WindowFlags.BORDERLESS * borderless
        flags |= WindowFlags.RESIZABLE * resizable
        flags |= WindowFlags.MINIMIZED * minimized
        flags |= WindowFlags.MAXIMIZED * maximized
        flags |= WindowFlags.INPUT_GRABBED * input_grabbed
        flags |= WindowFlags.ALLOW_HIGHDPI * allow_highdpi
        self._window_ptr = create_window(name, x, y, width, height, flags)
        if not self._window_ptr:
            raise Error("Could not create SDL window")
        self.surface = Surface(get_window_surface(self._window_ptr))

    fn __init__(inout self, _window_ptr: UnsafePointer[_Window]):
        self._window_ptr = _window_ptr
        self.surface = UnsafePointer[_Surface]()

    fn __moveinit__(inout self, owned other: Self):
        self._window_ptr = other._window_ptr
        self.surface = other.surface^

    fn __del__(owned self):
        destroy_window(self._window_ptr)

    fn update_surface(self) raises:
        var error_code = update_window_surface(self._window_ptr)
        if error_code != 0:
            raise Error("Could not update surface")


struct _Window:
    pass


struct WindowFlags:
    alias FULLSCREEN = 0x00000001
    """fullscreen window"""

    alias OPENGL = 0x00000002
    """window usable with OpenGL context."""
    alias SHOWN = 0x00000004
    """window is visible."""
    alias HIDDEN = 0x00000008
    """window is not visible."""
    alias BORDERLESS = 0x00000010
    """no window decoration."""
    alias RESIZABLE = 0x00000020
    """window can be resized."""
    alias MINIMIZED = 0x00000040
    """window is minimized."""
    alias MAXIMIZED = 0x00000080
    """window is maximized."""
    alias MOUSE_GRABBED = 0x00000100
    """window has grabbed mouse input."""
    alias INPUT_FOCUS = 0x00000200
    """window has input focus."""
    alias MOUSE_FOCUS = 0x00000400
    """window has mouse focus."""
    alias FULLSCREEN_DESKTOP = (Self.FULLSCREEN | 0x00001000)
    alias FOREIGN = 0x00000800
    """window not created by SDL."""
    alias ALLOW_HIGHDPI = 0x00002000
    """window should be created in high-DPI mode if supported.
    On macOS NSHighResolutionCapable must be set true in the application's Info.plist for this to have any effect."""
    alias MOUSE_CAPTURE = 0x00004000
    """window has mouse captured (unrelated to MOUSE_GRABBED)."""
    alias ALWAYS_ON_TOP = 0x00008000
    """window should always be above others."""
    alias SKIP_TASKBAR = 0x00010000
    """window should not be added to the taskbar."""
    alias UTILITY = 0x00020000
    """window should be treated as a utility window."""
    alias TOOLTIP = 0x00040000
    """window should be treated as a tooltip."""
    alias POPUP_MENU = 0x00080000
    """window should be treated as a popup menu."""
    alias KEYBOARD_GRABBED = 0x00100000
    """window has grabbed keyboard input."""
    alias VULKAN = 0x10000000
    """window usable for Vulkan surface."""
    alias METAL = 0x20000000
    """window usable for Metal view."""

    alias INPUT_GRABBED = Self.MOUSE_GRABBED
    """equivalent to SDL_WINDOW_MOUSE_GRABBED for compatibility."""


var _create_window = _sdl.get_function[
    fn (UnsafePointer[UInt8], Int32, Int32, Int32, Int32, UInt32) -> UnsafePointer[_Window]
]("SDL_CreateWindow")


fn create_window(
    name: String,
    xpos: Int32,
    ypos: Int32,
    width: Int32,
    height: Int32,
    flags: UInt32,
) -> UnsafePointer[_Window]:
    return _create_window(name.unsafe_ptr(), xpos, ypos, width, height, flags)


var _destroy_window = _sdl.get_function[fn (UnsafePointer[_Window]) -> None]("SDL_DestroyWindow")


fn destroy_window(window: UnsafePointer[_Window]) -> None:
    _destroy_window(window)


alias windowpos_undefined_mask = 0x1FFF0000
alias windowpos_centered_mask = 0x2FFF0000
alias WINDOWPOS_UNDEFINED = windowpos_undefined_display(0)
alias WINDOWPOS_CENTERED = windowpos_centered_display(0)


@always_inline
fn windowpos_undefined_display(x: Int32) -> Int32:
    return windowpos_undefined_mask | (x & 0xFFFF)


@always_inline
fn windowpos_centered_display(x: Int32) -> Int32:
    return windowpos_centered_mask | (x & 0xFFFF)


var _get_window_surface = _sdl.get_function[fn (UnsafePointer[_Window]) -> UnsafePointer[_Surface]](
    "SDL_GetWindowSurface"
)


fn get_window_surface(
    window: UnsafePointer[_Window],
) -> UnsafePointer[_Surface]:
    return _get_window_surface(window)


var _update_window_surface = _sdl.get_function[fn (UnsafePointer[_Window]) -> Int32](
    "SDL_UpdateWindowSurface"
)


fn update_window_surface(window: UnsafePointer[_Window]) -> Int32:
    return _update_window_surface(window)


var _get_renderer = _sdl.get_function[fn (UnsafePointer[_Window]) -> UnsafePointer[_Renderer]](
    "SDL_GetRenderer"
)


fn get_renderer(window: UnsafePointer[_Window]) raises -> UnsafePointer[_Renderer]:
    """Get the renderer associated with a window."""
    var renderer = _get_renderer(window)
    if not renderer:
        raise get_error()
    return renderer
