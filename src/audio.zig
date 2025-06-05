const rl = @import("raylib");

pub const SFX = struct {
    hit: rl.Sound,
    score: rl.Sound,
    start_music: rl.Music,

    const Self = @This();

    pub fn init() !Self {
        const hit: rl.Sound = try rl.loadSound("resources/audio/ping.ogg");
        const score: rl.Sound = try rl.loadSound("resources/audio/boing.ogg");
        const start_music: rl.Music = try rl.loadMusicStream("resources/audio/prologue.ogg");

        return Self{
            .hit = hit,
            .score = score,
            .start_music = start_music,
        };
    }

    pub fn deinit(self: *Self) void {
        rl.unloadSound(self.hit);
        rl.unloadSound(self.score);
        rl.unloadMusicStream(self.start_music);
    }
};
