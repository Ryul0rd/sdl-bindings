"""Defines an SDL Clock."""

from time import now, sleep


@value
struct Clock:
    var target_fps: Int
    var delta_time: Float64
    var _last_tick_time: Int

    fn __init__(inout self, target_fps: Int):
        self.target_fps = target_fps
        self.delta_time = 1 / target_fps
        self._last_tick_time = now()

    fn tick(inout self):
        var tick_time = now()
        var target_frame_time = 1 / self.target_fps
        var elapsed_time = (tick_time - self._last_tick_time) / 1_000_000_000
        if elapsed_time < target_frame_time:
            sleep(target_frame_time - elapsed_time)
            self.delta_time = target_frame_time
        else:
            self.delta_time = elapsed_time
        self._last_tick_time = tick_time


var _get_ticks = _sdl.get_function[fn () -> UInt32]("SDL_GetTicks")


fn get_ticks() -> UInt32:
    return _get_ticks()


var _delay = _sdl.get_function[fn (ms: UInt32) -> None]("SDL_Delay")


fn delay(ms: UInt32):
    _delay(ms)
