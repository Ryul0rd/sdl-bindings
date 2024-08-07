from ..surface import _Surface


struct Font:
    var _font_ptr: UnsafePointer[_Font]

    fn __init__(inout self, name: String, size: Int32):
        self._font_ptr = _ttf_open_font(name.unsafe_ptr(), size)

    fn __init__(inout self, font_ptr: UnsafePointer[_Font]):
        self._font_ptr = font_ptr

    fn __del__(owned self):
        _ttf_close_font(self._font_ptr)

    fn render_solid(self, text: String, color: Color) -> Surface:
        return Surface(render_solid_text(self._font_ptr, text.unsafe_ptr(), color.as_uint32()))

    fn render_shaded(self, text: String, foreground: Color, background: Color) -> Surface:
        return Surface(
            render_shaded_text(
                self._font_ptr,
                text.unsafe_ptr(),
                foreground.as_uint32(),
                background.as_uint32(),
            )
        )

    fn render_blended(self, text: String, color: Color) -> Surface:
        return Surface(render_blended_text(self._font_ptr, text.unsafe_ptr(), color.as_uint32()))


struct _Font:
    pass


var _ttf_init = _sdl_ttf.get_function[fn () -> Int32]("TTF_Init")


fn ttf_init() raises:
    var error_code = _ttf_init()
    if error_code != 0:
        raise Error("Could not initialize SDL TTF")


var _ttf_quit = _sdl_ttf.get_function[fn () -> None]("TTF_Quit")


fn ttf_quit():
    _ttf_quit()


var _ttf_open_font = _sdl_ttf.get_function[
    fn (UnsafePointer[UInt8], Int32) -> UnsafePointer[_Font]
]("TTF_OpenFont")


fn ttf_open_font(name: UnsafePointer[UInt8], size: Int32) -> UnsafePointer[_Font]:
    return _ttf_open_font(name, size)


var _ttf_close_font = _sdl_ttf.get_function[fn (UnsafePointer[_Font]) -> None]("TTF_CloseFont")


fn ttf_close_font(font: UnsafePointer[_Font]):
    _ttf_close_font(font)


var _ttf_render_text_solid = _sdl_ttf.get_function[
    fn (UnsafePointer[_Font], UnsafePointer[UInt8], UInt32) -> UnsafePointer[_Surface]
]("TTF_RenderText_Solid")


fn render_solid_text(
    font: UnsafePointer[_Font], text: UnsafePointer[UInt8], fg: UInt32
) -> UnsafePointer[_Surface]:
    return _ttf_render_text_solid(font, text, fg)


var _ttf_render_text_shaded = _sdl_ttf.get_function[
    fn (UnsafePointer[_Font], UnsafePointer[UInt8], UInt32, UInt32) -> UnsafePointer[_Surface]
]("TTF_RenderText_Shaded")


fn render_shaded_text(
    font: UnsafePointer[_Font],
    text: UnsafePointer[UInt8],
    fg: UInt32,
    bg: UInt32,
) -> UnsafePointer[_Surface]:
    return _ttf_render_text_shaded(font, text, fg, bg)


var _ttf_render_text_blended = _sdl_ttf.get_function[
    fn (UnsafePointer[_Font], UnsafePointer[UInt8], UInt32) -> UnsafePointer[_Surface]
]("TTF_RenderText_Blended")


fn render_blended_text(
    font: UnsafePointer[_Font], text: UnsafePointer[UInt8], fg: UInt32
) -> UnsafePointer[_Surface]:
    return _ttf_render_text_blended(font, text, fg)
