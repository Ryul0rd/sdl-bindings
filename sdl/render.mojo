"""Defines an SDL Surface."""

from .window import _Window
from .surface import _Surface
from .texture import _Texture
from .utils import opt2ptr, _Ptr, adr


struct Renderer:
    var _renderer_ptr: _Ptr[_Renderer]
    var window: Window
    var surface: Surface

    fn __init__(
        inout self,
        owned window: Window,
        index: Int = -1,
        flags: UInt32 = RendererFlags.SDL_RENDERER_ACCELERATED,
    ) raises:
        self._renderer_ptr = create_renderer(window._window_ptr, index, flags)
        self.window = window^
        self.surface = _Ptr[_Surface]()

    fn __init__(
        inout self,
        owned surface: Surface,
    ) raises:
        self._renderer_ptr = create_software_renderer(surface._surface_ptr)
        self.window = _Ptr[_Window]()
        self.surface = surface^

    fn __moveinit__(inout self, owned other: Self):
        self._renderer_ptr = other._renderer_ptr
        self.window = other.window^
        self.surface = other.surface^

    fn __del__(owned self):
        destroy_renderer(self._renderer_ptr)

    fn clear(self) raises:
        render_clear(self._renderer_ptr)

    fn copy(self, texture: Texture, src: Optional[Rect] = None, dst: Optional[Rect] = None) raises:
        render_copy(
            self._renderer_ptr,
            texture._texture_ptr,
            opt2ptr(src),
            opt2ptr(dst),
        )

    fn copy(
        self,
        texture: Texture,
        src: Optional[Rect],
        dst: Optional[Rect],
        angle: Float64,
        point: Point,
        flip: RendererFlip,
    ) raises:
        render_copy_ex(
            self._renderer_ptr,
            texture._texture_ptr,
            opt2ptr(src),
            opt2ptr(dst),
            angle,
            adr(point),
            flip,
        )

    fn copy(self, texture: Texture, src: Optional[Rect], dst: Optional[FRect]) raises:
        render_copy_f(
            self._renderer_ptr,
            texture._texture_ptr,
            opt2ptr(src),
            opt2ptr(dst),
        )

    fn copy(
        self,
        texture: Texture,
        src: Optional[Rect],
        dst: Optional[FRect],
        angle: Float64,
        point: FPoint,
        flip: RendererFlip,
    ) raises:
        render_copy_exf(
            self._renderer_ptr,
            texture._texture_ptr,
            opt2ptr(src),
            opt2ptr(dst),
            angle,
            adr(point),
            flip,
        )

    fn present(self):
        render_present(self._renderer_ptr)

    fn target_supported(self) -> Bool:
        return render_target_supported(self._renderer_ptr)

    fn set_target(self, texture: Texture) raises:
        set_render_target(self._renderer_ptr, texture._texture_ptr)

    fn reset_target(self) raises:
        set_render_target(self._renderer_ptr, _Ptr[_Texture]())

    fn get_target(self) raises -> Texture:
        return get_render_target(self._renderer_ptr)

    fn set_color(self, color: Color) raises:
        set_render_draw_color(self._renderer_ptr, color.r, color.g, color.b, color.a)

    fn get_color(self) raises -> (UInt8, UInt8, UInt8, UInt8):
        return get_render_draw_color(self._renderer_ptr)

    fn set_blendmode(self, blendmode: BlendMode) raises:
        set_render_draw_blendmode(self._renderer_ptr, blendmode)

    fn set_vsync(self, vsync: Int) raises:
        render_set_vsync(self._renderer_ptr, vsync)

    fn get_blendmode(self) raises -> BlendMode:
        return get_render_draw_blendmode(self._renderer_ptr)

    fn get_viewport(self) -> Rect:
        return render_get_viewport(self._renderer_ptr)

    fn set_viewport(self, rect: Rect) raises:
        return render_set_viewport(self._renderer_ptr, adr(rect))

    fn get_info(self) raises -> RendererInfo:
        return get_renderer_info(self._renderer_ptr)

    fn get_output_size(self) raises -> (Int, Int):
        return get_renderer_output_size(self._renderer_ptr)

    fn draw_line(self, x1: Int, y1: Int, x2: Int, y2: Int) raises:
        render_draw_line(self._renderer_ptr, x1, y1, x2, y2)

    fn draw_lines(self, points: List[Point]) raises:
        render_draw_lines(self._renderer_ptr, points.unsafe_ptr(), len(points))

    fn draw_line(self, x1: Float32, y1: Float32, x2: Float32, y2: Float32) raises:
        render_draw_line_f(self._renderer_ptr, x1, y1, x2, y2)

    fn draw_lines(self, points: List[FPoint]) raises:
        render_draw_lines_f(self._renderer_ptr, points.unsafe_ptr(), len(points))

    fn draw_point(self, x: Int, y: Int) raises:
        render_draw_point(self._renderer_ptr, x, y)

    fn draw_points(self, points: List[Point]) raises:
        render_draw_points(self._renderer_ptr, points.unsafe_ptr(), len(points))

    fn draw_point(self, x: Float32, y: Float32) raises:
        render_draw_point_f(self._renderer_ptr, x, y)

    fn draw_points(self, points: List[FPoint]) raises:
        render_draw_points_f(self._renderer_ptr, points.unsafe_ptr(), len(points))

    fn draw_rect(self, rect: Rect) raises:
        render_draw_rect(self._renderer_ptr, rect)

    fn draw_rects(self, rects: List[Rect]) raises:
        render_draw_rects(self._renderer_ptr, rects.unsafe_ptr(), len(rects))

    fn draw_rect(self, rect: FRect) raises:
        render_draw_rect_f(self._renderer_ptr, rect)

    fn draw_rects(self, rects: List[FRect]) raises:
        render_draw_rects_f(self._renderer_ptr, rects.unsafe_ptr(), len(rects))

    fn fill_rect(self, rect: Rect) raises:
        render_fill_rect(self._renderer_ptr, rect)

    fn fill_rects(self, rects: List[Rect]) raises:
        render_fill_rects(self._renderer_ptr, rects.unsafe_ptr(), len(rects))

    fn fill_rect(self, rect: FRect) raises:
        render_fill_rect_f(self._renderer_ptr, rect)

    fn fill_rects(self, rects: List[FRect]) raises:
        render_fill_rects_f(self._renderer_ptr, rects.unsafe_ptr(), len(rects))

    fn render(self, texture: Texture, vertices: List[Vertex], indices: List[Int]) raises:
        render_geometry(
            self._renderer_ptr,
            texture._texture_ptr,
            vertices.unsafe_ptr(),
            len(vertices),
            indices.unsafe_ptr(),
            len(indices),
        )

    fn flush(self) raises:
        render_flush(self._renderer_ptr)


