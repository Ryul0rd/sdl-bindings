"""Defines SDL x Opengl."""

from .window import _Window


struct GLContext:
    var _gl_context_ptr: UnsafePointer[_GLContext]

    fn __init__(inout self, window: Window) raises:
        self._gl_context_ptr = gl_create_context(window._window_ptr)

    fn close(self):
        gl_delete_context(self._gl_context_ptr)


struct _GLContext:
    pass


var _gl_create_context = _sdl.get_function[
    fn (UnsafePointer[_Window]) -> UnsafePointer[_GLContext]
]("SDL_GL_CreateContext")


fn gl_create_context(_window_ptr: UnsafePointer[_Window]) raises -> UnsafePointer[_GLContext]:
    var _gl_context_ptr = _gl_create_context(_window_ptr)
    if not _gl_context_ptr:
        raise get_error()
    return _gl_context_ptr


var _gl_delete_context = _sdl.get_function[fn (UnsafePointer[_GLContext]) -> None](
    "SDL_GL_DeleteContext"
)


fn gl_delete_context(_gl_context_ptr: UnsafePointer[_GLContext]):
    _gl_delete_context(_gl_context_ptr)
