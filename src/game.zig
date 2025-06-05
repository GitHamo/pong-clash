const std = @import("std");
const rl = @import("raylib");

const Ball = @import("ball.zig").Ball;
const Paddle = @import("paddle.zig").Paddle;
const Player = @import("player.zig").Player;

const PADDLE_PADDING = 10;
const PADDLE_WIDTH = 10;
const PADDLE_HEIGHT = 100;
const PADDLE_SPEED = 15;
const BALL_SPEED = 15;

pub const GameState = enum {
    start,
    playing,
    paused,
};

pub const GameMode = enum {
    practice,
    one_player,
    two_players,
    cpu_vs_cpu,
    cpu,
};

pub const GamePlayMode = enum {
    auto_response,
    auto_reaction,
    manual,
    wall,
};

pub const Game = struct {
    mode: GameMode,
    screen_w: f32,
    screen_h: f32,
    ball: Ball,
    player_one: Player,
    player_two: Player,
    max_score: f32,

    const Self = @This();

    pub fn init(width: f32, height: f32, max_score: f32, game_mode: GameMode) !Self {
        var player_one_mode: GamePlayMode = undefined;
        var player_two_mode: GamePlayMode = undefined;

        switch (game_mode) {
            .practice => {
                player_one_mode = GamePlayMode.manual;
                player_two_mode = GamePlayMode.wall;
            },
            .one_player => {
                var prng = std.Random.DefaultPrng.init(blk: {
                    var seed: u64 = undefined;
                    std.posix.getrandom(std.mem.asBytes(&seed)) catch unreachable;
                    break :blk seed;
                });
                const rand = prng.random();
                const index = rand.intRangeLessThan(usize, 1, 2);

                player_one_mode = GamePlayMode.manual;
                player_two_mode = GamePlayMode.auto_response;

                if (index == 1) {
                    player_two_mode = GamePlayMode.auto_reaction;
                }
            },
            .two_players => {
                player_one_mode = GamePlayMode.manual;
                player_two_mode = GamePlayMode.manual;
            },
            .cpu_vs_cpu => {
                player_one_mode = GamePlayMode.auto_response;
                player_two_mode = GamePlayMode.auto_reaction;
            },
            .cpu => {
                player_one_mode = GamePlayMode.auto_response;
                player_two_mode = GamePlayMode.wall;
            },
        }

        const player_one_paddle = Paddle.init(PADDLE_PADDING, height / 2, PADDLE_WIDTH, PADDLE_HEIGHT, PADDLE_SPEED);

        var player_two_paddle: ?Paddle = null;
        if (player_two_mode != GamePlayMode.wall) {
            player_two_paddle = Paddle.init(width - (PADDLE_PADDING + PADDLE_WIDTH), height / 2, PADDLE_WIDTH, PADDLE_HEIGHT, PADDLE_SPEED);
        }

        const player_one = Player.init(player_one_mode, player_one_paddle);
        const player_two = Player.init(player_two_mode, player_two_paddle);

        const ball = Ball.init(width / 2, height / 2, 10, BALL_SPEED, width, height) catch unreachable;

        return Self{
            .mode = game_mode,
            .screen_w = width,
            .screen_h = height,
            .ball = ball,
            .player_one = player_one,
            .player_two = player_two,
            .max_score = max_score,
        };
    }

    pub fn deinit(self: *Self) void {
        self.ball.deinit();
    }

    pub fn update(self: *Self) void {
        self.ball.update(self);

        self.update_player_left();
        self.update_player_right();
    }

    pub fn draw(self: *Self) void {
        self.ball.draw();
        self.player_one.draw();
        self.player_two.draw();
    }

    pub fn reset(self: *Self) !void {
        self.ball.reset();
        self.player_one.reset();
        self.player_two.reset();
    }

    pub fn shouldEnd(_: *Self) bool {
        return false;
    }

    fn update_player_left(self: *Self) void {
        var paddle = &(self.player_one.paddle orelse unreachable);
        switch (self.mode) {
            .practice, .one_player, .two_players => {
                if (rl.isKeyDown(.w)) {
                    paddle.update(-1, self.ball.screen_h);
                }

                if (rl.isKeyDown(.s)) {
                    paddle.update(1, self.ball.screen_h);
                }
            },
            .cpu, .cpu_vs_cpu => {
                paddle.move(self.player_one.mode, self.ball);
            },
        }
    }

    fn update_player_right(self: *Self) void {
        if (self.player_two.paddle) |*paddle| {
            switch (self.mode) {
                .practice, .two_players => {
                    if (rl.isKeyDown(.up)) {
                        paddle.update(-1, self.ball.screen_h);
                    }

                    if (rl.isKeyDown(.down)) {
                        paddle.update(1, self.ball.screen_h);
                    }
                },
                .cpu, .cpu_vs_cpu, .one_player => {
                    paddle.move(self.player_two.mode, self.ball);
                },
            }
        }
    }
};
