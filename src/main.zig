const std = @import("std");
const rl = @import("raylib");
const Game = @import("game.zig").Game;
const GameState = @import("game.zig").GameState;
const display = @import("display.zig");
const sfx = @import("audio.zig").SFX;

pub fn main() !void {
    const initialWidth = 1280;
    const initialHeight = 720;
    const maxScore = 100;

    rl.initWindow(initialWidth, initialHeight, "Pong!!");
    defer rl.closeWindow();

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    rl.setTargetFPS(60);

    var sounds = try sfx.init();
    defer sounds.deinit();

    var currentState = GameState.start;
    var game = Game.init(initialWidth, initialHeight, maxScore, .cpu_vs_cpu, sounds) catch |err| {
        std.log.err("Failed to initialize game: {any}", .{err});
        return err;
    };
    defer game.deinit();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.black);

        try display.update(&currentState, &game, sounds.start_music);
        try display.draw(currentState, &game);
    }
}
