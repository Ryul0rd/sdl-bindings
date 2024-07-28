alias C_Char = UInt8


# Application Events
alias QUIT = 0x100
# Window Events
alias WINDOWEVENT = 0x200
# Keyboard Events
alias KEYDOWN = 0x300
alias KEYUP = 0x301
alias TEXTEDITING = 0x302
alias TEXTINPUT = 0x303
alias KEYMAPCHANGED = 0x304
# Mouse Events
alias MOUSEMOTION = 0x400
alias MOUSEBUTTONDOWN = 0x401
alias MOUSEBUTTONUP = 0x402
# Audio Device Events
alias AUDIODEVICEADDED = 0x1100
alias AUDIODEVICEREMOVED = 0x1101

alias Event = Variant[
    QuitEvent, WindowEvent,
    KeyDownEvent, KeyUpEvent, TextEditingEvent, TextInputEvent, KeyMapChangedEvent,
    MouseMotionEvent, MouseButtonEvent,
    AudioDeviceEvent,
]

@value
struct C_Event:
    '''Total size is 56 bytes.'''
    var type: UInt32
    var data0: SIMD[DType.uint8, 4]
    var data1: SIMD[DType.uint8, 16]
    var data2: SIMD[DType.uint8, 32]

    fn __init__(inout self):
        self.type = 0
        self.data0 = 0
        self.data1 = 0
        self.data2 = 0

    fn to_nonc(owned self) -> Event:
        var ptr = UnsafePointer.address_of(self)
        if self.type == QUIT:
            return ptr.bitcast[QuitEvent]()[]
        elif self.type == WINDOWEVENT:
            return ptr.bitcast[WindowEvent]()[]
        elif self.type == KEYDOWN:
            return ptr.bitcast[KeyDownEvent]()[]
        elif self.type == KEYUP:
            return ptr.bitcast[KeyUpEvent]()[]
        elif self.type == TEXTEDITING:
            return ptr.bitcast[TextEditingEvent]()[]
        elif self.type == TEXTINPUT:
            return ptr.bitcast[TextInputEvent]()[]
        elif self.type == KEYMAPCHANGED:
            return ptr.bitcast[KeyMapChangedEvent]()[]
        elif self.type == MOUSEMOTION:
            return ptr.bitcast[MouseMotionEvent]()[]
        elif self.type == MOUSEBUTTONDOWN or self.type == MOUSEBUTTONUP:
            return ptr.bitcast[MouseButtonEvent]()[]
        elif self.type == AUDIODEVICEADDED or self.type == AUDIODEVICEREMOVED:
            return ptr.bitcast[AudioDeviceEvent]()[]
        else:
            print('Unhandled event type: ' + String(self.type))
            return ptr.bitcast[QuitEvent]()[]


@value
struct QuitEvent:
    var _type: UInt32
    var timestamp: UInt32

@value
struct WindowEvent:
    var _type: UInt32
    var timestamp: UInt32
    var window_id: UInt32
    var event: UInt8
    var _padding1: UInt8
    var _padding2: UInt8
    var _padding3: UInt8
    var data1: Int32
    var data2: Int32

@value
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
        constrained[name == 'key', 'Not a valid attr']()
        return self.keysym.sym

@value
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
        constrained[name == 'key', 'Not a valid attr']()
        return self.keysym.sym

@value
struct Keysym:
    var scancode: UInt32
    var sym: Int32
    var mode: UInt16
    var unused: UInt32

@value
struct TextEditingEvent:
    var type: UInt32
    var timestamp: UInt32
    var window_id: UInt32
    var text: UnsafePointer[C_Char]
    var start: Int32
    var length: Int32

@value
struct TextInputEvent:
    var _type: UInt32
    var timestamp: UInt32
    var window_id: UInt32
    var text: UnsafePointer[C_Char]

@value
struct KeyMapChangedEvent:
    var _type: UInt32
    var timestamp: UInt32

@value
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
struct AudioDeviceEvent:
    var type: UInt32
    var timestamp: UInt32
    var which: UInt32
    var iscapture: UInt8


fn event_list() -> List[Event]:
    var l = List[Event]()
    var event_ptr = UnsafePointer.address_of(C_Event())
    while poll_event(event_ptr) != 0:
        l.append(event_ptr[].to_nonc())
    return l


# alias C_EventAction = Variant[C_ADDEVENT, C_PEEKEVENT, C_GETEVENT]
# @value
# struct C_ADDEVENT: pass
# @value
# struct C_PEEKEVENT: pass
# @value
# struct C_GETEVENT: pass


var _poll_event = _sdl.get_function[fn(UnsafePointer[C_Event]) -> Int32]('SDL_PollEvent')
fn poll_event(event: UnsafePointer[C_Event]) -> Int32:
    return _poll_event(event)

# var _peep_events = sdl.get_function[fn(UnsafePointer[C_Event], Int32, UInt8, UInt32, UInt32) -> Int32]('SDL_PeepEvents')
# fn peep_events(events: UnsafePointer[C_Event], numevents: Int32, action: C_EventAction, min_type: Int32, max_type: Int32) -> Int32: