from sys import ffi
from bit import rotate_bits_left


var path = '/lib/x86_64-linux-gnu/libSDL2-2.0.so'
var sdl = ffi.DLHandle(path)


# window pos
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


struct Window:
    var surface: Surface
    var _c_window_ptr: UnsafePointer[C_Window]

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
            raise Error('Expected only one of `xpos` or `xcenter` but got both')
        if ypos and ycenter:
            raise Error('Expected only one of `ypos` or `ycenter` but got both')
        var x = xpos.value()[] if xpos else WINDOWPOS_CENTERED if xcenter else WINDOWPOS_UNDEFINED
        var y = ypos.value()[] if ypos else WINDOWPOS_CENTERED if ycenter else WINDOWPOS_UNDEFINED
        var flags: UInt32 = 0
        flags |= 0x00000001 * fullscreen
        flags |= 0x00000002 * opengl
        flags |= 0x00000004 * shown
        flags |= 0x00000008 * hidden
        flags |= 0x00000010 * borderless
        flags |= 0x00000020 * resizable
        flags |= 0x00000040 * minimized
        flags |= 0x00000080 * maximized
        flags |= 0x00000100 * input_grabbed
        flags |= 0x00002000 * allow_highdpi
        self._c_window_ptr = create_window(name, x, y, width, height, flags)
        if not self._c_window_ptr:
            raise Error('Could not create SDL window')
        self.surface = Surface(get_window_surface(self._c_window_ptr))

    fn __del__(owned self):
        destroy_window(self._c_window_ptr)

    fn update_surface(self) raises:
        var error_code = update_window_surface(self._c_window_ptr)
        if error_code != 0:
            raise Error('Could not update surface')


struct Surface:
    var _c_surface_ptr: UnsafePointer[C_Surface]

    fn __init__(inout self, width: Int32, height: Int32, color: Optional[Color]=None):
        self._c_surface_ptr = create_rgb_surface(0, width, height, 32, 0, 0, 0, 0)
        if color:
            try:
                self.fill(color.value()[])
            except:
                pass

    fn __init__(inout self, c_surface_ptr: UnsafePointer[C_Surface]):
        self._c_surface_ptr = c_surface_ptr

    fn __del__(owned self):
        free_surface(self._c_surface_ptr)

    fn fill(self, color: Color, rect: Optional[Rect]=None) raises:
        var r = UnsafePointer(rect.value()[]) if rect else UnsafePointer[Rect]()
        var error_code = fill_rect(self._c_surface_ptr, r, color.as_uint32())
        if error_code != 0:
            raise Error('Could not fill rect')

    fn blit(self, source: Surface, source_rect: Optional[Rect], destination_rect: Optional[Rect]) raises:
        var source_rect_ptr = UnsafePointer(source_rect.value()[]) if source_rect else UnsafePointer[Rect]()
        var destination_rect_ptr = UnsafePointer(destination_rect.value()[]) if destination_rect else UnsafePointer[Rect]()
        var error_code = blit_scaled(source._c_surface_ptr, source_rect_ptr, self._c_surface_ptr, destination_rect_ptr)
        if error_code != 0:
            raise Error('Could not blit surface')


struct C_Window:
    pass

struct C_Surface:
    var flags: UInt32 # SurfaceFlags
    var format: UnsafePointer[PixelFormat]
    var width: Int32
    var height: Int32
    var pitch: Int32
    var pixels: UnsafePointer[UInt32]
    var reserved: UnsafePointer[UInt8] 
    var locked: Int32
    var list_blitmap: UnsafePointer[UInt8]
    var clip_rect: Rect
    var map: UnsafePointer[UInt8]
    var refcount: Int32

struct PixelFormat:
    pass

@value
struct Rect:
    var x: Int32
    var y: Int32
    var w: Int32
    var h: Int32