struct _Renderer:
    pass


struct RendererFlags:
    alias SDL_RENDERER_SOFTWARE = 0x00000001
    """The renderer is a software fallback."""

    alias SDL_RENDERER_ACCELERATED = 0x00000002
    """The renderer uses hardware acceleration."""

    alias SDL_RENDERER_PRESENTVSYNC = 0x00000004
    """Present is synchronized with the refresh rate."""

    alias SDL_RENDERER_TARGETTEXTURE = 0x00000008
    """The renderer supports rendering to texture."""


struct RendererFlip:
    """Flip constants for `SDL_RenderCopyEx()`."""

    var value: Int

    alias NONE: Int = 0x00000000
    """Do not flip."""

    alias HORIZONTAL: Int = 0x00000001
    """Flip horizontally."""

    alias VERTICAL: Int = 0x00000002
    """Flip vertically."""


@value
struct RendererInfo:
    var name: String
    var flags: UInt32
    var num_texture_formats: UInt32
    var texture_formats: SIMD[DType.uint32, 16]
    var max_texture_width: Int
    var max_texture_height: Int


var _create_renderer = _sdl.get_function[fn (_Ptr[_Window], Int, UInt32) -> _Ptr[_Renderer]](
    "SDL_CreateRenderer"
)


fn create_renderer(_window_ptr: _Ptr[_Window], index: Int, flags: UInt32) raises -> _Ptr[_Renderer]:
    """Create a 2D rendering context for a window."""
    var _renderer_ptr = _create_renderer(_window_ptr, index, flags)
    if not _renderer_ptr:
        raise get_error()
    return _renderer_ptr


var _create_software_renderer = _sdl.get_function[fn (_Ptr[_Surface]) -> _Ptr[_Renderer]](
    "SDL_CreateSoftwareRenderer"
)


