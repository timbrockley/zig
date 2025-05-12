//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const Replacement = struct { from: u8, to: u8 };
//--------------------------------------------------------------------------------
pub fn escapeBytes(allocator: std.mem.Allocator, data: []const u8, replacements: []const Replacement) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    var escapeCount: usize = 0;
    //----------------------------------------
    // number of bytes that will need escaping and add to output size
    for (data) |byte| {
        for (replacements) |replacement| {
            if (byte == replacement.from) escapeCount += 1;
        }
    }
    //----------------------------------------------------------------------------
    var output: []u8 = try allocator.alloc(u8, data.len + escapeCount);
    errdefer allocator.free(output);
    //----------------------------------------------------------------------------
    var output_index: usize = 0;
    //----------------------------------------
    for (data) |byte| {
        var replaced = false;
        for (replacements) |replacement| {
            if (byte == replacement.from) {
                output[output_index] = '-';
                output_index += 1;
                output[output_index] = replacement.to;
                replaced = true;
                break;
            }
        }
        if (!replaced) {
            output[output_index] = byte;
        }
        output_index += 1;
    }
    //----------------------------------------------------------------------------
    return output;
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn main() !void {
    //----------------------------------------------------------------------------
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    //----------------------------------------------------------------------------
    const data = "\x09\x0A_ABC";
    const replacements = &[_]Replacement{
        .{ .from = 0x09, .to = 't' }, // replace tab with 't'
        .{ .from = 0x0A, .to = 'n' }, // new line return with 'n'
    };
    //----------------------------------------
    const result = try escapeBytes(allocator, data, replacements);
    defer allocator.free(result);
    //----------------------------------------
    std.debug.print("escapeBytes: {s}\n", .{result});
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
