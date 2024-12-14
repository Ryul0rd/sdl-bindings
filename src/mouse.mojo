"""Defines SDL Mouse."""

from .utils import adr
from ._sdl import _SDL


struct Mouse[lif: AnyLifetime[False].type]:
    var sdl: Reference[SDL, lif]

    fn __init__(inout self, ref [lif]sdl: SDL):
        self.sdl = sdl

    fn get_position(self) -> (Int, Int):
        var x: IntC = 0
        var y: IntC = 0
        _ = self.sdl[]._sdl.get_mouse_state(adr(x), adr(y))
        return (int(x), int(y))

    fn get_buttons(self) -> UInt32:
        return self.sdl[]._sdl.get_mouse_state(Ptr[IntC](), Ptr[IntC]())