@value
struct Color:
    var b: UInt8
    var g: UInt8
    var r: UInt8
    var a: UInt8

    fn __init__(inout self, r: UInt8, g: UInt8, b: UInt8, a: UInt8=0):
        self.r = r
        self.g = g
        self.b = b
        self.a = a

    fn as_uint32(owned self) -> UInt32:
        return UnsafePointer(self).bitcast[UInt32]()[]

var _create_window = sdl.get_function[fn(UnsafePointer[UInt8], Int32, Int32, Int32, Int32, UInt32) -> UnsafePointer[C_Window]]('SDL_CreateWindow')
fn create_window(name: String, xpos: Int32, ypos: Int32, width: Int32, height: Int32, flags: UInt32) -> UnsafePointer[C_Window]:
    return _create_window(name.unsafe_uint8_ptr(), xpos, ypos, width, height, flags)

var _destroy_window = sdl.get_function[fn(UnsafePointer[C_Window]) -> None]('SDL_DestroyWindow')
fn destroy_window(window: UnsafePointer[C_Window]) -> None:
    _destroy_window(window)

var _get_window_surface = sdl.get_function[fn(UnsafePointer[C_Window]) -> UnsafePointer[C_Surface]]('SDL_GetWindowSurface')
fn get_window_surface(window: UnsafePointer[C_Window]) -> UnsafePointer[C_Surface]:
    return _get_window_surface(window)

var _update_window_surface = sdl.get_function[fn(UnsafePointer[C_Window]) -> Int32]('SDL_UpdateWindowSurface')
fn update_window_surface(window: UnsafePointer[C_Window]) -> Int32:
    return _update_window_surface(window)

var _create_rgb_surface = sdl.get_function[
    fn(UInt32, Int32, Int32, Int32, UInt32, UInt32, UInt32, UInt32) -> UnsafePointer[C_Surface]
]('SDL_CreateRGBSurface')
fn create_rgb_surface(
    flags: UInt32,
    width: Int32,
    height: Int32,
    depth: Int32,
    rmask: UInt32,
    gmask: UInt32,
    bmask: UInt32,
    amask: UInt32
) -> UnsafePointer[C_Surface]:
    return _create_rgb_surface(flags, width, height, depth, rmask, gmask, bmask, amask)

var _free_surface = sdl.get_function[fn(UnsafePointer[C_Surface]) -> None]('SDL_FreeSurface')
fn free_surface(surface: UnsafePointer[C_Surface]):
    _free_surface(surface)

var _fill_rect = sdl.get_function[fn(UnsafePointer[C_Surface], UnsafePointer[Rect], UInt32) -> Int32]('SDL_FillRect')
fn fill_rect(surface: UnsafePointer[C_Surface], rect: UnsafePointer[Rect], color: UInt32) -> Int32:
    return _fill_rect(surface, rect, color)

# var _blit_surface = sdl.get_function[
#     fn(UnsafePointer[C_Surface], UnsafePointer[Rect], UnsafePointer[C_Surface], UnsafePointer[Rect]) -> Int32
# ]('SDL_UpperBlitSurface')
# fn blit_surface(
#     source_surface: UnsafePointer[C_Surface],
#     source_rect: UnsafePointer[Rect],
#     destination_surface: UnsafePointer[C_Surface],
#     destination_rect: UnsafePointer[Rect],
# ) -> Int32:
#     return _blit_surface(source_surface, source_rect, destination_surface, destination_rect)

var _blit_scaled = sdl.get_function[
    fn(UnsafePointer[C_Surface], UnsafePointer[Rect], UnsafePointer[C_Surface], UnsafePointer[Rect]) -> Int32
]('SDL_UpperBlitScaled')
fn blit_scaled(
    source_surface: UnsafePointer[C_Surface],
    source_rect: UnsafePointer[Rect],
    destination_surface: UnsafePointer[C_Surface],
    destination_rect: UnsafePointer[Rect],
) -> Int32:
    return _blit_scaled(source_surface, source_rect, destination_surface, destination_rect)
