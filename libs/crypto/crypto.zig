//------------------------------------------------------------
// Cryptographic Functions Library
// Copyright 2025, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//------------------------------------------------------------
const std = @import("std");
const conv = @import("libs/conv.zig");
//------------------------------------------------------------
//############################################################
//------------------------------------------------------------
pub const ObfuscateV0 = struct {
    //------------------------------------------------------------
    pub const Error = error{EncodingError};
    //------------------------------------------------------------
    pub const Replacement = struct { decoded: u8, encoded: u8, escaped: u8 };
    //------------------------------------------------------------
    pub const replacements = &[_]ObfuscateV0.Replacement{
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
    //------------------------------------------------------------
    pub const Encoding = enum { base, base64, base64url, base91, hex, default };
    pub const Defaults = struct { encoding: Encoding = .default };
    //------------------------------------------------------------
    pub fn obfuscate(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        _ = options;
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        var output: []u8 = try allocator.alloc(u8, data.len);
        errdefer allocator.free(output);
        //----------------------------------------
        for (data, 0..) |byte, index| {
            output[index] = ObfuscateV0.slideByte(byte);
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn slideByte(byte: u8) u8 {
        //------------------------------------------------------------
        return switch (byte) {
            0x00...0x1F => 0x1F - byte,
            0x20...0x7E => 0x7E - (byte - 0x20),
            0x7F => byte,
            0x80...0xFF => 0xFF - (byte - 0x80),
        };
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn encode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        const opts = setOptions(Defaults, options);
        //------------------------------------------------------------
        if (opts.encoding != .default) {
            //----------------------------------------
            const obfuscated_data = try ObfuscateV0.obfuscate(allocator, data, options);
            defer allocator.free(obfuscated_data);
            //----------------------------------------
            switch (opts.encoding) {
                .base => return conv.Base.encode(allocator, obfuscated_data, .{}),
                .base64 => return conv.Base64.encode(allocator, obfuscated_data, .{}),
                .base64url => return conv.Base64.urlEncode(allocator, obfuscated_data, .{}),
                .base91 => return conv.Base91.encode(allocator, obfuscated_data, .{ .escape = true }),
                .hex => return conv.Hex.encode(allocator, obfuscated_data, .{}),
                .default => return Error.EncodingError, // default encoding should be processed below
            }
            //----------------------------------------
        }
        //------------------------------------------------------------
        var escapeCount: usize = 0;
        for (data) |byte| {
            for (ObfuscateV0.replacements) |replacement| {
                if (byte == replacement.decoded) escapeCount += 1;
            }
        }
        //----------------------------------------
        var output: []u8 = try allocator.alloc(u8, data.len + escapeCount);
        errdefer allocator.free(output);
        //----------------------------------------
        var output_index: usize = 0;
        //----------------------------------------
        for (data) |byte| {
            //----------------------------------------
            const encoded = ObfuscateV0.slideByte(byte);
            //----------------------------------------
            var replaced = false;
            for (ObfuscateV0.replacements) |replacement| {
                if (encoded == replacement.encoded) {
                    output[output_index] = '-';
                    output_index += 1;
                    output[output_index] = replacement.escaped;
                    replaced = true;
                    break;
                }
            }
            if (!replaced) {
                output[output_index] = encoded;
            }
            output_index += 1;
            //----------------------------------------
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn decode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        const opts = setOptions(Defaults, options);
        //------------------------------------------------------------
        if (opts.encoding != .default) {
            //----------------------------------------
            const decoded_data = switch (opts.encoding) {
                .base => try conv.Base.decode(allocator, data, .{}),
                .base64 => try conv.Base64.decode(allocator, data, .{}),
                .base64url => try conv.Base64.urlDecode(allocator, data, .{}),
                .base91 => try conv.Base91.decode(allocator, data, .{ .escape = true }),
                .hex => try conv.Hex.decode(allocator, data, .{}),
                .default => return Error.EncodingError, // default encoding should be processed below
            };
            defer allocator.free(decoded_data);
            //----------------------------------------
            return ObfuscateV0.obfuscate(allocator, decoded_data, options);
            //----------------------------------------
        }
        //------------------------------------------------------------
        var scan_index: usize = 0;
        var escapeCount: usize = 0;
        while (scan_index < data.len - 1) {
            if (data[scan_index] == '-') {
                for (ObfuscateV0.replacements) |replacement| {
                    if (data[scan_index + 1] == replacement.escaped) {
                        escapeCount += 1;
                        scan_index += 1;
                        break;
                    }
                }
            }
            scan_index += 1;
        }
        //----------------------------------------
        var output: []u8 = try allocator.alloc(u8, data.len - escapeCount);
        errdefer allocator.free(output);
        //----------------------------------------
        var buffer_index: usize = 0;
        var output_index: usize = 0;
        //----------------------------------------
        while (buffer_index < data.len) {
            //----------------------------------------
            if (data[buffer_index] == '-' and buffer_index + 1 < data.len) {
                //----------------------------------------
                var replaced = false;
                for (ObfuscateV0.replacements) |replacement| {
                    if (data[buffer_index + 1] == replacement.escaped) {
                        output[output_index] = replacement.decoded;
                        replaced = true;
                        break;
                    }
                }
                if (!replaced) {
                    output[output_index] = 'q';
                    output_index += 1;
                    output[output_index] = ObfuscateV0.slideByte(data[buffer_index + 1]);
                }
                //----------------------------------------
                buffer_index += 1; // skip an extra byte as already processed
                //----------------------------------------
            } else {
                //----------------------------------------
                output[output_index] = ObfuscateV0.slideByte(data[buffer_index]);
                //----------------------------------------
            }
            //----------------------------------------
            buffer_index += 1;
            output_index += 1;
            //----------------------------------------
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn setOptions(T: type, options: anytype) T {
        var target = T{};
        inline for (std.meta.fields(@TypeOf(target))) |field| {
            if (@hasField(@TypeOf(options), field.name)) {
                @field(target, field.name) = @field(options, field.name);
            }
        }
        return target;
    }
    //------------------------------------------------------------
};
//------------------------------------------------------------
//############################################################
//------------------------------------------------------------
pub const ObfuscateV4 = struct {
    //------------------------------------------------------------
    pub const Error = error{EncodingError};
    //------------------------------------------------------------
    pub const Replacement = struct { decoded: u8, encoded: u8, escaped: u8 };
    //------------------------------------------------------------
    pub const replacements = &[_]ObfuscateV4.Replacement{
        .{ .decoded = 0x5C, .encoded = 0x5C, .escaped = 0x5C }, // backslash
        .{ .decoded = 0x09, .encoded = 0x09, .escaped = 't' }, // tab
        .{ .decoded = 0x0A, .encoded = 0x0A, .escaped = 'n' }, // new line
        .{ .decoded = 0x0D, .encoded = 0x0D, .escaped = 'r' }, // carriage return
        .{ .decoded = 'w', .encoded = 0x22, .escaped = 'q' }, // double quote
        .{ .decoded = 'B', .encoded = 0x27, .escaped = 'a' }, // apostrophy
        .{ .decoded = '>', .encoded = 0x60, .escaped = 'g' }, // grave accent
    };
    //------------------------------------------------------------
    pub const Encoding = enum { base, base64, base64url, base91, hex, default };
    pub const Defaults = struct { encoding: Encoding = .default, mix_chars: bool = true };
    //------------------------------------------------------------
    pub fn obfuscate(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        const opts = setOptions(Defaults, options);
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        var output: []u8 = try allocator.alloc(u8, data.len);
        errdefer allocator.free(output);
        //----------------------------------------
        if (!opts.mix_chars or data.len < 4) {
            for (data, 0..) |byte, index| {
                output[index] = ObfuscateV4.slideByte(byte);
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
        for (data[0..data.len], 0..data.len) |byte, index| {
            if (index < mixed_length and index % 2 != 0) {
                if (index < mixed_half) {
                    output[index + mixed_half] = ObfuscateV4.slideByte(byte);
                } else {
                    output[index - mixed_half] = ObfuscateV4.slideByte(byte);
                }
            } else {
                output[index] = ObfuscateV4.slideByte(byte);
            }
        }
        //----------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn slideByte(byte: u8) u8 {
        //------------------------------------------------------------
        return switch (byte) {
            0x20...0x7E => 0x7E - (byte - 0x20),
            else => byte,
        };
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn encode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        const opts = setOptions(Defaults, options);
        //------------------------------------------------------------
        const obfuscated_data = try ObfuscateV4.obfuscate(allocator, data, options);
        defer allocator.free(obfuscated_data);
        //------------------------------------------------------------
        if (opts.encoding != .default) {
            //----------------------------------------
            switch (opts.encoding) {
                .base => return conv.Base.encode(allocator, obfuscated_data, .{}),
                .base64 => return conv.Base64.encode(allocator, obfuscated_data, .{}),
                .base64url => return conv.Base64.urlEncode(allocator, obfuscated_data, .{}),
                .base91 => return conv.Base91.encode(allocator, obfuscated_data, .{ .escape = true }),
                .hex => return conv.Hex.encode(allocator, obfuscated_data, .{}),
                .default => return Error.EncodingError, // default encoding should be processed below
            }
            //----------------------------------------
        }
        //------------------------------------------------------------
        var escapeCount: usize = 0;
        for (obfuscated_data) |encoded| {
            for (ObfuscateV4.replacements) |replacement| {
                if (encoded == replacement.encoded) escapeCount += 1;
            }
        }
        //----------------------------------------
        var output: []u8 = try allocator.alloc(u8, obfuscated_data.len + escapeCount);
        errdefer allocator.free(output);
        //----------------------------------------
        var output_index: usize = 0;
        //----------------------------------------
        for (obfuscated_data) |encoded| {
            //----------------------------------------
            var replaced = false;
            for (ObfuscateV4.replacements) |replacement| {
                if (encoded == replacement.encoded) {
                    output[output_index] = 0x5C;
                    output_index += 1;
                    output[output_index] = replacement.escaped;
                    replaced = true;
                    break;
                }
            }
            if (!replaced) {
                output[output_index] = encoded;
            }
            //----------------------------------------
            output_index += 1;
            //----------------------------------------
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn decode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        const opts = setOptions(Defaults, options);
        //------------------------------------------------------------
        if (opts.encoding != .default) {
            //----------------------------------------
            const decoded_data = switch (opts.encoding) {
                .base => try conv.Base.decode(allocator, data, .{}),
                .base64 => try conv.Base64.decode(allocator, data, .{}),
                .base64url => try conv.Base64.urlDecode(allocator, data, .{}),
                .base91 => try conv.Base91.decode(allocator, data, .{ .escape = true }),
                .hex => try conv.Hex.decode(allocator, data, .{}),
                .default => return Error.EncodingError, // default encoding should be processed below
            };
            defer allocator.free(decoded_data);
            //----------------------------------------
            return ObfuscateV4.obfuscate(allocator, decoded_data, options);
            //----------------------------------------
        }
        //------------------------------------------------------------
        var scan_index: usize = 0;
        var escapeCount: usize = 0;
        while (scan_index < data.len - 1) {
            if (data[scan_index] == 0x5C) {
                for (ObfuscateV4.replacements) |replacement| {
                    if (data[scan_index + 1] == replacement.escaped) {
                        escapeCount += 1;
                        scan_index += 1;
                        break;
                    }
                }
            }
            scan_index += 1;
        }
        //----------------------------------------
        var output: []u8 = try allocator.alloc(u8, data.len - escapeCount);
        defer allocator.free(output);
        //----------------------------------------
        var buffer_index: usize = 0;
        var output_index: usize = 0;
        //----------------------------------------
        while (buffer_index < data.len) {
            //----------------------------------------
            if (data[buffer_index] == 0x5C and buffer_index + 1 < data.len) {
                //----------------------------------------
                var replaced = false;
                for (ObfuscateV4.replacements) |replacement| {
                    if (data[buffer_index + 1] == replacement.escaped) {
                        output[output_index] = replacement.encoded;
                        replaced = true;
                        break;
                    }
                }
                if (!replaced) {
                    output[output_index] = 0x5C;
                    output_index += 1;
                    output[output_index] = data[buffer_index + 1];
                }
                //----------------------------------------
                buffer_index += 1; // skip an extra byte as already processed
                //----------------------------------------
            } else {
                //----------------------------------------
                output[output_index] = data[buffer_index];
                //----------------------------------------
            }
            //----------------------------------------
            buffer_index += 1;
            output_index += 1;
            //----------------------------------------
        }
        //------------------------------------------------------------
        return ObfuscateV4.obfuscate(allocator, output, options);
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn setOptions(T: type, options: anytype) T {
        var target = T{};
        inline for (std.meta.fields(@TypeOf(target))) |field| {
            if (@hasField(@TypeOf(options), field.name)) {
                @field(target, field.name) = @field(options, field.name);
            }
        }
        return target;
    }
    //------------------------------------------------------------
};
//------------------------------------------------------------
//############################################################
//------------------------------------------------------------
pub const ObfuscateV5 = struct {
    //------------------------------------------------------------
    pub const Error = error{EncodingError};
    //------------------------------------------------------------
    pub const Replacement = struct { decoded: u8, encoded: u8, escaped: u8 };
    //------------------------------------------------------------
    pub const replacements = &[_]ObfuscateV5.Replacement{
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
    //------------------------------------------------------------
    pub const Encoding = enum { base, base64, base64url, base91, hex, default };
    pub const Defaults = struct { encoding: Encoding = .default };
    //------------------------------------------------------------
    pub fn obfuscate(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        _ = options;
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        var output: []u8 = try allocator.alloc(u8, data.len);
        errdefer allocator.free(output);
        //----------------------------------------
        if (data.len < 4) {
            for (data, 0..) |byte, index| {
                output[index] = ObfuscateV5.slideByte(byte);
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
        for (data[0..data.len], 0..data.len) |byte, index| {
            if (index < mixed_length and index % 2 != 0) {
                if (index < mixed_half) {
                    output[index + mixed_half] = ObfuscateV5.slideByte(byte);
                } else {
                    output[index - mixed_half] = ObfuscateV5.slideByte(byte);
                }
            } else {
                output[index] = ObfuscateV5.slideByte(byte);
            }
        }
        //----------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn slideByte(byte: u8) u8 {
        //------------------------------------------------------------
        return switch (byte) {
            0x00...0x1F => 0x1F - byte,
            0x20...0x7E => 0x7E - (byte - 0x20),
            0x7F => byte,
            0x80...0xFF => 0xFF - (byte - 0x80),
        };
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn encode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        const opts = setOptions(Defaults, options);
        //------------------------------------------------------------
        const obfuscated_data = try ObfuscateV5.obfuscate(allocator, data, options);
        defer allocator.free(obfuscated_data);
        //------------------------------------------------------------
        if (opts.encoding != .default) {
            //----------------------------------------
            switch (opts.encoding) {
                .base => return conv.Base.encode(allocator, obfuscated_data, .{}),
                .base64 => return conv.Base64.encode(allocator, obfuscated_data, .{}),
                .base64url => return conv.Base64.urlEncode(allocator, obfuscated_data, .{}),
                .base91 => return conv.Base91.encode(allocator, obfuscated_data, .{ .escape = true }),
                .hex => return conv.Hex.encode(allocator, obfuscated_data, .{}),
                .default => return Error.EncodingError, // default encoding should be processed below
            }
            //----------------------------------------
        }
        //------------------------------------------------------------
        var escapeCount: usize = 0;
        for (obfuscated_data) |encoded| {
            for (ObfuscateV5.replacements) |replacement| {
                if (encoded == replacement.encoded) escapeCount += 1;
            }
        }
        //----------------------------------------
        var output: []u8 = try allocator.alloc(u8, obfuscated_data.len + escapeCount);
        errdefer allocator.free(output);
        //----------------------------------------
        var output_index: usize = 0;
        //----------------------------------------
        for (obfuscated_data) |encoded| {
            //----------------------------------------
            var replaced = false;
            for (ObfuscateV5.replacements) |replacement| {
                if (encoded == replacement.encoded) {
                    output[output_index] = '-';
                    output_index += 1;
                    output[output_index] = replacement.escaped;
                    replaced = true;
                    break;
                }
            }
            if (!replaced) {
                output[output_index] = encoded;
            }
            //----------------------------------------
            output_index += 1;
            //----------------------------------------
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn decode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        const opts = setOptions(Defaults, options);
        //------------------------------------------------------------
        if (opts.encoding != .default) {
            //----------------------------------------
            const decoded_data = switch (opts.encoding) {
                .base => try conv.Base.decode(allocator, data, .{}),
                .base64 => try conv.Base64.decode(allocator, data, .{}),
                .base64url => try conv.Base64.urlDecode(allocator, data, .{}),
                .base91 => try conv.Base91.decode(allocator, data, .{ .escape = true }),
                .hex => try conv.Hex.decode(allocator, data, .{}),
                .default => return Error.EncodingError, // default encoding should be processed below
            };
            defer allocator.free(decoded_data);
            //----------------------------------------
            return ObfuscateV5.obfuscate(allocator, decoded_data, options);
            //----------------------------------------
        }
        //------------------------------------------------------------
        var scan_index: usize = 0;
        var escapeCount: usize = 0;
        while (scan_index < data.len - 1) {
            if (data[scan_index] == '-') {
                for (ObfuscateV5.replacements) |replacement| {
                    if (data[scan_index + 1] == replacement.escaped) {
                        escapeCount += 1;
                        scan_index += 1;
                        break;
                    }
                }
            }
            scan_index += 1;
        }
        //----------------------------------------
        var output: []u8 = try allocator.alloc(u8, data.len - escapeCount);
        defer allocator.free(output);
        //----------------------------------------
        var buffer_index: usize = 0;
        var output_index: usize = 0;
        //----------------------------------------
        while (buffer_index < data.len) {
            //----------------------------------------
            if (data[buffer_index] == '-' and buffer_index + 1 < data.len) {
                //----------------------------------------
                var replaced = false;
                for (ObfuscateV5.replacements) |replacement| {
                    if (data[buffer_index + 1] == replacement.escaped) {
                        output[output_index] = replacement.encoded;
                        replaced = true;
                        break;
                    }
                }
                if (!replaced) {
                    output[output_index] = '-';
                    output_index += 1;
                    output[output_index] = data[buffer_index + 1];
                }
                //----------------------------------------
                buffer_index += 1; // skip an extra byte as already processed
                //----------------------------------------
            } else {
                //----------------------------------------
                output[output_index] = data[buffer_index];
                //----------------------------------------
            }
            //----------------------------------------
            buffer_index += 1;
            output_index += 1;
            //----------------------------------------
        }
        //------------------------------------------------------------
        return ObfuscateV5.obfuscate(allocator, output, options);
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn setOptions(T: type, options: anytype) T {
        var target = T{};
        inline for (std.meta.fields(@TypeOf(target))) |field| {
            if (@hasField(@TypeOf(options), field.name)) {
                @field(target, field.name) = @field(options, field.name);
            }
        }
        return target;
    }
    //------------------------------------------------------------
};
//------------------------------------------------------------
//############################################################
//------------------------------------------------------------
pub const ObfuscateXOR = struct {
    //------------------------------------------------------------
    pub const Error = error{EncodingError};
    //------------------------------------------------------------
    pub const Replacement = struct { encoded: u8, escaped: u8 };
    //------------------------------------------------------------
    pub const replacements = &[_]ObfuscateXOR.Replacement{
        .{ .encoded = '-', .escaped = '-' }, // minus sign
        .{ .encoded = 0x09, .escaped = 't' }, // tab
        .{ .encoded = 0x0A, .escaped = 'n' }, // new line
        .{ .encoded = 0x0D, .escaped = 'r' }, // carriage return
        .{ .encoded = 0x20, .escaped = 's' }, // space
        .{ .encoded = 0x22, .escaped = 'q' }, // double quote
        .{ .encoded = 0x24, .escaped = 'd' }, // dollar sign
        .{ .encoded = 0x27, .escaped = 'a' }, // apostrophy
        .{ .encoded = 0x5C, .escaped = 'b' }, // backslash
        .{ .encoded = 0x60, .escaped = 'g' }, // grave accent
    };
    //------------------------------------------------------------
    pub const Encoding = enum { base, base64, base64url, base91, hex, default };
    pub const Defaults = struct { encoding: Encoding = .default };
    //------------------------------------------------------------
    pub fn obfuscate(allocator: *std.mem.Allocator, data: []const u8, value: u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        _ = options;
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        var output: []u8 = try allocator.alloc(u8, data.len);
        errdefer allocator.free(output);
        //----------------------------------------
        for (data, 0..) |byte, index| {
            output[index] = byte ^ value;
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn encode(allocator: *std.mem.Allocator, data: []const u8, value: u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        const opts = setOptions(Defaults, options);
        //------------------------------------------------------------
        if (opts.encoding != .default) {
            //----------------------------------------
            const obfuscated_data = try ObfuscateXOR.obfuscate(allocator, data, value, .{});
            defer allocator.free(obfuscated_data);
            //----------------------------------------
            switch (opts.encoding) {
                .base => return conv.Base.encode(allocator, obfuscated_data, .{}),
                .base64 => return conv.Base64.encode(allocator, obfuscated_data, .{}),
                .base64url => return conv.Base64.urlEncode(allocator, obfuscated_data, .{}),
                .base91 => return conv.Base91.encode(allocator, obfuscated_data, .{ .escape = true }),
                .hex => return conv.Hex.encode(allocator, obfuscated_data, .{}),
                .default => return Error.EncodingError, // default encoding should be processed below
            }
            //----------------------------------------
        }
        //------------------------------------------------------------
        var escapeCount: usize = 0;
        for (data) |byte| {
            for (ObfuscateXOR.replacements) |replacement| {
                if ((byte ^ value) == replacement.encoded) escapeCount += 1;
            }
        }
        //----------------------------------------
        var output: []u8 = try allocator.alloc(u8, data.len + escapeCount);
        errdefer allocator.free(output);
        //----------------------------------------
        var output_index: usize = 0;
        //----------------------------------------
        for (data) |byte| {
            //----------------------------------------
            const encoded = byte ^ value;
            //----------------------------------------
            var replaced = false;
            for (ObfuscateXOR.replacements) |replacement| {
                if (encoded == replacement.encoded) {
                    output[output_index] = '-';
                    output_index += 1;
                    output[output_index] = replacement.escaped;
                    replaced = true;
                    break;
                }
            }
            if (!replaced) {
                output[output_index] = encoded;
            }
            output_index += 1;
            //----------------------------------------
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn decode(allocator: *std.mem.Allocator, data: []const u8, value: u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        const opts = setOptions(Defaults, options);
        //------------------------------------------------------------
        if (opts.encoding != .default) {
            //----------------------------------------
            const decoded_data = switch (opts.encoding) {
                .base => try conv.Base.decode(allocator, data, .{}),
                .base64 => try conv.Base64.decode(allocator, data, .{}),
                .base64url => try conv.Base64.urlDecode(allocator, data, .{}),
                .base91 => try conv.Base91.decode(allocator, data, .{ .escape = true }),
                .hex => try conv.Hex.decode(allocator, data, .{}),
                .default => return Error.EncodingError, // default encoding should be processed below
            };
            defer allocator.free(decoded_data);
            //----------------------------------------
            return ObfuscateXOR.obfuscate(allocator, decoded_data, value, .{});
            //----------------------------------------
        }
        //------------------------------------------------------------
        var scan_index: usize = 0;
        var escapeCount: usize = 0;
        while (scan_index < data.len - 1) {
            if (data[scan_index] == '-') {
                for (ObfuscateXOR.replacements) |replacement| {
                    if (data[scan_index + 1] == replacement.escaped) {
                        escapeCount += 1;
                        scan_index += 1;
                        break;
                    }
                }
            }
            scan_index += 1;
        }
        //----------------------------------------
        var output: []u8 = try allocator.alloc(u8, data.len - escapeCount);
        errdefer allocator.free(output);
        //----------------------------------------
        var buffer_index: usize = 0;
        var output_index: usize = 0;
        //----------------------------------------
        while (buffer_index < data.len) {
            //----------------------------------------
            if (data[buffer_index] == '-' and buffer_index + 1 < data.len) {
                //----------------------------------------
                var replaced = false;
                for (ObfuscateXOR.replacements) |replacement| {
                    if (data[buffer_index + 1] == replacement.escaped) {
                        output[output_index] = replacement.encoded ^ value;
                        replaced = true;
                        break;
                    }
                }
                if (!replaced) {
                    output[output_index] = '-' ^ value;
                    output_index += 1;
                    output[output_index] = data[buffer_index + 1] ^ value;
                }
                //----------------------------------------
                buffer_index += 1; // skip an extra byte as already processed
                //----------------------------------------
            } else {
                //----------------------------------------
                output[output_index] = data[buffer_index] ^ value;
                //----------------------------------------
            }
            //----------------------------------------
            buffer_index += 1;
            output_index += 1;
            //----------------------------------------
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn setOptions(T: type, options: anytype) T {
        var target = T{};
        inline for (std.meta.fields(@TypeOf(target))) |field| {
            if (@hasField(@TypeOf(options), field.name)) {
                @field(target, field.name) = @field(options, field.name);
            }
        }
        return target;
    }
    //------------------------------------------------------------
};
//------------------------------------------------------------
//############################################################
//------------------------------------------------------------
pub fn main() void {
    //------------------------------------------------------------
    var it = std.process.args();
    const name = if (it.next()) |arg0| std.fs.path.basename(arg0) else "";
    std.debug.print("{s}: main function\n", .{name});
    //------------------------------------------------------------
}
//------------------------------------------------------------
