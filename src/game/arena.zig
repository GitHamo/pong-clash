const std = @import("std");
const Allocator = std.mem.Allocator;
const rl = @import("raylib");
const sfx = @import("../audio.zig").SFX;
const Ball = @import("ball.zig").Ball;
const Paddle = @import("paddle.zig").Paddle;
const Game = @import("game.zig");
const ArenaConfig = Game.ArenaConfig;
const GameConfig = Game.GameConfig;
const GameMode = Game.GameMode;
const GameLevel = Game.GameLevel;
const GameOver = Game.GameOver;
const PaddleMode = Game.PaddleMode;
const Gameplay = @import("play.zig").Gameplay;
const GameRound = @import("round.zig").RoundManager;
const GameSpawner = @import("spawner.zig");

pub const Arena = struct {
    allocator: Allocator,
    config: ArenaConfig,
    round: GameRound,
    ball: Ball,
    paddles: []Paddle,

    const Self = @This();

    pub fn init(allocator: Allocator, config: ArenaConfig, sounds: sfx) Self {
        const round = GameSpawner.createRound();
        const ball = GameSpawner.createBall(config, sounds);
        const paddles = GameSpawner.createPaddles(allocator, config) catch unreachable;

        return Self{
            .allocator = allocator,
            .config = config,
            .round = round,
            .ball = ball,
            .paddles = paddles,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.paddles);
    }

    pub fn update(self: *Self) void {
        self.round.update();

        switch (self.round.state) {
            .ended => {
                self.reset();
                self.round.reset();
                // TODO: Play game over sound
                // TODO: Show game over screen
            },
            else => {},
        }

        for (self.paddles, 0..) |*paddle, i| {
            const mode: PaddleMode = switch (self.config.game.mode) {
                .none => unreachable,
                .practice, .two_players => .manual,
                .one_player => if (i == 0) .manual else .auto_response,
                .cpu_vs_cpu => if (i == 0) .auto_reaction else .auto_response,
                .cpu => .auto_response,
            };
            paddle.update(mode, &self.ball);
        }

        const score = self.ball.update(&self.paddles);

        if (score) |player_id| {
            self.round.score(player_id);
            std.debug.print("Score: {d}-{d}\n", .{ self.round.scores.player1, self.round.scores.player2 });
        }
    }

    pub fn draw(self: *Self) void {
        self.ball.draw();

        for (self.paddles) |*paddle| {
            paddle.draw();
        }
    }

    pub fn reset(self: *Self) void {
        self.round.reset();
        self.ball.reset();
    }
};

fn create_paddles(allocator: Allocator, config: ArenaConfig) ![]Paddle {
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

fn create_paddle(config: ArenaConfig, x: f32) Paddle {
    return Paddle.init(
        x,
        config.h / 2,
        config.paddle_width,
        config.paddle_height,
        config.paddle_speed,
    );
}
