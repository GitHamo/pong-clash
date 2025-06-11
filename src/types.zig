pub const GameRoute = enum {
    start,
    game,
    exit,
};

pub const GameMode = enum {
    none,
    practice,
    one_player,
    two_players,
    cpu_vs_cpu,
    cpu,
};

pub const GameLevel = enum {
    easy,
    medium,
    hard,
};

pub const PaddleMode = enum {
    auto_response,
    auto_reaction,
    manual,
};

pub const GameOver = enum {
    seconds,
    points,
};

pub const GameConfig = struct {
    mode: GameMode = .none,
    level: GameLevel = .medium,
    win: GameOver = .seconds,
};

pub const ArenaConfig = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    ball_radius: f32 = 10,
    paddle_width: f32 = 10,
    paddle_margin: f32 = 10,
    game: GameConfig = .{},
};
