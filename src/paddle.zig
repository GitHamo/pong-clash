const std = @import("std");
const rl = @import("raylib");

const Ball = @import("ball.zig").Ball;
const GamePlayMode = @import("game.zig").GamePlayMode;

pub const Paddle = struct {
    x: f32,
    y: f32,
    w: f32, // width
    h: f32, // height
    s: f32, // speed

    const Self = @This();

    pub fn init(x: f32, y: f32, w: f32, h: f32, s: f32) Self {
        return Self{
            .x = x,
            .y = y,
            .w = w,
            .h = h,
            .s = s,
        };
    }

    pub fn update(self: *Self, d: f32, screen_h: f32) void {
        self.y += d * self.s;
        self.y = std.math.clamp(self.y, 0, screen_h - self.h);
    }

    pub fn draw(self: *Self) void {
        rl.drawRectangle(
            @intFromFloat(self.x),
            @intFromFloat(self.y),
            @intFromFloat(self.w),
            @intFromFloat(self.h),
            .white,
        );
    }

    pub fn move(self: *Self, mode: GamePlayMode, ball: Ball) void {
        switch (mode) {
            .auto_response => self.get_auto_response(ball, 0.9),
            .auto_reaction => self.get_auto_reaction(ball, 0.8),
            else => unreachable,
        }
    }

    fn get_auto_response(self: *Self, ball: Ball, factor: f32) void {
        var prng = std.Random.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            std.posix.getrandom(std.mem.asBytes(&seed)) catch unreachable;
            break :blk seed;
        });
        const rand = prng.random();

        // approach #1: reduce response
        if (self.y + self.h / 2 < ball.y) {
            if (rand.float(f32) < factor) {
                self.update(1, ball.screen_h);
            }
        } else if (self.y + self.h / 2 > ball.y) {
            if (rand.float(f32) < factor) {
                self.update(-1, ball.screen_h);
            }
        }
    }

    fn get_auto_reaction(self: *Self, ball: Ball, factor: f32) void {
        // approach #2: delay reaction
        if (ball.x > ball.screen_w * factor) {
            if (self.y + self.h / 2 < ball.y) {
                self.update(1, ball.screen_h);
            } else if (self.y + self.h / 2 > ball.y) {
                self.update(-1, ball.screen_h);
            }
        }
    }
};
