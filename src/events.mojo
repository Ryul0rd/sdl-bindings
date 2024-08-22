"""Defines SDL Events."""

from utils import Variant
from ._sdl import _SDL


struct EventType:
    alias FIRSTEVENT = 0
    """Unused (do not remove)."""

    # Application events
    alias QUIT = 0x100
    """User-requested quit."""

    # These application events have special meaning on iOS, see README-ios.md for details
    alias APP_TERMINATING = 0x101
    """
    The application is being terminated by the OS
    Called on iOS in applicationWillTerminate()
    Called on Android in onDestroy().
    """

    alias APP_LOWMEMORY = 0x102
    """
    The application is low on memory, free memory if possible.
    Called on iOS in applicationDidReceiveMemoryWarning().
    Called on Android in onLowMemory().
    """

    alias APP_WILLENTERBACKGROUND = 0x103
    """
    The application is about to enter the background.
    Called on iOS in applicationWillResignActive().
    Called on Android in onPause().
    """

    alias APP_DIDENTERBACKGROUND = 0x104
    """
    The application did enter the background and may not get CPU for some time.
    Called on iOS in applicationDidEnterBackground().
    Called on Android in onPause().
    """

    alias APP_WILLENTERFOREGROUND = 0x105
    """
    The application is about to enter the foreground.
    Called on iOS in applicationWillEnterForeground().
    Called on Android in onResume().
    """

    alias APP_DIDENTERFOREGROUND = 0x106
    """
    The application is now interactive.
    Called on iOS in applicationDidBecomeActive().
    Called on Android in onResume().
    """

    alias LOCALECHANGED = 0x107
    """The user's locale preferences have changed."""

    # Display events
    alias DISPLAYEVENT = 0x150
    """Display state change."""

    # Window events
    alias WINDOWEVENT = 0x200
    """Window state change."""

    alias SYSWMEVENT = 0x201
    """System specific event."""

    # Keyboard events
    alias KEYDOWN = 0x300
    """Key pressed."""

    alias KEYUP = 0x301
    """Key released."""

    alias TEXTEDITING = 0x302
    """Keyboard text editing (composition)."""

    alias TEXTINPUT = 0x303
    """Keyboard text input."""

    alias KEYMAPCHANGED = 0x304
    """Keymap changed due to a system event such as an input language or keyboard layout change."""

    alias TEXTEDITING_EXT = 0x305
    """Extended keyboard text editing (composition)."""

    # Mouse events
    alias MOUSEMOTION = 0x400
    """Mouse moved."""

    alias MOUSEBUTTONDOWN = 0x401
    """Mouse button pressed."""

    alias MOUSEBUTTONUP = 0x402
    """Mouse button released."""

    alias MOUSEWHEEL = 0x403
    """Mouse wheel motion."""

    # Joystick events
    alias JOYAXISMOTION = 0x600
    """Joystick axis motion."""

    alias JOYBALLMOTION = 0x601
    """Joystick trackball motion."""

    alias JOYHATMOTION = 0x602
    """Joystick hat position change."""

    alias JOYBUTTONDOWN = 0x603
    """Joystick button pressed."""

    alias JOYBUTTONUP = 0x604
    """Joystick button released."""

    alias JOYDEVICEADDED = 0x605
    """A new joystick has been inserted into the system."""

    alias JOYDEVICEREMOVED = 0x606
    """An opened joystick has been removed."""

    alias JOYBATTERYUPDATED = 0x607
    """Joystick battery level change."""

    # Game controller events
    alias CONTROLLERAXISMOTION = 0x650
    """Game controller axis motion."""

    alias CONTROLLERBUTTONDOWN = 0x651
    """Game controller button pressed."""

    alias CONTROLLERBUTTONUP = 0x652
    """Game controller button released."""

    alias CONTROLLERDEVICEADDED = 0x653
    """A new Game controller has been inserted into the system."""

    alias CONTROLLERDEVICEREMOVED = 0x654
    """An opened Game controller has been removed."""

    alias CONTROLLERDEVICEREMAPPED = 0x655
    """The controller mapping was updated."""

    alias CONTROLLERTOUCHPADDOWN = 0x656
    """Game controller touchpad was touched."""

    alias CONTROLLERTOUCHPADMOTION = 0x657
    """Game controller touchpad finger was moved."""

    alias CONTROLLERTOUCHPADUP = 0x658
    """Game controller touchpad finger was lifted."""

    alias CONTROLLERSENSORUPDATE = 0x659
    """Game controller sensor was updated."""

    alias CONTROLLERUPDATECOMPLETE_RESERVED_FOR_SDL3 = 0x65A

    alias CONTROLLERSTEAMHANDLEUPDATED = 0x65B
    """Game controller Steam handle has changed."""

    # Touch events
    alias FINGERDOWN = 0x700
    alias FINGERUP = 0x701
    alias FINGERMOTION = 0x702

    # Gesture events
    alias DOLLARGESTURE = 0x800
    alias DOLLARRECORD = 0x801
    alias MULTIGESTURE = 0x802

    # Clipboard events
    alias CLIPBOARDUPDATE = 0x900
    """The clipboard or primary selection changed."""

    # Drag and drop events
    alias DROPFILE = 0x1000
    """The system requests a file open."""

    alias DROPTEXT = 0x1001
    """text/plain drag-and-drop event."""

    alias DROPBEGIN = 0x1002
    """A new set of drops is beginning (NULL filename)."""

    alias DROPCOMPLETE = 0x1003
    """Current set of drops is now complete (NULL filename)."""

    # Audio hotplug events
    alias AUDIODEVICEADDED = 0x1100
    """A new audio device is available."""

    alias AUDIODEVICEREMOVED = 0x1101
    """An audio device has been removed."""

    # Sensor events
    alias SENSORUPDATE = 0x1200
    """A sensor was updated."""

    # Render events
    alias RENDER_TARGETS_RESET = 0x2000
    """The render targets have been reset and their contents need to be updated."""

    alias RENDER_DEVICE_RESET = 0x2001
    """The device has been reset and all textures need to be recreated."""

    # Internal events
    alias POLLSENTINEL = 0x7F00
    """Signals the end of an event poll cycle."""

    # Events SDL_USEREVENT through SDL_LASTEVENT are for your use,
    # and should be allocated with SDL_RegisterEvents()
    alias USEREVENT = 0x8000

    # This last event is only for bounding internal arrays
    alias LASTEVENT = 0xFFFF


