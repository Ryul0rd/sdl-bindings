"""Defines SDL_ttf bindings and wrappers for use in Mojo."""

from sys import DLHandle, os_is_macos, os_is_linux
from .._sdl import SDL_Fn
from ..surface import _Surface
from .font import Font, _Font
from builtin.constrained import constrained


struct _TTF:
    """Raw bindings to sdl_ttf."""

    var _handle: DLHandle
    var error: SDL_Error
    var _ttf_init: SDL_Fn["TTF_Init", fn () -> Int32]
    var _ttf_quit: SDL_Fn["TTF_Quit", fn () -> NoneType]
    var _ttf_open_font: SDL_Fn["TTF_OpenFont", fn (Ptr[CharC], Int32) -> Ptr[_Font]]
    var _ttf_close_font: SDL_Fn["TTF_CloseFont", fn (Ptr[_Font]) -> NoneType]
    var _ttf_render_text_solid: SDL_Fn[
        "TTF_RenderText_Solid",
        fn (Ptr[_Font], Ptr[CharC], UInt32) -> Ptr[_Surface],
    ]
    var _ttf_render_text_shaded: SDL_Fn[
        "TTF_RenderText_Shaded",
        fn (Ptr[_Font], Ptr[CharC], UInt32, UInt32) -> Ptr[_Surface],
    ]
    var _ttf_render_text_blended: SDL_Fn[
        "TTF_RenderText_Blended",
        fn (Ptr[_Font], Ptr[CharC], UInt32) -> UnsafePointer[_Surface],
    ]

    fn __init__(inout self, error: SDL_Error):
        @parameter
        if os_is_macos():
            self._handle = DLHandle(".magic/envs/default/lib/libSDL2_ttf.dylib")
        elif os_is_linux():
            self._handle = DLHandle(".magic/envs/default/lib/libSDL2_ttf.so")
        else:
            constrained[False, "OS is not supported"]()
            self._handle = utils._uninit[DLHandle]()

        self.error = error
        self._ttf_init = self._handle
        self._ttf_quit = self._handle
        self._ttf_open_font = self._handle
        self._ttf_close_font = self._handle
        self._ttf_render_text_solid = self._handle
        self._ttf_render_text_shaded = self._handle
        self._ttf_render_text_blended = self._handle

    @always_inline
    fn init(self) raises:
        self.error.if_code(self._ttf_init.call(), "Could not initialize SDL TTF")

    @always_inline
    fn quit(self):
        self._ttf_quit.call()

    @always_inline
    fn open_font(self, path: Ptr[CharC], size: Int32) raises -> Ptr[_Font]:
        return self.error.if_null(self._ttf_open_font.call(path, size), "Could not open font")

    @always_inline
    fn close_font(self, font: Ptr[_Font]):
        self._ttf_close_font.call(font)

    @always_inline
    fn render_solid_text(self, font: Ptr[_Font], text: Ptr[CharC], fg: UInt32) raises -> Ptr[_Surface]:
        return self.error.if_null(
            self._ttf_render_text_solid.call(font, text, fg),
            "Could not render solid text",
        )

    @always_inline
    fn render_shaded_text(self, font: Ptr[_Font], text: Ptr[CharC], fg: UInt32, bg: UInt32) raises -> Ptr[_Surface]:
        return self.error.if_null(
            self._ttf_render_text_shaded.call(font, text, fg, bg),
            "Could not render shaded text",
        )

    @always_inline
    fn render_blended_text(self, font: Ptr[_Font], text: Ptr[CharC], fg: UInt32) raises -> Ptr[_Surface]:
        return self.error.if_null(self._ttf_render_text_blended.call(font, text, fg), "Could not render blended text")
