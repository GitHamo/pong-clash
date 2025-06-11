const std = @import("std");
const rl = @import("raylib");
const Ball = @import("ball.zig").Ball;
const PaddleMode = @import("game.zig").PaddleMode;

const RESPONSE_FACTOR = 0.9; // less is easier
const REACTION_FACTOR = 0.05; // less is harder

pub const Paddle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    speed: f32,

    const Self = @This();

    pub fn init(x: f32, y: f32, width: f32, height: f32, speed: f32) Self {
        return Self{
            .x = x,
            .y = y,
            .width = width,
            .height = height,
            .speed = speed,
        };
    }

    pub fn update(self: *Self, mode: PaddleMode, ball: *const Ball) void {
        switch (mode) {
            .auto_response => self.get_auto_response(ball.y, ball.screen_h, RESPONSE_FACTOR),
            .auto_reaction => self.get_auto_reaction(ball.x, ball.y, ball.screen_w, ball.screen_h, REACTION_FACTOR),
            else => {}, // manual handle
        }
    }

    pub fn draw(self: *Self) void {
        rl.drawRectangle(
            @intFromFloat(self.x),
            @intFromFloat(self.y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            .white,
        );
    }

    pub fn resize(_: *Self, _: f32, _: f32) void {}

    fn get_auto_response(self: *Self, ball_y: f32, screen_height: f32, factor: f32) void {
        var prng = std.Random.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            std.posix.getrandom(std.mem.asBytes(&seed)) catch unreachable;
            break :blk seed;
        });
        const rand = prng.random();

        // approach #1: reduce response
        if (self.y + self.height / 2 < ball_y) {
            if (rand.float(f32) < factor) {
                self.move(1, screen_height);
            }
        } else if (self.y + self.height / 2 > ball_y) {
            if (rand.float(f32) < factor) {
                self.move(-1, screen_height);
            }
        }
    }

    fn get_auto_reaction(self: *Self, ball_x: f32, ball_y: f32, screen_width: f32, screen_height: f32, factor: f32) void {
        // approach #2: delay reaction
        if (ball_x > screen_width * factor) {
            if (self.y + self.height / 2 < ball_y) {
                self.move(1, screen_height);
            } else if (self.y + self.height / 2 > ball_y) {
                self.move(-1, screen_height);
            }
        }
    }

    pub fn move(self: *Self, direction: f32, screen_height: f32) void {
        // TODO: move auto
        self.y += direction * self.speed;
        self.y = std.math.clamp(self.y, 0, screen_height - self.height);
        // TODO: move manual

    }
};
