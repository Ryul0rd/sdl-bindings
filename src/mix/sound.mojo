"""Defines an sdl mix Sound."""


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


struct MixChunk[lif: AnyLifetime[False].type]:
    var mix: Reference[_MIX, lif]
    var _mixchunk_ptr: Ptr[_MixChunk]

    fn __init__(inout self, ref [lif]mix: _MIX, _mixchunk_ptr: Ptr[_MixChunk]):
        self.mix = mix
        self._mixchunk_ptr = _mixchunk_ptr

    fn __del__(owned self):
        self.mix[].free_chunk(self._mixchunk_ptr)

    fn play(self, channel: Int32, loops: Int32) raises:
        self.mix[].play_channel(channel, self._mixchunk_ptr, loops)


@register_passable("trivial")
struct _MixChunk:
    pass


struct MixMusic[lif: AnyLifetime[False].type]:
    var mix: Reference[_MIX, lif]
    var _mixmusic_ptr: Ptr[_MixMusic]

    fn __init__(inout self, ref [lif]mix: _MIX, path: String) raises:
        self.mix = mix
        self._mixmusic_ptr = mix.load_music(
            path.unsafe_cstr_ptr().bitcast[DType.uint8]()
        )

    fn __init__(inout self, ref [lif]mix: _MIX, _mixmusic_ptr: Ptr[_MixMusic]):
        self.mix = mix
        self._mixmusic_ptr = _mixmusic_ptr

    fn __del__(owned self):
        self.mix[].free_music(self._mixmusic_ptr)

    fn play(self, loops: Int32) raises:
        self.mix[].play_music(self._mixmusic_ptr, loops)


@register_passable("trivial")
struct _MixMusic:
    pass
