from sys import ffi


var path = '/lib/x86_64-linux-gnu/libSDL2-2.0.so'
var sdl = ffi.DLHandle(path)


var _init = sdl.get_function[fn(flags: UInt32) -> Int32]('SDL_Init')
fn init(
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
    #flags |= 0x00100000 * no_parachute
    if _init(flags) != 0:
        raise Error('Could not initialize SDL')


var _quit = sdl.get_function[fn() -> None]('SDL_Quit')
fn quit():
    _quit()

var _get_error = sdl.get_function[fn() -> UnsafePointer[UInt8]]('SDL_GetError')
fn get_error() -> String:
    var error_ptr = _get_error()
    return String(c_str_copy(error_ptr))

fn c_str_copy(source: UnsafePointer[UInt8]) -> UnsafePointer[UInt8]:
    var i = 0
    while source[i] != 0:
        i += 1
    var length = i + 1
    var new_ptr = UnsafePointer[UInt8].alloc(length)
    for i in range(length):
        new_ptr[i] = source
    return new_ptr
