"""Defines an SDL Renderer."""

from collections import Optional
from .utils import opt2ptr, adr
from ._sdl import _SDL
from .texture import _Texture


struct Renderer[lif: AnyLifetime[False].type]:
    var sdl: Reference[SDL, lif]
    var _renderer_ptr: Ptr[_Renderer]
    var window: Window[lif]
    var surface: Surface[lif]

    fn __init__(inout self, owned window: Window[lif], index: Int = -1, flags: UInt32 = RendererFlags.SDL_RENDERER_ACCELERATED) raises:
        self.sdl = window.sdl
        self._renderer_ptr = self.sdl[]._sdl.create_renderer(window._window_ptr, index, flags)
        self.window = window^
        self.surface = Surface(self.sdl[])

    fn __init__(inout self, owned surface: Surface[lif]) raises:
        self.sdl = surface.sdl
        self._renderer_ptr = self.sdl[]._sdl.create_software_renderer(surface._surface_ptr)
        self.window = Window(self.sdl[])
        self.surface = surface^

    fn __moveinit__(inout self, owned other: Self):
        self.sdl = other.sdl
        self._renderer_ptr = other._renderer_ptr
        self.window = other.window^
        self.surface = other.surface^

    fn __del__(owned self):
        self.sdl[]._sdl.destroy_renderer(self._renderer_ptr)

    fn clear(self) raises:
        self.sdl[]._sdl.render_clear(self._renderer_ptr)

    fn copy[type: DType = DType.int32](self, texture: Texture, src: Optional[Rect]) raises:
        @parameter
        if type.is_integral():
            self.sdl[]._sdl.render_copy(self._renderer_ptr, texture._texture_ptr, opt2ptr(src), Ptr[Rect]())
        elif type.is_floating_point():
            self.sdl[]._sdl.render_copy_f(self._renderer_ptr, texture._texture_ptr, opt2ptr(src), Ptr[FRect]())

    fn copy[type: DType = DType.int32](self, texture: Texture, src: Optional[Rect], dst: DRect[type]) raises:
        @parameter
        if type.is_integral():
            self.sdl[]._sdl.render_copy(self._renderer_ptr, texture._texture_ptr, opt2ptr(src), adr(dst.cast[DType.int32]()))
        elif type.is_floating_point():
            self.sdl[]._sdl.render_copy_f(self._renderer_ptr, texture._texture_ptr, opt2ptr(src), adr(dst.cast[DType.float32]()))

    fn copy(
        self,
        texture: Texture,
        src: Optional[Rect],
        dst: Optional[Rect],
        angle: Float64,
        point: Point,
        flip: RendererFlip,
    ) raises:
        self.sdl[]._sdl.render_copy_ex(
            self._renderer_ptr,
            texture._texture_ptr,
            opt2ptr(src),
            opt2ptr(dst),
            angle,
            adr(point),
            flip,
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
        self.sdl[]._sdl.render_copy_exf(
            self._renderer_ptr,
            texture._texture_ptr,
            opt2ptr(src),
            opt2ptr(dst),
            angle,
            adr(point),
            flip,
        )

    fn present(self):
        self.sdl[]._sdl.render_present(self._renderer_ptr)

    fn target_supported(self) -> Bool:
        return self.sdl[]._sdl.render_target_supported(self._renderer_ptr)

    fn set_target(self, texture: Texture) raises:
        self.sdl[]._sdl.set_render_target(self._renderer_ptr, texture._texture_ptr)

    fn reset_target(self) raises:
        self.sdl[]._sdl.set_render_target(self._renderer_ptr, Ptr[_Texture]())

    fn get_target(self) raises -> Texture:
        var texture = self.sdl[]._sdl.get_render_target(self._renderer_ptr)
        return Texture(self.sdl[], texture)

    fn set_color(self, color: Color) raises:
        self.sdl[]._sdl.set_render_draw_color(self._renderer_ptr, color.r, color.g, color.b, color.a)

    fn get_color(self) raises -> Color:
        var color: Color
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(color))
        self.sdl[]._sdl.get_render_draw_color(self._renderer_ptr, adr(color.r), adr(color.g), adr(color.b), adr(color.a))
        return color

    fn set_blendmode(self, blendmode: BlendMode) raises:
        self.sdl[]._sdl.set_render_draw_blend_mode(self._renderer_ptr, blendmode)

    fn set_vsync(self, vsync: Int) raises:
        self.sdl[]._sdl.render_set_vsync(self._renderer_ptr, vsync)

    fn get_blendmode(self) raises -> BlendMode:
        var blend_mode: BlendMode
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(blend_mode))
        self.sdl[]._sdl.get_render_draw_blend_mode(self._renderer_ptr, adr(blend_mode))
        return blend_mode

    fn get_viewport(self) -> Rect:
        var rect: Rect
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(rect))
        self.sdl[]._sdl.render_get_viewport(self._renderer_ptr, adr(rect))
        return rect

    fn set_viewport(self, rect: Rect) raises:
        return self.sdl[]._sdl.render_set_viewport(self._renderer_ptr, adr(rect))

    fn get_info(self) raises -> RendererInfo:
        var info: RendererInfo
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(info))
        self.sdl[]._sdl.get_renderer_info(self._renderer_ptr, adr(info))
        return info

    fn get_output_size(self) raises -> (Int, Int):
        var w: IntC
        var h: IntC
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(w))
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(h))
        self.sdl[]._sdl.get_renderer_output_size(self._renderer_ptr, adr(w), adr(h))
        return int(w), int(h)

    fn draw_point[type: DType = DType.float32](self, x: Scalar[type], y: Scalar[type]) raises:
        @parameter
        if type.is_integral():
            self.sdl[]._sdl.render_draw_point(self._renderer_ptr, x.cast[DType.int32](), y.cast[DType.int32]())
        elif type.is_floating_point():
            self.sdl[]._sdl.render_draw_point_f(self._renderer_ptr, x.cast[DType.float32](), y.cast[DType.float32]())

    fn draw_points(self, points: List[Point]) raises:
        self.sdl[]._sdl.render_draw_points(self._renderer_ptr, points.unsafe_ptr(), len(points))

    fn draw_points(self, points: List[FPoint]) raises:
        self.sdl[]._sdl.render_draw_points_f(self._renderer_ptr, points.unsafe_ptr(), len(points))

    fn draw_line[type: DType = DType.float32](self, x1: Scalar[type], y1: Scalar[type], x2: Scalar[type], y2: Scalar[type]) raises:
        @parameter
        if type.is_integral():
            self.sdl[]._sdl.render_draw_line(self._renderer_ptr, x1.cast[DType.int32](), y1.cast[DType.int32](), x2.cast[DType.int32](), y2.cast[DType.int32]())
        elif type.is_floating_point():
            self.sdl[]._sdl.render_draw_line_f(self._renderer_ptr, x1.cast[DType.float32](), y1.cast[DType.float32](), x2.cast[DType.float32](), y2.cast[DType.float32]())

    fn draw_lines(self, points: List[Point]) raises:
        self.sdl[]._sdl.render_draw_lines(self._renderer_ptr, points.unsafe_ptr(), len(points))

    fn draw_lines(self, points: List[FPoint]) raises:
        self.sdl[]._sdl.render_draw_lines_f(self._renderer_ptr, points.unsafe_ptr(), len(points))

    fn draw_circle[type: DType = DType.float32](self, center: DPoint[type], radius: Scalar) raises:
        self.sdl[].gfx.circle_color(self._renderer_ptr, center.x.cast[DType.int16](), center.y.cast[DType.int16](), radius.cast[DType.int16](), self.get_color().as_uint32())

    fn draw_rect[type: DType = DType.float32](self, rect: DRect[type]) raises:
        @parameter
        if type.is_integral():
            self.sdl[]._sdl.render_draw_rect(self._renderer_ptr, rect.cast[DType.int32]())
        if type.is_floating_point():
            self.sdl[]._sdl.render_draw_rect_f(self._renderer_ptr, rect.cast[DType.float32]())

    fn draw_rects(self, rects: List[Rect]) raises:
        self.sdl[]._sdl.render_draw_rects(self._renderer_ptr, rects.unsafe_ptr(), len(rects))

    fn draw_rects(self, rects: List[FRect]) raises:
        self.sdl[]._sdl.render_draw_rects_f(self._renderer_ptr, rects.unsafe_ptr(), len(rects))

    fn fill_rect[type: DType = DType.float32](self, rect: DRect[type]) raises:
        @parameter
        if type.is_integral():
            self.sdl[]._sdl.render_fill_rect(self._renderer_ptr, rect.cast[DType.int32]())
        if type.is_floating_point():
            self.sdl[]._sdl.render_fill_rect_f(self._renderer_ptr, rect.cast[DType.float32]())

    fn fill_rects(self, rects: List[Rect]) raises:
        self.sdl[]._sdl.render_fill_rects(self._renderer_ptr, rects.unsafe_ptr(), len(rects))

    fn fill_rects(self, rects: List[FRect]) raises:
        self.sdl[]._sdl.render_fill_rects_f(self._renderer_ptr, rects.unsafe_ptr(), len(rects))

    fn render_geometry(self, texture: Texture, vertices: List[Vertex], indices: List[IntC]) raises:
        self.sdl[]._sdl.render_geometry(
            self._renderer_ptr,
            texture._texture_ptr,
            vertices.unsafe_ptr(),
            len(vertices),
            indices.unsafe_ptr(),
            len(indices),
        )

    fn flush(self) raises:
        self.sdl[]._sdl.render_flush(self._renderer_ptr)


@register_passable("trivial")
struct _Renderer:
    pass


@register_passable("trivial")
struct RendererFlags:
    alias SDL_RENDERER_SOFTWARE = 0x00000001
    """The renderer is a software fallback."""

    alias SDL_RENDERER_ACCELERATED = 0x00000002
    """The renderer uses hardware acceleration."""

    alias SDL_RENDERER_PRESENTVSYNC = 0x00000004
    """Present is synchronized with the refresh rate."""

    alias SDL_RENDERER_TARGETTEXTURE = 0x00000008
    """The renderer supports rendering to texture."""


@register_passable("trivial")
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