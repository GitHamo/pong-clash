const std = @import("std");
const rl = @import("raylib");
const Game = @import("game.zig").Game;
const GameState = @import("game.zig").GameState;

pub fn update(state: *GameState, game: *Game) void {
    switch (state.*) {
        .start => {
            // update
        },
        .playing => {
            if (rl.isKeyPressed(.p)) {
                state.* = GameState.paused;
            }

            game.update();

            if (game.shouldEnd()) {
                state.* = GameState.start;
            }
        },
        .paused => {
            if (rl.isKeyPressed(.p)) {
                state.* = GameState.playing;
            }
            // Optional: update pause menu here
        },
    }
}

pub fn draw(state: GameState, game: *Game) void {
    const screen_width = rl.getScreenWidth();
    const screen_height = rl.getScreenHeight();

    switch (state) {
        .start => {
            //
        },
        .playing => {
            draw_game(game, screen_width, screen_height);
        },
        .paused => {
            draw_game(game, screen_width, screen_height); // Still draw game underneath pause overlay
            draw_pause_screen(screen_width, screen_height);
        },
    }

}

fn draw_start_screen(_: i32, _: i32) void {}

fn draw_pause_screen(w: i32, h: i32) void {
    rl.drawRectangle(0, 0, w, h, rl.Color{ .r = 0, .g = 0, .b = 0, .a = 192 });

    const message = "PAUSED";
    const font_size: i32 = 80;
    const text_width = rl.measureText(message, font_size);
    const text_x: i32 = @intFromFloat(@as(f32, @floatFromInt(w-text_width)) / 2);
    const text_y: i32 = @intFromFloat(@as(f32, @floatFromInt(h - font_size)) / 2);

    rl.drawText(message, text_x, text_y, font_size, .white);
}

fn draw_game(game: *Game, width: i32, height: i32) void {
    game.draw();
    draw_info_bar(width, height, 20);
    draw_game_bar(game);
}

fn draw_info_bar(w: i32, h: i32, fs: i32) void {
    const bar_width = w;
    const bar_height = 23;
    const bar_x = 0;
    const bar_y = h - bar_height;
    const padding = 3;

    rl.drawRectangle(bar_x, bar_y, bar_width, bar_height, rl.Color{ .r = 191, .g = 191, .b = 191, .a = 191 });

    var buffer: [64:0]u8 = undefined;
    const fps_text = std.fmt.bufPrintZ(&buffer, "FPS: {d} - [P] Pause [N] New [O] Out", .{ rl.getFPS() }) catch unreachable;

    rl.drawText(fps_text, @intCast(2 + padding), @intCast(bar_y + padding), fs, .black);
}

fn draw_game_bar(game: *Game) void {
    const score_one: i32 = @intFromFloat(game.player_one.score);
    const score_two: i32 = @intFromFloat(game.player_two.score);
    const screen_width: i32 = @intFromFloat(game.screen_w);
    const control_bar_width: i32 = @intFromFloat(game.screen_w * 0.8);
    const control_bar_height: i32 = @intFromFloat(game.screen_h * 0.1);
    const control_bar_x: i32 = @divTrunc(screen_width - control_bar_width, 2);
    const control_bar_y = 0;
    const control_bar_full_width: i32 = @intFromFloat(@as(f32, @floatFromInt(control_bar_width)) * game.player_one.score / game.max_score); // todo: make it from both

    // control bar
    rl.drawRectangle(
        0,
        control_bar_y,
        screen_width,
        control_bar_height,
        rl.Color{ .r = 191, .g = 191, .b = 191, .a = 191 }, // 75% .gray
    );

    // score bar
    rl.drawRectangle(control_bar_x, control_bar_y, control_bar_full_width, control_bar_height, .green);

    const score_text_size = calculate_font_size(game.screen_h);

    var buffer_left: [64:0]u8 = undefined;
    var buffer_right: [64:0]u8 = undefined;

    const score_left_text = std.fmt.bufPrintZ(&buffer_left, "{d}/{d}", .{ score_one, game.max_score }) catch unreachable;
    const score_right_text = std.fmt.bufPrintZ(&buffer_right, "{d}/{d}", .{ score_two, game.max_score }) catch unreachable;

    rl.drawText(score_left_text, @intCast(control_bar_x + 10), @intCast(control_bar_y + 10), score_text_size, .black);
    rl.drawText(score_right_text, @intCast(control_bar_width), @intCast(control_bar_y + 10), score_text_size, .black);
}

fn calculate_font_size(height: f32) i32 {
    const base_height: f32 = 450.0;
    const base_font: f32 = 30.0;

    const scale = height / base_height;
    const font_size = base_font * scale;

    return @intFromFloat(font_size);
}
