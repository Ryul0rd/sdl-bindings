var _img_init = _sdl_img.get_function[fn(Int32) -> Int32]('IMG_Init')

fn img_init(jpeg: Bool=False, png: Bool=False, tif: Bool=False, webp: Bool=False):
    var flags: Int32 = 0
    flags |= 0x00000001 * jpeg
    flags |= 0x00000002 * png
    flags |= 0x00000004 * tif
    flags |= 0x00000008 * webp
    _ = _img_init(flags)

var _img_quit = _sdl_img.get_function[fn() -> None]('IMG_Quit')
fn img_quit():
    _img_quit()

var _img_load = _sdl_img.get_function[fn(UnsafePointer[UInt8]) -> UnsafePointer[C_Surface]]('IMG_Load')
fn load_image(file: String) raises -> Surface:
    var c_surface_ptr = _img_load(file.unsafe_ptr())
    if c_surface_ptr:
        return Surface(c_surface_ptr)
    raise "No Image Found: " + file
