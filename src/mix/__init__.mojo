"""Defines SDL_mix bindings and wrappers for use in Mojo."""

from sys import DLHandle, os_is_macos, os_is_linux
from .._sdl import SDL_Fn
from .sound import MixChunk, _MixChunk, MixMusic, _MixMusic
from builtin.constrained import constrained


struct _MIX:
    """Raw bindings to sdl_mix."""

    var _handle: DLHandle
    var error: SDL_Error

    var _open_audio: SDL_Fn["Mix_OpenAudio", fn (Int32, UInt16, Int32, Int32) -> Int32]
    var _close_audio: SDL_Fn["Mix_CloseAudio", fn () -> NoneType]
    var _load_wav: SDL_Fn["Mix_LoadWAV", fn (Ptr[CharC]) -> Ptr[_MixChunk]]
    var _free_chunk: SDL_Fn["Mix_FreeChunk", fn (Ptr[_MixChunk]) -> NoneType]
    var _play_channel: SDL_Fn["Mix_PlayChannel", fn (Int32, Ptr[_MixChunk], Int32) -> Int32]
    var _load_mus: SDL_Fn["Mix_LoadMUS", fn (Ptr[CharC]) -> Ptr[_MixMusic]]
    var _free_music: SDL_Fn["Mix_FreeMusic", fn (Ptr[_MixMusic]) -> NoneType]
    var _play_music: SDL_Fn["Mix_PlayMusic", fn (Ptr[_MixMusic], Int32) -> Int32]

    fn __init__(inout self, error: SDL_Error):
        @parameter
        if os_is_macos():
            self._handle = DLHandle(".magic/envs/default/lib/libSDL2_mixer.dylib")
        elif os_is_linux():
            self._handle = DLHandle(".magic/envs/default/lib/libSDL2_mixer.so")
        else:
            constrained[False, "OS is not supported"]()
            self._handle = utils._uninit[DLHandle]()

        self.error = error
        self._open_audio = self._handle
        self._close_audio = self._handle
        self._load_wav = self._handle
        self._free_chunk = self._handle
        self._play_channel = self._handle
        self._load_mus = self._handle
        self._free_music = self._handle
        self._play_music = self._handle

    @always_inline
    fn init(
        self,
        frequency: Int32,
        format: UInt16,
        channels: Int32,
        chunksize: Int32,
    ) raises:
        self.error.if_code(
            self._open_audio.call(frequency, format, channels, chunksize),
            "Could not initialize sdl mix",
        )

    @always_inline
    fn quit(self):
        self._close_audio.call()

    @always_inline
    fn load_wav(self, file: Ptr[CharC]) raises -> Ptr[_MixChunk]:
        return self.error.if_null(self._load_wav.call(file), "Could not load WAV file")

    @always_inline
    fn free_chunk(self, _mixchunk_ptr: Ptr[_MixChunk]):
        self._free_chunk.call(_mixchunk_ptr)

    @always_inline
    fn play_channel(self, channel: Int32, mix_chunk: Ptr[_MixChunk], loops: Int32) raises:
        self.error.if_code(
            self._play_channel.call(channel, mix_chunk, loops),
            "Could not play channel",
        )

    @always_inline
    fn load_music(self, file: Ptr[CharC]) raises -> Ptr[_MixMusic]:
        return self.error.if_null(self._load_mus.call(file), "Could not load sound file")

    @always_inline
    fn free_music(self, _mixmusic_ptr: Ptr[_MixMusic]):
        self._free_music.call(_mixmusic_ptr)

    @always_inline
    fn play_music(self, music: Ptr[_MixMusic], loops: Int32) raises:
        self.error.if_code(self._play_music.call(music, loops), "Could not play sound file")
