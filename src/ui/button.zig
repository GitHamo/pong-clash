const rl = @import("raylib");

const ButtonState = enum {
    normal,
    hovered,
    pressed,
};

pub const Button = struct {
    state: ButtonState,
    rect: rl.Rectangle,
    text: []const u8,
    font_size: i32,
    normal_color: rl.Color,
    hover_color: rl.Color,
    press_color: rl.Color,
    focus_color: rl.Color,
    text_color: rl.Color,
    is_focused: bool = false,

    pub fn init(
        position_x: f32,
        position_y: f32,
        width: f32,
        height: f32,
        label: [:0]const u8,
        label_color: rl.Color,
        font_size: i32,
        color: rl.Color,
        hover_color: ?rl.Color,
        press_color: ?rl.Color,
        focus_color: ?rl.Color,
    ) Button {
        const final_hover_color = hover_color orelse color;
        const final_press_color = press_color orelse final_hover_color;
        const final_focus_color = focus_color orelse final_press_color;

        return .{
            .state = .normal,
            .rect = rl.Rectangle{ .x = position_x, .y = position_y, .width = width, .height = height },
            .text = label,
            .font_size = font_size,
            .normal_color = color,
            .hover_color = final_hover_color,
            .press_color = final_press_color,
            .focus_color = final_focus_color,
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
        var color = switch (self.state) {
            .normal => self.normal_color,
            .hovered => self.hover_color,
            .pressed => self.press_color,
        };

        if (self.is_focused) {
            color = self.focus_color;
        }

        rl.drawRectangleRec(self.rect, color);
        rl.drawRectangleLinesEx(self.rect, 2, rl.Color.white);

        const text_width = rl.measureText(@ptrCast(self.text), self.font_size);
        const text_x = self.rect.x + (self.rect.width - @as(f32, @floatFromInt(text_width))) / 2;
        const text_y = self.rect.y + (self.rect.height - @as(f32, @floatFromInt(self.font_size))) / 2;

        rl.drawText(@ptrCast(self.text), @intFromFloat(text_x), @intFromFloat(text_y), self.font_size, self.text_color);
    }

    pub fn setFocus(self: *Button, is_focused: bool) void {
        self.is_focused = is_focused;
    }
};
