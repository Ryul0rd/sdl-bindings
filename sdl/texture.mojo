"""Defines an SDL Texture."""

from .render import _Renderer
from .surface import _Surface
from .utils import opt2ptr, _Ptr, adr


@value
struct Texture:
    var _texture_ptr: _Ptr[_Texture]

    fn __init__(inout self, renderer: Renderer, format: UInt32, access: Int, w: Int, h: Int) raises:
        self._texture_ptr = create_texture(renderer._renderer_ptr, format, access, w, h)

    fn __init__(inout self, renderer: Renderer, surface: Surface) raises:
        self._texture_ptr = create_texture_from_surface(
            renderer._renderer_ptr, surface._surface_ptr
        )

    fn __del__(owned self):
        _destroy_texture(self._texture_ptr)

    fn lock(self, rect: Rect) raises -> Pixels:
        var pixels_ptr: _Ptr[NoneType]
        var pixels_pitch: Int
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(pixels_ptr))
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(pixels_pitch))
        lock_texture(self._texture_ptr, adr(rect), adr(pixels_ptr), adr(pixels_pitch))
        return Pixels(pixels_ptr, pixels_pitch)

    fn unlock(self):
        unlock_texture(self._texture_ptr)

    fn get_color_mod(self) raises -> Color:
        return get_texture_color_mod(self._texture_ptr)

    fn set_color_mod(self, color: Color) raises:
        set_texture_color_mod(self._texture_ptr, color.r, color.g, color.b)

    fn get_alpha_mod(self) raises -> UInt8:
        return get_texture_alpha_mod(self._texture_ptr)

    fn set_alpha_mod(self, alpha: UInt8) raises:
        set_texture_alpha_mod(self._texture_ptr, alpha)

    fn get_blend_mode(self) raises -> BlendMode:
        return get_texture_blend_mode(self._texture_ptr)

    fn set_blend_mode(self, blend_mode: BlendMode) raises:
        set_texture_blend_mode(self._texture_ptr, blend_mode)

    fn get_scale_mode(self) raises -> ScaleMode:
        return get_texture_scale_mode(self._texture_ptr)

    fn set_scale_mode(self, scale_mode: ScaleMode) raises:
        set_texture_scale_mode(self._texture_ptr, scale_mode)


struct _Texture:
    pass


struct TextureAccess:
    alias STATIC = 0
    """Changes rarely, not lockable."""
    alias STREAMING = 1
    """Changes frequently, lockable."""
    alias TARGET = 2
    """Texture can be used as a render target."""


@value
struct BlendMode:
    """The blend mode used in `SDL_RenderCopy()` and drawing operations.

    Additional custom blend modes can be returned by `SDL_ComposeCustomBlendMode()`.
    """

    var value: Int

    alias NONE: Int = 0x00000000
    """No blending.

        dstRGBA = srcRGBA
    """

    alias BLEND: Int = 0x00000001
    """Alpha blending.

        dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA))
        dstA = srcA + (dstA * (1-srcA))
    """

    alias ADD: Int = 0x00000002
    """Additive blending.

        dstRGB = (srcRGB * srcA) + dstRGB
        dstA = dstA
    """

    alias MOD: Int = 0x00000004
    """Color modulate.

        dstRGB = srcRGB * dstRGB
        dstA = dstA
    """

    alias MUL: Int = 0x00000008
    """Color multiply.

        dstRGB = (srcRGB * dstRGB) + (dstRGB * (1-srcA))
        dstA = dstA
    """

    alias INVALID: Int = 0x7FFFFFFF
    """Invalid."""


@value
struct ScaleMode:
    """The scaling mode for a texture."""

    var value: Int

    alias Nearest: Int = 0
    """Nearest pixel sampling."""

    alias Linear: Int = 1
    """Linear filtering."""

    alias Best: Int = 2
    """Anisotropic filtering."""


@value
struct TextureModulate:
    var value: Int

    alias NONE = 0x00000000
    """No modulation."""

    alias COLOR = 0x00000001
    """srcC = srcC * color"""

    alias ALPHA = 0x00000002
    """srcA = srcA * alpha"""


var _create_texture = _sdl.get_function[
    fn (_Ptr[_Renderer], UInt32, Int, Int, Int) -> _Ptr[_Texture]
]("SDL_CreateTexture")


fn create_texture(
    renderer: _Ptr[_Renderer], format: UInt32, access: Int, w: Int, h: Int
) raises -> _Ptr[_Texture]:
    """Create a texture for a rendering context."""
    var texture = _create_texture(renderer, format, access, w, h)
    if not texture:
        raise get_error()
    return texture


var _destroy_texture = _sdl.get_function[fn (_Ptr[_Texture]) -> None]("SDL_DestroyTexture")


fn destroy_texture(texture: _Ptr[_Texture]):
    """Destroy the specified texture."""
    _destroy_texture(texture)


var _create_texture_from_surface = _sdl.get_function[
    fn (_Ptr[_Renderer], _Ptr[_Surface]) -> _Ptr[_Texture]
]("SDL_CreateTextureFromSurface")