fn create_software_renderer(surface: _Ptr[_Surface]) raises -> _Ptr[_Renderer]:
    """Create a 2D software rendering context for a surface."""
    var renderer = _create_software_renderer(surface)
    if not renderer:
        raise get_error()
    return renderer


var _create_window_and_renderer = _sdl.get_function[
    fn (
        Int,
        Int,
        UInt32,
        _Ptr[_Ptr[_Window]],
        _Ptr[_Ptr[_Renderer]],
    ) -> Int
]("SDL_CreateWindowAndRenderer")


fn create_window_and_renderer(
    width: Int, height: Int, window_flags: UInt32
) raises -> (_Ptr[_Window], _Ptr[_Renderer]):
    """Create a window and default renderer."""
    var window: _Ptr[_Window]
    var renderer: _Ptr[_Renderer]
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(window))
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(renderer))
    if (
        _create_window_and_renderer(
            width,
            height,
            window_flags,
            adr(window),
            adr(renderer),
        )
        != 0
    ):
        raise get_error()
    return (window, renderer)


var _destroy_renderer = _sdl.get_function[fn (_Ptr[_Renderer]) -> None]("SDL_DestroyRenderer")


fn destroy_renderer(_renderer_ptr: _Ptr[_Renderer]):
    """Destroy the rendering context for a window and free associated textures."""
    _destroy_renderer(_renderer_ptr)


var _render_clear = _sdl.get_function[fn (_Ptr[_Renderer]) -> Int]("SDL_RenderClear")


fn render_clear(_renderer_ptr: _Ptr[_Renderer]) raises:
    """Clear the current rendering target with the drawing color."""
    if _render_clear(_renderer_ptr) < 0:
        raise get_error()


var _render_present = _sdl.get_function[fn (_Ptr[_Renderer]) -> None]("SDL_RenderPresent")


fn render_present(_renderer_ptr: _Ptr[_Renderer]):
    """Update the screen with any rendering performed since the previous call."""
    _render_present(_renderer_ptr)


var _render_get_window = _sdl.get_function[fn (_Ptr[_Renderer]) -> _Ptr[_Window]](
    "SDL_RenderGetWindow"
)


fn render_get_window(renderer: _Ptr[_Renderer]) raises -> _Ptr[_Window]:
    """Get the window associated with a renderer."""
    var window = _render_get_window(renderer)
    if not window:
        raise get_error()
    return window


var _set_render_target = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[_Texture]) -> Int](
    "SDL_SetRenderTarget"
)


fn set_render_target(_render_ptr: _Ptr[_Renderer], _texture_ptr: _Ptr[_Texture]) raises:
    if _set_render_target(_render_ptr, _texture_ptr) != 0:
        raise get_error()


var _set_render_draw_color = _sdl.get_function[
    fn (_Ptr[_Renderer], UInt8, UInt8, UInt8, UInt8) -> Int
]("SDL_SetRenderDrawColor")


fn set_render_draw_color(
    _renderer_ptr: _Ptr[_Renderer], r: UInt8, g: UInt8, b: UInt8, a: UInt8
) raises:
    if _set_render_draw_color(_renderer_ptr, r, g, b, a) != 0:
        raise get_error()


var _set_render_draw_blendmode = _sdl.get_function[fn (_Ptr[_Renderer], BlendMode) -> Int](
    "SDL_SetRenderDrawBlendMode"
)


fn set_render_draw_blendmode(renderer: _Ptr[_Renderer], blendmode: BlendMode) raises:
    """Set the blend mode used for drawing operations (Fill and Line)."""
    if _set_render_draw_blendmode(renderer, blendmode) != 0:
        raise get_error()


var _get_render_draw_color = _sdl.get_function[
    fn (
        _Ptr[_Renderer],
        _Ptr[UInt8],
        _Ptr[UInt8],
        _Ptr[UInt8],
        _Ptr[UInt8],
    ) -> Int
]("SDL_GetRenderDrawColor")


fn get_render_draw_color(renderer: _Ptr[_Renderer]) raises -> (UInt8, UInt8, UInt8, UInt8):
    """Get the color used for drawing operations (Rect, Line and Clear)."""
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(r))
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(g))
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(b))
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(a))
    if (
        _get_render_draw_color(
            renderer,
            adr(r),
            adr(g),
            adr(b),
            adr(a),
        )
        != 0
    ):
        raise get_error()
    return r, g, b, a


