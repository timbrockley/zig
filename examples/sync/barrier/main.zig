//---------------------------------------------------------------------------
const std = @import("std");
//---------------------------------------------------------------------------
const THREAD_COUNT = 4;
//---------------------------------------------------------------------------
const Barrier = struct {
    //-------------------------------------------------------
    io: std.Io,
    mutex: std.Io.Mutex,
    condition: std.Io.Condition,
    //-------------------------------------------------------
    count: usize = 0,
    generation: usize = 0,
    target: usize,
    //-------------------------------------------------------
    pub fn init(io: std.Io, target: usize) Barrier {
        return .{
            .io = io,
            .mutex = .init,
            .condition = .init,
            .target = target,
        };
    }
    //-------------------------------------------------------
    pub fn wait(self: *Barrier) !bool {
        //-------------------------------------------------------
        try self.mutex.lock(self.io);
        defer self.mutex.unlock(self.io);
        //-------------------------------------------------------
        const generation = self.generation;
        //-------------------------------------------------------
        self.count += 1;
        //-------------------------------------------------------
        if (self.count == self.target) {
            self.count = 0;
            self.generation += 1;
            self.condition.broadcast(self.io);
            return true;
        }
        //-------------------------------------------------------
        while (generation == self.generation) {
            try self.condition.wait(self.io, &self.mutex);
        }
        //-------------------------------------------------------
        return false;
        //-------------------------------------------------------
    }
};
//---------------------------------------------------------------------------
fn worker(barrier: *Barrier, id: usize) !void {
    //-------------------------------------------------------
    std.debug.print("worker {}: stage 1\n", .{id});
    //-------------------------------------------------------
    try barrier.io.sleep(.fromMilliseconds(10), .real);
    //-------------------------------------------------------
    std.debug.print("worker {}: waiting\n", .{id});
    //-------------------------------------------------------
    if (try barrier.wait()) {
        std.debug.print("=== Everyone reached the barrier ===\n", .{});
    }
    //-------------------------------------------------------
    std.debug.print("worker {}: stage 2\n", .{id});
    //-------------------------------------------------------
    try barrier.io.sleep(.fromMilliseconds(50), .real);
    //-------------------------------------------------------
    if (try barrier.wait()) {
        std.debug.print("=== all workers ended ===\n", .{});
    }
    //-------------------------------------------------------
    std.debug.print("worker {}: done\n", .{id});
    //-------------------------------------------------------
}
//---------------------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //-------------------------------------------------------
    var barrier = Barrier.init(init.io, THREAD_COUNT);
    //-------------------------------------------------------
    var threads: [THREAD_COUNT]std.Thread = undefined;

    for (0..THREAD_COUNT) |index| {
        threads[index] = try std.Thread.spawn(.{}, worker, .{ &barrier, index + 1 });
    }

    for (threads) |t| {
        t.join();
    }
    //-------------------------------------------------------
}
//---------------------------------------------------------------------------
