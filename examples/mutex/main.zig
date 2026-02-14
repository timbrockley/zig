const std = @import("std");

pub const Counter = struct {
    value: u32,
    mutex: std.Io.Mutex,
    io: std.Io,

    pub fn init(io: std.Io) Counter {
        return .{
            .value = 0,
            .mutex = .init,
            .io = io,
        };
    }

    pub fn addOne(self: *Counter) void {
        self.mutex.lock(self.io) catch {};
        defer self.mutex.unlock(self.io);

        self.value += 1;
    }

    pub fn get(self: *Counter) u32 {
        self.mutex.lock(self.io) catch return 0;
        defer self.mutex.unlock(self.io);

        return self.value;
    }
};

pub fn main(init: std.process.Init) !void {
    var counter = Counter.init(init.io);

    const t1 = try std.Thread.spawn(
        .{},
        Counter.addOne,
        .{&counter},
    );
    const t2 = try std.Thread.spawn(
        .{},
        Counter.addOne,
        .{&counter},
    );

    t1.join();
    t2.join();

    const final = counter.get();
    std.debug.print("Final value: {d}\n", .{final});
}