var _get_render_draw_blendmode = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[BlendMode]) -> Int](
    "SDL_GetRenderDrawBlendMode"
)


fn get_render_draw_blendmode(renderer: _Ptr[_Renderer]) raises -> BlendMode:
    """Get the blend mode used for drawing operations."""
    var blendmode: BlendMode
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(blendmode))
    if _get_render_draw_blendmode(renderer, adr(blendmode)) != 0:
        raise get_error()
    return blendmode


var _get_renderer_info = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[RendererInfo]) -> Int](
    "SDL_GetRendererInfo"
)


fn get_renderer_info(renderer: _Ptr[_Renderer]) raises -> RendererInfo:
    """Get information about a rendering context."""
    var renderer_info: RendererInfo
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(renderer_info))
    if _get_renderer_info(renderer, adr(renderer_info)) != 0:
        raise get_error()
    return renderer_info


var _get_renderer_output_size = _sdl.get_function[
    fn (_Ptr[_Renderer], _Ptr[Int], _Ptr[Int]) -> Int
]("SDL_GetRendererOutputSize")


fn get_renderer_output_size(renderer: _Ptr[_Renderer]) raises -> (Int, Int):
    """Get the output size in pixels of a rendering context."""
    var w: Int
    var h: Int
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(w))
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(h))
    if _get_renderer_output_size(renderer, adr(w), adr(h)) != 0:
        raise get_error()
    return w, h


var _get_render_target = _sdl.get_function[fn (_Ptr[_Renderer]) -> _Ptr[_Texture]](
    "SDL_GetRenderTarget"
)


fn get_render_target(renderer: _Ptr[_Renderer]) raises -> _Ptr[_Texture]:
    """Get the current render target."""
    var render_target = _get_render_target(renderer)
    if not render_target:
        raise get_error()
    return render_target


var _render_copy = _sdl.get_function[
    fn (_Ptr[_Renderer], _Ptr[_Texture], _Ptr[Rect], _Ptr[Rect]) -> Int
]("SDL_RenderCopy")


fn render_copy(
    _renderer_ptr: _Ptr[_Renderer],
    _texture_ptr: _Ptr[_Texture],
    srcrect: _Ptr[Rect],
    dstrect: _Ptr[Rect],
) raises:
    """Copy a portion of the texture to the current rendering target."""
    if _render_copy(_renderer_ptr, _texture_ptr, srcrect, dstrect) != 0:
        raise get_error()


var _render_copy_f = _sdl.get_function[
    fn (_Ptr[_Renderer], _Ptr[_Texture], _Ptr[Rect], _Ptr[FRect]) -> Int
]("SDL_RenderCopyF")


fn render_copy_f(
    _renderer_ptr: _Ptr[_Renderer],
    _texture_ptr: _Ptr[_Texture],
    srcrect: _Ptr[Rect],
    dstrect: _Ptr[FRect],
) raises:
    """Copy a portion of the texture to the current rendering target at subpixel precision."""
    if _render_copy_f(_renderer_ptr, _texture_ptr, srcrect, dstrect) != 0:
        raise get_error()


var _render_copy_ex = _sdl.get_function[
    fn (
        _Ptr[_Renderer],
        _Ptr[_Texture],
        _Ptr[Rect],
        _Ptr[Rect],
        Float64,
        _Ptr[Point],
        RendererFlip,
    ) -> Int
]("SDL_RenderCopyEx")


fn render_copy_ex(
    renderer: _Ptr[_Renderer],
    texture: _Ptr[_Texture],
    srcrect: _Ptr[Rect],
    dstrect: _Ptr[Rect],
    angle: Float64,
    center: _Ptr[Point],
    flip: RendererFlip,
) raises:
    """Copy a portion of the texture to the current rendering, with optional rotation and flipping.
    """
    if _render_copy_ex(renderer, texture, srcrect, dstrect, angle, center, flip) != 0:
        raise get_error()


var _render_copy_exf = _sdl.get_function[
    fn (
        _Ptr[_Renderer],
        _Ptr[_Texture],
        _Ptr[Rect],
        _Ptr[FRect],
        Float64,
        _Ptr[FPoint],
        RendererFlip,
    ) -> Int
]("SDL_RenderCopyExF")


