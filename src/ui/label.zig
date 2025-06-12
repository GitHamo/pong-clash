const rl = @import("raylib");

pub const Label = struct {
    text: [:0]const u8,
    x: f32,
    y: f32,
    font_size: i32,
    color: rl.Color,
    font: ?rl.Font = null,

    pub fn init(
        text: [:0]const u8,
        position_x: f32,
        position_y: f32,
        font_size: i32,
        color: rl.Color,
    ) Label {
        return .{
            .text = text,
            .x = position_x,
            .y = position_y,
            .font_size = font_size,
            .color = color,
        };
    }

    pub fn draw(self: *const Label) void {
        rl.drawText(@ptrCast(self.text), @intFromFloat(self.x), @intFromFloat(self.y), self.font_size, self.color);
    }

    pub fn center(self: *Label, screen_width: f32, screen_height: f32) void {
        self.centerX(screen_width);
        self.centerY(screen_height);
    }

    pub fn centerX(self: *Label, screen_width: f32) void {
        const text_width = rl.measureText(@ptrCast(self.text), self.font_size);
        self.x = (screen_width - @as(f32, @floatFromInt(text_width))) / 2;
    }

    pub fn centerY(self: *Label, screen_height: f32) void {
        const text_height = @as(f32, @floatFromInt(self.font_size));
        self.y = (screen_height - text_height) / 2;
    }
};
