const GameConfig = @import("types.zig").GameConfig;
const GameRoute = @import("types.zig").GameRoute;

pub const StateManager = struct {
    route: GameRoute = .start,
    config: GameConfig = .{},

    pub fn init() StateManager {
        return .{};
    }

    pub fn setRoute(self: *StateManager, route: GameRoute) void {
        self.route = route;
    }

    pub fn getRoute(self: *StateManager) GameRoute {
        return self.route;
    }

    pub fn setConfig(self: *StateManager, config: GameConfig) void {
        self.config = config;
    }

    pub fn getConfig(self: *StateManager) GameConfig {
        return self.config;
    }
};