fn render_copy_exf(
    renderer: _Ptr[_Renderer],
    texture: _Ptr[_Texture],
    srcrect: _Ptr[Rect],
    dstrect: _Ptr[FRect],
    angle: Float64,
    center: _Ptr[FPoint],
    flip: RendererFlip,
) raises:
    """Copy a portion of the source texture to the current rendering target, with rotation and flipping, at subpixel precision.
    """
    if _render_copy_exf(renderer, texture, srcrect, dstrect, angle, center, flip) != 0:
        raise get_error()


var _render_draw_line = _sdl.get_function[fn (_Ptr[_Renderer], Int, Int, Int, Int) -> Int](
    "SDL_RenderDrawLine"
)


fn render_draw_line(_renderer_ptr: _Ptr[_Renderer], x1: Int, y1: Int, x2: Int, y2: Int) raises:
    """Draw a line on the current rendering target."""
    if _render_draw_line(_renderer_ptr, x1, y1, x2, y2) != 0:
        raise get_error()


var _render_draw_lines = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[Point], Int) -> Int](
    "SDL_RenderDrawLines"
)


fn render_draw_lines(renderer: _Ptr[_Renderer], points: _Ptr[Point], count: Int) raises:
    """Draw a series of connected lines on the current rendering target at subpixel precision."""
    if _render_draw_lines(renderer, points, count) != 0:
        raise get_error()


var _render_draw_line_f = _sdl.get_function[
    fn (_Ptr[_Renderer], Float32, Float32, Float32, Float32) -> Int
]("SDL_RenderDrawLineF")


fn render_draw_line_f(
    _renderer_ptr: _Ptr[_Renderer], x1: Float32, y1: Float32, x2: Float32, y2: Float32
) raises:
    """Draw a line on the current rendering target at subpixel precision."""
    if _render_draw_line_f(_renderer_ptr, x1, y1, x2, y2) != 0:
        raise get_error()


var _render_draw_lines_f = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[FPoint], Int) -> Int](
    "SDL_RenderDrawLinesF"
)


fn render_draw_lines_f(renderer: _Ptr[_Renderer], points: _Ptr[FPoint], count: Int) raises:
    """Draw a series of connected lines on the current rendering target at subpixel precision."""
    if _render_draw_lines_f(renderer, points, count) != 0:
        raise get_error()


var _render_draw_point = _sdl.get_function[fn (_Ptr[_Renderer], Int, Int) -> Int](
    "SDL_RenderDrawPoint"
)


fn render_draw_point(_renderer_ptr: _Ptr[_Renderer], x: Int, y: Int) raises:
    """Draw a point on the current rendering target."""
    if _render_draw_point(_renderer_ptr, x, y) != 0:
        raise get_error()


var _render_draw_point_f = _sdl.get_function[fn (_Ptr[_Renderer], Float32, Float32) -> Int](
    "SDL_RenderDrawPointF"
)


fn render_draw_point_f(_renderer_ptr: _Ptr[_Renderer], x: Float32, y: Float32) raises:
    """Draw a point on the current rendering target at subpixel precision."""
    if _render_draw_point_f(_renderer_ptr, x, y) != 0:
        raise get_error()


var _render_draw_points = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[Point], Int) -> Int](
    "SDL_RenderDrawPoints"
)


fn render_draw_points(renderer: _Ptr[_Renderer], points: _Ptr[Point], count: Int) raises:
    """Draw multiple points on the current rendering target."""
    if _render_draw_points(renderer, points, count) != 0:
        raise get_error()


var _render_draw_points_f = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[FPoint], Int) -> Int](
    "SDL_RenderDrawPointsF"
)


fn render_draw_points_f(renderer: _Ptr[_Renderer], points: _Ptr[FPoint], count: Int) raises:
    """Draw multiple points on the current rendering target at subpixel precision."""
    if _render_draw_points_f(renderer, points, count) != 0:
        raise get_error()


var _render_draw_rect = _sdl.get_function[fn (_Ptr[_Renderer], Rect) -> Int]("SDL_RenderDrawRect")


fn render_draw_rect(_renderer_ptr: _Ptr[_Renderer], rect: Rect) raises:
    """Draw a rectangle on the current rendering target."""
    if _render_draw_rect(_renderer_ptr, rect) != 0:
        raise get_error()


