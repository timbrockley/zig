//--------------------------------------------------------------------------------
const std = @import("std");
const ut = @import("libs/unittest.zig");
const obf = @import("crypto.zig");
//--------------------------------------------------------------------------------
pub fn main() !void {
    //----------------------------------------------------------------------------
    ut.init();
    //----------------------------------------------------------------------------
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    // const allocator = gpa.allocator();
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    var allocator = arena_allocator.allocator();
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateXOR.obfuscate";
        const value = 0b10101010;
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
        }{
            .{ .data = "", .expected = "" },
            .{ .data = "hello", .expected = &[_]u8{ 194, 207, 198, 198, 197 } },
            .{ .data = &[_]u8{ 194, 207, 198, 198, 197 }, .expected = "hello" },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |case| {
            //----------------------------------------
            if (obf.ObfuscateXOR.obfuscate(&allocator, case.data, value, .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareByteSlice(name, case.expected, result);
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                fail_count += 1;
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateXOR.encode";
        const value = 0b10101010;
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            encoding: obf.ObfuscateXOR.Encoding,
        }{
            .{ .data = "", .expected = "", .encoding = .default },
            .{ .data = &[_]u8{ 247, 135, 163, 160, 167, 138, 136, 142, 141, 246, 202, 135, 242 }, .expected = "]---t-n-r-s-q-d-a-b-g--X", .encoding = .default },
            .{ .data = "hello", .expected = &[_]u8{ 194, 207, 198, 198, 197 }, .encoding = .default },
            .{ .data = "hello", .expected = "dX&9De>", .encoding = .base },
            .{ .data = "hello", .expected = "ws/GxsU=", .encoding = .base64 },
            .{ .data = "hello", .expected = "ws_GxsU", .encoding = .base64url },
            .{ .data = "hello", .expected = "ess!GxB", .encoding = .base91 },
            .{ .data = "hello", .expected = "C2CFC6C6C5", .encoding = .hex },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |case| {
            //----------------------------------------
            if (obf.ObfuscateXOR.encode(&allocator, case.data, value, .{ .encoding = case.encoding })) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    if (case.encoding == .default) {
                        ut.compareByteSlice(name, case.expected, result);
                    } else {
                        ut.compareStringSlice(name, case.expected, result);
                    }
                    //----------------------------------------
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                fail_count += 1;
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateXOR.decode";
        const value = 0b10101010;
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            encoding: obf.ObfuscateXOR.Encoding,
        }{
            .{ .data = "", .expected = "", .encoding = .default },
            .{ .data = "]---t-n-r-s-q-d-a-b-g--X", .expected = &[_]u8{ 247, 135, 163, 160, 167, 138, 136, 142, 141, 246, 202, 135, 242 }, .encoding = .default },
            .{ .data = "dX&9De>", .expected = "hello", .encoding = .base },
            .{ .data = "ws/GxsU=", .expected = "hello", .encoding = .base64 },
            .{ .data = "ws_GxsU", .expected = "hello", .encoding = .base64url },
            .{ .data = "ess!GxB", .expected = "hello", .encoding = .base91 },
            .{ .data = "C2CFC6C6C5", .expected = "hello", .encoding = .hex },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |case| {
            //----------------------------------------
            if (obf.ObfuscateXOR.decode(&allocator, case.data, value, .{ .encoding = case.encoding })) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    if (case.encoding == .default) {
                        ut.compareByteSlice(name, case.expected, result);
                    } else {
                        ut.compareStringSlice(name, case.expected, result);
                    }
                    //----------------------------------------
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                fail_count += 1;
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateV0.obfuscate";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
        }{
            .{ .data = "", .expected = "" },
            .{ .data = "hello", .expected = "6922/" },
            .{ .data = "6922/", .expected = "hello" },
            .{
                .data = "test BBB>>>www|||qqqzzz 123 \x00\x09\x0A ~~~",
                .expected = &[_]u8{ 42, 57, 43, 42, 126, 92, 92, 92, 96, 96, 96, 39, 39, 39, 34, 34, 34, 45, 45, 45, 36, 36, 36, 126, 109, 108, 107, 126, 31, 22, 21, 126, 32, 32, 32 },
            },
            .{
                .data = &[_]u8{ 42, 57, 43, 42, 126, 92, 92, 92, 96, 96, 96, 39, 39, 39, 34, 34, 34, 45, 45, 45, 36, 36, 36, 126, 109, 108, 107, 126, 31, 22, 21, 126, 32, 32, 32 },
                .expected = "test BBB>>>www|||qqqzzz 123 \x00\x09\x0A ~~~",
            },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |case| {
            //----------------------------------------
            if (obf.ObfuscateV0.obfuscate(&allocator, case.data, .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareByteSlice(name, case.expected, result);
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                fail_count += 1;
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateV0.slideByte";
        const test_cases = [_]struct {
            data: u8,
            expected: u8,
        }{
            .{ .data = 0, .expected = 31 },
            .{ .data = 31, .expected = 0 },
            .{ .data = 32, .expected = 126 },
            .{ .data = 126, .expected = 32 },
            .{ .data = 127, .expected = 127 },
            .{ .data = 128, .expected = 255 },
            .{ .data = 255, .expected = 128 },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |case| {
            //----------------------------------------
            const result = obf.ObfuscateV0.slideByte(case.data);
            //----------------------------------------
            if (result != case.expected) {
                fail_count += 1;
                ut.compareByte(name, case.expected, result);
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateV0.encode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            encoding: obf.ObfuscateV0.Encoding,
        }{
            .{ .data = "", .expected = "", .encoding = .default },
            .{ .data = "Aq\x16\x15\x12~|zwB>qF", .expected = "]---t-n-r-s-q-d-a-b-g--X", .encoding = .default },
            .{ .data = "ABC\u{1f427}", .expected = "B!OWun=%=", .encoding = .base },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |case| {
            //----------------------------------------
            if (obf.ObfuscateV0.encode(&allocator, case.data, .{ .encoding = case.encoding })) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    if (case.encoding == .default) {
                        ut.compareByteSlice(name, case.expected, result);
                    } else {
                        ut.compareStringSlice(name, case.expected, result);
                    }
                    //----------------------------------------
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                fail_count += 1;
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateV0.decode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            encoding: obf.ObfuscateV0.Encoding,
        }{
            .{ .data = "", .expected = "", .encoding = .default },
            .{ .data = "]---t-n-r-s-q-d-a-b-g--X", .expected = "Aq\x16\x15\x12~|zwB>qF", .encoding = .default },
            .{ .data = "B!OWun=%=", .expected = "ABC\u{1f427}", .encoding = .base },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |case| {
            //----------------------------------------
            if (obf.ObfuscateV0.decode(&allocator, case.data, .{ .encoding = case.encoding })) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    if (case.encoding == .default) {
                        ut.compareByteSlice(name, case.expected, result);
                    } else {
                        ut.compareStringSlice(name, case.expected, result);
                    }
                    //----------------------------------------
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                fail_count += 1;
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateV4.obfuscate";
        const expected_strings = [_][2][]const u8{
            .{ "", "" },
            .{ "hello", "6229/" },
            .{ "6229/", "hello" },
            .{ "test BBB>>>www|||qqq 123XXX", "*\x27+\x22~-\x5C-\x60m\x60k\x279\x22*\x22\x5C-\x5C~\x60l\x27FFF" },
            .{
                "*\x27+\x22~-\x5C-\x60m\x60k\x279\x22*\x22\x5C-\x5C~\x60l\x27FFF", "test BBB>>>www|||qqq 123XXX",
            },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (expected_strings) |expected| {
            //----------------------------------------
            if (obf.ObfuscateV4.obfuscate(&allocator, expected[0], .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, expected[1])) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareByteSlice(name, expected[1], result);
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                fail_count += 1;
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateV4.slideByte";
        const expected_bytes = [_][2]u8{
            .{ 0, 0 },
            .{ 31, 31 },
            .{ 32, 126 },
            .{ 126, 32 },
            .{ 127, 127 },
            .{ 128, 128 },
            .{ 255, 255 },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (expected_bytes) |expected| {
            //----------------------------------------
            const result = obf.ObfuscateV4.slideByte(expected[0]);
            //----------------------------------------
            if (result != expected[1]) {
                fail_count += 1;
                ut.compareByte(name, expected[1], result);
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateV4.encode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            encoding: obf.ObfuscateV4.Encoding,
        }{
            .{ .data = "", .expected = "", .encoding = .default },
            .{ .data = "\x00 ABC \n \r \x22 \x7C \x27 \x77 \x60 \x3E \u{65e5}\u{672c}\u{8a9e}\u{1f427}", .expected = "\x00\x7E\x5D\x7E\x5B\x7E\x5C\x6E\x97\x5C\x72\xE6\x7C\xAC\x5C\x71\xAA\x77\xF0\x5C\x61\x7E\x3E\x5C\x5C\x5C\x67\x7E\xE6\x7E\xA5\x7E\x9C\x7E\xE8\x7E\x9E\x7E\x9F\x90\xA7", .encoding = .default },
            .{ .data = "test BBB>>>www|||qqq 123", .expected = "1RTdoLS#jYBz<=j0WQD%/&^c,LXKyA", .encoding = .base },
            .{ .data = "test BBB>>>www|||qqq 123", .expected = "KicrIn4tXC1gbWBrJzkiKiJcLVx+YGwn", .encoding = .base64 },
            .{ .data = "test BBB>>>www|||qqq 123", .expected = "KicrIn4tXC1gbWBrJzkiKiJcLVx-YGwn", .encoding = .base64url },
            .{ .data = "test BBB>>>www|||qqq 123", .expected = "OU/w-d}u)}H;#-ql>NXG%w.-du)TWm!&B", .encoding = .base91 },
            .{ .data = "test BBB>>>www|||qqq 123", .expected = "2A272B227E2D5C2D606D606B2739222A225C2D5C7E606C27", .encoding = .hex },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |case| {
            //----------------------------------------
            if (obf.ObfuscateV4.encode(&allocator, case.data, .{ .encoding = case.encoding })) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    if (case.encoding == .default) {
                        ut.compareByteSlice(name, case.expected, result);
                    } else {
                        ut.compareStringSlice(name, case.expected, result);
                    }
                    //----------------------------------------
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                fail_count += 1;
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateV4.decode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            encoding: obf.ObfuscateV4.Encoding,
        }{
            .{ .data = "", .expected = "", .encoding = .default },
            .{ .data = "\x00\x7E\x5D\x7E\x5B\x7E\x5C\x6E\x97\x5C\x72\xE6\x7C\xAC\x5C\x71\xAA\x77\xF0\x5C\x61\x7E\x3E\x5C\x5C\x5C\x67\x7E\xE6\x7E\xA5\x7E\x9C\x7E\xE8\x7E\x9E\x7E\x9F\x90\xA7", .expected = "\x00 ABC \n \r \x22 \x7C \x27 \x77 \x60 \x3E \u{65e5}\u{672c}\u{8a9e}\u{1f427}", .encoding = .default },
            .{ .data = "1RTdoLS#jYBz<=j0WQD%/&^c,LXKyA", .expected = "test BBB>>>www|||qqq 123", .encoding = .base },
            .{ .data = "KicrIn4tXC1gbWBrJzkiKiJcLVx+YGwn", .expected = "test BBB>>>www|||qqq 123", .encoding = .base64 },
            .{ .data = "KicrIn4tXC1gbWBrJzkiKiJcLVx-YGwn", .expected = "test BBB>>>www|||qqq 123", .encoding = .base64url },
            .{ .data = "OU/w-d}u)}H;#-ql>NXG%w.-du)TWm!&B", .expected = "test BBB>>>www|||qqq 123", .encoding = .base91 },
            .{ .data = "2A272B227E2D5C2D606D606B2739222A225C2D5C7E606C27", .expected = "test BBB>>>www|||qqq 123", .encoding = .hex },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |case| {
            //----------------------------------------
            if (obf.ObfuscateV4.decode(&allocator, case.data, .{ .encoding = case.encoding })) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    if (case.encoding == .default) {
                        ut.compareByteSlice(name, case.expected, result);
                    } else {
                        ut.compareStringSlice(name, case.expected, result);
                    }
                    //----------------------------------------
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                fail_count += 1;
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateV5.obfuscate";
        const expected_strings = [_][2][]const u8{
            .{ "", "" },
            .{ "hello", "6922/" },
            .{ "6922/", "hello" },
            .{
                "test BBB>>>www|||qqqzzz 123 \x00\x09\x0A ~~~",
                &[_]u8{ 42, 57, 43, 42, 126, 92, 92, 92, 96, 96, 96, 39, 39, 39, 34, 34, 34, 45, 45, 45, 36, 36, 36, 126, 109, 108, 107, 126, 31, 22, 21, 126, 32, 32, 32 },
            },
            .{
                &[_]u8{ 42, 57, 43, 42, 126, 92, 92, 92, 96, 96, 96, 39, 39, 39, 34, 34, 34, 45, 45, 45, 36, 36, 36, 126, 109, 108, 107, 126, 31, 22, 21, 126, 32, 32, 32 },
                "test BBB>>>www|||qqqzzz 123 \x00\x09\x0A ~~~",
            },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (expected_strings) |expected| {
            //----------------------------------------
            if (obf.ObfuscateV5.obfuscate(&allocator, expected[0], .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, expected[1])) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareByteSlice(name, expected[1], result);
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                fail_count += 1;
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateV5.slideByte";
        const expected_bytes = [_][2]u8{
            .{ 0, 31 },
            .{ 31, 0 },
            .{ 32, 126 },
            .{ 126, 32 },
            .{ 127, 127 },
            .{ 128, 255 },
            .{ 255, 128 },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (expected_bytes) |expected| {
            //----------------------------------------
            const result = obf.ObfuscateV5.slideByte(expected[0]);
            //----------------------------------------
            if (result != expected[1]) {
                fail_count += 1;
                ut.compareByte(name, expected[1], result);
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateV5.encode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            encoding: obf.ObfuscateV5.Encoding,
        }{
            .{ .data = "", .expected = "", .encoding = .default },
            .{ .data = "Aq\x16\x15\x12~|zwB>qF", .expected = "]---t-n-r-s-q-d-a-b-g--X", .encoding = .default },
            .{ .data = "ABC\u{1f427}", .expected = "B!OWun=%=", .encoding = .base },
            .{ .data = "ABC\u{1f427}", .expected = "XVxbj+Dv2A==", .encoding = .base64 },
            .{ .data = "ABC\u{1f427}", .expected = "XVxbj-Dv2A", .encoding = .base64url },
            .{ .data = "ABC\u{1f427}", .expected = ".?x;](ZyN", .encoding = .base91 },
            .{ .data = "ABC\u{1f427}", .expected = "5D5C5B8FE0EFD8", .encoding = .hex },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |case| {
            //----------------------------------------
            if (obf.ObfuscateV5.encode(&allocator, case.data, .{ .encoding = case.encoding })) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    if (case.encoding == .default) {
                        ut.compareByteSlice(name, case.expected, result);
                    } else {
                        ut.compareStringSlice(name, case.expected, result);
                    }
                    //----------------------------------------
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                fail_count += 1;
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "ObfuscateV5.decode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            encoding: obf.ObfuscateV5.Encoding,
        }{
            .{ .data = "", .expected = "", .encoding = .default },
            .{ .data = "]---t-n-r-s-q-d-a-b-g--X", .expected = "Aq\x16\x15\x12~|zwB>qF", .encoding = .default },
            .{ .data = "B!OWun=%=", .expected = "ABC\u{1f427}", .encoding = .base },
            .{ .data = "XVxbj+Dv2A==", .expected = "ABC\u{1f427}", .encoding = .base64 },
            .{ .data = "XVxbj-Dv2A", .expected = "ABC\u{1f427}", .encoding = .base64url },
            .{ .data = ".?x;](ZyN", .expected = "ABC\u{1f427}", .encoding = .base91 },
            .{ .data = "5D5C5B8FE0EFD8", .expected = "ABC\u{1f427}", .encoding = .hex },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |case| {
            //----------------------------------------
            if (obf.ObfuscateV5.decode(&allocator, case.data, .{ .encoding = case.encoding })) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    if (case.encoding == .default) {
                        ut.compareByteSlice(name, case.expected, result);
                    } else {
                        ut.compareStringSlice(name, case.expected, result);
                    }
                    //----------------------------------------
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                fail_count += 1;
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        if (fail_count == 0) ut.pass(name, "");
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    ut.printSummary();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
