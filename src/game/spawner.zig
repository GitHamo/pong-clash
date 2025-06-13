const std = @import("std");
const sfx = @import("../audio.zig").SFX;
const ArenaConfig = @import("../types.zig").ArenaConfig;
const Gameplay = @import("play.zig");
const GameRound = @import("round.zig").RoundManager;
const Ball = @import("ball.zig").Ball;
const Paddle = @import("paddle.zig").Paddle;

const ROUND_MAX_POINTS = 10;

pub fn createRound() GameRound {
    return GameRound.init(ROUND_MAX_POINTS);
}

pub fn createBall(config: *const ArenaConfig, sounds: sfx) Ball {
    const screen_width = config.w;
    const screen_height = config.h;
    const ball_x = screen_width / 2;
    const ball_y = screen_height / 2;
    return Ball.init(
        ball_x,
        ball_y,
        config.ball_radius,
        Gameplay.getBallSpeed(config.game.level),
        screen_width,
        screen_height,
        sounds,
    );
}

pub fn createPaddles(allocator: std.mem.Allocator, config: *const ArenaConfig) ![]Paddle {
    const paddle_count: u8 = switch (config.game.mode) {
        .none => 0,
        .practice, .cpu => 1,
        .one_player, .two_players, .cpu_vs_cpu => 2,
    };

    var paddles = try allocator.alloc(Paddle, paddle_count);

    switch (config.game.mode) {
        .none => {},
        .practice, .cpu => {
            paddles[0] = create_paddle(config, config.paddle_margin);
        },
        .one_player, .two_players, .cpu_vs_cpu => {
            paddles[0] = create_paddle(config, config.paddle_margin);
            paddles[1] = create_paddle(config, config.w - config.paddle_margin);
        },
    }

    return paddles;
}

fn create_paddle(config: *const ArenaConfig, x: f32) Paddle {
    return Paddle.init(
        x,
        config.h / 2,
        config.paddle_width,
        Gameplay.getPaddleHeight(config.game.level),
        Gameplay.getPaddleSpeed(config.game.level),
    );
}
