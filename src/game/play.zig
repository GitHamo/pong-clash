const commons = @import("../types.zig");
const GameOver = commons.GameOver;
const GameLevel = commons.GameLevel;

pub fn getPaddleHeight(level: GameLevel) f32 {
    switch (level) {
        .easy => return 200,
        .medium => return 150,
        .hard => return 100,
    }
}

pub fn getPaddleSpeed(level: GameLevel) f32 {
    switch (level) {
        .easy => return 15,
        .medium => return 10,
        .hard => return 5,
    }
}

pub fn getBallRadius(level: GameLevel) f32 {
    switch (level) {
        .easy => return 15,
        .medium => return 10,
        .hard => return 5,
    }
}

pub fn getBallSpeed(level: GameLevel) f32 {
    switch (level) {
        .easy => return 7,
        .medium => return 15,
        .hard => return 20,
    }
}

pub fn getRoundMax(condition: GameOver) u32 {
    switch (condition) {
        .seconds => return 6,
        .points => return 10,
    }
}
