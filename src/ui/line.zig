const rl = @import("raylib");

const Orientation = enum {
    horizontal,
    vertical,
};

const Style = enum {
    solid,
    dashed,
};

const Position = @Vector(2, f32);

pub const Line = struct {
    start: Position,
    end: Position,
    width: f32,
    gap: f32 = 0,
    style: Style,
    orientation: Orientation,
    color: rl.Color,

    const Self = @This();

    pub fn init(start: Position, end: Position, width: f32, style: Style, orientation: Orientation, color: rl.Color) Self {
        return Self{
            .start = start,
            .end = end,
            .width = width,
            .style = style,
            .orientation = orientation,
            .gap = 0,
            .color = color,
        };
    }

    pub fn draw(self: Self) void {
        switch (self.style) {
            .solid => self.draw_line_solid(),
            .dashed => self.draw_line_dashed(),
        }
    }

    fn draw_line_solid(self: Self) void {
        rl.drawLineV(
            .{ .x = self.start[0], .y = self.start[1] },
            .{ .x = self.end[0], .y = self.end[1] },
            self.color,
        );
    }

    fn draw_line_dashed(self: Self) void {
        const line_x = self.start[0];
        const line_y_start = self.start[1];
        const line_y_end = self.end[1];
        const dash_length = self.width;
        const dash_gap = @divTrunc(dash_length, 2);

        var y: f32 = line_y_start;
        while (y < line_y_end) : (y += dash_length + dash_gap) {
            const y_end = @min(y + dash_length, line_y_end);

            rl.drawLineV(.{ .x = line_x, .y = y }, .{ .x = line_x, .y = y_end }, .white);
        }
    }
};
