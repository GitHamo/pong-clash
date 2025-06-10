const std = @import("std");
const Allocator = std.mem.Allocator;
const rl = @import("raylib");
const sfx = @import("../audio.zig").SFX;
const Ball = @import("ball.zig").Ball;
const Paddle = @import("paddle.zig").Paddle;
const Game = @import("game.zig");
const GameMode = Game.GameMode;
const GameLevel = Game.GameLevel;
const PaddleMode = Game.PaddleMode;
const Gameplay = @import("play.zig").Gameplay;
const GameRound = @import("round.zig").RoundManager;

pub const ArenaConfig = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    ball_radius: f32,
    ball_speed: f32,
    paddle_width: f32,
    paddle_height: f32,
    paddle_margin: f32,
    paddle_speed: f32,
    game_mode: GameMode,
    game_level: GameLevel,
};

pub const Arena = struct {
    allocator: Allocator,
    config: ArenaConfig,
    round: GameRound,
    ball: Ball,
    paddles: []Paddle,

    const Self = @This();

    pub fn init(allocator: Allocator, config: ArenaConfig, round: GameRound, sounds: sfx) Self {
        const screen_width = config.w;
        const screen_height = config.h;
        const ball_x = screen_width / 2;
        const ball_y = screen_height / 2;

        const ball = Ball.init(
            ball_x,
            ball_y,
            config.ball_radius,
            config.ball_speed,
            screen_width,
            screen_height,
            sounds,
        );

        const paddles = create_paddles(allocator, config) catch unreachable;

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
        self.ball.update();

        for (self.paddles, 0..) |*paddle, i| {
            const mode: PaddleMode = switch (self.config.game_mode) {
                .none => unreachable,
                .practice, .two_players => .manual,
                .one_player => if (i == 0) .manual else .auto_response,
                .cpu_vs_cpu => if (i == 0) .auto_reaction else .auto_response,
                .cpu => .auto_response,
            };
            paddle.update(mode, self.ball);
        }

        self.check_collision();
    }

    pub fn draw(self: *Self) void {
        self.ball.draw();

        for (self.paddles) |*paddle| {
            paddle.draw();
        }
    }

    pub fn reset(self: *Self) void {
        self.ball.reset();
    }

    fn check_collision(self: *Self) void {
        self.check_collision_y();
        self.check_collision_x_left();
        self.check_collision_x_right();
        self.check_collision_x_left_p();
        self.check_collision_x_right_p();
    }

    fn check_collision_y(self: *Self) void {
        if (self.ball.y - self.ball.r < 0 or self.ball.y + self.ball.r > self.config.h) {
            self.ball.bounce_y();
        }
    }

    fn check_collision_x_left_p(self: *Self) void {
        if (self.paddles.len > 0) {
            if (check_p_collision(self.ball, self.paddles[0])) {
                self.ball.bounce_x();
            }
        }
    }

    fn check_collision_x_right_p(self: *Self) void {
        if (self.paddles.len > 1) {
            if (check_p_collision(self.ball, self.paddles[1])) {
                self.ball.bounce_x();
            }
        }
    }

    fn check_collision_x_left(self: *Self) void {
        // Left wall
        if (self.ball.x - self.ball.r < 0) {
            if (self.paddles.len > 0) {
                self.round.score(1); // player2 scores
                self.reset();
            } else {
                self.ball.bounce_x();
            }
        }
    }

    fn check_collision_x_right(self: *Self) void {
        if (self.ball.x + self.ball.r > self.config.w) {
            if (self.paddles.len > 1) {
                self.round.score(0); // player1 scores
                self.reset();
            } else {
                self.ball.bounce_x();
            }
        }
    }
};

fn check_p_collision(ball: Ball, paddle: Paddle) bool {
    const paddle_top = paddle.y;
    const paddle_bottom = paddle.y + paddle.height;
    const paddle_left = paddle.x;
    const paddle_right = paddle.x + paddle.width;

    return (ball.x + ball.r > paddle_left and
        ball.x - ball.r < paddle_right and
        ball.y + ball.r > paddle_top and
        ball.y - ball.r < paddle_bottom);
}

fn create_paddles(allocator: Allocator, config: ArenaConfig) ![]Paddle {
    const paddle_count: u8 = switch (config.game_mode) {
        .none => 0,
        .practice, .cpu => 1,
        .one_player, .two_players, .cpu_vs_cpu => 2,
    };

    var paddles = try allocator.alloc(Paddle, paddle_count);

    switch (config.game_mode) {
        .none => {},
        .practice, .cpu => {
            paddles[0] = create_paddle(config);
        },
        .one_player, .two_players, .cpu_vs_cpu => {
            paddles[0] = create_paddle(config);
            paddles[1] = create_paddle(config);
        },
    }

    return paddles;
}

fn create_paddle(config: ArenaConfig) Paddle {
    return Paddle.init(
        config.paddle_margin,
        config.h / 2,
        config.paddle_width,
        config.paddle_height,
        config.paddle_speed,
    );
}