fn create_texture_from_surface(
    renderer: _Ptr[_Renderer], surface: _Ptr[_Surface]
) raises -> _Ptr[_Texture]:
    """Create a texture from an existing surface."""
    var texture = _create_texture_from_surface(renderer, surface)
    if not texture:
        raise get_error()
    return texture


var _gl_bind_texture = _sdl.get_function[fn (_Ptr[_Texture], _Ptr[Float32], _Ptr[Float32]) -> Int](
    "SDL_GL_BindTexture"
)


fn gl_bind_texture(texture: _Ptr[_Texture], texw: _Ptr[Float32], texh: _Ptr[Float32]) raises:
    """Bind an OpenGL/ES/ES2 texture to the current context."""
    if _gl_bind_texture(texture, texw, texh) != 0:
        raise get_error()


var _gl_unbind_texture = _sdl.get_function[fn (_Ptr[_Texture]) -> Int]("SDL_GL_UnbindTexture")


fn gl_unbind_texture(texture: _Ptr[_Texture]) raises:
    """Unbind an OpenGL/ES/ES2 texture from the current context."""
    if _gl_unbind_texture(texture) != 0:
        raise get_error()


var _lock_texture = _sdl.get_function[
    fn (
        _Ptr[_Texture],
        _Ptr[Rect],
        _Ptr[_Ptr[NoneType]],
        _Ptr[Int],
    ) -> Int
]("SDL_LockTexture")


fn lock_texture(
    texture: _Ptr[_Texture],
    rect: _Ptr[Rect],
    pixels: _Ptr[_Ptr[NoneType]],
    pitch: _Ptr[Int],
) raises:
    """Lock a portion of the texture for write-only pixel access."""
    if _lock_texture(texture, rect, pixels, pitch) != 0:
        raise get_error()


var _lock_texture_to_surface = _sdl.get_function[
    fn (_Ptr[_Texture], _Ptr[Rect], _Ptr[_Ptr[_Surface]]) -> Int
]("SDL_LockTextureToSurface")


fn lock_texture_to_surface(
    texture: _Ptr[_Texture],
    rect: _Ptr[Rect],
    surface: _Ptr[_Ptr[_Surface]],
) raises:
    """Lock a portion of the texture for write-only pixel access, and expose it as a SDL surface."""
    if _lock_texture_to_surface(texture, rect, surface) != 0:
        raise get_error()


var _unlock_texture = _sdl.get_function[fn (_Ptr[_Texture]) -> None]("SDL_UnlockTexture")


fn unlock_texture(texture: _Ptr[_Texture]):
    """Unlock a texture, uploading the changes to video memory, if needed."""
    _unlock_texture(texture)


var _query_texture = _sdl.get_function[
    fn (
        _Ptr[_Texture],
        _Ptr[UInt32],
        _Ptr[Int],
        _Ptr[Int],
        _Ptr[Int],
    ) -> Int
]("SDL_QueryTexture")


fn query_texture(
    texture: _Ptr[_Texture],
    format: _Ptr[UInt32],
    access: _Ptr[Int],
    w: _Ptr[Int],
    h: _Ptr[Int],
) raises:
    """Query the attributes of a texture."""
    if _query_texture(texture, format, access, w, h) != 0:
        raise get_error()


var _get_texture_color_mod = _sdl.get_function[
    fn (_Ptr[_Texture], _Ptr[UInt8], _Ptr[UInt8], _Ptr[UInt8]) -> Int
]("SDL_GetTextureColorMod")


fn get_texture_color_mod(texture: _Ptr[_Texture]) raises -> Color:
    """Get the additional color value multiplied into render copy operations."""
    var r: UInt8
    var g: UInt8
    var b: UInt8
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(r))
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(g))
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(b))
    if _get_texture_color_mod(texture, adr(r), adr(g), adr(b)) != 0:
        raise get_error()
    return Color(r, g, b)


var _get_texture_alpha_mod = _sdl.get_function[fn (_Ptr[_Texture], _Ptr[UInt8]) -> Int](
    "SDL_GetTextureAlphaMod"
)


fn get_texture_alpha_mod(texture: _Ptr[_Texture]) raises -> UInt8:
    """Get the additional alpha value multiplied into render copy operations."""
    var a: UInt8
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(a))
    if _get_texture_alpha_mod(texture, adr(a)) != 0:
        raise get_error()
    return a


var _get_texture_blend_mode = _sdl.get_function[fn (_Ptr[_Texture], _Ptr[BlendMode]) -> Int](
    "SDL_GetTextureBlendMode"
)


fn get_texture_blend_mode(texture: _Ptr[_Texture]) raises -> BlendMode:
    """Get the blend mode used for texture copy operations."""
    var blendmode: BlendMode
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(blendmode))
    if _get_texture_blend_mode(texture, adr(blendmode)) != 0:
        raise get_error()
    return blendmode


var _get_texture_scale_mode = _sdl.get_function[fn (_Ptr[_Texture], _Ptr[ScaleMode]) -> Int](
    "SDL_GetTextureScaleMode"
)


