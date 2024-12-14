"""Defines an SDL struct."""

from sys import DLHandle, os_is_macos, os_is_linux
from pathlib import Path
from collections import Optional
from .window import _Window, _GLContext
from .surface import _Surface
from .render import _Renderer
from .texture import _Texture
from .events import _Event
from .gfx import _GFX
from .img import _IMG
from .mix import _MIX
from .ttf import _TTF


trait AddonLib:
    fn __init__(inout self, error: SDL_Error):
        ...

    fn quit(self):
        ...


struct OptionalLib[LibType: AddonLib, error_msg: StringLiteral]:
    var _lib: LibType
    var _enabled: Bool

    fn __init__(inout self, none: None):
        self._lib = utils._uninit[LibType]()
        self._enabled = False

    fn __init__(inout self, error: SDL_Error):
        self._lib = LibType(error)
        self._enabled = True

    fn __bool__(self) -> Bool:
        return self._enabled

    fn __call__(self) raises -> ref [__lifetime_of(self)] LibType:
        """Unwrap the optional if possible, otherwise error."""

        @parameter
        if error.error_level > 0:
            if not self:
                raise error_msg
        return self._lib

    fn __del__(owned self):
        if self._enabled:
            self._lib.quit()


struct SDL:
    """Safe wrapper around sdl bindings."""

    # raw bindings
    var _sdl: _SDL

    # libraries
    var _gfx: OptionalLib[_GFX, "sdl_gfx is not enabled"]
    var _img: OptionalLib[_IMG, "sdl_img is not enabled"]
    var _mix: OptionalLib[_MIX, "sdl_mix is not enabled"]
    var _ttf: OptionalLib[_TTF, "sdl_ttf is not enabled"]

    fn __init__(
        inout self,
        timer: Bool = False,
        audio: Bool = False,
        video: Bool = False,
        joystick: Bool = False,
        haptic: Bool = False,
        gamecontroller: Bool = False,
        events: Bool = False,
        everything: Bool = False,
        gfx: Bool = False,
        img: Bool = False,
        mix: Bool = False,
        ttf: Bool = False,
    ) raises:
        """This initializes SDL bindings, and SDL itself.

        If you want to only initialize the bindings, use `_SDL`.
        """
        self._sdl = _SDL()
        self._gfx = None
        self._img = None
        self._mix = None
        self._ttf = None

        # x--- set window flags
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
        # flags |= 0x00100000 * no_parachute

        # x--- initialize sdl
        self._sdl.init(flags)

        if gfx:
            self.init_gfx()
        if img:
            self.init_img()
        if mix:
            self.init_mix()
        if ttf:
            self.init_ttf()

    fn init_gfx(inout self) raises:
        self._gfx = self._sdl.error

    fn init_img(inout self, jpeg: Bool = True, png: Bool = True, tif: Bool = False, webp: Bool = False) raises:
        self._img = self._sdl.error
        var flags: Int32 = 0
        flags |= 0x00000001 * jpeg
        flags |= 0x00000002 * png
        flags |= 0x00000004 * tif
        flags |= 0x00000008 * webp
        self._img._lib.init(flags)

    fn init_mix(inout self, frequency: Int32 = 44100, format: UInt16 = mix.sound.AUDIO_S16LSB, channels: Int32 = 2, chunksize: Int32 = 2048) raises:
        self._mix = self._sdl.error
        self._mix._lib.init(frequency, format, channels, chunksize)

    fn init_ttf(inout self) raises:
        self._ttf = self._sdl.error
        self._ttf._lib.init()

    fn __del__(owned self):
        self._sdl.quit()

    fn next_event(self) -> Optional[Event]:
        var event_ptr = Ptr[_Event].alloc(1)
        var result = Optional[Event](None)
        if self._sdl.poll_event(event_ptr) != 0:
            result = _Event.to_event(event_ptr)
        event_ptr.free()
        return result

    fn event_list(self) -> List[Event]:
        var l = List[Event]()
        var event_ptr = Ptr[_Event].alloc(1)
        while self._sdl.poll_event(event_ptr) != 0:
            l.append(_Event.to_event(event_ptr))
        event_ptr.free()
        return l


# TODO: This is so we dont have to carry around aliases to function types,
#       since __type_of currently doesnt work for this. Maybe this could
#       be taken further to abstract away the secondary functions as well,
#       but using variadic packs here doesnt work yet, so i'm not sure yet.
@register_passable("trivial")
struct SDL_Fn[name: String, T: AnyTrivialRegType]:
    var call: T

    @always_inline("nodebug")
    fn __init__(inout self, _handle: DLHandle):
        self.call = _handle.get_function[T](name)


