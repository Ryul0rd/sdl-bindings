import sdl
from sdl import keys

# TODO: collision rect/point
# TODO: mouse stuff? (getting mouse position and click events)
# TODO: Sound


fn main() raises:
    alias screen_width = 640
    alias screen_height = 480

    sdl.sdl_init(video=True, audio=True, timer=True, events=True)
    sdl.img_init(png=True)
    sdl.ttf_init()
    var window = sdl.Window('SDL Test', screen_width, screen_height)
    var clock = sdl.Clock(target_fps=60)
    var held_keys = SIMD[DType.bool, 512]()

    var apple = sdl.load_image('assets/apple.png')
    var rotated_apple = sdl.rotozoom_surface(apple, 90, 1, True)
    var font = sdl.Font("assets/Beef'd.ttf", 24)
    var hello = font.render_solid('Hello, World!', sdl.Color(255, 0, 255, 255))
    hello.convert(window.surface)

    var player_color = sdl.Color(255, 0, 0, 255)
    var background_color = sdl.Color(255, 255, 255, 255)
    var player_box = sdl.Rect(100, 100, 50, 50)
    var player_speed = 200

    var playing = 1
    while playing:
        for event in sdl.event_list():
            if event[].isa[sdl.QuitEvent]():
                playing = 0
            elif event[].isa[sdl.KeyDownEvent]():
                var e = event[][sdl.KeyDownEvent]
                held_keys[int(e.key)] = True
            elif event[].isa[sdl.KeyUpEvent]():
                var e = event[][sdl.KeyUpEvent]
                held_keys[int(e.key)] = False

        if held_keys[keys.w]:
            player_box.y -= int(player_speed * clock.delta_time)
        if held_keys[keys.a]:
            player_box.x -= int(player_speed * clock.delta_time)
        if held_keys[keys.s]:
            player_box.y += int(player_speed * clock.delta_time)
        if held_keys[keys.d]:
            player_box.x += int(player_speed * clock.delta_time)

        window.surface.fill(background_color)
        window.surface.fill(player_color, player_box)

        var green = sdl.Surface(100, 100, sdl.Color(0, 255, 0))
        window.surface.blit(green, None, sdl.Rect(200, 200, 30, 30))
        window.surface.blit(rotated_apple, None, sdl.Rect(300, 300, 30, 30))
        window.surface.blit(hello, None, sdl.Rect(300, 300, 300, 44))

        window.update_surface()
        clock.tick()
    sdl.sdl_quit()
    sdl.img_quit()
    sdl.ttf_quit()