alias Event = Variant[
    QuitEvent,
    WindowEvent,
    KeyDownEvent,
    KeyUpEvent,
    TextEditingEvent,
    TextInputEvent,
    KeyMapChangedEvent,
    MouseMotionEvent,
    MouseButtonEvent,
    MouseWheelEvent,
    AudioDeviceEvent,
]


# alias C_EventAction = Variant[C_ADDEVENT, C_PEEKEVENT, C_GETEVENT]
# @value
# struct C_ADDEVENT: pass
# @value
# struct C_PEEKEVENT: pass
# @value
# struct C_GETEVENT: pass


@value
@register_passable("trivial")
struct _Event:
    """Total size is 56 bytes."""

    var type: UInt32
    var data0: SIMD[DType.uint8, 4]
    var data1: SIMD[DType.uint8, 16]
    var data2: SIMD[DType.uint8, 32]

    fn __init__(inout self):
        self.type = 0
        self.data0 = 0
        self.data1 = 0
        self.data2 = 0

    @staticmethod
    fn to_event(_event: Ptr[_Event]) -> Event:
        if _event[].type == EventType.QUIT:
            return _event.bitcast[QuitEvent]()[]
        elif _event[].type == EventType.WINDOWEVENT:
            return _event.bitcast[WindowEvent]()[]
        elif _event[].type == EventType.KEYDOWN:
            return _event.bitcast[KeyDownEvent]()[]
        elif _event[].type == EventType.KEYUP:
            return _event.bitcast[KeyUpEvent]()[]
        elif _event[].type == EventType.TEXTEDITING:
            return _event.bitcast[TextEditingEvent]()[]
        elif _event[].type == EventType.TEXTINPUT:
            return _event.bitcast[TextInputEvent]()[]
        elif _event[].type == EventType.KEYMAPCHANGED:
            return _event.bitcast[KeyMapChangedEvent]()[]
        elif _event[].type == EventType.MOUSEMOTION:
            return _event.bitcast[MouseMotionEvent]()[]
        elif _event[].type == EventType.MOUSEBUTTONDOWN or _event[].type == EventType.MOUSEBUTTONUP:
            return _event.bitcast[MouseButtonEvent]()[]
        elif _event[].type == EventType.MOUSEWHEEL:
            return _event.bitcast[MouseWheelEvent]()[]
        elif _event[].type == EventType.AUDIODEVICEADDED or _event[].type == EventType.AUDIODEVICEREMOVED:
            return _event.bitcast[AudioDeviceEvent]()[]
        else:
            print("Unhandled event type: " + str(_event[].type))
            return _event.bitcast[QuitEvent]()[]