struct _SDL:
    """Raw unsafe SDL Bindings."""

    # sdl handle
    var _handle: DLHandle

    # sdl error
    var error: SDL_Error

    # sdl bindings
    var _init: SDL_Fn["SDL_Init", fn (UInt32) -> IntC]
    var _quit: SDL_Fn["SDL_Quit", fn () -> NoneType]
    var _init_sub_system: SDL_Fn["SDL_InitSubSystem", fn (UInt32) -> IntC]
    var _quit_sub_system: SDL_Fn["SDL_QuitSubSystem", fn (UInt32) -> NoneType]

    # keyboard bindings
    var _get_keyboard_state: SDL_Fn["SDL_GetKeyboardState", fn (Ptr[IntC]) -> Ptr[UInt8]]

    # mouse bindings
    var _get_mouse_state: SDL_Fn["SDL_GetMouseState", fn (Ptr[IntC], Ptr[IntC]) -> UInt32]

    # event bindings
    var _poll_event: SDL_Fn["SDL_PollEvent", fn (Ptr[_Event]) -> IntC]

    # timer
    var _get_ticks: SDL_Fn["SDL_GetTicks", fn () -> UInt32]
    var _delay: SDL_Fn["SDL_Delay", fn (UInt32) -> NoneType]

    # window bindings
    var _create_window: SDL_Fn["SDL_CreateWindow", fn (Ptr[CharC], IntC, IntC, IntC, IntC, UInt32) -> Ptr[_Window]]
    var _create_shaped_window: SDL_Fn["SDL_CreateShapedWindow", fn (Ptr[CharC], UIntC, UIntC, UIntC, UIntC, UInt32) -> Ptr[_Window]]
    var _create_window_and_renderer: SDL_Fn["SDL_CreateWindowAndRenderer", fn (IntC, IntC, UInt32, Ptr[_Window], Ptr[_Renderer]) -> IntC]
    var _create_window_from: SDL_Fn["SDL_CreateWindowFrom", fn (Ptr[NoneType]) -> Ptr[_Window]]
    var _destroy_window_surface: SDL_Fn["SDL_DestroyWindowSurface", fn (Ptr[_Window]) -> IntC]
    var _destroy_window: SDL_Fn["SDL_DestroyWindow", fn (Ptr[_Window]) -> NoneType]
    var _is_shaped_window: SDL_Fn["SDL_IsShapedWindow", fn (Ptr[_Window]) -> BoolC]
    var _has_window_surface: SDL_Fn["SDL_HasWindowSurface", fn (Ptr[_Window]) -> BoolC]
    var _get_grabbed_window: SDL_Fn["SDL_GetGrabbedWindow", fn () -> Ptr[_Window]]
    # SDL_GetShapedWindowMode
    var _get_window_border_size: SDL_Fn["SDL_GetWindowBordersSize", fn (Ptr[_Window], Ptr[IntC], Ptr[IntC], Ptr[IntC], Ptr[IntC]) -> IntC]
    var _get_window_brightness: SDL_Fn["SDL_GetWindowBrightness", fn (Ptr[_Window]) -> Float32]
    var _get_window_gamma_ramp: SDL_Fn["SDL_GetWindowGammaRamp", fn (Ptr[_Window], Ptr[UInt16], Ptr[UInt16], Ptr[UInt16]) -> IntC]
    var _get_window_opacity: SDL_Fn["SDL_GetWindowOpacity", fn (Ptr[_Window], Ptr[Float32]) -> IntC]
    var _get_window_data: SDL_Fn["SDL_GetWindowData", fn (Ptr[_Window], Ptr[CharC]) -> Ptr[NoneType]]
    var _get_window_display_index: SDL_Fn["SDL_GetWindowDisplayIndex", fn (Ptr[_Window]) -> IntC]
    var _get_window_display_mode: SDL_Fn["SDL_GetWindowDisplayMode", fn (Ptr[_Window], Ptr[DisplayMode]) -> IntC]
    var _get_window_flags: SDL_Fn["SDL_GetWindowFlags", fn (Ptr[_Window]) -> UInt32]
    var _get_window_from_id: SDL_Fn["SDL_GetWindowFromID", fn (UInt32) -> Ptr[_Window]]
    var _get_window_grab: SDL_Fn["SDL_GetWindowGrab", fn (Ptr[_Window]) -> BoolC]
    # SDL_GetWindowICCProfile
    var _get_window_id: SDL_Fn["SDL_GetWindowID", fn (Ptr[_Window]) -> UInt32]
    var _get_window_keyboard_grab: SDL_Fn["SDL_GetWindowKeyboardGrab", fn (Ptr[_Window]) -> BoolC]
    var _get_window_mouse_grab: SDL_Fn["SDL_GetWindowMouseGrab", fn (Ptr[_Window]) -> BoolC]
    var _get_window_maximum_size: SDL_Fn["SDL_GetWindowMaximumSize", fn (Ptr[_Window], Ptr[IntC], Ptr[IntC]) -> NoneType]
    var _get_window_minimum_size: SDL_Fn["SDL_GetWindowMinimumSize", fn (Ptr[_Window], Ptr[IntC], Ptr[IntC]) -> NoneType]
    var _get_window_mouse_rect: SDL_Fn["SDL_GetWindowMouseRect", fn (Ptr[_Window]) -> Ptr[Rect]]
    var _get_window_pixel_format: SDL_Fn["SDL_GetWindowPixelFormat", fn (Ptr[_Window]) -> UInt32]
    var _get_window_title: SDL_Fn["SDL_GetWindowTitle", fn (Ptr[_Window]) -> Ptr[CharC]]
    var _get_window_position: SDL_Fn["SDL_GetWindowPosition", fn (Ptr[_Window], Ptr[IntC], Ptr[IntC]) -> NoneType]
    var _get_window_size: SDL_Fn["SDL_GetWindowSize", fn (Ptr[_Window], Ptr[IntC], Ptr[IntC]) -> NoneType]
    var _get_window_size_in_pixels: SDL_Fn["SDL_GetWindowSizeInPixels", fn (Ptr[_Window], Ptr[IntC], Ptr[IntC]) -> NoneType]
    # # SDL_GetWindowWMInfo
    var _get_window_surface: SDL_Fn["SDL_GetWindowSurface", fn (Ptr[_Window]) -> Ptr[_Surface]]
    var _get_renderer: SDL_Fn["SDL_GetRenderer", fn (Ptr[_Window]) -> Ptr[_Renderer]]
    var _set_window_always_on_top: SDL_Fn["SDL_SetWindowAlwaysOnTop", fn (Ptr[_Window], BoolC) -> NoneType]
    var _set_window_bordered: SDL_Fn["SDL_SetWindowBordered", fn (Ptr[_Window], BoolC) -> NoneType]
    var _set_window_brightness: SDL_Fn["SDL_SetWindowBrightness", fn (Ptr[_Window], Float32) -> IntC]
    var _set_window_gamma_ramp: SDL_Fn["SDL_SetWindowGammaRamp", fn (Ptr[_Window], Ptr[UInt16], Ptr[UInt16], Ptr[UInt16]) -> IntC]
    var _set_window_opacity: SDL_Fn["SDL_SetWindowOpacity", fn (Ptr[_Window], Float32) -> IntC]
    var _set_window_data: SDL_Fn["SDL_SetWindowData", fn (Ptr[_Window], Ptr[CharC], Ptr[NoneType]) -> Ptr[NoneType]]
    var _set_window_display_mode: SDL_Fn["SDL_SetWindowDisplayMode", fn (Ptr[_Window], Ptr[DisplayMode]) -> IntC]
    var _set_window_fullscreen: SDL_Fn["SDL_SetWindowFullscreen", fn (Ptr[_Window], UInt32) -> IntC]
    var _set_window_grab: SDL_Fn["SDL_SetWindowGrab", fn (Ptr[_Window], BoolC) -> NoneType]
    # SDL_SetWindowHitTest
    var _set_window_icon: SDL_Fn["SDL_SetWindowIcon", fn (Ptr[_Window], Ptr[_Surface]) -> NoneType]
    var _set_window_input_focus: SDL_Fn["SDL_SetWindowInputFocus", fn (Ptr[_Window]) -> IntC]
    var _set_window_keyboard_grab: SDL_Fn["SDL_SetWindowKeyboardGrab", fn (Ptr[_Window], BoolC) -> NoneType]
    var _set_window_mouse_grab: SDL_Fn["SDL_SetWindowMouseGrab", fn (Ptr[_Window], BoolC) -> NoneType]
    var _set_window_maximum_size: SDL_Fn["SDL_SetWindowMaximumSize", fn (Ptr[_Window], IntC, IntC) -> NoneType]
    var _set_window_minimum_size: SDL_Fn["SDL_SetWindowMinimumSize", fn (Ptr[_Window], IntC, IntC) -> NoneType]
    var _set_window_modal_for: SDL_Fn["SDL_SetWindowModalFor", fn (Ptr[_Window], Ptr[_Window]) -> IntC]
    var _set_window_mouse_rect: SDL_Fn["SDL_SetWindowMouseRect", fn (Ptr[_Window], Ptr[Rect]) -> IntC]
    var _set_window_position: SDL_Fn["SDL_SetWindowPosition", fn (Ptr[_Window], IntC, IntC) -> NoneType]
    var _set_window_resizable: SDL_Fn["SDL_SetWindowResizable", fn (Ptr[_Window], BoolC) -> NoneType]
    var _set_window_size: SDL_Fn["SDL_SetWindowSize", fn (Ptr[_Window], IntC, IntC) -> NoneType]
    # SDL_SetWindowsMessageHook
    # SDL_SetWindowShape
    var _set_window_title: SDL_Fn["SDL_SetWindowTitle", fn (Ptr[_Window], Ptr[CharC]) -> NoneType]
    # # SDL_GL_GetCurrentWindow
    # # SDL_GL_SwapWindow
    var _update_window_surface: SDL_Fn["SDL_UpdateWindowSurface", fn (Ptr[_Window]) -> IntC]
    var _update_window_surface_rects: SDL_Fn["SDL_UpdateWindowSurfaceRects", fn (Ptr[_Window], Ptr[Rect], IntC) -> IntC]
    var _show_window: SDL_Fn["SDL_ShowWindow", fn (Ptr[_Window]) -> NoneType]
    var _hide_window: SDL_Fn["SDL_HideWindow", fn (Ptr[_Window]) -> NoneType]
    var _maximize_window: SDL_Fn["SDL_MaximizeWindow", fn (Ptr[_Window]) -> NoneType]
    var _minimize_window: SDL_Fn["SDL_MinimizeWindow", fn (Ptr[_Window]) -> NoneType]
    var _flash_window: SDL_Fn["SDL_FlashWindow", fn (Ptr[_Window], FlashOperation) -> IntC]
    var _raise_window: SDL_Fn["SDL_RaiseWindow", fn (Ptr[_Window]) -> NoneType]
    var _restore_window: SDL_Fn["SDL_RestoreWindow", fn (Ptr[_Window]) -> NoneType]
    var _warp_mouse_in_window: SDL_Fn["SDL_WarpMouseInWindow", fn (Ptr[_Window], IntC, IntC) -> NoneType]

    # surface bindings
    var _create_rgb_surface: SDL_Fn["SDL_CreateRGBSurface", fn (UInt32, IntC, IntC, IntC, UInt32, UInt32, UInt32, UInt32) -> Ptr[_Surface]]
    var _create_rgb_surface_from: SDL_Fn["SDL_CreateRGBSurfaceFrom", fn (Ptr[NoneType], IntC, IntC, IntC, IntC, UInt32, UInt32, UInt32, UInt32) -> Ptr[_Surface]]
    var _create_rgb_surface_with_format: SDL_Fn["SDL_CreateRGBSurfaceWithFormat", fn (UInt32, IntC, IntC, IntC, UInt32) -> Ptr[_Surface]]
    var _create_rgb_surface_with_format_from: SDL_Fn["SDL_CreateRGBSurfaceWithFormatFrom", fn (Ptr[NoneType], IntC, IntC, IntC, IntC, UInt32) -> Ptr[_Surface]]
    var _free_surface: SDL_Fn["SDL_FreeSurface", fn (Ptr[_Surface]) -> None]
    var _convert_surface: SDL_Fn["SDL_ConvertSurface", fn (Ptr[_Surface], Ptr[SurfacePixelFormat], UInt32) -> Ptr[_Surface]]
    var _convert_surface_format: SDL_Fn["SDL_ConvertSurfaceFormat", fn (Ptr[_Surface], UInt32, UInt32) -> Ptr[_Surface]]
    var _has_surface_rle: SDL_Fn["SDL_HasSurfaceRLE", fn (Ptr[_Surface]) -> BoolC]
    var _get_surface_color_mod: SDL_Fn["SDL_GetSurfaceColorMod", fn (Ptr[_Surface], Ptr[UInt8], Ptr[UInt8], Ptr[UInt8]) -> IntC]
    var _get_surface_alpha_mod: SDL_Fn["SDL_GetSurfaceAlphaMod", fn (Ptr[_Surface], Ptr[UInt8]) -> IntC]
    var _get_surface_blend_mode: SDL_Fn["SDL_GetSurfaceBlendMode", fn (Ptr[_Surface], Ptr[BlendMode]) -> IntC]
    var _set_surface_color_mod: SDL_Fn["SDL_SetSurfaceColorMod", fn (Ptr[_Surface], UInt8, UInt8, UInt8) -> IntC]
    var _set_surface_alpha_mod: SDL_Fn["SDL_SetSurfaceAlphaMod", fn (Ptr[_Surface], UInt8) -> IntC]
    var _set_surface_blend_mode: SDL_Fn["SDL_SetSurfaceBlendMode", fn (Ptr[_Surface], BlendMode) -> IntC]
    var _set_surface_palette: SDL_Fn["SDL_SetSurfacePalette", fn (Ptr[_Surface], Ptr[Palette]) -> IntC]
    var _set_surface_rle: SDL_Fn["SDL_SetSurfaceRLE", fn (Ptr[_Surface], IntC) -> IntC]
    var _fill_rect: SDL_Fn["SDL_FillRect", fn (Ptr[_Surface], Ptr[Rect], UInt32) -> IntC]
    var _fill_rects: SDL_Fn["SDL_FillRects", fn (Ptr[_Surface], Ptr[Rect], IntC, UInt32) -> IntC]
    var _lock_surface: SDL_Fn["SDL_LockSurface", fn (Ptr[_Surface]) -> IntC]
    var _unlock_surface: SDL_Fn["SDL_UnlockSurface", fn (Ptr[_Surface]) -> NoneType]
    var _lower_blit: SDL_Fn["SDL_LowerBlit", fn (Ptr[_Surface], Ptr[Rect], Ptr[_Surface], Ptr[Rect]) -> IntC]
    var _lower_blit_scaled: SDL_Fn["SDL_LowerBlitScaled", fn (Ptr[_Surface], Ptr[Rect], Ptr[_Surface], Ptr[Rect]) -> IntC]
    var _upper_blit: SDL_Fn["SDL_UpperBlit", fn (Ptr[_Surface], Ptr[Rect], Ptr[_Surface], Ptr[Rect]) -> IntC]
    var _upper_blit_scaled: SDL_Fn["SDL_UpperBlitScaled", fn (Ptr[_Surface], Ptr[Rect], Ptr[_Surface], Ptr[Rect]) -> IntC]

    # renderer bindings
    var _create_renderer: SDL_Fn["SDL_CreateRenderer", fn (Ptr[_Window], IntC, UInt32) -> Ptr[_Renderer]]
    var _create_software_renderer: SDL_Fn["SDL_CreateSoftwareRenderer", fn (Ptr[_Surface]) -> Ptr[_Renderer]]
    var _destroy_renderer: SDL_Fn["SDL_DestroyRenderer", fn (Ptr[_Renderer]) -> None]
    var _render_clear: SDL_Fn["SDL_RenderClear", fn (Ptr[_Renderer]) -> IntC]
    var _render_present: SDL_Fn["SDL_RenderPresent", fn (Ptr[_Renderer]) -> None]
    var _render_get_window: SDL_Fn["SDL_RenderGetWindow", fn (Ptr[_Renderer]) -> Ptr[_Window]]
    var _set_render_target: SDL_Fn["SDL_SetRenderTarget", fn (Ptr[_Renderer], Ptr[_Texture]) -> IntC]
    var _set_render_draw_color: SDL_Fn["SDL_SetRenderDrawColor", fn (Ptr[_Renderer], UInt8, UInt8, UInt8, UInt8) -> IntC]
    var _set_render_draw_blend_mode: SDL_Fn["SDL_SetRenderDrawBlendMode", fn (Ptr[_Renderer], BlendMode) -> IntC]
    var _get_render_draw_color: SDL_Fn["SDL_GetRenderDrawColor", fn (Ptr[_Renderer], Ptr[UInt8], Ptr[UInt8], Ptr[UInt8], Ptr[UInt8]) -> IntC]
    var _get_render_draw_blend_mode: SDL_Fn["SDL_GetRenderDrawBlendMode", fn (Ptr[_Renderer], Ptr[BlendMode]) -> IntC]
    var _get_renderer_info: SDL_Fn["SDL_GetRendererInfo", fn (Ptr[_Renderer], Ptr[RendererInfo]) -> IntC]
    var _get_renderer_output_size: SDL_Fn["SDL_GetRendererOutputSize", fn (Ptr[_Renderer], Ptr[IntC], Ptr[IntC]) -> IntC]
    var _get_render_target: SDL_Fn["SDL_GetRenderTarget", fn (Ptr[_Renderer]) -> Ptr[_Texture]]
    var _get_num_render_drivers: SDL_Fn["SDL_GetNumRenderDrivers", fn () -> IntC]
    var _get_render_driver_info: SDL_Fn["SDL_GetRenderDriverInfo", fn (IntC, Ptr[RendererInfo]) -> IntC]
    var _render_copy: SDL_Fn["SDL_RenderCopy", fn (Ptr[_Renderer], Ptr[_Texture], Ptr[Rect], Ptr[Rect]) -> IntC]
    var _render_copy_f: SDL_Fn["SDL_RenderCopyF", fn (Ptr[_Renderer], Ptr[_Texture], Ptr[Rect], Ptr[FRect]) -> IntC]
    var _render_copy_ex: SDL_Fn["SDL_RenderCopyEx", fn (Ptr[_Renderer], Ptr[_Texture], Ptr[Rect], Ptr[Rect], Float64, Ptr[Point], RendererFlip) -> IntC]
    var _render_copy_exf: SDL_Fn["SDL_RenderCopyExF", fn (Ptr[_Renderer], Ptr[_Texture], Ptr[Rect], Ptr[FRect], Float64, Ptr[FPoint], RendererFlip) -> IntC]
    var _render_draw_line: SDL_Fn["SDL_RenderDrawLine", fn (Ptr[_Renderer], IntC, IntC, IntC, IntC) -> IntC]
    var _render_draw_line_f: SDL_Fn["SDL_RenderDrawLineF", fn (Ptr[_Renderer], Float32, Float32, Float32, Float32) -> IntC]
    var _render_draw_lines: SDL_Fn["SDL_RenderDrawLines", fn (Ptr[_Renderer], Ptr[Point], IntC) -> IntC]
    var _render_draw_lines_f: SDL_Fn["SDL_RenderDrawLinesF", fn (Ptr[_Renderer], Ptr[FPoint], IntC) -> IntC]
    var _render_draw_point: SDL_Fn["SDL_RenderDrawPoint", fn (Ptr[_Renderer], IntC, IntC) -> IntC]
    var _render_draw_point_f: SDL_Fn["SDL_RenderDrawPointF", fn (Ptr[_Renderer], Float32, Float32) -> IntC]
    var _render_draw_points: SDL_Fn["SDL_RenderDrawPoints", fn (Ptr[_Renderer], Ptr[Point], IntC) -> IntC]
    var _render_draw_points_f: SDL_Fn["SDL_RenderDrawPointsF", fn (Ptr[_Renderer], Ptr[FPoint], IntC) -> IntC]
    var _render_draw_rect: SDL_Fn["SDL_RenderDrawRect", fn (Ptr[_Renderer], Rect) -> IntC]
    var _render_draw_rect_f: SDL_Fn["SDL_RenderDrawRectF", fn (Ptr[_Renderer], FRect) -> IntC]
    var _render_draw_rects: SDL_Fn["SDL_RenderDrawRects", fn (Ptr[_Renderer], Ptr[Rect], IntC) -> IntC]
    var _render_draw_rects_f: SDL_Fn["SDL_RenderDrawRectsF", fn (Ptr[_Renderer], Ptr[FRect], IntC) -> IntC]
    var _render_fill_rect: SDL_Fn["SDL_RenderFillRect", fn (Ptr[_Renderer], Rect) -> IntC]
    var _render_fill_rect_f: SDL_Fn["SDL_RenderFillRectF", fn (Ptr[_Renderer], FRect) -> IntC]
    var _render_fill_rects: SDL_Fn["SDL_RenderFillRects", fn (Ptr[_Renderer], Ptr[Rect], IntC) -> IntC]
    var _render_fill_rects_f: SDL_Fn["SDL_RenderFillRectsF", fn (Ptr[_Renderer], Ptr[FRect], IntC) -> IntC]
    var _render_flush: SDL_Fn["SDL_RenderFlush", fn (Ptr[_Renderer]) -> IntC]
    var _render_geometry: SDL_Fn["SDL_RenderGeometry", fn (Ptr[_Renderer], Ptr[_Texture], Ptr[Vertex], IntC, Ptr[IntC], IntC) -> IntC]
    var _render_geometry_raw: SDL_Fn["SDL_RenderGeometryRaw", fn (Ptr[_Renderer], Ptr[_Texture], Ptr[Float32], IntC, Ptr[Color], IntC, Ptr[Float32], IntC, IntC, Ptr[NoneType], IntC, IntC) -> IntC]
    var _render_get_clip_rect: SDL_Fn["SDL_RenderGetClipRect", fn (Ptr[_Renderer], Ptr[Rect]) -> NoneType]
    var _render_get_integer_scale: SDL_Fn["SDL_RenderGetIntegerScale", fn (Ptr[_Renderer]) -> BoolC]
    var _render_get_logical_size: SDL_Fn["SDL_RenderGetLogicalSize", fn (Ptr[_Renderer], Ptr[IntC], Ptr[IntC]) -> NoneType]
    var _render_get_metal_command_encoder: SDL_Fn["SDL_RenderGetMetalCommandEncoder", fn (Ptr[_Renderer]) -> Ptr[NoneType]]
    var _render_get_metal_layer: SDL_Fn["SDL_RenderGetMetalLayer", fn (Ptr[_Renderer]) -> Ptr[NoneType]]
    var _render_get_scale: SDL_Fn["SDL_RenderGetScale", fn (Ptr[_Renderer], Ptr[IntC], Ptr[IntC]) -> NoneType]
    var _render_get_viewport: SDL_Fn["SDL_RenderGetViewport", fn (Ptr[_Renderer], Ptr[Rect]) -> NoneType]
    var _render_is_clip_enabled: SDL_Fn["SDL_RenderIsClipEnabled", fn (Ptr[_Renderer]) -> BoolC]
    var _render_logical_to_window: SDL_Fn["SDL_RenderLogicalToWindow", fn (Ptr[_Renderer], Float32, Float32, Ptr[IntC], Ptr[IntC]) -> NoneType]
    var _render_read_pixels: SDL_Fn["SDL_RenderReadPixels", fn (Ptr[_Renderer], Ptr[Rect], UInt32, Ptr[NoneType], IntC) -> IntC]
    var _render_set_clip_rect: SDL_Fn["SDL_RenderSetClipRect", fn (Ptr[_Renderer], Ptr[Rect]) -> IntC]
    var _render_set_integer_scale: SDL_Fn["SDL_RenderSetIntegerScale", fn (Ptr[_Renderer], BoolC) -> IntC]
    var _render_set_logical_size: SDL_Fn["SDL_RenderSetLogicalSize", fn (Ptr[_Renderer], IntC, IntC) -> IntC]
    var _render_set_scale: SDL_Fn["SDL_RenderSetScale", fn (Ptr[_Renderer], Float32, Float32) -> IntC]
    var _render_set_viewport: SDL_Fn["SDL_RenderSetViewport", fn (Ptr[_Renderer], Ptr[Rect]) -> IntC]
    var _render_set_vsync: SDL_Fn["SDL_RenderSetVSync", fn (Ptr[_Renderer], IntC) -> IntC]
    var _render_target_supported: SDL_Fn["SDL_RenderTargetSupported", fn (Ptr[_Renderer]) -> BoolC]
    var _render_window_to_logical: SDL_Fn["SDL_RenderWindowToLogical", fn (Ptr[_Renderer], IntC, IntC, Ptr[Float32], Ptr[Float32]) -> NoneType]

    # texture bindings
    var _create_texture: SDL_Fn["SDL_CreateTexture", fn (Ptr[_Renderer], UInt32, IntC, IntC, IntC) -> Ptr[_Texture]]
    var _create_texture_from_surface: SDL_Fn["SDL_CreateTextureFromSurface", fn (Ptr[_Renderer], Ptr[_Surface]) -> Ptr[_Texture]]
    var _destroy_texture: SDL_Fn["SDL_DestroyTexture", fn (Ptr[_Texture]) -> NoneType]
    var _gl_bind_texture: SDL_Fn["SDL_GL_BindTexture", fn (Ptr[_Texture], Ptr[Float32], Ptr[Float32]) -> IntC]
    var _gl_unbind_texture: SDL_Fn["SDL_GL_UnbindTexture", fn (Ptr[_Texture]) -> IntC]
    var _lock_texture: SDL_Fn["SDL_LockTexture", fn (Ptr[_Texture], Ptr[Rect], Ptr[Ptr[NoneType]], Ptr[IntC]) -> IntC]
    var _lock_texture_to_surface: SDL_Fn["SDL_LockTextureToSurface", fn (Ptr[_Texture], Ptr[Rect], Ptr[Ptr[_Surface]]) -> IntC]
    var _unlock_texture: SDL_Fn["SDL_UnlockTexture", fn (Ptr[_Texture]) -> NoneType]
    var _query_texture: SDL_Fn["SDL_QueryTexture", fn (Ptr[_Texture], Ptr[UInt32], Ptr[IntC], Ptr[IntC], Ptr[IntC]) -> IntC]
    var _get_texture_color_mod: SDL_Fn["SDL_GetTextureColorMod", fn (Ptr[_Texture], Ptr[UInt8], Ptr[UInt8], Ptr[UInt8]) -> IntC]
    var _get_texture_alpha_mod: SDL_Fn["SDL_GetTextureAlphaMod", fn (Ptr[_Texture], Ptr[UInt8]) -> IntC]
    var _get_texture_blend_mode: SDL_Fn["SDL_GetTextureBlendMode", fn (Ptr[_Texture], Ptr[BlendMode]) -> IntC]
    var _get_texture_scale_mode: SDL_Fn["SDL_GetTextureScaleMode", fn (Ptr[_Texture], Ptr[ScaleMode]) -> IntC]
    var _get_texture_user_data: SDL_Fn["SDL_GetTextureUserData", fn (Ptr[_Texture]) -> Ptr[NoneType]]
    var _set_texture_color_mod: SDL_Fn["SDL_SetTextureColorMod", fn (Ptr[_Texture], UInt8, UInt8, UInt8) -> IntC]
    var _set_texture_alpha_mod: SDL_Fn["SDL_SetTextureAlphaMod", fn (Ptr[_Texture], UInt8) -> IntC]
    var _set_texture_blend_mode: SDL_Fn["SDL_SetTextureBlendMode", fn (Ptr[_Texture], BlendMode) -> IntC]
    var _set_texture_scale_mode: SDL_Fn["SDL_SetTextureScaleMode", fn (Ptr[_Texture], ScaleMode) -> IntC]
    var _set_texture_user_data: SDL_Fn["SDL_SetTextureUserData", fn (Ptr[_Texture], Ptr[NoneType]) -> IntC]
    var _update_texture: SDL_Fn["SDL_UpdateTexture", fn (Ptr[_Texture], Ptr[Rect], Ptr[NoneType], IntC) -> IntC]
    var _update_nv_texture: SDL_Fn["SDL_UpdateNVTexture", fn (Ptr[_Texture], Ptr[Rect], Ptr[UInt8], IntC, Ptr[UInt8], IntC) -> IntC]
    var _update_yuv_texture: SDL_Fn["SDL_UpdateYUVTexture", fn (Ptr[_Texture], Ptr[Rect], Ptr[UInt8], IntC, Ptr[UInt8], IntC, Ptr[UInt8], IntC) -> IntC]

    # opengl
    var _gl_create_context: SDL_Fn["SDL_GL_CreateContext", fn (Ptr[_Window]) -> Ptr[_GLContext]]
    var _gl_delete_context: SDL_Fn["SDL_GL_DeleteContext", fn (Ptr[_GLContext]) -> None]

    fn __init__(inout self) raises:
        # x--- initialize sdl bindings
        @parameter
        if os_is_macos():
            self._handle = DLHandle(".magic/envs/default/lib/libSDL2.dylib")
        elif os_is_linux():
            self._handle = DLHandle(".magic/envs/default/lib/libSDL2.so")
        else:
            constrained[False, "OS is not supported"]()
            self._handle = utils._uninit[DLHandle]()

        self._init = self._handle
        self._quit = self._handle
        self._init_sub_system = self._handle
        self._quit_sub_system = self._handle

        # x--- initialize sdl error
        self.error = self._handle

        # x--- initialize keyboard bindings
        self._get_keyboard_state = self._handle

        # x--- initialize mouse bindings
        self._get_mouse_state = self._handle

        # x--- initialize event bindings
        self._poll_event = self._handle

        # x--- initialize timer
        self._get_ticks = self._handle
        self._delay = self._handle

        # x--- initialize window bindings
        self._create_window = self._handle
        self._create_shaped_window = self._handle
        self._create_window_and_renderer = self._handle
        self._create_window_from = self._handle
        self._destroy_window_surface = self._handle
        self._destroy_window = self._handle
        self._is_shaped_window = self._handle
        self._has_window_surface = self._handle
        self._get_grabbed_window = self._handle
        # SDL_GetShapedWindowMode
        self._get_window_border_size = self._handle
        self._get_window_brightness = self._handle
        self._get_window_gamma_ramp = self._handle
        self._get_window_opacity = self._handle
        self._get_window_data = self._handle
        self._get_window_display_index = self._handle
        self._get_window_display_mode = self._handle
        self._get_window_flags = self._handle
        self._get_window_from_id = self._handle
        self._get_window_grab = self._handle
        # SDL_GetWindowICCProfile
        self._get_window_id = self._handle
        self._get_window_keyboard_grab = self._handle
        self._get_window_mouse_grab = self._handle
        self._get_window_maximum_size = self._handle
        self._get_window_minimum_size = self._handle
        self._get_window_mouse_rect = self._handle
        self._get_window_pixel_format = self._handle
        self._get_window_title = self._handle
        self._get_window_position = self._handle
        self._get_window_size = self._handle
        self._get_window_size_in_pixels = self._handle
        # # SDL_GetWindowWMInfo
        self._get_window_surface = self._handle
        self._get_renderer = self._handle
        self._set_window_always_on_top = self._handle
        self._set_window_bordered = self._handle
        self._set_window_brightness = self._handle
        self._set_window_gamma_ramp = self._handle
        self._set_window_opacity = self._handle
        self._set_window_data = self._handle
        self._set_window_display_mode = self._handle
        self._set_window_fullscreen = self._handle
        self._set_window_grab = self._handle
        # SDL_SetWindowHitTest
        self._set_window_icon = self._handle
        self._set_window_input_focus = self._handle
        self._set_window_keyboard_grab = self._handle
        self._set_window_mouse_grab = self._handle
        self._set_window_maximum_size = self._handle
        self._set_window_minimum_size = self._handle
        self._set_window_modal_for = self._handle
        self._set_window_mouse_rect = self._handle
        self._set_window_position = self._handle
        self._set_window_resizable = self._handle
        self._set_window_size = self._handle
        # SDL_SetWindowsMessageHook
        # SDL_SetWindowShape
        self._set_window_title = self._handle
        # # SDL_GL_GetCurrentWindow
        # # SDL_GL_SwapWindow
        self._update_window_surface = self._handle
        self._update_window_surface_rects = self._handle
        self._show_window = self._handle
        self._hide_window = self._handle
        self._maximize_window = self._handle
        self._minimize_window = self._handle
        self._flash_window = self._handle
        self._raise_window = self._handle
        self._restore_window = self._handle
        self._warp_mouse_in_window = self._handle

        # x--- initialize surface bindings
        self._create_rgb_surface = self._handle
        self._create_rgb_surface_from = self._handle
        self._create_rgb_surface_with_format = self._handle
        self._create_rgb_surface_with_format_from = self._handle
        self._free_surface = self._handle
        self._convert_surface = self._handle
        self._convert_surface_format = self._handle
        self._has_surface_rle = self._handle
        self._get_surface_color_mod = self._handle
        self._get_surface_alpha_mod = self._handle
        self._get_surface_blend_mode = self._handle
        self._set_surface_color_mod = self._handle
        self._set_surface_alpha_mod = self._handle
        self._set_surface_blend_mode = self._handle
        self._set_surface_palette = self._handle
        self._set_surface_rle = self._handle
        self._fill_rect = self._handle
        self._fill_rects = self._handle
        self._lock_surface = self._handle
        self._unlock_surface = self._handle
        self._lower_blit = self._handle
        self._lower_blit_scaled = self._handle
        self._upper_blit = self._handle
        self._upper_blit_scaled = self._handle

        # x--- initialize renderer bindings
        self._create_renderer = self._handle
        self._create_software_renderer = self._handle
        self._destroy_renderer = self._handle
        self._render_clear = self._handle
        self._render_present = self._handle
        self._render_get_window = self._handle
        self._set_render_target = self._handle
        self._set_render_draw_color = self._handle
        self._set_render_draw_blend_mode = self._handle
        self._get_render_draw_color = self._handle
        self._get_render_draw_blend_mode = self._handle
        self._get_renderer_info = self._handle
        self._get_renderer_output_size = self._handle
        self._get_render_target = self._handle
        self._get_num_render_drivers = self._handle
        self._get_render_driver_info = self._handle
        self._render_copy = self._handle
        self._render_copy_f = self._handle
        self._render_copy_ex = self._handle
        self._render_copy_exf = self._handle
        self._render_draw_line = self._handle
        self._render_draw_line_f = self._handle
        self._render_draw_lines = self._handle
        self._render_draw_lines_f = self._handle
        self._render_draw_point = self._handle
        self._render_draw_point_f = self._handle
        self._render_draw_points = self._handle
        self._render_draw_points_f = self._handle
        self._render_draw_rect = self._handle
        self._render_draw_rect_f = self._handle
        self._render_draw_rects = self._handle
        self._render_draw_rects_f = self._handle
        self._render_fill_rect = self._handle
        self._render_fill_rect_f = self._handle
        self._render_fill_rects = self._handle
        self._render_fill_rects_f = self._handle
        self._render_flush = self._handle
        self._render_geometry = self._handle
        self._render_geometry_raw = self._handle
        self._render_get_clip_rect = self._handle
        self._render_get_integer_scale = self._handle
        self._render_get_logical_size = self._handle
        self._render_get_metal_command_encoder = self._handle
        self._render_get_metal_layer = self._handle
        self._render_get_scale = self._handle
        self._render_get_viewport = self._handle
        self._render_is_clip_enabled = self._handle
        self._render_logical_to_window = self._handle
        self._render_read_pixels = self._handle
        self._render_set_clip_rect = self._handle
        self._render_set_integer_scale = self._handle
        self._render_set_logical_size = self._handle
        self._render_set_scale = self._handle
        self._render_set_viewport = self._handle
        self._render_set_vsync = self._handle
        self._render_target_supported = self._handle
        self._render_window_to_logical = self._handle

        # x--- initialize texture bindings
        self._create_texture = self._handle
        self._create_texture_from_surface = self._handle
        self._destroy_texture = self._handle
        self._gl_bind_texture = self._handle
        self._gl_unbind_texture = self._handle
        self._lock_texture = self._handle
        self._lock_texture_to_surface = self._handle
        self._unlock_texture = self._handle
        self._query_texture = self._handle
        self._get_texture_color_mod = self._handle
        self._get_texture_alpha_mod = self._handle
        self._get_texture_blend_mode = self._handle
        self._get_texture_scale_mode = self._handle
        self._get_texture_user_data = self._handle
        self._set_texture_color_mod = self._handle
        self._set_texture_alpha_mod = self._handle
        self._set_texture_blend_mode = self._handle
        self._set_texture_scale_mode = self._handle
        self._set_texture_user_data = self._handle
        self._update_texture = self._handle
        self._update_nv_texture = self._handle
        self._update_yuv_texture = self._handle

        # x--- initialize opengl
        self._gl_create_context = self._handle
        self._gl_delete_context = self._handle

    # TODO: These could be generated automatically, but
    #       im still looking for a nice way. Then these
    #       could be made more private and parametrically
    #       use the raising version if desired.

    # +--- sdl functions

    @always_inline
    fn init(self, flags: UInt32) raises:
        self.error.if_code(self._init.call(flags), "Could not initialize SDL")

    @always_inline
    fn quit(self):
        self._quit.call()

    @always_inline
    fn init_sub_system(self, flags: UInt32) raises:
        """Compatibility function to initialize the SDL library."""
        self.error.if_code(self._init_sub_system.call(flags), "Could not initialize sub-system")

    @always_inline
    fn quit_sub_system(self, flags: UInt32):
        """Shut down specific SDL subsystems."""
        self._quit_sub_system.call(flags)

    # +--- keyboard functions

    @always_inline
    fn get_keyboard_state(self, numkeys: Ptr[IntC]) -> Ptr[UInt8]:
        """Get a snapshot of the current state of the keyboard."""
        return self._get_keyboard_state.call(numkeys)

    # +--- keyboard functions

    @always_inline
    fn get_mouse_state(self, x: Ptr[IntC], y: Ptr[IntC]) -> UInt32:
        """Retrieve the current state of the mouse."""
        return self._get_mouse_state.call(x, y)

    # +--- event functions

    @always_inline
    fn poll_event(self, event: Ptr[_Event]) -> IntC:
        """Poll for currently pending events."""
        return self._poll_event.call(event)

    # +--- timer functions

    @always_inline
    fn get_ticks(self) -> UInt32:
        """Get the number of milliseconds since SDL library initialization."""
        return self._get_ticks.call()

    @always_inline
    fn delay(self, ms: UInt32):
        """Wait a specified number of milliseconds before returning."""
        self._delay.call(ms)

    # +--- window functions

    @always_inline
    fn create_window(self, title: Ptr[CharC], x: IntC, y: IntC, w: IntC, h: IntC, flags: UInt32) raises -> Ptr[_Window]:
        """Create a window with the specified position, dimensions, and flags."""
        return self.error.if_null(self._create_window.call(title, x, y, w, h, flags), "Could not create window")

    @always_inline
    fn create_shaped_window(self, title: Ptr[CharC], x: UIntC, y: UIntC, w: UIntC, h: UIntC, flags: UInt32) raises -> Ptr[_Window]:
        """Create a window that can be shaped with the specified position, dimensions, and flags."""
        return self.error.if_null(self._create_shaped_window.call(title, x, y, w, h, flags), "Could not create shaped window")

    @always_inline
    fn create_window_and_renderer(self, width: IntC, height: IntC, window_flags: UInt32, window: Ptr[_Window], renderer: Ptr[_Renderer]) raises:
        """Create a window and default renderer."""
        self.error.if_code(self._create_window_and_renderer.call(width, height, window_flags, window, renderer), "Could not create window and renderer")

    @always_inline
    fn create_window_from(self, data: Ptr[NoneType]) raises -> Ptr[_Window]:
        """Create an SDL window from an existing native window."""
        return self.error.if_null(self._create_window_from.call(data), "Could not create window from")

    @always_inline
    fn destroy_window(self, window: Ptr[_Window]):
        """Destroy a window."""
        self._destroy_window.call(window)

    @always_inline
    fn destroy_window_surface(self, window: Ptr[_Window]) raises:
        """Destroy the surface associated with the window."""
        self.error.if_code(self._destroy_window_surface.call(window), "Could not destroy window surface")

    @always_inline
    fn get_window_surface(self, window: Ptr[_Window]) raises -> Ptr[_Surface]:
        """Get the SDL surface associated with the window."""
        return self.error.if_null(self._get_window_surface.call(window), "Could not get surface")

    @always_inline
    fn get_renderer(self, window: Ptr[_Window]) raises -> Ptr[_Renderer]:
        """Get the renderer associated with a window."""
        return self.error.if_null(self._get_renderer.call(window), "Could not get renderer")

    @always_inline
    fn set_window_fullscreen(self, window: Ptr[_Window], flags: UInt32) raises:
        """Set a window's fullscreen state."""
        self.error.if_code(self._set_window_fullscreen.call(window, flags), "Could not set fullscreen")

    @always_inline
    fn update_window_surface(self, window: Ptr[_Window]) raises:
        """Copy the window surface to the screen."""
        self.error.if_code(self._update_window_surface.call(window), "Could not update window surface")

    # +--- surface functions

    @always_inline
    fn create_rgb_surface(self, flags: UInt32, width: IntC, height: IntC, depth: IntC, r_mask: UInt32, g_mask: UInt32, b_mask: UInt32, a_mask: UInt32) raises -> Ptr[_Surface]:
        """Allocate a new RGB surface."""
        return self.error.if_null(self._create_rgb_surface.call(flags, width, height, depth, r_mask, g_mask, b_mask, a_mask), "Could not create surface")

    @always_inline
    fn create_rgb_surface_from(self, pixels: Ptr[NoneType], width: IntC, height: IntC, depth: IntC, pitch: IntC, r_mask: UInt32, g_mask: UInt32, b_mask: UInt32, a_mask: UInt32) raises -> Ptr[_Surface]:
        """Allocate a new RGB surface with existing pixel data."""
        return self.error.if_null(self._create_rgb_surface_from.call(pixels, width, height, depth, pitch, r_mask, g_mask, b_mask, a_mask), "Could not create surface from")

    @always_inline
    fn create_rgb_surface_with_format(self, flags: UInt32, width: IntC, height: IntC, depth: IntC, format: UInt32) raises -> Ptr[_Surface]:
        """Allocate a new RGB surface with a specific pixel format."""
        return self.error.if_null(self._create_rgb_surface_with_format.call(flags, width, height, depth, format), "Could not create surface with format")

    @always_inline
    fn create_rgb_surface_with_format_from(self, pixels: Ptr[NoneType], width: IntC, height: IntC, depth: IntC, pitch: IntC, format: UInt32) raises -> Ptr[_Surface]:
        """Allocate a new RGB surface with with a specific pixel format and existing pixel data."""
        return self.error.if_null(self._create_rgb_surface_with_format_from.call(pixels, width, height, depth, pitch, format), "Could not create surface with format from")

    @always_inline
    fn free_surface(self, surface: Ptr[_Surface]):
        """Free an RGB surface."""
        self._free_surface.call(surface)

    @always_inline
    fn convert_surface(self, src: Ptr[_Surface], fmt: Ptr[SurfacePixelFormat], flags: UInt32) raises -> Ptr[_Surface]:
        """Copy an existing surface to a new surface of the specified format."""
        return self.error.if_null(self._convert_surface.call(src, fmt, flags), "Could not convert surface")

    @always_inline
    fn convert_surface_format(self, src: Ptr[_Surface], pixel_format: UInt32, flags: UInt32) raises -> Ptr[_Surface]:
        """Copy an existing surface to a new surface of the specified format enum."""
        return self.error.if_null(self._convert_surface_format.call(src, pixel_format, flags), "Could not convert surface format")

    @always_inline
    fn fill_rect(self, surface: Ptr[_Surface], rect: Ptr[Rect], color: UInt32) raises:
        """Perform a fast fill of a rectangle with a specific color."""
        self.error.if_code(self._fill_rect.call(surface, rect, color), "Could not fill rect")

    @always_inline
    fn fill_rects(self, surface: Ptr[_Surface], rects: Ptr[Rect], count: IntC, color: UInt32) raises:
        """Perform a fast fill of a set of rectangles with a specific color."""
        self.error.if_code(self._fill_rects.call(surface, rects, count, color), "Could not fill rects")

    # var _get_surface_color_mod: SDL_Fn["SDL_GetSurfaceColorMod", fn (Ptr[_Surface], Ptr[UInt8], Ptr[UInt8], Ptr[UInt8]) -> IntC]
    # var _get_surface_alpha_mod: SDL_Fn["SDL_GetSurfaceAlphaMod", fn (Ptr[_Surface], Ptr[UInt8]) -> IntC]
    # var _get_surface_blend_mode: SDL_Fn["SDL_GetSurfaceBlendMode", fn (Ptr[_Surface], Ptr[BlendMode]) -> IntC]
    # var _has_surface_rle: SDL_Fn["SDL_HasSurfaceRLE", fn (Ptr[_Surface]) -> BoolC]

    @always_inline
    fn lock_surface(self, surface: Ptr[_Surface]) raises:
        """Set up a surface for directly accessing the pixels."""
        self.error.if_code(self._lock_surface.call(surface), "Could not lock surface")

    @always_inline
    fn unlock_surface(self, surface: Ptr[_Surface]):
        """Release a surface after directly accessing the pixels."""
        self._unlock_surface.call(surface)

    # var _set_surface_color_mod: SDL_Fn["SDL_SetSurfaceColorMod", fn(Ptr[_Surface], UInt8, UInt8, UInt8) -> IntC]
    # var _set_surface_alpha_mod: SDL_Fn["SDL_SetSurfaceAlphaMod", fn (Ptr[_Surface], UInt8) -> IntC]
    # var _set_surface_blend_mode: SDL_Fn["SDL_SetSurfaceBlendMode", fn (Ptr[_Surface], BlendMode) -> IntC]
    # var _set_surface_palette: SDL_Fn["SDL_SetSurfacePalette", fn (Ptr[_Surface], Ptr[Palette]) -> IntC]
    # var _set_surface_rle: SDL_Fn["SDL_SetSurfaceRLE", fn (Ptr[_Surface], IntC) -> IntC]

    @always_inline
    fn lower_blit(self, src: Ptr[_Surface], src_rect: Ptr[Rect], dst: Ptr[_Surface], dst_rect: Ptr[Rect]) raises:
        """Perform low-level surface blitting only, assuming the input rectangles have already been clipped."""
        self.error.if_code(self._lower_blit.call(src, src_rect, dst, dst_rect), "Could not lower blit surface")

    @always_inline
    fn lower_blit_scaled(self, src: Ptr[_Surface], src_rect: Ptr[Rect], dst: Ptr[_Surface], dst_rect: Ptr[Rect]) raises:
        """Perform low-level surface scaled blitting only, assuming the input rectangles have already been clipped."""
        self.error.if_code(self._lower_blit_scaled.call(src, src_rect, dst, dst_rect), "Could not lower blit scaled surface")

    @always_inline
    fn upper_blit(self, src: Ptr[_Surface], src_rect: Ptr[Rect], dst: Ptr[_Surface], dst_rect: Ptr[Rect]) raises:
        """Perform a fast blit from the source surface to the destination surface."""
        self.error.if_code(self._upper_blit.call(src, src_rect, dst, dst_rect), "Could not upper blit surface")

    @always_inline
    fn upper_blit_scaled(self, src: Ptr[_Surface], src_rect: Ptr[Rect], dst: Ptr[_Surface], dst_rect: Ptr[Rect]) raises:
        """Perform a scaled surface copy to a destination surface."""
        self.error.if_code(self._upper_blit_scaled.call(src, src_rect, dst, dst_rect), "Could not upper blit scaled surface")

    # +--- renderer functions

    @always_inline
    fn create_renderer(self, window: Ptr[_Window], index: IntC, flags: UInt32) raises -> Ptr[_Renderer]:
        """Create a 2D rendering context for a window."""
        return self.error.if_null(self._create_renderer.call(window, index, flags), "Could not create renderer")

    @always_inline
    fn create_software_renderer(self, surface: Ptr[_Surface]) raises -> Ptr[_Renderer]:
        """Create a 2D software rendering context for a surface."""
        return self.error.if_null(self._create_software_renderer.call(surface), "Could not create software renderer")

    @always_inline
    fn destroy_renderer(self, renderer: Ptr[_Renderer]):
        """Destroy the rendering context for a window and free associated textures."""
        self._destroy_renderer.call(renderer)

    @always_inline
    fn render_clear(self, renderer: Ptr[_Renderer]) raises:
        """Clear the current rendering target with the drawing color."""
        self.error.if_code(self._render_clear.call(renderer), "Could not clear the current rendering target")

    @always_inline
    fn render_present(self, renderer: Ptr[_Renderer]):
        """Update the screen with any rendering performed since the previous call."""
        self._render_present.call(renderer)

    @always_inline
    fn render_get_window(self, renderer: Ptr[_Renderer]) raises -> Ptr[_Window]:
        """Get the window associated with a renderer."""
        return self.error.if_null(self._render_get_window.call(renderer), "Could not get renderer window")

    @always_inline
    fn set_render_target(self, renderer: Ptr[_Renderer], texture: Ptr[_Texture]) raises:
        """Set a texture as the current rendering target."""
        self.error.if_code(self._set_render_target.call(renderer, texture), "Could not set render target")

    @always_inline
    fn set_render_draw_color(self, renderer: Ptr[_Renderer], r: UInt8, g: UInt8, b: UInt8, a: UInt8) raises:
        """Set the color used for drawing operations (Rect, Line and Clear)."""
        self.error.if_code(self._set_render_draw_color.call(renderer, r, g, b, a), "Could not set render draw color")

    @always_inline
    fn set_render_draw_blend_mode(self, renderer: Ptr[_Renderer], blend_mode: BlendMode) raises:
        """Set the blend mode used for drawing operations (Fill and Line)."""
        self.error.if_code(self._set_render_draw_blend_mode.call(renderer, blend_mode), "Could not set render draw blend mode")

    @always_inline
    fn get_render_draw_color(self, renderer: Ptr[_Renderer], r: Ptr[UInt8], g: Ptr[UInt8], b: Ptr[UInt8], a: Ptr[UInt8]) raises:
        """Get the color used for drawing operations (Rect, Line and Clear)."""
        self.error.if_code(self._get_render_draw_color.call(renderer, r, g, b, a), "Could not get render draw color")

    @always_inline
    fn get_render_draw_blend_mode(self, renderer: Ptr[_Renderer], blend_mode: Ptr[BlendMode]) raises:
        """Get the blend mode used for drawing operations."""
        self.error.if_code(self._get_render_draw_blend_mode.call(renderer, blend_mode), "Could not get render draw blend mode")

    @always_inline
    fn get_renderer_info(self, renderer: Ptr[_Renderer], info: Ptr[RendererInfo]) raises:
        """Get information about a rendering context."""
        self.error.if_code(self._get_renderer_info.call(renderer, info), "Could not get renderer info")

    @always_inline
    fn get_renderer_output_size(self, renderer: Ptr[_Renderer], w: Ptr[IntC], h: Ptr[IntC]) raises:
        """Get the output size in pixels of a rendering context."""
        self.error.if_code(self._get_renderer_output_size.call(renderer, w, h), "Could not get renderer output size")

    @always_inline
    fn get_render_target(self, renderer: Ptr[_Renderer]) -> Ptr[_Texture]:
        """Get the current render target."""
        return self._get_render_target.call(renderer)

    @always_inline
    fn get_num_render_drivers(self) raises -> IntC:
        """Get the number of 2D rendering drivers available for the current display."""
        var num_render_drivers = self._get_num_render_drivers.call()
        if num_render_drivers < 0:
            raise self.error()
        return num_render_drivers

    @always_inline
    fn get_render_driver_info(self, index: IntC) raises -> RendererInfo:
        """Get info about a specific 2D rendering driver for the current display."""
        var renderer_info = utils._uninit[RendererInfo]()
        self.error.if_code(self._get_render_driver_info.call(index, Ptr.address_of(renderer_info)), "Could not get render driver info")
        return renderer_info

    @always_inline
    fn render_copy(self, renderer: Ptr[_Renderer], texture: Ptr[_Texture], src_rect: Ptr[Rect], dst_rect: Ptr[Rect]) raises:
        """Copy a portion of the texture to the current rendering target."""
        self.error.if_code(self._render_copy.call(renderer, texture, src_rect, dst_rect), "Could not copy texture")

    @always_inline
    fn render_copy_f(self, renderer: Ptr[_Renderer], texture: Ptr[_Texture], src_rect: Ptr[Rect], dst_rect: Ptr[FRect]) raises:
        """Copy a portion of the texture to the current rendering target at subpixel precision."""
        self.error.if_code(self._render_copy_f.call(renderer, texture, src_rect, dst_rect), "Could not copy texture")

    @always_inline
    fn render_copy_ex(self, renderer: Ptr[_Renderer], texture: Ptr[_Texture], src_rect: Ptr[Rect], dst_rect: Ptr[Rect], angle: Float64, center: Ptr[Point], flip: RendererFlip) raises:
        """Copy a portion of the texture to the current rendering, with optional rotation and flipping."""
        self.error.if_code(self._render_copy_ex.call(renderer, texture, src_rect, dst_rect, angle, center, flip), "Could not copy texture")

    @always_inline
    fn render_copy_exf(self, renderer: Ptr[_Renderer], texture: Ptr[_Texture], src_rect: Ptr[Rect], dst_rect: Ptr[FRect], angle: Float64, center: Ptr[FPoint], flip: RendererFlip) raises:
        """Copy a portion of the source texture to the current rendering target, with rotation and flipping, at subpixel precision."""
        self.error.if_code(self._render_copy_exf.call(renderer, texture, src_rect, dst_rect, angle, center, flip), "Could not copy texture")

    @always_inline
    fn render_draw_line(self, renderer: Ptr[_Renderer], x1: IntC, y1: IntC, x2: IntC, y2: IntC) raises:
        """Draw a line on the current rendering target."""
        self.error.if_code(self._render_draw_line.call(renderer, x1, y1, x2, y2), "Could not draw line")

    @always_inline
    fn render_draw_line_f(self, renderer: Ptr[_Renderer], x1: Float32, y1: Float32, x2: Float32, y2: Float32) raises:
        """Draw a line on the current rendering target at subpixel precision."""
        self.error.if_code(self._render_draw_line_f.call(renderer, x1, y1, x2, y2), "Could not draw line")

    @always_inline
    fn render_draw_lines(self, renderer: Ptr[_Renderer], points: Ptr[Point[]], count: IntC) raises:
        """Draw a series of connected lines on the current rendering target at subpixel precision."""
        self.error.if_code(self._render_draw_lines.call(renderer, points, count), "Could not draw lines")

    @always_inline
    fn render_draw_lines_f(self, renderer: Ptr[_Renderer], points: Ptr[FPoint], count: IntC) raises:
        """Draw a series of connected lines on the current rendering target at subpixel precision."""
        self.error.if_code(self._render_draw_lines_f.call(renderer, points, count), "Could not draw lines")

    @always_inline
    fn render_draw_point(self, renderer: Ptr[_Renderer], x: IntC, y: IntC) raises:
        """Draw a point on the current rendering target."""
        self.error.if_code(self._render_draw_point.call(renderer, x, y), "Could not draw point")

    @always_inline
    fn render_draw_point_f(self, renderer: Ptr[_Renderer], x: Float32, y: Float32) raises:
        """Draw a point on the current rendering target at subpixel precision."""
        self.error.if_code(self._render_draw_point_f.call(renderer, x, y), "Could not draw point")

    @always_inline
    fn render_draw_points(self, renderer: Ptr[_Renderer], points: Ptr[Point[]], count: IntC) raises:
        """Draw multiple points on the current rendering target."""
        self.error.if_code(self._render_draw_points.call(renderer, points, count), "Could not draw points")

    @always_inline
    fn render_draw_points_f(self, renderer: Ptr[_Renderer], points: Ptr[FPoint], count: IntC) raises:
        """Draw multiple points on the current rendering target at subpixel precision."""
        self.error.if_code(self._render_draw_points_f.call(renderer, points, count), "Could not draw points")

    @always_inline
    fn render_draw_rect(self, renderer: Ptr[_Renderer], rect: Rect) raises:
        """Draw a rectangle on the current rendering target."""
        self.error.if_code(self._render_draw_rect.call(renderer, rect), "Could not draw rect")

    @always_inline
    fn render_draw_rect_f(self, renderer: Ptr[_Renderer], rect: FRect) raises:
        """Draw a rectangle on the current rendering target at subpixel precision."""
        self.error.if_code(self._render_draw_rect_f.call(renderer, rect), "Could not draw rect")

    @always_inline
    fn render_draw_rects(self, renderer: Ptr[_Renderer], rects: Ptr[Rect], count: IntC) raises:
        """Draw some number of rectangles on the current rendering target."""
        self.error.if_code(self._render_draw_rects.call(renderer, rects, count), "Could not draw rects")

    @always_inline
    fn render_draw_rects_f(self, renderer: Ptr[_Renderer], rects: Ptr[FRect], count: IntC) raises:
        """Draw some number of rectangles on the current rendering target at subpixel precision."""
        self.error.if_code(self._render_draw_rects_f.call(renderer, rects, count), "Could not draw rects")

    @always_inline
    fn render_fill_rect(self, renderer: Ptr[_Renderer], rect: Rect) raises:
        """Fill a rectangle on the current rendering target."""
        self.error.if_code(self._render_fill_rect.call(renderer, rect), "Could not fill rect")

    @always_inline
    fn render_fill_rect_f(self, renderer: Ptr[_Renderer], rect: FRect) raises:
        """Fill a rectangle on the current rendering target at subpixel precision."""
        self.error.if_code(self._render_fill_rect_f.call(renderer, rect), "Could not fill rect")

    @always_inline
    fn render_fill_rects(self, renderer: Ptr[_Renderer], rects: Ptr[Rect], count: IntC) raises:
        """Fill some number of rectangles on the current rendering target."""
        self.error.if_code(self._render_fill_rects.call(renderer, rects, count), "Could not fill rects")

    @always_inline
    fn render_fill_rects_f(self, renderer: Ptr[_Renderer], rects: Ptr[FRect], count: IntC) raises:
        """Fill some number of rectangles on the current rendering target at subpixel precision."""
        self.error.if_code(self._render_fill_rects_f.call(renderer, rects, count), "Could not fill rects")

    @always_inline
    fn render_flush(self, renderer: Ptr[_Renderer]) raises:
        """Force the rendering context to flush any pending commands to the underlying rendering API."""
        self.error.if_code(self._render_flush.call(renderer), "Could not flush, clogged")

    @always_inline
    fn render_geometry(self, renderer: Ptr[_Renderer], texture: Ptr[_Texture], vertices: Ptr[Vertex], num_vertices: IntC, indices: Ptr[IntC], num_indices: IntC) raises:
        """Render a list of triangles, optionally using a texture and indices into the vertex array Color
        and alpha modulation is done per vertex (SDL_SetTextureColorMod and SDL_SetTextureAlphaMod are ignored)."""
        self.error.if_code(self._render_geometry.call(renderer, texture, vertices, num_vertices, indices, num_indices), "Could not render geometry")

    @always_inline
    fn render_geometry_raw(
        self,
        renderer: Ptr[_Renderer],
        texture: Ptr[_Texture],
        xy: Ptr[Float32],
        xy_stride: IntC,
        color: Ptr[Color],
        color_stride: IntC,
        uv: Ptr[Float32],
        uv_stride: IntC,
        num_vertices: IntC,
        indices: Ptr[NoneType],
        num_indices: IntC,
        size_indices: IntC,
    ) raises:
        self.error.if_code(
            self._render_geometry_raw.call(
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
            ),
            "Could not render geometry raw",
        )

    @always_inline
    fn render_get_clip_rect(self, renderer: Ptr[_Renderer], rect: Ptr[Rect]):
        """Get the clip rectangle for the current target."""
        self._render_get_clip_rect.call(renderer, rect)

    @always_inline
    fn render_get_integer_scale(self, renderer: Ptr[_Renderer]) -> Bool:
        """Get whether integer scales are forced for resolution-independent rendering."""
        return self._render_get_integer_scale.call(renderer)

    @always_inline
    fn render_get_logical_size(self, renderer: Ptr[_Renderer], w: Ptr[IntC], h: Ptr[IntC]):
        """Get device independent resolution for rendering."""
        self._render_get_logical_size.call(renderer, w, h)

    @always_inline
    fn render_get_metal_command_encoder(self, renderer: Ptr[_Renderer]) raises -> Ptr[NoneType]:
        """Get the Metal command encoder for the current frame."""
        return self.error.if_null(self._render_get_metal_command_encoder.call(renderer), "Could not get metal command encoder")

    @always_inline
    fn render_get_metal_layer(self, renderer: Ptr[_Renderer]) raises -> Ptr[NoneType]:
        """Get the CAMetalLayer associated with the given Metal renderer."""
        return self.error.if_null(self._render_get_metal_layer.call(renderer), "Could not get metal layer")

    @always_inline
    fn render_get_scale(self, renderer: Ptr[_Renderer], scale_x: Ptr[IntC], scale_y: Ptr[IntC]):
        """Get the drawing scale for the current target."""
        self._render_get_scale.call(renderer, scale_x, scale_y)

    @always_inline
    fn render_get_viewport(self, renderer: Ptr[_Renderer], rect: Ptr[Rect]):
        """Get the drawing area for the current target."""
        self._render_get_viewport.call(renderer, rect)

    @always_inline
    fn render_is_clip_enabled(self, renderer: Ptr[_Renderer]) -> Bool:
        """Get whether clipping is enabled on the given renderer."""
        return self._render_is_clip_enabled.call(renderer)

    @always_inline
    fn render_logical_to_window(self, renderer: Ptr[_Renderer], logical_x: Float32, logical_y: Float32, window_x: Ptr[IntC], window_y: Ptr[IntC]):
        """Get real coordinates of point in window when given logical coordinates of point in renderer."""
        self._render_logical_to_window.call(renderer, logical_x, logical_y, window_x, window_y)

    @always_inline
    fn render_read_pixels(self, renderer: Ptr[_Renderer], rect: Ptr[Rect], format: UInt32, pixels: Ptr[NoneType], pitch: IntC) raises:
        """Read pixels from the current rendering target to an array of pixels."""
        self.error.if_code(self._render_read_pixels.call(renderer, rect, format, pixels, pitch), "Could not read pixels")

    @always_inline
    fn render_set_clip_rect(self, renderer: Ptr[_Renderer], rect: Ptr[Rect]) raises:
        """Set the clip rectangle for rendering on the specified target."""
        self.error.if_code(self._render_set_clip_rect.call(renderer, rect), "Could not set render clip rect")

    @always_inline
    fn render_set_integer_scale(self, renderer: Ptr[_Renderer], enable: Bool) raises:
        """Set whether to force integer scales for resolution-independent rendering."""
        self.error.if_code(self._render_set_integer_scale.call(renderer, enable), "Could not set integer render scale")

    @always_inline
    fn render_set_logical_size(self, renderer: Ptr[_Renderer], w: IntC, h: IntC) raises:
        """Set a device independent resolution for rendering."""
        self.error.if_code(self._render_set_logical_size.call(renderer, w, h), "Could not set logical render size")

    @always_inline
    fn render_set_scale(self, renderer: Ptr[_Renderer], scale_x: Float32, scale_y: Float32) raises:
        """Set the drawing scale for rendering on the current target."""
        self.error.if_code(self._render_set_scale.call(renderer, scale_x, scale_y), "Could not set render scale")

    @always_inline
    fn render_set_viewport(self, renderer: Ptr[_Renderer], rect: Ptr[Rect]) raises:
        """Set the drawing area for rendering on the current target."""
        self.error.if_code(self._render_set_viewport.call(renderer, rect), "Could not set viewport")

    @always_inline
    fn render_set_vsync(self, renderer: Ptr[_Renderer], vsync: IntC) raises:
        """Toggle VSync of the given renderer."""
        self.error.if_code(self._render_set_vsync.call(renderer, vsync), "Could not set vsync")

    @always_inline
    fn render_target_supported(self, renderer: Ptr[_Renderer]) -> Bool:
        """Determine whether a renderer supports the use of render targets."""
        return self._render_target_supported.call(renderer)

    @always_inline
    fn render_window_to_logical(self, renderer: Ptr[_Renderer], window_x: IntC, window_y: IntC, logical_x: Ptr[Float32], logical_y: Ptr[Float32]):
        """Get logical coordinates of point in renderer when given real coordinates of point in window."""
        self._render_window_to_logical.call(renderer, window_x, window_y, logical_x, logical_y)

    # +--- texture functions

    @always_inline
    fn create_texture(self, renderer: Ptr[_Renderer], format: UInt32, access: IntC, w: IntC, h: IntC) raises -> Ptr[_Texture]:
        """Create a texture for a rendering context."""
        return self.error.if_null(self._create_texture.call(renderer, format, access, w, h), "Could not create texture")

    @always_inline
    fn create_texture_from_surface(self, renderer: Ptr[_Renderer], surface: Ptr[_Surface]) raises -> Ptr[_Texture]:
        """Create a texture from an existing surface."""
        return self.error.if_null(self._create_texture_from_surface.call(renderer, surface), "Could not create texture from surface")

    @always_inline
    fn destroy_texture(self, texture: Ptr[_Texture]):
        """Destroy the specified texture."""
        self._destroy_texture.call(texture)

    @always_inline
    fn gl_bind_texture(self, texture: Ptr[_Texture], texw: Ptr[Float32], texh: Ptr[Float32]) raises:
        """Bind an OpenGL/ES/ES2 texture to the current context."""
        self.error.if_code(self._gl_bind_texture.call(texture, texw, texh), "Could not bind GL texture")

    @always_inline
    fn gl_unbind_texture(self, texture: Ptr[_Texture]) raises:
        """Unbind an OpenGL/ES/ES2 texture from the current context."""
        self.error.if_code(self._gl_unbind_texture.call(texture), "Could not unbind GL texture")

    @always_inline
    fn lock_texture(self, texture: Ptr[_Texture], rect: Ptr[Rect], pixels: Ptr[Ptr[NoneType]], pitch: Ptr[IntC]) raises:
        """Lock a portion of the texture for write-only pixel access."""
        self.error.if_code(self._lock_texture.call(texture, rect, pixels, pitch), "Could not lock texture")

    @always_inline
    fn lock_texture_to_surface(self, texture: Ptr[_Texture], rect: Ptr[Rect], surface: Ptr[Ptr[_Surface]]) raises:
        """Lock a portion of the texture for write-only pixel access, and expose it as a SDL surface."""
        self.error.if_code(self._lock_texture_to_surface.call(texture, rect, surface), "Could not lock texture to surface")

    @always_inline
    fn unlock_texture(self, texture: Ptr[_Texture]):
        """Unlock a texture, uploading the changes to video memory, if needed."""
        self._unlock_texture.call(texture)

    @always_inline
    fn query_texture(self, texture: Ptr[_Texture], format: Ptr[UInt32], access: Ptr[IntC], w: Ptr[IntC], h: Ptr[IntC]) raises:
        """Query the attributes of a texture."""
        self.error.if_code(self._query_texture.call(texture, format, access, w, h), "Could not query texture")

    @always_inline
    fn get_texture_color_mod(self, texture: Ptr[_Texture], r: Ptr[UInt8], g: Ptr[UInt8], b: Ptr[UInt8]) raises:
        """Get the additional color value multiplied into render copy operations."""
        self.error.if_code(self._get_texture_color_mod.call(texture, r, g, b), "Could not get texture color mod")

    @always_inline
    fn get_texture_alpha_mod(self, texture: Ptr[_Texture], a: Ptr[UInt8]) raises:
        """Get the additional alpha value multiplied into render copy operations."""
        self.error.if_code(self._get_texture_alpha_mod.call(texture, a), "Could not get texture alpha mod")

    @always_inline
    fn get_texture_blend_mode(self, texture: Ptr[_Texture], blend_mode: Ptr[BlendMode]) raises:
        """Get the blend mode used for texture copy operations."""
        self.error.if_code(self._get_texture_blend_mode.call(texture, blend_mode), "Could not get texture blend mode")

    @always_inline
    fn get_texture_scale_mode(self, texture: Ptr[_Texture], scale_mode: Ptr[ScaleMode]) raises:
        """Get the scale mode used for texture scale operations."""
        self.error.if_code(self._get_texture_scale_mode.call(texture, scale_mode), "Could not get texture scale mode")

    @always_inline
    fn get_texture_user_data(self, texture: Ptr[_Texture]) raises -> Ptr[NoneType]:
        """Get the user-specified pointer associated with a texture."""
        return self.error.if_null(self._get_texture_user_data.call(texture), "Could not get texture user data")

    @always_inline
    fn set_texture_color_mod(self, texture: Ptr[_Texture], r: UInt8, g: UInt8, b: UInt8) raises:
        """Set an additional color value multiplied into render copy operations."""
        self.error.if_code(self._set_texture_color_mod.call(texture, r, g, b), "Could not set texture color mod")

    @always_inline
    fn set_texture_alpha_mod(self, texture: Ptr[_Texture], alpha: UInt8) raises:
        """Set an additional alpha value multiplied into render copy operations."""
        self.error.if_code(self._set_texture_alpha_mod.call(texture, alpha), "Could not set texture alpha mod")

    @always_inline
    fn set_texture_blend_mode(self, texture: Ptr[_Texture], blend_mode: BlendMode) raises:
        """Set the scale mode used for texture scale operations."""
        self.error.if_code(self._set_texture_blend_mode.call(texture, blend_mode), "Could not set texture blend mode")

    @always_inline
    fn set_texture_scale_mode(self, texture: Ptr[_Texture], scale_mode: ScaleMode) raises:
        """Set the scale mode used for texture scale operations."""
        self.error.if_code(self._set_texture_scale_mode.call(texture, scale_mode), "Could not set texture scale mode")

    @always_inline
    fn set_texture_user_data(self, texture: Ptr[_Texture], user_data: Ptr[NoneType]) raises:
        """Associate a user-specified pointer with a texture."""
        self.error.if_code(self._set_texture_user_data.call(texture, user_data), "Could not set texture user data")

    @always_inline
    fn update_texture(self, texture: Ptr[_Texture], rect: Ptr[Rect], pixels: Ptr[NoneType], pitch: IntC) raises:
        """Update the given texture rectangle with new pixel data."""
        self.error.if_code(self._update_texture.call(texture, rect, pixels, pitch), "Could not update texture")

    @always_inline
    fn update_nv_texture(self, texture: Ptr[_Texture], rect: Ptr[Rect], y_plane: Ptr[UInt8], y_pitch: IntC, uv_plane: Ptr[UInt8], uv_pitch: IntC) raises:
        """Update a rectangle within a planar NV12 or NV21 texture with new pixels."""
        self.error.if_code(self._update_nv_texture.call(texture, rect, y_plane, y_pitch, uv_plane, uv_pitch), "Could not update nv texture")

    @always_inline
    fn update_yuv_texture(self, texture: Ptr[_Texture], rect: Ptr[Rect], y_plane: Ptr[UInt8], y_pitch: Int, u_plane: Ptr[UInt8], u_pitch: Int, v_plane: Ptr[UInt8], v_pitch: Int) raises:
        """Update a rectangle within a planar YV12 or IYUV texture with new pixel data."""
        self.error.if_code(self._update_yuv_texture.call(texture, rect, y_plane, y_pitch, u_plane, u_pitch, v_plane, v_pitch), "Could not update yuv texture")

    # +--- opengl functions

    fn gl_create_context(self, window: Ptr[_Window]) raises -> Ptr[_GLContext]:
        return self.error.if_null(self._gl_create_context.call(window), "Could not create gl context")

    fn gl_delete_context(self, gl_context: Ptr[_GLContext]):
        self._gl_delete_context.call(gl_context)
