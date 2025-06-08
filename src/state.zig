pub const Screen = enum {
    start,
    playing,
};

pub const StateManager = struct {
    current: Screen,

    pub fn init() StateManager {
        return StateManager{
            .current = .playing,
        };
    }

    pub fn set(self: *StateManager, state: Screen) void {
        self.current = state;
    }

    pub fn get(self: StateManager) Screen {
        return self.current;
    }

    //// todo: remove if not used
    pub fn shouldExit(self: *const StateManager) bool {
        return self.current == .exit;
    }
};
