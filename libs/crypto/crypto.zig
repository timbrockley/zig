//--------------------------------------------------------------------------------
// Cryptographic Functions Library
// Copyright 2024, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std = @import("std");
const conv = @import("libs/conv.zig");
//--------------------------------------------------------------------------------
const ReplacementV4 = struct { decoded: u8, encoded: u8, escaped: u8 };
//----------------------------------------
const replacementsV4 = &[_]ReplacementV4{
    .{ .decoded = 0x5C, .encoded = 0x5C, .escaped = 0x5C }, // backslash
    .{ .decoded = 0x09, .encoded = 0x09, .escaped = 't' }, // tab
    .{ .decoded = 0x0A, .encoded = 0x0A, .escaped = 'n' }, // new line
    .{ .decoded = 0x0D, .encoded = 0x0D, .escaped = 'r' }, // carriage return
    .{ .decoded = 'w', .encoded = 0x22, .escaped = 'q' }, // double quote
    .{ .decoded = 'B', .encoded = 0x27, .escaped = 'a' }, // apostrophy
    .{ .decoded = '>', .encoded = 0x60, .escaped = 'g' }, // grave accent
};
//--------------------------------------------------------------------------------
const Replacementv5 = struct { decoded: u8, encoded: u8, escaped: u8 };
//----------------------------------------
const replacementsV5 = &[_]Replacementv5{
    .{ .decoded = 'q', .encoded = '-', .escaped = '-' }, // minus sign
    .{ .decoded = 0x16, .encoded = 0x09, .escaped = 't' }, // tab
    .{ .decoded = 0x15, .encoded = 0x0A, .escaped = 'n' }, // new line
    .{ .decoded = 0x12, .encoded = 0x0D, .escaped = 'r' }, // carriage return
    .{ .decoded = '~', .encoded = 0x20, .escaped = 's' }, // space
    .{ .decoded = '|', .encoded = 0x22, .escaped = 'q' }, // double quote
    .{ .decoded = 'z', .encoded = 0x24, .escaped = 'd' }, // dollar sign
    .{ .decoded = 'w', .encoded = 0x27, .escaped = 'a' }, // apostrophy
    .{ .decoded = 'B', .encoded = 0x5C, .escaped = 'b' }, // backslash
    .{ .decoded = '>', .encoded = 0x60, .escaped = 'g' }, // grave accent
};
//--------------------------------------------------------------------------------
pub fn obfuscateV4(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    var output: []u8 = try allocator.alloc(u8, data.len);
    errdefer allocator.free(output);
    //----------------------------------------
    if (data.len < 4) {
        for (data, 0..) |byte, index| {
            output[index] = slideByteV4(byte);
        }
        return output;
    }
    //----------------------------------------
    var mixed_length = data.len;
    var mixed_half = mixed_length / 2;
    //----------------------------------------
    if (mixed_half % 2 != 0) {
        mixed_half -= 1;
        mixed_length = mixed_half * 2;
    }
    //----------------------------------------
    for (data[0..mixed_length], 0..mixed_length) |byte, index| {
        if (index % 2 != 0) {
            if (index < mixed_half) {
                output[index + mixed_half] = slideByteV4(byte);
            } else {
                output[index - mixed_half] = slideByteV4(byte);
            }
        } else {
            output[index] = slideByteV4(byte);
        }
    }
    //----------------------------------------
    if (mixed_length < data.len) {
        for (data[mixed_length..], mixed_length..) |byte, index| {
            output[index] = slideByteV4(byte);
        }
    }
    //----------------------------------------
    return output;
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn slideByteV4(byte: u8) u8 {
    //----------------------------------------------------------------------------
    if (byte >= 0x20 and byte <= 0x7E) {
        return 0x9E - byte;
    }
    return byte;
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV4Encode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const obf_data = try obfuscateV4(allocator, data);
    defer allocator.free(obf_data);
    //----------------------------------------------------------------------------
    var escapeCount: usize = 0;
    for (obf_data) |encoded| {
        for (replacementsV4) |replacement| {
            if (encoded == replacement.encoded) escapeCount += 1;
        }
    }
    //----------------------------------------
    var output: []u8 = try allocator.alloc(u8, obf_data.len + escapeCount);
    errdefer allocator.free(output);
    //----------------------------------------
    var outputIndex: usize = 0;
    //----------------------------------------
    for (obf_data) |encoded| {
        //----------------------------------------
        var replaced = false;
        for (replacementsV4) |replacement| {
            if (encoded == replacement.encoded) {
                output[outputIndex] = 0x5C;
                outputIndex += 1;
                output[outputIndex] = replacement.escaped;
                replaced = true;
                break;
            }
        }
        if (!replaced) {
            output[outputIndex] = encoded;
        }
        //----------------------------------------
        outputIndex += 1;
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    return output;
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV4Decode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    var scanIndex: usize = 0;
    var escapeCount: usize = 0;
    while (scanIndex < data.len - 1) {
        if (data[scanIndex] == 0x5C) {
            for (replacementsV4) |replacement| {
                if (data[scanIndex + 1] == replacement.escaped) {
                    escapeCount += 1;
                    scanIndex += 1;
                    break;
                }
            }
        }
        scanIndex += 1;
    }
    //----------------------------------------
    var output: []u8 = try allocator.alloc(u8, data.len - escapeCount);
    defer allocator.free(output);
    //----------------------------------------
    var bufferIndex: usize = 0;
    var outputIndex: usize = 0;
    //----------------------------------------
    while (bufferIndex < data.len) {
        //----------------------------------------
        if (data[bufferIndex] == 0x5C and bufferIndex + 1 < data.len) {
            //----------------------------------------
            var replaced = false;
            for (replacementsV4) |replacement| {
                if (data[bufferIndex + 1] == replacement.escaped) {
                    output[outputIndex] = replacement.encoded;
                    replaced = true;
                    break;
                }
            }
            if (!replaced) {
                output[outputIndex] = 0x5C;
                outputIndex += 1;
                output[outputIndex] = data[bufferIndex + 1];
            }
            //----------------------------------------
            bufferIndex += 1; // skip an extra byte as already processed
            //----------------------------------------
        } else {
            //----------------------------------------
            output[outputIndex] = data[bufferIndex];
            //----------------------------------------
        }
        //----------------------------------------
        bufferIndex += 1;
        outputIndex += 1;
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    return obfuscateV4(allocator, output);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV4BaseEncode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const obf_data = try obfuscateV4(allocator, data);
    defer allocator.free(obf_data);
    //----------------------------------------------------------------------------
    return conv.Base.encode(allocator, obf_data, .{});
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV4BaseDecode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const decoded_data = try conv.Base.decode(allocator, data, .{});
    defer allocator.free(decoded_data);
    //----------------------------------------------------------------------------
    return obfuscateV4(allocator, decoded_data);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV4Base64Encode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const obf_data = try obfuscateV4(allocator, data);
    defer allocator.free(obf_data);
    //----------------------------------------------------------------------------
    return conv.Base64.encode(allocator, obf_data, .{});
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV4Base64Decode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const decoded_data = try conv.Base64.decode(allocator, data, .{});
    defer allocator.free(decoded_data);
    //----------------------------------------------------------------------------
    return obfuscateV4(allocator, decoded_data);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV4Base64UrlEncode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const obf_data = try obfuscateV4(allocator, data);
    defer allocator.free(obf_data);
    //----------------------------------------------------------------------------
    return conv.Base64.urlEncode(allocator, obf_data, .{});
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV4Base64UrlDecode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const decoded_data = try conv.Base64.urlDecode(allocator, data, .{});
    defer allocator.free(decoded_data);
    //----------------------------------------------------------------------------
    return obfuscateV4(allocator, decoded_data);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV4Base91Encode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const obf_data = try obfuscateV4(allocator, data);
    defer allocator.free(obf_data);
    //----------------------------------------------------------------------------
    return conv.Base91.encode(allocator, obf_data, .{ .escape = true });
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV4Base91Decode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const decoded_data = try conv.Base91.decode(allocator, data, .{ .escape = true });
    defer allocator.free(decoded_data);
    //----------------------------------------------------------------------------
    return obfuscateV4(allocator, decoded_data);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV5(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    var output: []u8 = try allocator.alloc(u8, data.len);
    errdefer allocator.free(output);
    //----------------------------------------
    if (data.len < 4) {
        for (data, 0..) |byte, index| {
            output[index] = slideByteV5(byte);
        }
        return output;
    }
    //----------------------------------------
    var mixed_length = data.len;
    var mixed_half = mixed_length / 2;
    //----------------------------------------
    if (mixed_half % 2 != 0) {
        mixed_half -= 1;
        mixed_length = mixed_half * 2;
    }
    //----------------------------------------
    for (data[0..mixed_length], 0..mixed_length) |byte, index| {
        if (index % 2 != 0) {
            if (index < mixed_half) {
                output[index + mixed_half] = slideByteV5(byte);
            } else {
                output[index - mixed_half] = slideByteV5(byte);
            }
        } else {
            output[index] = slideByteV5(byte);
        }
    }
    //----------------------------------------
    if (mixed_length < data.len) {
        for (data[mixed_length..], mixed_length..) |byte, index| {
            output[index] = slideByteV5(byte);
        }
    }
    //----------------------------------------
    return output;
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn slideByteV5(byte: u8) u8 {
    //----------------------------------------------------------------------------
    if (byte <= 0x1F) {
        return 0x1F - byte;
    } else if (byte <= 0x7E) {
        return 0x7E - (byte - 0x20);
    } else if (byte >= 0x80) {
        return 0xFF - (byte - 0x80);
    }
    return byte;
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV5Encode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const obf_data = try obfuscateV5(allocator, data);
    defer allocator.free(obf_data);
    //----------------------------------------------------------------------------
    var escapeCount: usize = 0;
    for (obf_data) |encoded| {
        for (replacementsV5) |replacement| {
            if (encoded == replacement.encoded) escapeCount += 1;
        }
    }
    //----------------------------------------
    var output: []u8 = try allocator.alloc(u8, obf_data.len + escapeCount);
    errdefer allocator.free(output);
    //----------------------------------------
    var outputIndex: usize = 0;
    //----------------------------------------
    for (obf_data) |encoded| {
        //----------------------------------------
        var replaced = false;
        for (replacementsV5) |replacement| {
            if (encoded == replacement.encoded) {
                output[outputIndex] = '-';
                outputIndex += 1;
                output[outputIndex] = replacement.escaped;
                replaced = true;
                break;
            }
        }
        if (!replaced) {
            output[outputIndex] = encoded;
        }
        //----------------------------------------
        outputIndex += 1;
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    return output;
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV5Decode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    var scanIndex: usize = 0;
    var escapeCount: usize = 0;
    while (scanIndex < data.len - 1) {
        if (data[scanIndex] == '-') {
            for (replacementsV5) |replacement| {
                if (data[scanIndex + 1] == replacement.escaped) {
                    escapeCount += 1;
                    scanIndex += 1;
                    break;
                }
            }
        }
        scanIndex += 1;
    }
    //----------------------------------------
    var output: []u8 = try allocator.alloc(u8, data.len - escapeCount);
    defer allocator.free(output);
    //----------------------------------------
    var bufferIndex: usize = 0;
    var outputIndex: usize = 0;
    //----------------------------------------
    while (bufferIndex < data.len) {
        //----------------------------------------
        if (data[bufferIndex] == '-' and bufferIndex + 1 < data.len) {
            //----------------------------------------
            var replaced = false;
            for (replacementsV5) |replacement| {
                if (data[bufferIndex + 1] == replacement.escaped) {
                    output[outputIndex] = replacement.encoded;
                    replaced = true;
                    break;
                }
            }
            if (!replaced) {
                output[outputIndex] = '-';
                outputIndex += 1;
                output[outputIndex] = data[bufferIndex + 1];
            }
            //----------------------------------------
            bufferIndex += 1; // skip an extra byte as already processed
            //----------------------------------------
        } else {
            //----------------------------------------
            output[outputIndex] = data[bufferIndex];
            //----------------------------------------
        }
        //----------------------------------------
        bufferIndex += 1;
        outputIndex += 1;
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    return obfuscateV5(allocator, output);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV5BaseEncode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const obf_data = try obfuscateV5(allocator, data);
    defer allocator.free(obf_data);
    //----------------------------------------------------------------------------
    return conv.Base.encode(allocator, obf_data, .{});
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV5BaseDecode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const decoded_data = try conv.Base.decode(allocator, data, .{});
    defer allocator.free(decoded_data);
    //----------------------------------------------------------------------------
    return obfuscateV5(allocator, decoded_data);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV5Base64Encode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const obf_data = try obfuscateV5(allocator, data);
    defer allocator.free(obf_data);
    //----------------------------------------------------------------------------
    return conv.Base64.encode(allocator, obf_data, .{});
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV5Base64Decode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const decoded_data = try conv.Base64.decode(allocator, data, .{});
    defer allocator.free(decoded_data);
    //----------------------------------------------------------------------------
    return obfuscateV5(allocator, decoded_data);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV5Base64UrlEncode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const obf_data = try obfuscateV5(allocator, data);
    defer allocator.free(obf_data);
    //----------------------------------------------------------------------------
    return conv.Base64.urlEncode(allocator, obf_data, .{});
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV5Base64UrlDecode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const decoded_data = try conv.Base64.urlDecode(allocator, data, .{});
    defer allocator.free(decoded_data);
    //----------------------------------------------------------------------------
    return obfuscateV5(allocator, decoded_data);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV5Base91Encode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const obf_data = try obfuscateV5(allocator, data);
    defer allocator.free(obf_data);
    //----------------------------------------------------------------------------
    return conv.Base91.encode(allocator, obf_data, .{ .escape = true });
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn obfuscateV5Base91Decode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const decoded_data = try conv.Base91.decode(allocator, data, .{ .escape = true });
    defer allocator.free(decoded_data);
    //----------------------------------------------------------------------------
    return obfuscateV5(allocator, decoded_data);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn swapStringV0(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    var output: []u8 = try allocator.alloc(u8, data.len);
    errdefer allocator.free(output);
    //----------------------------------------
    for (data, 0..) |byte, index| {
        output[index] = slideByteV5(byte);
    }
    //----------------------------------------------------------------------------
    return output;
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn swapStringV0Encode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    var escapeCount: usize = 0;
    for (data) |byte| {
        for (replacementsV5) |replacement| {
            if (byte == replacement.decoded) escapeCount += 1;
        }
    }
    //----------------------------------------
    var output: []u8 = try allocator.alloc(u8, data.len + escapeCount);
    errdefer allocator.free(output);
    //----------------------------------------
    var outputIndex: usize = 0;
    //----------------------------------------
    for (data) |byte| {
        //----------------------------------------
        const encoded = slideByteV5(byte);
        //----------------------------------------
        var replaced = false;
        for (replacementsV5) |replacement| {
            if (encoded == replacement.encoded) {
                output[outputIndex] = '-';
                outputIndex += 1;
                output[outputIndex] = replacement.escaped;
                replaced = true;
                break;
            }
        }
        if (!replaced) {
            output[outputIndex] = encoded;
        }
        outputIndex += 1;
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    return output;
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn swapStringV0Decode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    var scanIndex: usize = 0;
    var escapeCount: usize = 0;
    while (scanIndex < data.len - 1) {
        if (data[scanIndex] == '-') {
            for (replacementsV5) |replacement| {
                if (data[scanIndex + 1] == replacement.escaped) {
                    escapeCount += 1;
                    scanIndex += 1;
                    break;
                }
            }
        }
        scanIndex += 1;
    }
    //----------------------------------------
    var output: []u8 = try allocator.alloc(u8, data.len - escapeCount);
    errdefer allocator.free(output);
    //----------------------------------------
    var bufferIndex: usize = 0;
    var outputIndex: usize = 0;
    //----------------------------------------
    while (bufferIndex < data.len) {
        //----------------------------------------
        if (data[bufferIndex] == '-' and bufferIndex + 1 < data.len) {
            //----------------------------------------
            var replaced = false;
            for (replacementsV5) |replacement| {
                if (data[bufferIndex + 1] == replacement.escaped) {
                    output[outputIndex] = replacement.decoded;
                    replaced = true;
                    break;
                }
            }
            if (!replaced) {
                output[outputIndex] = 'q';
                outputIndex += 1;
                output[outputIndex] = slideByteV5(data[bufferIndex + 1]);
            }
            //----------------------------------------
            bufferIndex += 1; // skip an extra byte as already processed
            //----------------------------------------
        } else {
            //----------------------------------------
            output[outputIndex] = slideByteV5(data[bufferIndex]);
            //----------------------------------------
        }
        //----------------------------------------
        bufferIndex += 1;
        outputIndex += 1;
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    return output;
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn swapStringV0BaseEncode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const swapped_data = try swapStringV0(allocator, data);
    defer allocator.free(swapped_data);
    //----------------------------------------------------------------------------
    return conv.Base.encode(allocator, swapped_data, .{});
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn swapStringV0BaseDecode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const decoded_data = try conv.Base.decode(allocator, data, .{});
    defer allocator.free(decoded_data);
    //----------------------------------------------------------------------------
    return swapStringV0(allocator, decoded_data);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn swapStringV0Base64Encode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const swapped_data = try swapStringV0(allocator, data);
    defer allocator.free(swapped_data);
    //----------------------------------------------------------------------------
    return conv.Base64.encode(allocator, swapped_data, .{});
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn swapStringV0Base64Decode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const decoded_data = try conv.Base64.decode(allocator, data, .{});
    defer allocator.free(decoded_data);
    //----------------------------------------------------------------------------
    return swapStringV0(allocator, decoded_data);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn swapStringV0Base64UrlEncode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const swapped_data = try swapStringV0(allocator, data);
    defer allocator.free(swapped_data);
    //----------------------------------------------------------------------------
    return conv.Base64.urlEncode(allocator, swapped_data, .{});
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn swapStringV0Base64UrlDecode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const decoded_data = try conv.Base64.urlDecode(allocator, data, .{});
    defer allocator.free(decoded_data);
    //----------------------------------------------------------------------------
    return swapStringV0(allocator, decoded_data);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn swapStringV0Base91Encode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const swapped_data = try swapStringV0(allocator, data);
    defer allocator.free(swapped_data);
    //----------------------------------------------------------------------------
    return conv.Base91.encode(allocator, swapped_data, .{ .escape = true });
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn swapStringV0Base91Decode(allocator: *std.mem.Allocator, data: []const u8) ![]u8 {
    //----------------------------------------------------------------------------
    if (data.len == 0) return allocator.alloc(u8, 0);
    //----------------------------------------------------------------------------
    const decoded_data = try conv.Base91.decode(allocator, data, .{ .escape = true });
    defer allocator.free(decoded_data);
    //----------------------------------------------------------------------------
    return swapStringV0(allocator, decoded_data);
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn main() void {
    //----------------------------------------------------------------------------
    var it = std.process.args();
    const name = if (it.next()) |arg0| std.fs.path.basename(arg0) else "";
    std.debug.print("{s}: main function\n", .{name});
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
