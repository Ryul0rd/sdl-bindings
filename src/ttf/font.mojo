"""Defines an sdl ttf font."""


struct Font[lif: AnyLifetime[False].type]:
    var sdl: Reference[SDL, lif]
    var _font_ptr: Ptr[_Font]

    fn __init__(inout self, ref[lif]sdl: SDL, path: String, size: Int32) raises:
        self.sdl = sdl
        self._font_ptr = sdl.ttf.open_font(path.unsafe_cstr_ptr().bitcast[DType.uint8](), size)

    fn __init__(inout self, ref[lif]sdl: SDL, font_ptr: Ptr[_Font]):
        self.sdl = sdl
        self._font_ptr = font_ptr

    fn __del__(owned self):
        self.sdl[].ttf.close_font(self._font_ptr)

    fn render_solid(self, text: String, color: Color) raises -> Surface[lif]:
        return Surface(self.sdl[], self.sdl[].ttf.render_solid_text(self._font_ptr, text.unsafe_cstr_ptr().bitcast[DType.uint8](), color.as_uint32()))

    fn render_shaded(self, text: String, foreground: Color, background: Color) raises -> Surface[lif]:
        return Surface(self.sdl[], self.sdl[].ttf.render_shaded_text(self._font_ptr, text.unsafe_cstr_ptr().bitcast[DType.uint8](), foreground.as_uint32(), background.as_uint32()))

    fn render_blended(self, text: String, color: Color) raises -> Surface[lif]:
        return Surface(self.sdl[], self.sdl[].ttf.render_blended_text(self._font_ptr, text.unsafe_cstr_ptr().bitcast[DType.uint8](), color.as_uint32()))


@register_passable("trivial")
struct _Font:
    pass



