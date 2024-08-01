"""Defines SDL Sound."""


alias AUDIO_U8 = 0x0008
alias AUDIO_S8 = 0x8008
alias AUDIO_U16LSB = 0x0010
alias AUDIO_S16LSB = 0x8008
alias AUDIO_U16MSB = 0x1010
alias AUDIO_S16MSB = 0x9010
alias AUDIO_U16 = AUDIO_U16LSB
alias AUDIO_S16 = AUDIO_S16LSB

alias AUDIO_S32LSB = 0x8020
alias AUDIO_S32MSB = 0x9020
alias AUDIO_S32 = AUDIO_S32LSB

alias AUDIO_F32LSB = 0x8120
alias AUDIO_F32MSB = 0x9120
alias AUDIO_F32 = AUDIO_F32LSB


struct MixChunk:
    var _c_mixchunk_ptr: UnsafePointer[C_MixChunk]

    fn __init__(inout self, c_mixchunk_ptr: UnsafePointer[C_MixChunk]):
        self._c_mixchunk_ptr = c_mixchunk_ptr

    fn __del__(owned self):
        free_chunk(self._c_mixchunk_ptr)

    fn play(self, channel: Int32, loops: Int32) raises:
        play_channel(channel, self._c_mixchunk_ptr, loops)


struct C_MixChunk:
    pass


struct MixMusic:
    var _c_mixmusic_ptr: UnsafePointer[C_MixMusic]

    fn __init__(inout self, c_mixmusic_ptr: UnsafePointer[C_MixMusic]):
        self._c_mixmusic_ptr = c_mixmusic_ptr

    fn __del__(owned self):
        free_music(self._c_mixmusic_ptr)

    fn play(self, loops: Int32) raises:
        play_music(self._c_mixmusic_ptr, loops)


struct C_MixMusic:
    pass


var _open_audio = _sdl_mix.get_function[fn (Int32, UInt16, Int32, Int32) -> Int32]("Mix_OpenAudio")


fn open_audio(frequency: Int32, format: UInt16, channels: Int32, chunksize: Int32) raises:
    var error_code = _open_audio(frequency, format, channels, chunksize)
    if error_code != 0:
        raise Error("Failed to initialize SDL Mixer")


var _close_audio = _sdl_mix.get_function[fn () -> None]("Mix_CloseAudio")


fn close_audio():
    _close_audio()


# TODO: figure out why this segfaults
var _load_wav = _sdl_mix.get_function[fn (UnsafePointer[UInt8]) -> UnsafePointer[C_MixChunk]](
    "Mix_LoadWAV"
)


fn load_wav(name: String) raises -> MixChunk:
    var c_mixchunk_ptr = _load_wav(name.unsafe_ptr())
    if not c_mixchunk_ptr:
        raise Error("Failed to load WAV: " + get_error())
    return MixChunk(c_mixchunk_ptr)


var _free_chunk = _sdl_mix.get_function[fn (UnsafePointer[C_MixChunk]) -> None]("Mix_FreeChunk")


fn free_chunk(c_mixchunk_ptr: UnsafePointer[C_MixChunk]):
    _free_chunk(c_mixchunk_ptr)


var _play_channel = _sdl_mix.get_function[fn (Int32, UnsafePointer[C_MixChunk], Int32) -> Int32](
    "Mix_PlayChannel"
)


fn play_channel(channel: Int32, mix_chunk: UnsafePointer[C_MixChunk], loops: Int32) raises:
    var error_code = _play_channel(channel, mix_chunk, loops)
    if error_code != 0:
        raise Error("Failed to play channel")


var _load_mus = _sdl_mix.get_function[fn (UnsafePointer[UInt8]) -> UnsafePointer[C_MixMusic]](
    "Mix_LoadMUS"
)


fn load_music(name: String) raises -> MixMusic:
    var c_mixmusic_ptr = _load_mus(name.unsafe_ptr())
    if not c_mixmusic_ptr:
        raise Error("Failed to load sound file: " + get_error())
    return MixMusic(c_mixmusic_ptr)


var _free_music = _sdl_mix.get_function[fn (UnsafePointer[C_MixMusic]) -> None]("Mix_FreeMusic")


fn free_music(c_mixmusic_ptr: UnsafePointer[C_MixMusic]):
    _free_music(c_mixmusic_ptr)


var _play_music = _sdl_mix.get_function[fn (UnsafePointer[C_MixMusic], Int32) -> Int32](
    "Mix_PlayMusic"
)


fn play_music(music: UnsafePointer[C_MixMusic], loops: Int32) raises:
    var error_code = _play_music(music, loops)
    if error_code != 0:
        raise Error("Failed to play sound file")
