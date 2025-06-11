const Ball = @import("ball.zig").Ball;
const Paddle = @import("paddle.zig").Paddle;

pub fn check_y_top(ball: *const Ball) bool {
    return ball.y - ball.r < 0;
}

pub fn check_y_bottom(ball: *const Ball) bool {
    return ball.y + ball.r > ball.screen_h;
}

pub fn check_x_left(ball: *const Ball) bool {
    return ball.x - ball.r < 0;
}

pub fn check_x_right(ball: *const Ball) bool {
    return ball.x + ball.r > ball.screen_w;
}

pub fn check_ps(ball: *const Ball, paddles: *const []Paddle) bool {
    if (paddles.*.len > 0) {
        for (paddles.*) |*paddle| {
            if (check_p(ball, paddle)) {
                return true;
            }
        }
    }

    return false;
}

fn check_p(ball: *const Ball, paddle: *const Paddle) bool {
    const paddle_top = paddle.y;
    const paddle_bottom = paddle.y + paddle.height;
    const paddle_left = paddle.x;
    const paddle_right = paddle.x + paddle.width;

    return (ball.x + ball.r > paddle_left and
        ball.x - ball.r < paddle_right and
        ball.y + ball.r > paddle_top and
        ball.y - ball.r < paddle_bottom);
}
