//---------------------------------------------------------------------------
const std = @import("std");
//---------------------------------------------------------------------------
const TESTS: usize = 5;
//---------------------------------------------------------------------------
const WaitGroup = struct {
    //-------------------------------------------------------
    io: std.Io,
    mutex: std.Io.Mutex,
    condition: std.Io.Condition,
    count: u32,
    //-------------------------------------------------------
    const Self = @This();
    //-------------------------------------------------------
    fn init(io: std.Io) Self {
        return WaitGroup{
            .io = io,
            .mutex = .init,
            .condition = .init,
            .count = 0,
        };
    }
    //-------------------------------------------------------
    fn add(self: *Self, count: u32) !void {
        try self.mutex.lock(self.io);
        defer self.mutex.unlock(self.io);
        self.count += count;
    }
    //-------------------------------------------------------
    fn done(self: *Self) !void {
        try self.mutex.lock(self.io);
        defer self.mutex.unlock(self.io);
        self.count -= 1;
        if (self.count == 0) {
            self.condition.broadcast(self.io);
        }
    }
    //-------------------------------------------------------
    fn wait(self: *Self) !void {
        try self.mutex.lock(self.io);
        defer self.mutex.unlock(self.io);

        if (self.count > 0) {
            try self.condition.wait(self.io, &self.mutex);
        }
    }
    //-------------------------------------------------------
};
//---------------------------------------------------------------------------
fn worker(
    wg: *WaitGroup,
    id: usize,
    ms: i64,
) !void {
    //-------------------------------------------------------
    std.debug.print("id: {d} started\n", .{id});
    //-------------------------------------------------------
    try wg.io.sleep(.fromMilliseconds(ms), .real);
    //-------------------------------------------------------
    std.debug.print("id: {d} ended\n", .{id});
    //-------------------------------------------------------
    try wg.done();
    //-------------------------------------------------------
}
//---------------------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //-------------------------------------------------------
    var wg = WaitGroup.init(init.io);
    //-------------------------------------------------------
    try wg.add(TESTS);
    //-------------------------------------------------------
    var threads: [TESTS]std.Thread = undefined;

    for (0..TESTS) |index| {
        threads[index] = try std.Thread.spawn(.{}, worker, .{ &wg, index + 1, @as(i64, @intCast((index + 1) * 400)) });
    }

    for (0..TESTS) |index| {
        threads[index].detach();
    }
    //-------------------------------------------------------
    try wg.wait();
    //-------------------------------------------------------
}
//---------------------------------------------------------------------------
