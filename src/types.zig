pub const GameRoute = enum {
    start,
    playing,
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

pub const PlayerMode = enum {
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

pub const RoundConfig = struct {
    mode: GameMode,
    level: GameLevel,
    win: GameOver,
};
