const std = @import("std");
const rl = @import("raylib");

pub const Button = struct {
    state: ButtonState,
    rect: rl.Rectangle,
    text: []const u8,
    font_size: i32,
    normal_color: rl.Color,
    hover_color: rl.Color,
    press_color: rl.Color,
    text_color: rl.Color,

    pub fn init(
        position_x: f32,
        position_y: f32,
        width: f32,
        height: f32,
        label: [:0]const u8,
        label_color: rl.Color,
        font_size: i32,
        color: rl.Color,
        hover_color: rl.Color,
        press_color: rl.Color,
    ) Button {
        return .{
            .state = .normal,
            .rect = rl.Rectangle{ .x = position_x, .y = position_y, .width = width, .height = height },
            .text = label,
            .font_size = font_size,
            .normal_color = color,
            .hover_color = hover_color,
            .press_color = press_color,
            .text_color = label_color,
        };
    }

    pub fn update(self: *Button) bool {
        const mouse_pos = rl.getMousePosition();
        const is_hovered = rl.checkCollisionPointRec(mouse_pos, self.rect);

        if (is_hovered) {
            // Set cursor to pointer when hovering
            rl.setMouseCursor(rl.MouseCursor.pointing_hand);

            if (rl.isMouseButtonDown(rl.MouseButton.left)) {
                self.state = .pressed;
            } else {
                self.state = .hovered;
            }

            // Return true if clicked (mouse button released while hovering)
            if (rl.isMouseButtonReleased(rl.MouseButton.left)) {
                return true;
            }
        } else {
            self.state = .normal;
        }

        return false;
    }

    pub fn draw(self: *Button) void {
        const color = switch (self.state) {
            .normal => self.normal_color,
            .hovered => self.hover_color,
            .pressed => self.press_color,
        };
        // Draw button background
        rl.drawRectangleRec(self.rect, color);
        rl.drawRectangleLinesEx(self.rect, 2, rl.Color.white);
        // Calculate text position to center it
        const text_width = rl.measureText(@ptrCast(self.text), self.font_size);
        const text_x = self.rect.x + (self.rect.width - @as(f32, @floatFromInt(text_width))) / 2;
        const text_y = self.rect.y + (self.rect.height - @as(f32, @floatFromInt(self.font_size))) / 2;
        // Draw text
        rl.drawText(@ptrCast(self.text), @intFromFloat(text_x), @intFromFloat(text_y), self.font_size, self.text_color);
    }
};

pub const ButtonState = enum {
    normal,
    hovered,
    pressed,
};

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
