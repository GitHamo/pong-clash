const std = @import("std");
const rl = @import("raylib");
const Game = @import("game.zig").Game;
const GameMode = @import("game.zig").GameMode;
const GamePlayMode = @import("game.zig").GamePlayMode;
const Paddle = @import("paddle.zig").Paddle;
const Player = @import("player.zig").Player;

pub const Ball = struct {
    x: f32,
    y: f32,
    r: f32, // radius
    vx: f32,
    vy: f32,
    s: f32, // speed
    screen_w: f32, // screen width
    screen_h: f32, // screen height

    const Self = @This();

    pub fn init(x: f32, y: f32, r: f32, s: f32, screen_w: f32, screen_h: f32) Self {
        return Self{
            .x = x,
            .y = y,
            .r = r,
            .vx = s,
            .vy = s,
            .s = s,
            .screen_w = screen_w,
            .screen_h = screen_h,
        };
    }

    pub fn update(self: *Self, game: *Game) void {
        self.x += self.vx;
        self.y += self.vy;

        self.check_collision(game);
    }

    pub fn draw(self: *Self) void {
        rl.drawCircle(
            @intFromFloat(self.x),
            @intFromFloat(self.y),
            self.r,
            .white,
        );
    }

    fn reset(self: *Self) void {
        self.x = self.screen_w / 2;
        self.y = self.screen_h / 2;
        self.vx = if ((self.vx > 0)) -self.s else self.s;
        self.vy = self.s;
    }

    fn bounceOff(self: *Self) void {
        self.vx = -self.vx;
    }

    fn check_collision(self: *Self, game: *Game) void {
        if (self.y - self.r < 0 or self.y + self.r > self.screen_h) {
            // handle top/bottom wall collision
            self.vy = -self.vy;
        }

        const ball_mid_y = self.y;

        // LEFT SIDE
        if (self.x - self.r < 0) {
            const paddle_left = game.player_one.paddle orelse unreachable;

            // Check if ball is within paddle height
            const collision =
                ball_mid_y > paddle_left.y and
                ball_mid_y < paddle_left.y + paddle_left.h;

            if (collision) {
                self.vx = -self.vx;
                self.x = self.r; // Push ball just outside wall
            } else {
                game.player_two.score += 1;
                self.reset();
            }
        }

        // RIGHT SIDE
        if (self.x + self.r > game.screen_w) {
            const paddle_right = game.player_two.paddle;

            if (paddle_right) |paddle| {
                const collision =
                    ball_mid_y > paddle.y and
                    ball_mid_y < paddle.y + paddle.h;

                if (collision) {
                    // handle right wall collision as a paddle hit (bounce off)
                    self.bounceOff();
                } else {
                    // handle right wall collision as a paddle miss (score to player 1)
                    game.player_one.score += 1;
                    self.reset();
                }
            } else {
                // handle right wall collision as a wall hit (bounce off)
                self.bounceOff();
            }
        }
    }
};