var _render_draw_rect_f = _sdl.get_function[fn (_Ptr[_Renderer], FRect) -> Int](
    "SDL_RenderDrawRectF"
)


fn render_draw_rect_f(_renderer_ptr: _Ptr[_Renderer], rect: FRect) raises:
    """Draw a rectangle on the current rendering target at subpixel precision."""
    if _render_draw_rect_f(_renderer_ptr, rect) != 0:
        raise get_error()


var _render_draw_rects = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[Rect], Int) -> Int](
    "SDL_RenderDrawRects"
)


fn render_draw_rects(_renderer_ptr: _Ptr[_Renderer], rects: _Ptr[Rect], count: Int) raises:
    """Draw some number of rectangles on the current rendering target."""
    if _render_draw_rects(_renderer_ptr, rects, count) != 0:
        raise get_error()


var _render_draw_rects_f = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[FRect], Int) -> Int](
    "SDL_RenderDrawRectsF"
)


fn render_draw_rects_f(_renderer_ptr: _Ptr[_Renderer], rects: _Ptr[FRect], count: Int) raises:
    """Draw some number of rectangles on the current rendering target at subpixel precision."""
    if _render_draw_rects_f(_renderer_ptr, rects, count) != 0:
        raise get_error()


var _render_fill_rect = _sdl.get_function[fn (_Ptr[_Renderer], Rect) -> Int]("SDL_RenderFillRect")


fn render_fill_rect(_renderer_ptr: _Ptr[_Renderer], rect: Rect) raises:
    """Fill a rectangle on the current rendering target."""
    if _render_fill_rect(_renderer_ptr, rect) != 0:
        raise get_error()


var _render_fill_rect_f = _sdl.get_function[fn (_Ptr[_Renderer], FRect) -> Int](
    "SDL_RenderFillRectF"
)


fn render_fill_rect_f(_renderer_ptr: _Ptr[_Renderer], rect: FRect) raises:
    """Fill a rectangle on the current rendering target at subpixel precision."""
    if _render_fill_rect_f(_renderer_ptr, rect) != 0:
        raise get_error()


var _render_fill_rects = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[Rect], Int) -> Int](
    "SDL_RenderFillRects"
)


fn render_fill_rects(_renderer_ptr: _Ptr[_Renderer], rects: _Ptr[Rect], count: Int) raises:
    """Fill some number of rectangles on the current rendering target."""
    if _render_fill_rects(_renderer_ptr, rects, count) != 0:
        raise get_error()


var _render_fill_rects_f = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[FRect], Int) -> Int](
    "SDL_RenderFillRectsF"
)


fn render_fill_rects_f(_renderer_ptr: _Ptr[_Renderer], rects: _Ptr[FRect], count: Int) raises:
    """Fill some number of rectangles on the current rendering target at subpixel precision."""
    if _render_fill_rects_f(_renderer_ptr, rects, count) != 0:
        raise get_error()


var _render_flush = _sdl.get_function[fn (_Ptr[_Renderer]) -> Int]("SDL_RenderFlush")


fn render_flush(renderer: _Ptr[_Renderer]) raises:
    """Force the rendering context to flush any pending commands to the underlying rendering API."""
    if _render_flush(renderer) != 0:
        raise get_error()


var _render_geometry = _sdl.get_function[
    fn (
        _Ptr[_Renderer],
        _Ptr[_Texture],
        _Ptr[Vertex],
        Int,
        _Ptr[Int],
        Int,
    ) -> Int
]("SDL_RenderGeometry")


fn render_geometry(
    renderer: _Ptr[_Renderer],
    texture: _Ptr[_Texture],
    vertices: _Ptr[Vertex],
    num_vertices: Int,
    indices: _Ptr[Int],
    num_indices: Int,
) raises:
    """Render a list of triangles, optionally using a texture and indices into the vertex array Color and alpha modulation is done per vertex (SDL_SetTextureColorMod and SDL_SetTextureAlphaMod are ignored).
    """
    if _render_geometry(renderer, texture, vertices, num_vertices, indices, num_indices) != 0:
        raise get_error()


var _render_geometry_raw = _sdl.get_function[
    fn (
        _Ptr[_Renderer],
        _Ptr[_Texture],
        _Ptr[Float32],
        Int,
        _Ptr[Color],
        Int,
        _Ptr[Float32],
        Int,
        Int,
        _Ptr[NoneType],
        Int,
        Int,
    ) -> Int
]("SDL_RenderGeometryRaw")


