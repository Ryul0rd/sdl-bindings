"""Defines driver utilities."""

# from .render import RendererInfo


# var _get_num_render_drivers = _sdl.get_function[fn () -> Int]("SDL_GetNumRenderDrivers")


# fn get_num_render_drivers() raises -> Int:
#     """Get the number of 2D rendering drivers available for the current display."""
#     var num_render_drivers = _get_num_render_drivers()
#     if num_render_drivers < 0:
#         raise get_error()
#     return num_render_drivers


# var _get_render_driver_info = _sdl.get_function[fn (Int, Ptr[RendererInfo]) -> Int](
#     "SDL_GetRenderDriverInfo"
# )


# fn get_render_drive_info(index: Int) raises -> RendererInfo:
#     """Get info about a specific 2D rendering driver for the current display."""
#     var renderer_info: RendererInfo
#     __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(renderer_info))
#     if _get_render_driver_info(index, Ptr.address_of(renderer_info)) != 0:
#         raise get_error()
#     return renderer_info
