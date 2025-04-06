const std = @import("std");

fn multiply_with_sse(a: []const f32, b: []const f32, result: []f32) void {
    const vecSize = 8; // Number of f32 in a single SIMD register (for SSE)
    const numVecs = a.len / vecSize; // Precompute the number of vector operations
    for (0..numVecs) |i| {
        const index = i * vecSize;
        // Load vectors and perform multiplication
        const va = std.simd.f32.load(a[index .. index + vecSize]);
        const vb = std.simd.f32.load(b[index .. index + vecSize]);
        const vr = std.simd.f32.mul(va, vb);
        std.simd.f32.store(result[index .. index + vecSize], vr);
    }

    // Handle remaining elements if the array length is not a multiple of vecSize
    for ((numVecs * vecSize)..a.len) |i| {
        result[i] = a[i] * b[i];
    }
}

fn multiply_floats(a: []const f32, b: []const f32, result: []f32) void {
    if (@hasDecl(std.Target, "hasSSE")) {
        multiply_with_sse(a, b, result);
    } else {
        for (0..a.len) |i| {
            result[i] = a[i] * b[i];
        }
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const size = 1024;
    var a = try allocator.alloc(f32, size);
    var b = try allocator.alloc(f32, size);
    const result = try allocator.alloc(f32, size);

    // Initialize arrays a and b
    for (0..size) |i| {
        a[i] = @floatFromInt(i);
        b[i] = @floatFromInt(size - i);
    }

    multiply_floats(a, b, result);

    // output results
    for (0..size) |i| {
        std.debug.print("result[{}] = {}\n", .{ i, result[i] });
    }

    // Cleanup
    allocator.free(a);
    allocator.free(b);
    allocator.free(result);
}