@value
@register_passable("trivial")
struct QuitEvent:
    var _type: UInt32
    var timestamp: UInt32


@value
@register_passable("trivial")
struct WindowEvent:
    """Window state change event data (event.window.*)."""

    var _type: UInt32
    """SDL_WINDOWEVENT."""
    var timestamp: UInt32
    """In milliseconds, populated using SDL_GetTicks()."""
    var window_id: UInt32
    """The associated window."""
    var event: UInt8
    """SDL_WindowEventID."""
    var _padding1: UInt8
    var _padding2: UInt8
    var _padding3: UInt8
    var data1: Int32
    """Event dependent data."""
    var data2: Int32
    """Event dependent data."""


struct WindowEventID:
    """Event subtype for window events."""

    alias WINDOWEVENT_NONE: IntC = 0
    """Never used."""
    alias WINDOWEVENT_SHOWN: IntC = 1
    """Window has been shown."""
    alias WINDOWEVENT_HIDDEN: IntC = 2
    """Window has been hidden."""
    alias WINDOWEVENT_EXPOSED: IntC = 3
    """Window has been exposed and should be redrawn."""
    alias WINDOWEVENT_MOVED: IntC = 4
    """Window has been moved to data1, data2."""
    alias WINDOWEVENT_RESIZED: IntC = 5
    """Window has been resized to data1xdata2."""
    alias WINDOWEVENT_SIZE_CHANGED: IntC = 6
    """The window size has changed, either as a result of an API call or through the system or user changing the window size."""
    alias WINDOWEVENT_MINIMIZED: IntC = 7
    """Window has been minimized."""
    alias WINDOWEVENT_MAXIMIZED: IntC = 8
    """Window has been maximized."""
    alias WINDOWEVENT_RESTORED: IntC = 9
    """Window has been restored to normal size and position."""
    alias WINDOWEVENT_ENTER: IntC = 10
    """Window has gained mouse focus."""
    alias WINDOWEVENT_LEAVE: IntC = 11
    """Window has lost mouse focus."""
    alias WINDOWEVENT_FOCUS_GAINED: IntC = 12
    """Window has gained keyboard focus."""
    alias WINDOWEVENT_FOCUS_LOST: IntC = 13
    """Window has lost keyboard focus."""
    alias WINDOWEVENT_CLOSE: IntC = 14
    """The window manager requests that the window be closed."""
    alias WINDOWEVENT_TAKE_FOCUS: IntC = 15
    """Window is being offered a focus (should SetWindowInputFocus() on itself or a subwindow, or ignore)."""
    alias WINDOWEVENT_HIT_TEST: IntC = 16
    """Window had a hit test that wasn't SDL_HITTEST_NORMAL."""
    alias WINDOWEVENT_ICCPROF_CHANGED: IntC = 17
    """The ICC profile of the window's display has changed."""
    alias WINDOWEVENT_DISPLAY_CHANGED: IntC = 18
    """Window has been moved to display data1."""