fn render_geometry_raw(
    renderer: _Ptr[_Renderer],
    texture: _Ptr[_Texture],
    xy: _Ptr[Float32],
    xy_stride: Int,
    color: _Ptr[Color],
    color_stride: Int,
    uv: _Ptr[Float32],
    uv_stride: Int,
    num_vertices: Int,
    indices: _Ptr[NoneType],
    num_indices: Int,
    size_indices: Int,
) raises:
    if (
        _render_geometry_raw(
            renderer,
            texture,
            xy,
            xy_stride,
            color,
            color_stride,
            uv,
            uv_stride,
            num_vertices,
            indices,
            num_indices,
            size_indices,
        )
        != 0
    ):
        raise get_error()


var _render_get_clip_rect = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[Rect]) -> None](
    "SDL_RenderGetClipRect"
)


fn render_get_clip_rect(renderer: _Ptr[_Renderer], rect: _Ptr[Rect]):
    """Get the clip rectangle for the current target."""
    _render_get_clip_rect(renderer, rect)


var _render_get_integer_scale = _sdl.get_function[fn (_Ptr[_Renderer]) -> Bool](
    "SDL_RenderGetIntegerScale"
)


fn render_get_integer_scale(renderer: _Ptr[_Renderer]) -> Bool:
    """Get whether integer scales are forced for resolution-independent rendering."""
    return _render_get_integer_scale(renderer)


var _render_get_logical_size = _sdl.get_function[
    fn (_Ptr[_Renderer], _Ptr[Int], _Ptr[Int]) -> None
]("SDL_RenderGetLogicalSize")


fn render_get_logical_size(renderer: _Ptr[_Renderer]) -> (Int, Int):
    """Get device independent resolution for rendering."""
    var w: Int
    var h: Int
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(w))
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(h))
    _render_get_logical_size(renderer, adr(w), adr(h))
    return w, h


var _render_get_metal_command_encoder = _sdl.get_function[fn (_Ptr[_Renderer]) -> _Ptr[NoneType]](
    "SDL_RenderGetMetalCommandEncoder"
)


fn render_get_metal_command_encoder(renderer: _Ptr[_Renderer]) raises -> _Ptr[NoneType]:
    """Get the Metal command encoder for the current frame."""
    var metal_command_encoder = _render_get_metal_command_encoder(renderer)
    if not metal_command_encoder:
        raise get_error()
    return metal_command_encoder


var _render_get_metal_layer = _sdl.get_function[fn (_Ptr[_Renderer]) -> _Ptr[NoneType]](
    "SDL_RenderGetMetalLayer"
)


fn render_get_metal_layer(renderer: _Ptr[_Renderer]) raises -> _Ptr[NoneType]:
    """Get the CAMetalLayer associated with the given Metal renderer."""
    var metal_layer = _render_get_metal_layer(renderer)
    if not metal_layer:
        raise get_error()
    return metal_layer


var _render_get_scale = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[Int], _Ptr[Int]) -> None](
    "SDL_RenderGetScale"
)


fn render_get_scale(renderer: _Ptr[_Renderer]) -> (Int, Int):
    """Get the drawing scale for the current target."""
    var scale_x: Int
    var scale_y: Int
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(scale_x))
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(scale_y))
    _render_get_scale(renderer, adr(scale_x), adr(scale_y))
    return scale_x, scale_y


var _render_get_viewport = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[Rect]) -> None](
    "SDL_RenderGetViewport"
)


fn render_get_viewport(renderer: _Ptr[_Renderer]) -> Rect:
    """Get the drawing area for the current target."""
    var viewport: Rect
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(viewport))
    _render_get_viewport(renderer, adr(viewport))
    return viewport


var _render_is_clip_enabled = _sdl.get_function[fn (_Ptr[_Renderer]) -> Bool](
    "SDL_RenderIsClipEnabled"
)


fn render_is_clip_enabled(renderer: _Ptr[_Renderer]) -> Bool:
    """Get whether clipping is enabled on the given renderer."""
    return _render_is_clip_enabled(renderer)


var _render_logical_to_window = _sdl.get_function[
    fn (_Ptr[_Renderer], Float32, Float32, _Ptr[Int], _Ptr[Int]) -> None
]("SDL_RenderLogicalToWindow")


