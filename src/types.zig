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
