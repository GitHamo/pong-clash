const std = @import("std");
const Allocator = std.mem.Allocator;
const rl = @import("raylib");
const sfx = @import("../audio.zig").SFX;
const Ball = @import("ball.zig").Ball;
const Paddle = @import("paddle.zig").Paddle;
const ArenaConfig = @import("../types.zig").ArenaConfig;
const GameRound = @import("round.zig").RoundManager;
const GameSpawner = @import("spawner.zig");
const Line = @import("ui_components").Line;

pub const Arena = struct {
    allocator: Allocator,
    config: *const ArenaConfig,
    round: GameRound,
    ball: Ball,
    paddles: []Paddle,
    separator: Line,

    const Self = @This();

    pub fn init(allocator: Allocator, config: *const ArenaConfig, sounds: sfx) Self {
        const round = GameSpawner.createRound();
        const ball = GameSpawner.createBall(config, sounds);
        const paddles = GameSpawner.createPaddles(allocator, config) catch unreachable;
        const separator = create_arena_separator(config);

        return Self{
            .allocator = allocator,
            .config = config,
            .round = round,
            .ball = ball,
            .paddles = paddles,
            .separator = separator,
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

        self.update_paddles();

        const score = self.ball.update(&self.paddles);

        if (score) |player_id| {
            self.round.score(player_id);
            std.debug.print("Score: {d}-{d}\n", .{ self.round.scores.player1, self.round.scores.player2 });
        }
    }

    pub fn draw(self: *Self) void {
        self.ball.draw();

        self.separator.draw();

        for (self.paddles) |*paddle| {
            paddle.draw();
        }
    }

    pub fn reset(self: *Self) void {
        self.round.reset();
        self.ball.reset();
    }

    fn update_paddles(self: *Self) void {
        const screen_height = self.config.h;

        switch (self.config.game.mode) {
            .practice, .one_player => {
                if (self.paddles.len > 0) {
                    const paddle_left = &self.paddles[0];
                    if (rl.isKeyDown(.w) or rl.isKeyDown(.up)) {
                        paddle_left.move(-1, screen_height);
                    }
                    if (rl.isKeyDown(.s) or rl.isKeyDown(.down)) {
                        paddle_left.move(1, screen_height);
                    }
                }
            },
            .cpu, .cpu_vs_cpu => {
                if (self.paddles.len > 0) {
                    self.paddles[0].update(.auto_response, &self.ball);
                }
            },
            else => {},
        }

        switch (self.config.game.mode) {
            .two_players => {
                if (self.paddles.len > 1) {
                    const paddle_right = &self.paddles[1];
                    if (rl.isKeyDown(.up)) {
                        paddle_right.move(-1, screen_height);
                    }
                    if (rl.isKeyDown(.down)) {
                        paddle_right.move(1, screen_height);
                    }
                }
            },
            .one_player, .cpu_vs_cpu => {
                if (self.paddles.len > 1) {
                    self.paddles[1].update(.auto_reaction, &self.ball);
                }
            },
            else => {},
        }
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

fn create_arena_separator(config: ArenaConfig) Line {
    const separator_x = config.w / 2;
    const separator_y_start = 0;
    const separator_y_end = config.h;
    const separator_width = 20;
    const separator_start = @Vector(2, f32){ separator_x, separator_y_start };
    const separator_end = @Vector(2, f32){ separator_x, separator_y_end };

    return Line.init(
        separator_start,
        separator_end,
        separator_width,
        .dashed,
        .vertical,
        .white,
    );
}
