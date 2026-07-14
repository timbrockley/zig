//----------------------------------------------------------------------------------
const std = @import("std");
//----------------------------------------------------------------------------------
const SpinLock = struct {
    //-------------------------------------------------------------
    locked: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),
    //-------------------------------------------------------------
    pub fn lock(self: *SpinLock) void {
        while (true) {
            if (!self.locked.swap(true, .acquire)) {
                return;
            }
            while (self.locked.load(.monotonic)) {
                std.atomic.spinLoopHint();
            }
        }
    }
    //-------------------------------------------------------------
    pub fn unlock(self: *SpinLock) void {
        self.locked.store(false, .release);
    }
    //-------------------------------------------------------------
};
//----------------------------------------------------------------------------------
fn worker(spinlock: *SpinLock, counter: *usize, iterations: usize, id: usize) void {
    //-------------------------------------------------------------
    for (0..iterations) |_| {
        spinlock.lock();
        counter.* += 1;
        spinlock.unlock();
    }
    //-------------------------------------------------------------
    std.debug.print("thread {d} ended\n", .{id});
    //-------------------------------------------------------------
}
//----------------------------------------------------------------------------------
pub fn main() !void {
    //-------------------------------------------------------------
    var spinlock = SpinLock{};
    var counter: usize = 0;
    //-------------------------------------------------------------
    const max_threads = 8;
    const iterations_per_thread = 1_000_000;
    //-------------------------------------------------------------
    var threads: [max_threads]std.Thread = undefined;
    //-------------------------------------------------------------
    std.debug.print("starting {d} threads, each doing {d} increments...\n\n", .{
        max_threads, iterations_per_thread,
    });
    //-------------------------------------------------------------
    for (0..max_threads) |index| {
        threads[index] = try std.Thread.spawn(.{}, worker, .{
            &spinlock,
            &counter,
            iterations_per_thread,
            index + 1,
        });
    }
    for (threads) |thread| {
        thread.join();
    }
    //-------------------------------------------------------------
    const expected = max_threads * iterations_per_thread;
    std.debug.print("\nfinal counter: {d} (expected: {d})\n", .{ counter, expected });
    //-------------------------------------------------------------
    if (counter == expected) {
        std.debug.print("success: no data races\n", .{});
    } else {
        std.debug.print("invalid result!\n", .{});
    }
    //-------------------------------------------------------------
}
//----------------------------------------------------------------------------------
