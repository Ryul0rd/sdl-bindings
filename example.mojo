from sdl import *

# TODO: collision rect/point


def main():
    alias screen_width = 640
    alias screen_height = 480

    var sdl = SDL(video=True, audio=True, timer=True, events=True, gfx=True, img=True, mix=True, ttf=True)
    var window = Window(sdl, 'SDL Test', screen_width, screen_height)
    var clock = Clock(sdl, target_fps=60)
    var held_keys = SIMD[DType.bool, 512]()

    var apple = Surface(sdl, sdl.img.load_image(('assets/apple.png').unsafe_cstr_ptr().bitcast[DType.uint8]()))
    var rotated_apple = Surface(sdl, sdl.gfx.rotozoom_surface(apple, 90, 1, True))
    var font = ttf.Font(sdl, "assets/Beef'd.ttf", 24)
    var hello = font.render_solid('Hello, World!', Color(255, 0, 255, 255))
    hello.convert(window.surface)

    var test_sound = mix.MixMusic(sdl.mix, 'assets/audio/error_003.ogg')

    var player_color = Color(255, 0, 0, 255)
    var background_color = Color(255, 255, 255, 255)
    var player_box = Rect(100, 100, 50, 50)
    var player_speed = 200

    var playing = True
    while playing:
        for event in sdl.event_list():
            if event[].isa[QuitEvent]():
                playing = 0
            elif event[].isa[KeyDownEvent]():
                var e = event[][KeyDownEvent]
                held_keys[int(e.key)] = True
                if e.key == Keys.space:
                    test_sound.play(1)
            elif event[].isa[KeyUpEvent]():
                var e = event[][KeyUpEvent]
                held_keys[int(e.key)] = False

        if held_keys[Keys.w]:
            player_box.y -= int(player_speed * clock.delta_time)
        if held_keys[Keys.a]:
            player_box.x -= int(player_speed * clock.delta_time)
        if held_keys[Keys.s]:
            player_box.y += int(player_speed * clock.delta_time)
        if held_keys[Keys.d]:
            player_box.x += int(player_speed * clock.delta_time)

        window.surface.fill(background_color)
        window.surface.fill(player_color, player_box)

        var green = Surface(sdl, 100, 100, Color(0, 255, 0))
        window.surface.blit(green, None, Rect(200, 200, 30, 30))
        window.surface.blit(rotated_apple, None, Rect(300, 300, 30, 30))
        window.surface.blit(hello, None, Rect(300, 100, 300, 44))

        window.update_surface()
        clock.tick()