fn get_texture_scale_mode(texture: _Ptr[_Texture]) raises -> ScaleMode:
    """Get the scale mode used for texture scale operations."""
    var scalemode: ScaleMode
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(scalemode))
    if _get_texture_scale_mode(texture, adr(scalemode)) != 0:
        raise get_error()
    return scalemode


var _get_texture_user_data = _sdl.get_function[fn (_Ptr[_Texture]) -> _Ptr[NoneType]](
    "SDL_GetTextureUserData"
)


fn get_texture_user_data(texture: _Ptr[_Texture]) raises -> _Ptr[NoneType]:
    """Get the user-specified pointer associated with a texture."""
    var ptr = _get_texture_user_data(texture)
    if not ptr:
        raise get_error()
    return ptr


var _set_texture_color_mod = _sdl.get_function[fn (_Ptr[_Texture], UInt8, UInt8, UInt8) -> Int](
    "SDL_SetTextureColorMod"
)


fn set_texture_color_mod(texture: _Ptr[_Texture], r: UInt8, g: UInt8, b: UInt8) raises:
    """Set an additional color value multiplied into render copy operations."""
    if _set_texture_color_mod(texture, r, g, b) != 0:
        raise get_error()


var _set_texture_alpha_mod = _sdl.get_function[fn (_Ptr[_Texture], UInt8) -> Int](
    "SDL_SetTextureAlphaMod"
)


fn set_texture_alpha_mod(texture: _Ptr[_Texture], alpha: UInt8) raises:
    """Set an additional alpha value multiplied into render copy operations."""
    if _set_texture_alpha_mod(texture, alpha) != 0:
        raise get_error()


var _set_texture_blend_mode = _sdl.get_function[fn (_Ptr[_Texture], BlendMode) -> Int](
    "SDL_SetTextureBlendMode"
)


fn set_texture_blend_mode(texture: _Ptr[_Texture], blendmode: BlendMode) raises:
    """Set the scale mode used for texture scale operations."""
    if _set_texture_blend_mode(texture, blendmode) != 0:
        raise get_error()


var _set_texture_scale_mode = _sdl.get_function[fn (_Ptr[_Texture], ScaleMode) -> Int](
    "SDL_SetTextureScaleMode"
)


fn set_texture_scale_mode(texture: _Ptr[_Texture], scalemode: ScaleMode) raises:
    """Set the scale mode used for texture scale operations."""
    if _set_texture_scale_mode(texture, scalemode) != 0:
        raise get_error()


var _set_texture_user_data = _sdl.get_function[fn (_Ptr[_Texture], _Ptr[NoneType]) -> Int](
    "SDL_SetTextureUserData"
)


fn set_texture_user_data(texture: _Ptr[_Texture], userdata: _Ptr[NoneType]) raises:
    """Associate a user-specified pointer with a texture."""
    if _set_texture_user_data(texture, userdata) != 0:
        raise get_error()


var _update_texture = _sdl.get_function[
    fn (_Ptr[_Texture], _Ptr[Rect], _Ptr[NoneType], Int) -> Int
]("SDL_UpdateTexture")


fn update_texture(
    texture: _Ptr[_Texture],
    rect: _Ptr[Rect],
    pixels: _Ptr[NoneType],
    pitch: Int,
) raises:
    """Update the given texture rectangle with new pixel data."""
    if _update_texture(texture, rect, pixels, pitch) != 0:
        raise get_error()


var _update_nv_texture = _sdl.get_function[
    fn (
        _Ptr[_Texture],
        _Ptr[Rect],
        _Ptr[UInt8],
        Int,
        _Ptr[UInt8],
        Int,
    ) -> Int
]("SDL_UpdateNVTexture")


fn update_nv_texture(
    texture: _Ptr[_Texture],
    rect: _Ptr[Rect],
    y_plane: _Ptr[UInt8],
    y_pitch: Int,
    uv_plane: _Ptr[UInt8],
    uv_pitch: Int,
) raises:
    """Update a rectangle within a planar NV12 or NV21 texture with new pixels."""
    if _update_nv_texture(texture, rect, y_plane, y_pitch, uv_plane, uv_pitch) != 0:
        raise get_error()


var _update_yuv_texture = _sdl.get_function[
    fn (
        _Ptr[_Texture],
        _Ptr[Rect],
        _Ptr[UInt8],
        Int,
        _Ptr[UInt8],
        Int,
        _Ptr[UInt8],
        Int,
    ) -> Int
]("SDL_UpdateYUVTexture")


fn update_yuv_texture(
    texture: _Ptr[_Texture],
    rect: _Ptr[Rect],
    y_plane: _Ptr[UInt8],
    y_pitch: Int,
    u_plane: _Ptr[UInt8],
    u_pitch: Int,
    v_plane: _Ptr[UInt8],
    v_pitch: Int,
) raises:
    """Update a rectangle within a planar YV12 or IYUV texture with new pixel data."""
    if (
        _update_yuv_texture(texture, rect, y_plane, y_pitch, u_plane, u_pitch, v_plane, v_pitch)
        != 0
    ):
        raise get_error()
