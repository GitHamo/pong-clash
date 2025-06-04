const std = @import("std");
const rl = @import("raylib");

const Ball = @import("ball.zig").Ball;
const Game = @import("game.zig").Game;
const GamePlayMode = @import("game.zig").GamePlayMode;
const Paddle = @import("paddle.zig").Paddle;

pub const Player = struct {
    mode: GamePlayMode,
    paddle: ?Paddle,
    score: f32,

    const Self = @This();

    pub fn init(mode: GamePlayMode, paddle: ?Paddle) Self {
        return Self{
            .mode = mode,
            .paddle = paddle,
            .score = 0,
        };
    }

    pub fn draw(self: *Self) void {
        if (self.paddle) |*paddle| {
            paddle.draw();
        }
    }
};
