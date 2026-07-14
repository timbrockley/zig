//------------------------------------------------------------
const std = @import("std");
//------------------------------------------------------------
pub const Counter = struct {
    //------------------------------------------------------------
    io: std.Io,
    rwlock: std.Io.RwLock,
    value: u32,
    //------------------------------------------------------------
    pub fn init(io: std.Io) Counter {
        return .{
            .io = io,
            .rwlock = .init,
            .value = 0,
        };
    }
    //------------------------------------------------------------
    pub fn addOne(self: *Counter) void {
        self.rwlock.lock(self.io) catch {};
        defer self.rwlock.unlock(self.io);

        self.value += 1;
    }
    //------------------------------------------------------------
    pub fn get(self: *Counter) u32 {
        self.rwlock.lockShared(self.io) catch return 0;
        defer self.rwlock.unlockShared(self.io);

        return self.value;
    }
    //------------------------------------------------------------
};
//------------------------------------------------------------
pub fn workerWrite(counter: *Counter) void {
    //------------------------------------------------------------
    for (0..5) |_| {
        counter.addOne();
        counter.io.sleep(.fromMilliseconds(6), .real) catch {};
    }
    //------------------------------------------------------------
}
//------------------------------------------------------------
pub fn workerRead(counter: *Counter) void {
    //------------------------------------------------------------
    for (0..5) |_| {
        const value = counter.get();
        std.debug.print("counter.get: {d}\n", .{value});
        counter.io.sleep(.fromMilliseconds(4), .real) catch {};
    }
    //------------------------------------------------------------
}
//------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    std.debug.print("\n", .{});
    //------------------------------------------------------------
    var counter = Counter.init(init.io);
    //------------------------------------------------------------
    const t1 = try std.Thread.spawn(
        .{},
        workerWrite,
        .{&counter},
    );
    //------------------------------------------------------------
    const t2 = try std.Thread.spawn(
        .{},
        workerRead,
        .{&counter},
    );
    //------------------------------------------------------------
    t1.join();
    t2.join();
    //------------------------------------------------------------
    const value = counter.get();
    std.debug.print("\ncounter.get: {d}\n\n", .{value});
    //------------------------------------------------------------
}
//------------------------------------------------------------