@value
@register_passable("trivial")
struct KeyDownEvent:
    var _type: UInt32
    var timestamp: UInt32
    var window_id: UInt32
    var state: UInt8
    var repeat: UInt8
    var _padding2: UInt8
    var _padding3: UInt8
    var keysym: Keysym

    fn __getattr__[name: StringLiteral](self) -> Int32:
        constrained[name == "key", "Not a valid attr"]()
        return self.keysym.sym


@value
@register_passable("trivial")
struct KeyUpEvent:
    var _type: UInt32
    var timestamp: UInt32
    var window_id: UInt32
    var state: UInt8
    var repeat: UInt8
    var _padding2: UInt8
    var _padding3: UInt8
    var keysym: Keysym

    fn __getattr__[name: StringLiteral](self) -> Int32:
        constrained[name == "key", "Not a valid attr"]()
        return self.keysym.sym


@value
@register_passable("trivial")
struct Keysym:
    var scancode: UInt32
    var sym: Int32
    var mode: UInt16
    var unused: UInt32


@value
@register_passable("trivial")
struct TextEditingEvent:
    var type: UInt32
    var timestamp: UInt32
    var window_id: UInt32
    var text: Ptr[CharC]
    var start: Int32
    var length: Int32


@value
@register_passable("trivial")
struct TextInputEvent:
    var _type: UInt32
    var timestamp: UInt32
    var window_id: UInt32
    var text: Ptr[CharC]


@value
@register_passable("trivial")
struct KeyMapChangedEvent:
    var _type: UInt32
    var timestamp: UInt32


@value
@register_passable("trivial")
struct MouseMotionEvent:
    var type: UInt32
    var timestamp: UInt32
    var window_id: UInt32
    var which: UInt32
    var state: UInt32
    var x: UInt8
    var y: UInt8
    var xrel: Int32
    var yrel: Int32


@value
@register_passable("trivial")
struct MouseButtonEvent:
    var type: UInt32
    var timestamp: UInt32
    var window_id: UInt32
    var which: UInt32
    var button: UInt8
    var state: UInt8
    var clicks: UInt8
    var _padding1: UInt8
    var x: Int32
    var y: Int32


@value
@register_passable("trivial")
struct MouseWheelEvent:
    """Mouse wheel event structure (event.wheel.*)."""
    var type: UInt32
    """SDL_MOUSEWHEEL."""
    var timestamp: UInt32
    """In milliseconds, populated using SDL_GetTicks()."""
    var windowID: UInt32
    """The window with mouse focus, if any."""
    var which: UInt32
    """The mouse instance id, or SDL_TOUCH_MOUSEID."""
    var x: Int32
    """The amount scrolled horizontally, positive to the right and negative to the left."""
    var y: Int32
    """The amount scrolled vertically, positive away from the user and negative toward the user."""
    var direction: UInt32
    """Set to one of the SDL_MOUSEWHEEL_* defines. When FLIPPED the values in X and Y will be opposite. Multiply by -1 to change them back."""
    var preciseX: Float32
    """The amount scrolled horizontally, positive to the right and negative to the left, with float precision (added in 2.0.18)."""
    var preciseY: Float32
    """The amount scrolled vertically, positive away from the user and negative toward the user, with float precision (added in 2.0.18)."""
    var mouseX: Int32
    """X coordinate, relative to window (added in 2.26.0)."""
    var mouseY: Int32
    """Y coordinate, relative to window (added in 2.26.0)."""


@value
@register_passable("trivial")
struct AudioDeviceEvent:
    var type: UInt32
    var timestamp: UInt32
    var which: UInt32
    var iscapture: UInt8





# # var _peep_events = _sdl.get_function[fn(Ptr[C_Event], Int32, UInt8, UInt32, UInt32) -> Int32]('SDL_PeepEvents')
# # fn peep_events(events: Ptr[C_Event], numevents: Int32, action: C_EventAction, min_type: Int32, max_type: Int32) -> Int32:
