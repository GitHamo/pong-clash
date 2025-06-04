const std = @import("std");
const rl = @import("raylib");
const Game = @import("game.zig").Game;

pub fn main() !void {
    const initialWidth = 1280;
    const initialHeight = 720;
    const maxScore = 100;

    rl.initWindow(initialWidth, initialHeight, "Pong!!");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var game = Game.init(initialWidth, initialHeight, maxScore, .cpu_vs_cpu);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.black);

        game.update();
        game.draw();
    }
}
