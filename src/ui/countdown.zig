const std = @import("std");
const Allocator = std.mem.Allocator;
const rl = @import("raylib");

pub const Countdown = struct {
    allocator: Allocator,
    start_time: f64,
    seconds: i32,
    remaining: i32,

    const Self = @This();

    pub fn init(allocator: Allocator, seconds: i32) Self {
        return Self{
            .allocator = allocator,
            .start_time = rl.getTime(),
            .seconds = seconds,
            .remaining = seconds,
        };
    }

    pub fn update(self: *Self) void {
        const current_time = rl.getTime();
        const elapsed = current_time - self.start_time;
        self.remaining = @max(0, self.seconds - @as(i32, @intFromFloat(elapsed)));

        if (self.remaining == 0) {
            self.start_time = current_time;
        }
    }

    pub fn draw(self: *Self) void {
        if (self.remaining > 0) {
            const text = std.fmt.allocPrintZ(self.allocator, "{d}", .{self.remaining}) catch "3";
            defer self.allocator.free(text);

            rl.drawText(text, 350, 280, 60, .white);
        } else {
            rl.drawText("GO!", 350, 280, 60, .green);
        }
    }

    pub fn isOver(self: *Self) bool {
        return self.remaining == 0;
    }
};
