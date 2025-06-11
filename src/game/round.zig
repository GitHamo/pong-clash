const Player = struct {
    id: u2,
    score: f32,

    pub fn init(id: u2, score: f32) Player {
        return Player{
            .id = id,
            .score = score,
        };
    }
};

const Scores = struct {
    player1: f32 = 0,
    player2: f32 = 0,
    player3: f32 = 0,
    player4: f32 = 0,

    pub fn reset(self: *Scores) void {
        self.* = .{};
    }

    pub fn addScore(self: *Scores, player_id: u2, points: f32) void {
        switch (player_id) {
            0 => self.player1 += points,
            1 => self.player2 += points,
            2 => self.player3 += points,
            3 => self.player4 += points,
        }
    }

    pub fn getFirst(self: *const Scores) ?Player {
        const players = [4]Player{
            Player.init(0, self.player1),
            Player.init(1, self.player2),
            Player.init(2, self.player3),
            Player.init(3, self.player4),
        };

        var highest: ?Player = null;

        for (players) |player| {
            if (highest == null or player.score > highest.?.score) {
                highest = player;
            }
        }
        return highest;
    }
};

const RoundState = enum { running, ended };

pub const RoundManager = struct {
    state: RoundState = .running,
    scores: Scores = .{},
    max_points: f32,

    const Self = @This();

    pub fn init(points: u32) Self {
        return .{
            .max_points = @floatFromInt(points),
        };
    }

    pub fn update(self: *Self) void {
        if (self.state != .running) return;

        if (self.scores.getFirst()) |first_player| {
            if (first_player.score >= self.max_points) {
                self.state = .ended;
            }
        }
    }

    pub fn reset(self: *Self) void {
        self.state = .running;
        self.scores.reset();
    }

    pub fn score(self: *Self, player_id: u2) void {
        self.scores.addScore(player_id, 1);
    }

    pub fn isOver(self: *const Self) bool {
        return self.state == .ended;
    }
};
