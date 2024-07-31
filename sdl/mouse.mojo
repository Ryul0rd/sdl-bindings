"""Defines SDL Mouse."""


var _get_mouse_state = _sdl.get_function[fn (inout Int, inout Int) -> UInt32]("SDL_GetMouseState")


fn get_mouse_state(inout x: Int, inout y: Int) -> UInt32:
    return _get_mouse_state(x, y)


fn get_cursor_position() -> (Int, Int):
    var x: Int = 0
    var y: Int = 0
    _ = get_mouse_state(x, y)
    return (x, y)
