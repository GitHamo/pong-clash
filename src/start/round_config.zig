const std = @import("std");
const rl = @import("raylib");
const ui = @import("ui_components");
const Game = @import("../types.zig");
const Button = ui.Button;
const GameMode = Game.GameMode;
const GameLevel = Game.GameLevel;
const GameOver = Game.GameOver;
const GameRoundConfig = Game.GameConfig;

pub const GameRoundConfigButtons = struct {
    left: std.ArrayList(Button),
    middle: std.ArrayList(Button),
    right: std.ArrayList(Button),
    selected: GameRoundConfig = .{},

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, screen_width: f32, screen_height: f32) !Self {
        const column_positions = calc_column_positions(screen_width, 3);

        return Self{
            .left = try create_game_options_column(allocator, column_positions[0], screen_height, GameOver),
            .middle = try create_game_options_column(allocator, column_positions[1], screen_height, GameMode),
            .right = try create_game_options_column(allocator, column_positions[2], screen_height, GameLevel),
        };
    }

    pub fn deinit(self: *Self) void {
        self.left.deinit();
        self.middle.deinit();
        self.right.deinit();
    }

    // pub fn resize(self: *Self) void {} // todo:

    pub fn reset(self: *Self) void {
        self.selected = .{};
    }

    pub fn draw(self: *Self) void {
        for (self.left.items) |*button| {
            button.draw();
        }

        for (self.middle.items) |*button| {
            button.draw();
        }

        for (self.right.items) |*button| {
            button.draw();
        }
    }

    pub fn update(self: *Self) *const GameRoundConfig {
        self.preselectFocus();
        for (self.left.items, 0..) |*button, i| {
            if (button.update()) {
                self.resetFocus(&self.left);
                self.selected.win = switch (i) {
                    0 => .seconds,
                    1 => .points,
                    else => unreachable,
                };
                button.setFocus(true);
            }
        }
        for (self.middle.items, 0..) |*button, i| {
            if (button.update()) {
                self.resetFocus(&self.middle);
                self.selected.mode = switch (i) {
                    0 => .none,
                    1 => .practice,
                    2 => .one_player,
                    3 => .two_players,
                    4 => .cpu_vs_cpu,
                    5 => .cpu,
                    else => unreachable,
                };
                button.setFocus(true);
            }
        }
        for (self.right.items, 0..) |*button, i| {
            if (button.update()) {
                self.resetFocus(&self.right);
                self.selected.level = switch (i) {
                    0 => .easy,
                    1 => .medium,
                    2 => .hard,
                    else => unreachable,
                };
                button.setFocus(true);
            }
        }

        return &self.selected;
    }

    fn resetFocus(_: *Self, buttons_group: *std.ArrayList(Button)) void {
        for (buttons_group.items) |*other_button| {
            other_button.setFocus(false);
        }
    }

    fn preselectFocus(self: *Self) void {
        const initial_config = self.selected;

        for (self.left.items, 0..) |*button, i| {
            const should_select = switch (i) {
                0 => initial_config.win == .seconds,
                1 => initial_config.win == .points,
                else => false,
            };
            button.setFocus(should_select);
        }

        for (self.middle.items, 0..) |*button, i| {
            const should_select = switch (i) {
                0 => initial_config.mode == .none,
                1 => initial_config.mode == .practice,
                2 => initial_config.mode == .one_player,
                3 => initial_config.mode == .two_players,
                4 => initial_config.mode == .cpu_vs_cpu,
                5 => initial_config.mode == .cpu,
                else => false,
            };
            button.setFocus(should_select);
        }

        for (self.right.items, 0..) |*button, i| {
            const should_select = switch (i) {
                0 => initial_config.level == .easy,
                1 => initial_config.level == .medium,
                2 => initial_config.level == .hard,
                else => false,
            };
            button.setFocus(should_select);
        }
    }
};

fn create_game_options_column(
    allocator: std.mem.Allocator,
    column_center_x: f32,
    screen_height: f32,
    comptime OptionsType: type,
) !std.ArrayList(Button) {
    var buttons = std.ArrayList(Button).init(allocator);
    const fields = std.meta.fields(OptionsType);

    inline for (fields, 0..) |field, i| {
        try buttons.append(Button.init(
            column_center_x - 100, // Center button in column
            screen_height / 2 - 170 + @as(f32, @floatFromInt(i)) * 60,
            200,
            50,
            field.name,
            .white,
            24,
            .{ .r = 0, .g = 120, .b = 0, .a = 255 },
            .{ .r = 0, .g = 150, .b = 0, .a = 255 },
            .{ .r = 0, .g = 90, .b = 0, .a = 255 },
            .blue,
        ));
    }

    return buttons;
}

fn calc_column_positions(screen_width: f32, column_count: f32) [3]f32 {
    const padding: f32 = 10;
    const total_padding = padding * (column_count - 1);
    const column_width = (screen_width - total_padding) / column_count;

    return [3]f32{ column_width / 2, column_width / 2 + column_width + padding, column_width / 2 + (column_width + padding) * 2 };
}
