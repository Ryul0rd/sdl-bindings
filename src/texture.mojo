"""Defines an SDL Texture."""

from collections import Optional
from .utils import adr, opt2ptr
from ._sdl import _SDL


struct Texture:
    var sdl: UnsafePointer[SDL]
    var _texture_ptr: Ptr[_Texture]
    var _rc: UnsafePointer[Int]

    fn __init__(inout self, renderer: Renderer, format: UInt32, access: Int, w: Int, h: Int) raises:
        self.sdl = adr(renderer.sdl[])
        self._texture_ptr = self.sdl[]._sdl.create_texture(renderer._renderer_ptr, format, access, w, h)
        self._rc = UnsafePointer[Int].alloc(1)
        self._rc[] = 0

    fn __init__(inout self, renderer: Renderer, surface: Surface) raises:
        self.sdl = adr(renderer.sdl[])
        self._texture_ptr = self.sdl[]._sdl.create_texture_from_surface(renderer._renderer_ptr, surface._surface_ptr)
        self._rc = UnsafePointer[Int].alloc(1)
        self._rc[] = 0

    fn __init__(inout self, sdl: SDL, texture_ptr: Ptr[_Texture] = Ptr[_Texture]()) raises:
        self.sdl = adr(sdl)
        self._texture_ptr = texture_ptr
        self._rc = UnsafePointer[Int].alloc(1)
        self._rc[] = 0

    fn __copyinit__(inout self, other: Self):
        self.sdl = other.sdl
        self._texture_ptr = other._texture_ptr
        self._rc = other._rc
        self._rc[] += 1

    fn __moveinit__(inout self, owned other: Self):
        self.sdl = other.sdl
        self._texture_ptr = other._texture_ptr
        self._rc = other._rc

    fn __del__(owned self):
        if self._rc[] == 0:
            self.sdl[]._sdl.destroy_texture(self._texture_ptr)
        else:
            self._rc[] -= 1

    fn lock(self, rect: Optional[Rect] = None) raises -> Pixels:
        var pixels_ptr: Ptr[NoneType]
        var pixels_pitch: IntC
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(pixels_ptr))
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(pixels_pitch))
        self.sdl[]._sdl.lock_texture(self._texture_ptr, opt2ptr(rect), adr(pixels_ptr), adr(pixels_pitch))
        return Pixels(pixels_ptr, pixels_pitch)

    fn unlock(self):
        self.sdl[]._sdl.unlock_texture(self._texture_ptr)

    fn get_color_mod(self) raises -> (UInt8, UInt8, UInt8):
        var r: UInt8
        var g: UInt8
        var b: UInt8
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(r))
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(g))
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(b))
        self.sdl[]._sdl.get_texture_color_mod(self._texture_ptr, adr(r), adr(g), adr(b))
        return r, g, b

    fn set_color_mod(self, color: Color) raises:
        self.sdl[]._sdl.set_texture_color_mod(self._texture_ptr, color.r, color.g, color.b)

    fn get_alpha_mod(self) raises -> UInt8:
        var a: UInt8
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(a))
        self.sdl[]._sdl.get_texture_alpha_mod(self._texture_ptr, adr(a))
        return a

    fn set_alpha_mod(self, alpha: UInt8) raises:
        self.sdl[]._sdl.set_texture_alpha_mod(self._texture_ptr, alpha)

    fn get_blend_mode(self) raises -> BlendMode:
        var blend_mode: BlendMode
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(blend_mode))
        self.sdl[]._sdl.get_texture_blend_mode(self._texture_ptr, adr(blend_mode))
        return blend_mode

    fn set_blend_mode(self, blend_mode: BlendMode) raises:
        self.sdl[]._sdl.set_texture_blend_mode(self._texture_ptr, blend_mode)

    fn get_scale_mode(self) raises -> ScaleMode:
        var scale_mode: ScaleMode
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(scale_mode))
        self.sdl[]._sdl.get_texture_scale_mode(self._texture_ptr, adr(scale_mode))
        return scale_mode

    fn set_scale_mode(self, scale_mode: ScaleMode) raises:
        self.sdl[]._sdl.set_texture_scale_mode(self._texture_ptr, scale_mode)


@register_passable("trivial")
struct _Texture:
    pass


@register_passable("trivial")
struct TextureAccess:
    alias STATIC = 0
    """Changes rarely, not lockable."""
    alias STREAMING = 1
    """Changes frequently, lockable."""
    alias TARGET = 2
    """Texture can be used as a render target."""


@value
@register_passable("trivial")
struct BlendMode:
    """The blend mode used in `SDL_RenderCopy()` and drawing operations.

    Additional custom blend modes can be returned by `SDL_ComposeCustomBlendMode()`.
    """

    var value: IntC

    alias NONE: IntC = 0x00000000
    """No blending.

        dstRGBA = srcRGBA
    """

    alias BLEND: IntC = 0x00000001
    """Alpha blending.

        dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA))
        dstA = srcA + (dstA * (1-srcA))
    """

    alias ADD: IntC = 0x00000002
    """Additive blending.

        dstRGB = (srcRGB * srcA) + dstRGB
        dstA = dstA
    """

    alias MOD: IntC = 0x00000004
    """Color modulate.

        dstRGB = srcRGB * dstRGB
        dstA = dstA
    """

    alias MUL: IntC = 0x00000008
    """Color multiply.

        dstRGB = (srcRGB * dstRGB) + (dstRGB * (1-srcA))
        dstA = dstA
    """

    alias INVALID: IntC = 0x7FFFFFFF
    """Invalid."""


@value
@register_passable("trivial")
struct ScaleMode:
    """The scaling mode for a texture."""

    var value: IntC

    alias Nearest: IntC = 0
    """Nearest pixel sampling."""

    alias Linear: IntC = 1
    """Linear filtering."""

    alias Best: IntC = 2
    """Anisotropic filtering."""


@value
@register_passable("trivial")
struct TextureModulate:
    """The texture channel modulation used in SDL_RenderCopy()."""

    var value: IntC

    alias NONE: IntC = 0x00000000
    """No modulation."""

    alias COLOR: IntC = 0x00000001
    """srcC = srcC * color"""

    alias ALPHA: IntC = 0x00000002
    """srcA = srcA * alpha"""
