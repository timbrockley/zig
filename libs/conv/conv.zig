//------------------------------------------------------------
// Conversion Library
// Copyright 2025, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//------------------------------------------------------------
const std = @import("std");
//------------------------------------------------------------
pub const Base = struct {
    //------------------------------------------------------------
    pub const Error = error{InvalidInput};
    //------------------------------------------------------------
    pub fn encode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        _ = options;
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        var paddingLength: usize = 0;
        if (data.len % 4 > 0) {
            paddingLength = (4 - data.len % 4);
        }
        //------------------------------------------------------------
        const output_len = ((data.len + paddingLength) / 4 * 5) - paddingLength;
        //------------------------------------------------------------
        const output: []u8 = try allocator.alloc(u8, output_len);
        errdefer allocator.free(output);
        //------------------------------------------------------------
        var output_index: usize = 0;
        //------------------------------------------------------------
        var data_index: usize = 0;
        while (data_index < data.len) : (data_index += 4) {
            //---------------------------------------------------
            const b0: u32 = if (data_index < data.len) data[data_index] else 0;
            const b1: u32 = if (data_index + 1 < data.len) data[data_index + 1] else 0;
            const b2: u32 = if (data_index + 2 < data.len) data[data_index + 2] else 0;
            const b3: u32 = if (data_index + 3 < data.len) data[data_index + 3] else 0;
            //---------------------------------------------------
            var dataChunkSum: u32 = b0 << 24 | b1 << 16 | b2 << 8 | b3;
            //---------------------------------------------------
            if (dataChunkSum == 0) {
                //---------------------------------------------------
                for (0..5) |block_index| {
                    if (output_index + block_index < output_len) {
                        output[output_index + block_index] = '!';
                    }
                }
                //--------------------
                output_index += 5;
                //---------------------------------------------------
            } else {
                //---------------------------------------------------
                for (0..5) |block_index| {
                    //----------------------------------------
                    const value: u32 = dataChunkSum % 85;
                    dataChunkSum = (dataChunkSum - value) / 85;
                    //----------------------------------------
                    const reversed_block_index = 5 - block_index - 1;
                    if (output_index + reversed_block_index < output_len) {
                        output[output_index + reversed_block_index] = try baseValueEncode(@intCast(value & 0xFF));
                    }
                    //----------------------------------------
                }
                //---------------------------------------------------
                output_index += 5;
                //---------------------------------------------------
            }
            //---------------------------------------------------
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn decode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        _ = options;
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        var paddingLength: usize = 0;
        if (data.len % 5 > 0) {
            paddingLength = (5 - data.len % 5);
        }
        //------------------------------------------------------------
        const output_len = ((data.len + paddingLength) / 5 * 4) - paddingLength;
        //------------------------------------------------------------
        const output: []u8 = try allocator.alloc(u8, output_len);
        errdefer allocator.free(output);
        //------------------------------------------------------------
        var output_index: usize = 0;
        var data_index: usize = 0;
        while (data_index < data.len) : (data_index += 5) {
            //---------------------------------------------------
            var b0: u64 = undefined;
            var b1: u64 = undefined;
            var b2: u64 = undefined;
            var b3: u64 = undefined;
            var b4: u64 = undefined;
            //---------------------------------------------------
            b0 = if (data_index < data.len) try baseValueDecode(data[data_index]) else 'z';
            b1 = if (data_index + 1 < data.len) try baseValueDecode(data[data_index + 1]) else 'z';
            b2 = if (data_index + 2 < data.len) try baseValueDecode(data[data_index + 2]) else 'z';
            b3 = if (data_index + 3 < data.len) try baseValueDecode(data[data_index + 3]) else 'z';
            b4 = if (data_index + 4 < data.len) try baseValueDecode(data[data_index + 4]) else 'z';
            //---------------------------------------------------
            const decodedChunk: u64 = 52200625 * b0 + 614125 * b1 + 7225 * b2 + 85 * b3 + b4;
            //---------------------------------------------------
            if (output_index < output_len) output[output_index] = @intCast(decodedChunk >> 24 & 0xFF);
            if (output_index + 1 < output_len) output[output_index + 1] = @intCast(decodedChunk >> 16 & 0xFF);
            if (output_index + 2 < output_len) output[output_index + 2] = @intCast(decodedChunk >> 8 & 0xFF);
            if (output_index + 3 < output_len) output[output_index + 3] = @intCast(decodedChunk & 0xFF);
            //---------------------------------------------------
            output_index += 4;
            //---------------------------------------------------
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn baseValueEncode(byte: u8) !u8 {
        return switch (byte) {
            0 => '!',
            1 => '#',
            2 => '%',
            3 => '&',
            4...55 => byte + 36,
            56 => ']',
            57 => '^',
            58 => '_',
            59...84 => byte + 38,
            else => error.InvalidInput,
        };
    }
    //------------------------------------------------------------
    pub fn baseValueDecode(char: u8) !u8 {
        return switch (char) {
            '!' => 0,
            '#' => 1,
            '%' => 2,
            '&' => 3,
            '('...'[' => char - 36,
            ']' => 56,
            '^' => 57,
            '_' => 58,
            'a'...'z' => char - 38,
            else => error.InvalidInput,
        };
    }
    //------------------------------------------------------------
    fn setOptions(T: type, options: anytype) T {
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
pub const Base64 = struct {
    //------------------------------------------------------------
    pub const Error = error{InvalidInput};
    //------------------------------------------------------------
    pub const Defaults = struct {
        charset: []const u8 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",
        pad_char: ?u8 = '=',
    };
    //------------------------------------------------------------
    pub const DefaultsUrl = struct {
        charset: []const u8 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_",
        pad_char: ?u8 = null,
    };
    //------------------------------------------------------------
    pub fn encode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        const opts = setOptions(Defaults, options);
        //------------------------------------------------------------
        const encoding_len = switch (opts.pad_char != null) {
            true => plaintextToBase64Length(data),
            else => plaintextToBase64UrlLength(data),
        };
        //------------------------------------------------------------
        const output: []u8 = try allocator.alloc(u8, encoding_len);
        errdefer allocator.free(output);
        //------------------------------------------------------------
        var index: usize = 0;
        var output_index: usize = 0;
        while (index + 15 < data.len) : (index += 12) {
            const bits = std.mem.readInt(u128, data[index..][0..16], .big);
            inline for (0..16) |i| {
                output[output_index + i] = opts.charset[@truncate((bits >> (122 - i * 6)) & 0x3f)];
            }
            output_index += 16;
        }
        //------------------------------------------------------------
        while (index + 3 < data.len) : (index += 3) {
            const bits = std.mem.readInt(u32, data[index..][0..4], .big);
            output[output_index] = opts.charset[(bits >> 26) & 0x3f];
            output[output_index + 1] = opts.charset[(bits >> 20) & 0x3f];
            output[output_index + 2] = opts.charset[(bits >> 14) & 0x3f];
            output[output_index + 3] = opts.charset[(bits >> 8) & 0x3f];
            output_index += 4;
        }
        if (index + 2 < data.len) {
            output[output_index] = opts.charset[data[index] >> 2];
            output[output_index + 1] = opts.charset[((data[index] & 0x3) << 4) | (data[index + 1] >> 4)];
            output[output_index + 2] = opts.charset[(data[index + 1] & 0xf) << 2 | (data[index + 2] >> 6)];
            output[output_index + 3] = opts.charset[data[index + 2] & 0x3f];
            output_index += 4;
        } else if (index + 1 < data.len) {
            output[output_index] = opts.charset[data[index] >> 2];
            output[output_index + 1] = opts.charset[((data[index] & 0x3) << 4) | (data[index + 1] >> 4)];
            output[output_index + 2] = opts.charset[(data[index + 1] & 0xf) << 2];
            output_index += 3;
        } else if (index < data.len) {
            output[output_index] = opts.charset[data[index] >> 2];
            output[output_index + 1] = opts.charset[(data[index] & 0x3) << 4];
            output_index += 2;
        }
        //------------------------------------------------------------
        if (opts.pad_char) |pad_char| {
            for (output[output_index..encoding_len]) |*pad| pad.* = pad_char;
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
        if (opts.pad_char != null and data.len % 4 != 0) return Error.InvalidInput;
        //------------------------------------------------------------
        const encoding_len = switch (opts.pad_char != null) {
            true => try base64ToPlaintextLength(data),
            else => base64UrlToPlaintextLength(data),
        };
        //------------------------------------------------------------
        const output: []u8 = try allocator.alloc(u8, encoding_len);
        errdefer allocator.free(output);
        //------------------------------------------------------------
        var index: usize = 0;
        var output_index: usize = 0;
        while (index + 1 < data.len) : (index += 4) {
            const val0 = base64Value(data[index]) catch return Error.InvalidInput;
            const val1 = base64Value(data[index + 1]) catch return Error.InvalidInput;
            const val2 = if (index + 2 >= data.len) 0 else base64Value(data[index + 2]) catch return Error.InvalidInput;
            const val3 = if (index + 3 >= data.len) 0 else base64Value(data[index + 3]) catch return Error.InvalidInput;
            output[output_index] = @truncate((val0 << 2) | (val1 >> 4));
            if (output_index + 1 < output.len) {
                output[output_index + 1] = @truncate((val1 << 4) | (val2 >> 2));
            }
            if (output_index + 2 < output.len) {
                output[output_index + 2] = @truncate((val2 << 6) | val3);
            }
            output_index += 3;
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn urlEncode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        return encode(allocator, data, setOptions(DefaultsUrl, options));
    }
    //------------------------------------------------------------
    pub fn urlDecode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        return decode(allocator, data, setOptions(DefaultsUrl, options));
    }
    //------------------------------------------------------------
    pub fn base64Value(char: u8) !u8 {
        return switch (char) {
            'A'...'Z' => char - 'A',
            'a'...'z' => char - 'a' + 26,
            '0'...'9' => char - '0' + 52,
            '+', '-' => 62,
            '/', '_' => 63,
            '=' => 0,
            else => Error.InvalidInput,
        };
    }
    //------------------------------------------------------------
    pub fn plaintextToBase64Length(data: []const u8) usize {
        return @divTrunc(data.len + 2, 3) * 4;
    }
    //------------------------------------------------------------
    pub fn plaintextToBase64UrlLength(data: []const u8) usize {
        return @divTrunc(data.len, 3) * 4 + @divTrunc(data.len % 3 * 4 + 2, 3);
    }
    //------------------------------------------------------------
    pub fn base64ToPlaintextLength(data: []const u8) !usize {
        if (data.len % 4 != 0) return Error.InvalidInput;
        var result = data.len * 6 / 8;
        if (data.len >= 1 and data[data.len - 1] == '=') result -= 1;
        if (data.len >= 2 and data[data.len - 2] == '=') result -= 1;
        return result;
    }
    //------------------------------------------------------------
    pub fn base64UrlToPlaintextLength(data: []const u8) usize {
        return switch (data.len % 4) {
            2 => data.len / 4 * 3 + 1,
            3 => data.len / 4 * 3 + 2,
            else => data.len / 4 * 3,
        };
    }
    //------------------------------------------------------------
    pub fn base64ToBase64UrlLength(data: []const u8) usize {
        var result = data.len;
        if (data.len >= 1 and data[data.len - 1] == '=') result -= 1;
        if (data.len >= 2 and data[data.len - 2] == '=') result -= 1;
        return result;
    }
    //------------------------------------------------------------
    pub fn base64UrlToBase64Length(data: []const u8) usize {
        return if (data.len % 4 != 0) data.len + 4 - (data.len % 4) else data.len;
    }
    //------------------------------------------------------------
    pub fn base64ToBase64Url(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        const encoding_len = base64ToBase64UrlLength(data);
        //------------------------------------------------------------
        const output: []u8 = try allocator.alloc(u8, encoding_len);
        errdefer allocator.free(output);
        //------------------------------------------------------------
        var index: usize = 0;
        for (data) |char| {
            switch (char) {
                '+' => output[index] = '-',
                '/' => output[index] = '_',
                '=' => continue,
                else => output[index] = char,
            }
            index += 1;
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn base64UrlToBase64(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        const encoding_len = base64UrlToBase64Length(data);
        //------------------------------------------------------------
        const output: []u8 = try allocator.alloc(u8, encoding_len);
        errdefer allocator.free(output);
        //------------------------------------------------------------
        var index: usize = 0;
        for (data) |char| {
            switch (char) {
                '-' => output[index] = '+',
                '_' => output[index] = '/',
                else => output[index] = char,
            }
            index += 1;
        }
        //------------------------------------------------------------
        for (output[index..encoding_len]) |*pad| pad.* = '=';
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    fn setOptions(T: type, options: anytype) T {
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
pub const Base85 = struct {
    //------------------------------------------------------------
    pub const Error = error{InvalidInput};
    //------------------------------------------------------------
    pub const DefaultsEncode = struct {
        escape: bool = false,
        replace_zero: bool = true,
        trim: bool = false,
        wrap: bool = false,
    };
    //------------------------------------------------------------
    pub const DefaultsDecode = struct {
        escape: bool = false,
        replace_zero: bool = true,
        trim: bool = true,
        wrap: bool = false,
    };
    //------------------------------------------------------------
    pub fn encode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        const opts = setOptions(DefaultsEncode, options);
        //------------------------------------------------------------
        var data_ptr = data.ptr;
        var data_len = data.len;
        //------------------------------------------------------------
        var _data: []const u8 = undefined;
        //-----------------------------------
        if (opts.trim) {
            //-----------------------------------
            _data = std.mem.trim(u8, data, &std.ascii.whitespace);
            //-----------------------------------
            data_ptr = _data.ptr;
            data_len = _data.len;
            //-----------------------------------
        }
        //------------------------------------------------------------
        // scan for zero replacements here as need to know before output buffer created
        var zero_replacements: usize = 0;
        //-----------------------------------
        if (opts.replace_zero and data_len >= 4) {
            //-----------------------------------
            var zero_index: usize = 0;
            //-----------------------------------
            while (zero_index < data_len) : (zero_index += 4) {
                const remaining: usize = data_len - zero_index;
                if (remaining >= 4 and data_ptr[zero_index] == 0 and
                    data_ptr[zero_index + 1] == 0 and
                    data_ptr[zero_index + 2] == 0 and
                    data_ptr[zero_index + 3] == 0)
                {
                    zero_replacements += 4;
                }
            }
            //-----------------------------------
        }
        //------------------------------------------------------------
        var paddingLength: usize = 0;
        if (data_len % 4 > 0) {
            paddingLength = (4 - data_len % 4);
        }
        //------------------------------------------------------------
        var output_len = ((data_len + paddingLength) / 4 * 5) - paddingLength - zero_replacements;
        var encoding_len = output_len;
        if (opts.wrap) {
            output_len += 4;
            encoding_len += 2;
        }
        //------------------------------------------------------------
        const output: []u8 = try allocator.alloc(u8, output_len);
        errdefer allocator.free(output);
        //------------------------------------------------------------
        var output_index: usize = 0;
        if (opts.wrap) {
            output[0] = '<';
            output[1] = '~';
            output_index += 2;
        }
        //------------------------------------------------------------
        var data_index: usize = 0;
        while (data_index < data_len) : (data_index += 4) {
            //---------------------------------------------------
            const b0: u32 = if (data_index < data_len) data_ptr[data_index] else 0;
            const b1: u32 = if (data_index + 1 < data_len) data_ptr[data_index + 1] else 0;
            const b2: u32 = if (data_index + 2 < data_len) data_ptr[data_index + 2] else 0;
            const b3: u32 = if (data_index + 3 < data_len) data_ptr[data_index + 3] else 0;
            //---------------------------------------------------
            var dataChunkSum: u32 = b0 << 24 | b1 << 16 | b2 << 8 | b3;
            //---------------------------------------------------
            if (dataChunkSum == 0) {
                //---------------------------------------------------
                const remaining: usize = data_len - data_index;
                //---------------------------------------------------
                if (opts.replace_zero and output_index < encoding_len and remaining >= 4) {
                    //--------------------
                    output[output_index] = 'z';
                    //--------------------
                    output_index += 1;
                    //--------------------
                } else {
                    //--------------------
                    for (0..5) |block_index| {
                        if (output_index + block_index < encoding_len) {
                            output[output_index + block_index] = '!';
                        }
                    }
                    //--------------------
                    output_index += 5;
                    //--------------------
                }
                //---------------------------------------------------
            } else {
                //---------------------------------------------------
                for (0..5) |block_index| {
                    //----------------------------------------
                    const encodedChar32: u32 = dataChunkSum % 85;
                    dataChunkSum = (dataChunkSum - encodedChar32) / 85;
                    //----------------------------------------
                    const reversed_block_index = 5 - block_index - 1;
                    if (output_index + reversed_block_index < encoding_len) {
                        if (opts.escape) {
                            output[output_index + reversed_block_index] = try escapeChar(@intCast((encodedChar32 + 33) & 0xFF));
                        } else {
                            output[output_index + reversed_block_index] = @intCast((encodedChar32 + 33) & 0xFF);
                        }
                    }
                    //----------------------------------------
                }
                //---------------------------------------------------
                output_index += 5;
                //---------------------------------------------------
            }
            //---------------------------------------------------
        }
        //------------------------------------------------------------
        if (opts.wrap) {
            output[output_len - 2] = '~';
            output[output_len - 1] = '>';
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
        const opts = setOptions(DefaultsDecode, options);
        //------------------------------------------------------------
        var data_ptr = data.ptr;
        var data_len = data.len;
        //------------------------------------------------------------
        var _data: []const u8 = undefined;
        //-----------------------------------
        if (opts.trim) {
            //-----------------------------------
            _data = try trim(data);
            //-----------------------------------
            data_ptr = _data.ptr;
            data_len = _data.len;
            //-----------------------------------
        }
        //------------------------------------------------------------
        if (opts.replace_zero) {
            //-----------------------------------
            _data = try std.mem.replaceOwned(u8, allocator.*, _data, "z", "!!!!!");
            //-----------------------------------
            data_ptr = _data.ptr;
            data_len = _data.len;
            //-----------------------------------
        }
        //------------------------------------------------------------
        var paddingLength: usize = 0;
        if (data_len % 5 > 0) {
            paddingLength = (5 - data_len % 5);
        }
        //------------------------------------------------------------
        const encoding_len = ((data_len + paddingLength) / 5 * 4) - paddingLength;
        //------------------------------------------------------------
        const output: []u8 = try allocator.alloc(u8, encoding_len);
        errdefer allocator.free(output);
        //------------------------------------------------------------
        var output_index: usize = 0;
        var data_index: usize = 0;
        while (data_index < data_len) : (data_index += 5) {
            //---------------------------------------------------
            var b0: u64 = undefined;
            var b1: u64 = undefined;
            var b2: u64 = undefined;
            var b3: u64 = undefined;
            var b4: u64 = undefined;
            //---------------------------------------------------
            if (opts.escape) {
                b0 = if (data_index < data_len) try unescapeChar(data_ptr[data_index]) else 'u';
                b1 = if (data_index + 1 < data_len) try unescapeChar(data_ptr[data_index + 1]) else 'u';
                b2 = if (data_index + 2 < data_len) try unescapeChar(data_ptr[data_index + 2]) else 'u';
                b3 = if (data_index + 3 < data_len) try unescapeChar(data_ptr[data_index + 3]) else 'u';
                b4 = if (data_index + 4 < data_len) try unescapeChar(data_ptr[data_index + 4]) else 'u';
            } else {
                b0 = if (data_index < data_len) data_ptr[data_index] else 'u';
                b1 = if (data_index + 1 < data_len) data_ptr[data_index + 1] else 'u';
                b2 = if (data_index + 2 < data_len) data_ptr[data_index + 2] else 'u';
                b3 = if (data_index + 3 < data_len) data_ptr[data_index + 3] else 'u';
                b4 = if (data_index + 4 < data_len) data_ptr[data_index + 4] else 'u';
            }
            //---------------------------------------------------
            if (b0 < 33 or b0 > 117) return Error.InvalidInput;
            if (b1 < 33 or b1 > 117) return Error.InvalidInput;
            if (b2 < 33 or b2 > 117) return Error.InvalidInput;
            if (b3 < 33 or b3 > 117) return Error.InvalidInput;
            if (b4 < 33 or b4 > 117) return Error.InvalidInput;
            //---------------------------------------------------
            const decodedChunk: u64 = 52200625 * (b0 - 33) + 614125 * (b1 - 33) + 7225 * (b2 - 33) + 85 * (b3 - 33) + (b4 - 33);
            //---------------------------------------------------
            if (output_index < encoding_len) output[output_index] = @intCast((decodedChunk >> 24) & 0xFF);
            if (output_index + 1 < encoding_len) output[output_index + 1] = @intCast((decodedChunk >> 16) & 0xFF);
            if (output_index + 2 < encoding_len) output[output_index + 2] = @intCast((decodedChunk >> 8) & 0xFF);
            if (output_index + 3 < encoding_len) output[output_index + 3] = @intCast(decodedChunk & 0xFF);
            //---------------------------------------------------
            output_index += 4;
            //---------------------------------------------------
        }
        //------------------------------------------------------------
        return output;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn trim(data: []const u8) ![]const u8 {
        //------------------------------------------------------------
        var _data = std.mem.trim(u8, data, &std.ascii.whitespace);
        //------------------------------------------------------------
        if (_data[0] == '<' or _data[_data.len - 1] == '>') {
            //-----------------------------------
            if (_data[0] == '<' and _data[1] != '~' or _data[_data.len - 1] == '>' and _data[_data.len - 2] != '~') return Error.InvalidInput;
            //-----------------------------------
            const start: usize = if (_data[0] == '<') 2 else 0;
            const end: usize = if (_data[_data.len - 1] == '>') _data.len - 2 else _data.len;
            //-----------------------------------
            return _data[start..end];
            //-----------------------------------
        }
        //------------------------------------------------------------
        return _data;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn escapeChar(char: u8) !u8 {
        return switch (char) {
            0x00...0x20 => Error.InvalidInput,
            0x22 => '{', // quotes
            0x24 => 'x', // dollar
            0x27 => '}', // apostrophy
            0x5C => '|', // backslash
            0x60 => '~', // grave accent
            0x76...0x77 => Error.InvalidInput,
            0x79 => Error.InvalidInput,
            0x7F...0xFF => Error.InvalidInput,
            else => char,
        };
    }
    //------------------------------------------------------------
    pub fn unescapeChar(char: u8) !u8 {
        return switch (char) {
            0x00...0x20 => Error.InvalidInput,
            '{' => 0x22, // quotes
            'x' => 0x24, // dollar
            '}' => 0x27, // apostrophy
            '|' => 0x5C, // backslash
            '~' => 0x60, // grave accent
            0x76...0x77 => Error.InvalidInput,
            0x79 => Error.InvalidInput,
            0x7F...0xFF => Error.InvalidInput,
            else => char,
        };
    }
    //------------------------------------------------------------
    fn setOptions(T: type, options: anytype) T {
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
pub const Base91 = struct {
    //------------------------------------------------------------
    pub const Error = error{InvalidInput};
    //------------------------------------------------------------
    pub const base91_charset = [91]u8{
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!', '#', '$',
        '%', '&', '(', ')', '*', '+', ',', '.', '/', ':', ';', '<', '=',
        '>', '?', '@', '[', ']', '^', '_', '`', '{', '|', '}', '~', '"',
    };
    //------------------------------------------------------------
    pub const base91_encoded_chars = [256]u8{ 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 62, 90, 63, 64, 65, 66, 91, 67, 68, 69, 70, 71, 91, 72, 73, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 74, 75, 76, 77, 78, 79, 80, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 81, 91, 82, 83, 84, 85, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 86, 87, 88, 89, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91, 91 };
    //------------------------------------------------------------
    pub const Defaults = struct { escape: bool = false };
    //------------------------------------------------------------
    pub fn encode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //-----------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //-----------------------------------------------------------
        const opts = setOptions(Defaults, options);
        //------------------------------------------------------------
        const buffer: []u8 = try allocator.alloc(u8, data.len * 2);
        defer allocator.free(buffer);
        //-----------------------------------------------------------
        var queue: u32 = 0;
        var num_bits: u32 = 0;
        //-----------------------------------------------------------
        var buffer_index: usize = 0;
        //-----------------------------------------------------------
        for (data) |byte| {
            //-----------------------------------------------------------
            queue |= @as(u32, byte) << @intCast(num_bits);
            num_bits += 8;
            //-----------------------------------------------------------
            while (num_bits > 13) {
                //-----------------------------------------------------------
                var value = queue & 8191;
                //-----------------------------------------------------------
                if (value > 88) {
                    queue >>= 13;
                    num_bits -= 13;
                } else {
                    value = queue & 16383;
                    queue >>= 14;
                    num_bits -= 14;
                }
                //-----------------------------------------------------------
                if (opts.escape) {
                    base91EscapedOutput(buffer, &buffer_index, base91_charset[value % 91]);
                    base91EscapedOutput(buffer, &buffer_index, base91_charset[value / 91]);
                } else {
                    buffer[buffer_index] = base91_charset[value % 91];
                    buffer[buffer_index + 1] = base91_charset[value / 91];
                    buffer_index += 2;
                }
                //-----------------------------------------------------------
            }
            //-----------------------------------------------------------
        }
        //-----------------------------------------------------------
        if (num_bits > 0) {
            //-----------------------------------------------------------
            if (opts.escape) {
                base91EscapedOutput(buffer, &buffer_index, base91_charset[queue % 91]);
            } else {
                buffer[buffer_index] = base91_charset[queue % 91];
                buffer_index += 1;
            }
            //-----------------------------------------------------------
            if (num_bits > 7 or queue > 90) {
                //-----------------------------------------------------------
                if (opts.escape) {
                    base91EscapedOutput(buffer, &buffer_index, base91_charset[queue / 91]);
                } else {
                    buffer[buffer_index] = base91_charset[queue / 91];
                    buffer_index += 1;
                }
                //-----------------------------------------------------------
            }
            //-----------------------------------------------------------
        }
        //-----------------------------------------------------------
        const output: []u8 = try allocator.alloc(u8, buffer_index);
        errdefer allocator.free(output);
        //-----------------------------------------------------------
        for (buffer[0..buffer_index], output) |s, *d| d.* = s;
        //-----------------------------------------------------------
        return output;
        //-----------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn decode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //-----------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //-----------------------------------------------------------
        const opts = setOptions(Defaults, options);
        //------------------------------------------------------------
        const buffer: []u8 = try allocator.alloc(u8, data.len);
        defer allocator.free(buffer);
        //-----------------------------------------------------------
        var queue: u32 = 0;
        var num_bits: u32 = 0;
        //-----------------------------------------------------------
        var value: u32 = 0xFFFFFFFF;
        //-----------------------------------------------------------
        var data_index: usize = 0;
        //-----------------------------------------------------------
        var buffer_index: usize = 0;
        //-----------------------------------------------------------
        while (data_index < data.len) : (data_index += 1) {
            //-----------------------------------------------------------
            var char: u8 = data[data_index];
            //----------------------------------------
            if (opts.escape and data_index < data.len - 1 and char == '-') {
                data_index += 1;
                char = try base91UnescapeChar(data[data_index]);
            }
            //-----------------------------------------------------------
            const encoded_value = base91_encoded_chars[char];
            //----------------------------------------
            if (encoded_value == 91) return Error.InvalidInput;
            //-----------------------------------------------------------
            if (value == 0xFFFFFFFF) {
                value = encoded_value;
            } else {
                value += @as(u32, encoded_value) * 91;
                queue |= value << @intCast(num_bits);

                num_bits += if (value & 8191 > 88) 13 else 14;
                while (num_bits > 7) {
                    buffer[buffer_index] = @truncate(queue & 0xff);
                    buffer_index += 1;
                    queue >>= 8;
                    num_bits -= 8;
                }
                value = 0xFFFFFFFF;
            }
            //-----------------------------------------------------------
        }
        //-----------------------------------------------------------
        if (value != 0xFFFFFFFF) {
            buffer[buffer_index] = @truncate(queue | value << @intCast(num_bits) & 0xff);
            buffer_index += 1;
        }
        //-----------------------------------------------------------
        const output: []u8 = try allocator.alloc(u8, buffer_index);
        errdefer allocator.free(output);
        //-----------------------------------------------------------
        for (buffer[0..buffer_index], output) |s, *d| d.* = s;
        //-----------------------------------------------------------
        return output;
        //-----------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn base91EscapedOutput(output: []u8, output_index: *usize, char: u8) void {
        switch (char) {
            0x22 => {
                output[output_index.*] = '-';
                output[output_index.* + 1] = 'q';
                output_index.* += 2;
            },
            0x24 => {
                output[output_index.*] = '-';
                output[output_index.* + 1] = 'd';
                output_index.* += 2;
            },
            0x60 => {
                output[output_index.*] = '-';
                output[output_index.* + 1] = 'g';
                output_index.* += 2;
            },
            else => {
                output[output_index.*] = char;
                output_index.* += 1;
            },
        }
    }
    //------------------------------------------------------------
    pub fn base91UnescapeChar(char: u8) !u8 {
        return switch (char) {
            'q' => 0x22,
            'd' => 0x24,
            'g' => 0x60,
            else => Error.InvalidInput,
        };
    }
    //------------------------------------------------------------
    fn setOptions(T: type, options: anytype) T {
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
pub const Hex = struct {
    //------------------------------------------------------------
    pub const Error = error{InvalidInputLength};
    //------------------------------------------------------------
    pub fn encode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //-----------------------------------------------------------
        _ = options;
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        return try std.fmt.allocPrint(allocator.*, "{X}", .{data});
        //-----------------------------------------------------------
    }
    //------------------------------------------------------------
    pub fn decode(allocator: *std.mem.Allocator, data: []const u8, options: anytype) ![]u8 {
        //-----------------------------------------------------------
        _ = options;
        //------------------------------------------------------------
        if (data.len == 0) return allocator.alloc(u8, 0);
        //------------------------------------------------------------
        if (data.len % 2 != 0) return Error.InvalidInputLength;
        //------------------------------------------------------------
        const output: []u8 = try allocator.alloc(u8, data.len / 2);
        errdefer allocator.free(output);
        //------------------------------------------------------------
        var index: usize = 0;
        while (index < data.len) : (index += 2) {
            //---------------------------------------------------
            const slice = data[index .. index + 2];
            const value = try std.fmt.parseInt(u8, slice, 16);
            output[index / 2] = value;
            //---------------------------------------------------
        }
        //-----------------------------------------------------------
        return output;
        //-----------------------------------------------------------
    }
    //------------------------------------------------------------
    fn setOptions(T: type, options: anytype) T {
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
pub fn main() void {
    //------------------------------------------------------------
    var it = std.process.args();
    const name = if (it.next()) |arg0| std.fs.path.basename(arg0) else "";
    std.debug.print("{s}: main function\n", .{name});
    //------------------------------------------------------------
}
//------------------------------------------------------------
