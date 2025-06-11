const std = @import("std");
const rl = @import("raylib");
const sfx = @import("../audio.zig").SFX;
const collision = @import("collision.zig");
const Paddle = @import("paddle.zig").Paddle;

pub const Ball = struct {
    x: f32,
    y: f32,
    r: f32,
    vx: f32,
    vy: f32,
    s: f32,
    screen_w: f32,
    screen_h: f32,
    fx_hit: rl.Sound,
    fx_score: rl.Sound,

    const Self = @This();

    pub fn init(
        x: f32,
        y: f32,
        radius: f32,
        speed: f32,
        screen_w: f32,
        screen_h: f32,
        sounds: sfx,
    ) Self {
        return Self{
            .x = x,
            .y = y,
            .r = radius,
            .vx = speed,
            .vy = speed,
            .s = speed,
            .screen_w = screen_w,
            .screen_h = screen_h,
            .fx_hit = sounds.hit,
            .fx_score = sounds.score,
        };
    }

    pub fn update(self: *Self, paddles: *const []Paddle) ?u2 {
        self.x += self.vx;
        self.y += self.vy;

        if (collision.check_y_top(self) or collision.check_y_bottom(self)) {
            self.bounce_y();
        }

        if (collision.check_ps(self, paddles)) {
            self.bounce_x();
        }

        if (collision.check_x_left(self)) {
            if (paddles.len > 0) {
                self.reset();
                return 1; // player 2 scores
            }
            self.bounce_x();
        }

        if (collision.check_x_right(self)) {
            if (paddles.len > 1) {
                self.reset();
                return 0; // player 1 scores
            }
            self.bounce_x();
        }

        return null;
    }

    pub fn draw(self: *Self) void {
        rl.drawCircle(
            @intFromFloat(self.x),
            @intFromFloat(self.y),
            self.r,
            .white,
        );
    }

    pub fn resize(_: *Self, _: f32, _: f32) void {}

    pub fn reset(self: *Self) void {
        self.x = self.screen_w / 2;
        self.y = self.screen_h / 2;
        self.vx = if ((self.vx > 0)) -self.s else self.s;
        self.vy = self.s;

        rl.playSound(self.fx_score);
    }

    fn bounce_y(self: *Self) void {
        self.vy = -self.vy;
        rl.playSound(self.fx_hit);
    }

    fn bounce_x(self: *Self) void {
        self.vx = -self.vx;
        rl.playSound(self.fx_hit);
    }
};
