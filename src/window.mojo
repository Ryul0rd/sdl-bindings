"""Defines an SDL Window."""

from collections import Optional
from ._sdl import _SDL

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


struct Window[lif: AnyLifetime[False].type]:
    """A higher level wrapper around an SDL_Window."""

    var sdl: Reference[SDL, lif]
    var _window_ptr: Ptr[_Window]

    fn __init__(
        inout self,
        ref [lif]sdl: SDL,
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
        # set sdl
        self.sdl = sdl

        # calculate window position
        if xpos and xcenter:
            raise Error("Expected only one of `xpos` or `xcenter` but got both")
        if ypos and ycenter:
            raise Error("Expected only one of `ypos` or `ycenter` but got both")
        var x = xpos.or_else(WINDOWPOS_CENTERED if xcenter else WINDOWPOS_UNDEFINED)
        var y = ypos.or_else(WINDOWPOS_CENTERED if ycenter else WINDOWPOS_UNDEFINED)

        # set window flags
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

        self._window_ptr = self.sdl[]._sdl.create_window(
            name.unsafe_cstr_ptr().bitcast[DType.uint8](),
            x,
            y,
            width,
            height,
            flags,
        )

    fn __init__(
        inout self,
        ref [lif]sdl: SDL,
        _window_ptr: Ptr[_Window] = Ptr[_Window](),
    ):
        self.sdl = sdl
        self._window_ptr = _window_ptr

    fn __moveinit__(inout self, owned other: Self):
        self.sdl = other.sdl
        self._window_ptr = other._window_ptr

    fn __del__(owned self):
        self.sdl[]._sdl.destroy_window(self._window_ptr)

    fn set_fullscreen(inout self, flags: UInt32) raises:
        self.sdl[]._sdl.set_window_fullscreen(self._window_ptr, flags)

    fn get_surface(inout self) raises -> Surface[lif]:
        var surface = Surface(self.sdl[], self.sdl[]._sdl.get_window_surface(self._window_ptr))
        surface._surface_ptr[].refcount += 1
        return surface^

    fn update_surface(self) raises:
        self.sdl[]._sdl.update_window_surface(self._window_ptr)

    fn destroy_surface(inout self) raises:
        self.sdl[]._sdl.destroy_window_surface(self._window_ptr)


@register_passable("trivial")
struct _Window:
    """The opaque type used to identify a window."""

    pass


struct WindowFlags:
    """Window Flags."""

    alias FULLSCREEN = 0x00000001
    """Fullscreen window."""

    alias OPENGL = 0x00000002
    """Window usable with OpenGL context."""
    alias SHOWN = 0x00000004
    """Window is visible."""
    alias HIDDEN = 0x00000008
    """Window is not visible."""
    alias BORDERLESS = 0x00000010
    """No window decoration."""
    alias RESIZABLE = 0x00000020
    """Window can be resized."""
    alias MINIMIZED = 0x00000040
    """Window is minimized."""
    alias MAXIMIZED = 0x00000080
    """Window is maximized."""
    alias MOUSE_GRABBED = 0x00000100
    """Window has grabbed mouse input."""
    alias INPUT_FOCUS = 0x00000200
    """Window has input focus."""
    alias MOUSE_FOCUS = 0x00000400
    """Window has mouse focus."""
    alias FULLSCREEN_DESKTOP = (Self.FULLSCREEN | 0x00001000)
    """Fullscreen desktop window."""
    alias FOREIGN = 0x00000800
    """Window not created by SDL."""
    alias ALLOW_HIGHDPI = 0x00002000
    """Window should be created in high-DPI mode if supported.
    On macOS NSHighResolutionCapable must be set true in the application's Info.plist for this to have any effect."""
    alias MOUSE_CAPTURE = 0x00004000
    """Window has mouse captured (unrelated to MOUSE_GRABBED)."""
    alias ALWAYS_ON_TOP = 0x00008000
    """Window should always be above others."""
    alias SKIP_TASKBAR = 0x00010000
    """Window should not be added to the taskbar."""
    alias UTILITY = 0x00020000
    """Window should be treated as a utility window."""
    alias TOOLTIP = 0x00040000
    """Window should be treated as a tooltip."""
    alias POPUP_MENU = 0x00080000
    """Window should be treated as a popup menu."""
    alias KEYBOARD_GRABBED = 0x00100000
    """Window has grabbed keyboard input."""
    alias VULKAN = 0x10000000
    """Window usable for Vulkan surface."""
    alias METAL = 0x20000000
    """Window usable for Metal view."""

    alias INPUT_GRABBED = Self.MOUSE_GRABBED
    """Equivalent to SDL_WINDOW_MOUSE_GRABBED for compatibility."""


struct DisplayMode:
    """The structure that defines a display mode."""

    var format: UInt32
    """Pixel format."""
    var w: IntC
    """Width, in screen coordinates."""
    var h: IntC
    """Height, in screen coordinates."""
    var refresh_rate: IntC
    """Refresh rate (or zero for unspecified)."""
    var driverdata: Ptr[NoneType]
    """Driver-specific data, initialize to 0."""


struct FlashOperation:
    """Window flash operation."""

    alias FLASH_CANCEL: IntC = 0
    """Cancel any window flash state."""
    alias FLASH_BRIEFLY: IntC = 1
    """Flash the window briefly to get attention."""
    alias SDL_FLASH_UNTIL_FOCUSED: IntC = 2
    """Flash the window until it gets focus."""


@register_passable("trivial")
struct _GLContext:
    pass