fn render_logical_to_window(
    renderer: _Ptr[_Renderer],
    logical_x: Float32,
    logical_y: Float32,
    window_x: _Ptr[Int],
    window_y: _Ptr[Int],
):
    """Get real coordinates of point in window when given logical coordinates of point in renderer.
    """
    _render_logical_to_window(renderer, logical_x, logical_y, window_x, window_y)


var _render_read_pixels = _sdl.get_function[
    fn (_Ptr[_Renderer], _Ptr[Rect], UInt32, _Ptr[NoneType], Int) -> Int
]("SDL_RenderReadPixels")


fn render_read_pixels(
    renderer: _Ptr[_Renderer], rect: _Ptr[Rect], format: UInt32, pixels: _Ptr[NoneType], pitch: Int
) raises:
    """Read pixels from the current rendering target to an array of pixels."""
    if _render_read_pixels(renderer, rect, format, pixels, pitch) != 0:
        raise get_error()


var _render_set_clip_rect = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[Rect]) -> Int](
    "SDL_RenderSetClipRect"
)


fn render_set_clip_rect(renderer: _Ptr[_Renderer], rect: _Ptr[Rect]) raises:
    """Set the clip rectangle for rendering on the specified target."""
    if _render_set_clip_rect(renderer, rect) != 0:
        raise get_error()


var _render_set_integer_scale = _sdl.get_function[fn (_Ptr[_Renderer], Bool) -> Int](
    "SDL_RenderSetIntegerScale"
)


fn render_set_integer_scale(renderer: _Ptr[_Renderer], enable: Bool) raises:
    """Set whether to force integer scales for resolution-independent rendering."""
    if _render_set_integer_scale(renderer, enable) != 0:
        raise get_error()


var _render_set_logical_size = _sdl.get_function[fn (_Ptr[_Renderer], Int, Int) -> Int](
    "SDL_RenderSetLogicalSize"
)


fn render_set_logical_size(renderer: _Ptr[_Renderer], w: Int, h: Int) raises:
    """Set a device independent resolution for rendering."""
    if _render_set_logical_size(renderer, w, h) != 0:
        raise get_error()


var _render_set_scale = _sdl.get_function[fn (_Ptr[_Renderer], Float32, Float32) -> Int](
    "SDL_RenderSetScale"
)


fn render_set_scale(renderer: _Ptr[_Renderer], scale_x: Float32, scale_y: Float32) raises:
    """Set the drawing scale for rendering on the current target."""
    if _render_set_scale(renderer, scale_x, scale_y) != 0:
        raise get_error()


var _render_set_viewport = _sdl.get_function[fn (_Ptr[_Renderer], _Ptr[Rect]) -> Int](
    "SDL_RenderSetViewport"
)


fn render_set_viewport(renderer: _Ptr[_Renderer], rect: _Ptr[Rect]) raises:
    """Set the drawing area for rendering on the current target."""
    if _render_set_viewport(renderer, rect) != 0:
        raise get_error()


var _render_set_vsync = _sdl.get_function[fn (_Ptr[_Renderer], Int) -> Int]("SDL_RenderSetVSync")


fn render_set_vsync(renderer: _Ptr[_Renderer], vsync: Int) raises:
    """Toggle VSync of the given renderer."""
    if _render_set_vsync(renderer, vsync) != 0:
        raise get_error()


var _render_target_supported = _sdl.get_function[fn (_Ptr[_Renderer]) -> Bool](
    "SDL_RenderTargetSupported"
)


fn render_target_supported(renderer: _Ptr[_Renderer]) -> Bool:
    """Determine whether a renderer supports the use of render targets."""
    return _render_target_supported(renderer)


var _render_window_to_logical = _sdl.get_function[
    fn (_Ptr[_Renderer], Int, Int, _Ptr[Float32], _Ptr[Float32]) -> None
]("SDL_RenderWindowToLogical")


fn render_window_to_logical(
    renderer: _Ptr[_Renderer],
    window_x: Int,
    window_y: Int,
    logical_x: _Ptr[Float32],
    logical_y: _Ptr[Float32],
):
    """Get logical coordinates of point in renderer when given real coordinates of point in window.
    """
    _render_window_to_logical(renderer, window_x, window_y, logical_x, logical_y)
