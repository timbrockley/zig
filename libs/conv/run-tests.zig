//--------------------------------------------------------------------------------
const std = @import("std");
const ut = @import("libs/unittest.zig");
const conv = @import("conv.zig");
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
        const name = "Base.encode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            expected_error: ?conv.Base.Error,
        }{
            .{ .data = "", .expected = "", .expected_error = null },
            .{ .data = "A", .expected = "8q", .expected_error = null },
            .{ .data = "AA", .expected = "8x]", .expected_error = null },
            .{ .data = "AAA", .expected = "8x_i", .expected_error = null },
            .{ .data = "AAAA", .expected = "8x_j)", .expected_error = null },
            .{ .data = "ABC\u{1f427}", .expected = "8xix1W</w", .expected_error = null },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            if (conv.Base.encode(&allocator, test_case.data, .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, test_case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareStringSlice(name, test_case.expected, result);
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
        const name = "Base.decode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            expected_error: ?conv.Base.Error,
        }{
            .{ .data = "\x00", .expected = "", .expected_error = error.InvalidInput },
            .{ .data = "", .expected = "", .expected_error = null },
            .{ .data = "8q", .expected = "A", .expected_error = null },
            .{ .data = "8x]", .expected = "AA", .expected_error = null },
            .{ .data = "8x_i", .expected = "AAA", .expected_error = null },
            .{ .data = "8x_j)", .expected = "AAAA", .expected_error = null },
            .{ .data = "8xix1W</w", .expected = "ABC\u{1f427}", .expected_error = null },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            if (conv.Base.decode(&allocator, test_case.data, .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, test_case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareStringSlice(name, test_case.expected, result);
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                if (test_case.expected_error != null and err == test_case.expected_error.?) {
                    ut.errorPass(name, err);
                } else {
                    fail_count += 1;
                    ut.errorFail(name, err);
                }
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
        const name = "Base64.encode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            expected_error: ?conv.Base64.Error,
        }{
            .{ .data = "", .expected = "", .expected_error = null },
            .{ .data = "A", .expected = "QQ==", .expected_error = null },
            .{ .data = "AA", .expected = "QUE=", .expected_error = null },
            .{ .data = "AAA", .expected = "QUFB", .expected_error = null },
            .{ .data = "AAAA", .expected = "QUFBQQ==", .expected_error = null },
            .{ .data = "ABC\u{1f427}", .expected = "QUJD8J+Qpw==", .expected_error = null },
            .{ .data = "\u{1f427}\u{1f427}", .expected = "8J+Qp/CfkKc=", .expected_error = null },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            if (conv.Base64.encode(&allocator, test_case.data, .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, test_case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareStringSlice(name, test_case.expected, result);
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
        const name = "Base64.decode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            expected_error: ?conv.Base64.Error,
        }{
            .{ .data = "\x00", .expected = "", .expected_error = error.InvalidInput },
            .{ .data = "", .expected = "", .expected_error = null },
            .{ .data = "QQ==", .expected = "A", .expected_error = null },
            .{ .data = "QUE=", .expected = "AA", .expected_error = null },
            .{ .data = "QUFB", .expected = "AAA", .expected_error = null },
            .{ .data = "QUFBQQ==", .expected = "AAAA", .expected_error = null },
            .{ .data = "QUJD8J+Qpw==", .expected = "ABC\u{1f427}", .expected_error = null },
            .{ .data = "8J+Qp/CfkKc=", .expected = "\u{1f427}\u{1f427}", .expected_error = null },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            if (conv.Base64.decode(&allocator, test_case.data, .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, test_case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareStringSlice(name, test_case.expected, result);
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                if (test_case.expected_error != null and err == test_case.expected_error.?) {
                    ut.errorPass(name, err);
                } else {
                    fail_count += 1;
                    ut.errorFail(name, err);
                }
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
        const name = "Base64.urlEncode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            expected_error: ?conv.Base64.Error,
        }{
            .{ .data = "", .expected = "", .expected_error = null },
            .{ .data = "A", .expected = "QQ", .expected_error = null },
            .{ .data = "AA", .expected = "QUE", .expected_error = null },
            .{ .data = "AAA", .expected = "QUFB", .expected_error = null },
            .{ .data = "AAAA", .expected = "QUFBQQ", .expected_error = null },
            .{ .data = "ABC\u{1f427}", .expected = "QUJD8J-Qpw", .expected_error = null },
            .{ .data = "\u{1f427}\u{1f427}", .expected = "8J-Qp_CfkKc", .expected_error = null },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            if (conv.Base64.urlEncode(&allocator, test_case.data, .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, test_case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareStringSlice(name, test_case.expected, result);
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
        const name = "Base64.urlDecode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            expected_error: ?conv.Base64.Error,
        }{
            .{ .data = "\x00", .expected = "", .expected_error = error.InvalidInput },
            .{ .data = "", .expected = "", .expected_error = null },
            .{ .data = "QQ", .expected = "A", .expected_error = null },
            .{ .data = "QUE", .expected = "AA", .expected_error = null },
            .{ .data = "QUFB", .expected = "AAA", .expected_error = null },
            .{ .data = "QUFBQQ", .expected = "AAAA", .expected_error = null },
            .{ .data = "QUJD8J-Qpw", .expected = "ABC\u{1f427}", .expected_error = null },
            .{ .data = "8J-Qp_CfkKc", .expected = "\u{1f427}\u{1f427}", .expected_error = null },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            if (conv.Base64.urlDecode(&allocator, test_case.data, .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, test_case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareStringSlice(name, test_case.expected, result);
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                if (test_case.expected_error != null and err == test_case.expected_error.?) {
                    ut.errorPass(name, err);
                } else {
                    fail_count += 1;
                    ut.errorFail(name, err);
                }
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
        const name = "base64Value";
        const data = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        //----------------------------------------
        var expected: [data.len]u8 = undefined;
        for (0..expected.len) |index| expected[index] = @intCast(index);
        //----------------------------------------
        var result: [data.len]u8 = undefined;
        //----------------------------------------
        for (data, 0..) |char, index| {
            //----------------------------------------
            if (conv.Base64.base64Value(char)) |value| {
                //----------------------------------------
                result[index] = value;
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                ut.errorFail(name, err);
                //----------------------------------------
            }
            //----------------------------------------
        }
        //----------------------------------------
        ut.compareByteSlice(name, expected[0..], result[0..]);
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        const name = "plaintextToBase64Length";
        const strings = [_][]const u8{ "A", "Hello", "World", "Zig", "Language" };
        const expected_total: usize = 4 + 8 + 8 + 4 + 12;

        var total: usize = 0;
        for (strings) |data| {
            total += conv.Base64.plaintextToBase64Length(data);
        }

        ut.compareInt(name, expected_total, total);
    }
    //----------------------------------------------------------------------------
    {
        const name = "plaintextToBase64UrlLength";
        const strings = [_][]const u8{ "A", "Hello", "World", "Zig", "Language" };
        const expected_total: usize = 2 + 7 + 7 + 4 + 11;

        var total: usize = 0;
        for (strings) |data| {
            total += conv.Base64.plaintextToBase64UrlLength(data);
        }

        ut.compareInt(name, expected_total, total);
    }
    //----------------------------------------------------------------------------
    {
        const name = "base64ToPlaintextLength";
        const data = "A"; // invalid input

        if (conv.Base64.base64ToPlaintextLength(data)) |_| {
            ut.fail(name, "test failed as it did not return an error");
        } else |err| {
            ut.errorPass(name, err); // should return an error
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "base64ToPlaintextLength";
        const strings = [_][]const u8{ "QQ==", "SGVsbG8=", "V29ybGQ=", "Wmln", "TGFuZ3VhZ2U=" };
        const expected_total: usize = 1 + 5 + 5 + 3 + 8;

        var total: usize = 0;
        for (strings) |data| {
            if (conv.Base64.base64ToPlaintextLength(data)) |length| {
                total += length;
            } else |err| {
                ut.errorFail(name, err);
            }
        }

        ut.compareInt(name, expected_total, total);
    }
    //----------------------------------------------------------------------------
    {
        const name = "base64UrlToPlaintextLength";
        const strings = [_][]const u8{ "QQ", "SGVsbG8", "V29ybGQ", "Wmln", "TGFuZ3VhZ2U" };
        const expected_total: usize = 1 + 5 + 5 + 3 + 8;

        var total: usize = 0;
        for (strings) |data| {
            total += conv.Base64.base64UrlToPlaintextLength(data);
        }

        ut.compareInt(name, expected_total, total);
    }
    //----------------------------------------------------------------------------
    {
        const name = "base64ToBase64UrlLength";
        const strings = [_][]const u8{ "QQ==", "SGVsbG8=", "V29ybGQ=", "Wmln", "TGFuZ3VhZ2U=" };
        const expected_total: usize = 2 + 7 + 7 + 4 + 11;

        var total: usize = 0;
        for (strings) |data| {
            total += conv.Base64.base64ToBase64UrlLength(data);
        }

        ut.compareInt(name, expected_total, total);
    }
    //----------------------------------------------------------------------------
    {
        const name = "base64UrlToBase64Length";
        const strings = [_][]const u8{ "QQ", "SGVsbG8", "V29ybGQ", "Wmln", "TGFuZ3VhZ2U" };
        const expected_total: usize = 4 + 8 + 8 + 4 + 12;

        var total: usize = 0;
        for (strings) |data| {
            total += conv.Base64.base64UrlToBase64Length(data);
        }

        ut.compareInt(name, expected_total, total);
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "Base85.encode";
        const test_cases = [_]struct {
            data: []const u8,
            options: conv.Base85.DefaultsEncode,
            expected: []const u8,
            expected_error: ?conv.Base85.Error,
        }{
            .{ .data = "", .options = .{}, .expected = "", .expected_error = null },
            .{ .data = "A", .options = .{}, .expected = "5l", .expected_error = null },
            .{ .data = "AA", .options = .{}, .expected = "5sY", .expected_error = null },
            .{ .data = "AAA", .options = .{}, .expected = "5s[d", .expected_error = null },
            .{ .data = "AAAA", .options = .{}, .expected = "5s[e&", .expected_error = null },
            .{ .data = "\xFF\xFF\xFF\xFF", .options = .{}, .expected = "s8W-!", .expected_error = null },
            .{ .data = "ABC\u{1f427}", .options = .{}, .expected = "5sds.T9,r", .expected_error = null },
            .{ .data = "\x00", .options = .{ .escape = true, .replace_zero = true, .trim = true, .wrap = true }, .expected = "<~!!~>", .expected_error = null },
            .{ .data = "\x00\x00\x00\x00!#%&()*+,./:;<=>?@[]^_{|}0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", .options = .{ .escape = true, .replace_zero = true, .trim = true, .wrap = true }, .expected = "<~z+X89[-n-Vr/1rS:4x5Yi5<rFY?=/&,I5!B21GgsI2~Nf~6:4.07Rp!@8kViP:/=|~;HxOp<~~C+>%(lMA7]@cBPD3sCi+}.E,fo>FEMbNG^4T~>", .expected_error = null },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            if (conv.Base85.encode(&allocator, test_case.data, test_case.options)) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, test_case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareStringSlice(name, test_case.expected, result);
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
        const name = "Base85.decode";
        const test_cases = [_]struct {
            data: []const u8,
            options: conv.Base85.DefaultsDecode,
            expected: []const u8,
            expected_error: ?conv.Base85.Error,
        }{
            .{ .data = "\x00", .options = .{ .escape = true }, .expected = "", .expected_error = error.InvalidInput },
            .{ .data = "", .options = .{ .escape = true }, .expected = "", .expected_error = null },
            .{ .data = "5l", .options = .{ .escape = true }, .expected = "A", .expected_error = null },
            .{ .data = "5sY", .options = .{ .escape = true }, .expected = "AA", .expected_error = null },
            .{ .data = "5s[d", .options = .{ .escape = true }, .expected = "AAA", .expected_error = null },
            .{ .data = "5s[e&", .options = .{ .escape = true }, .expected = "AAAA", .expected_error = null },
            .{ .data = "s8W-!", .options = .{ .escape = true }, .expected = "\xFF\xFF\xFF\xFF", .expected_error = null },
            .{ .data = "5sds.T9,r", .options = .{ .escape = true }, .expected = "ABC\u{1f427}", .expected_error = null },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            if (conv.Base85.decode(&allocator, test_case.data, test_case.options)) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, test_case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareStringSlice(name, test_case.expected, result);
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                if (test_case.expected_error != null and err == test_case.expected_error.?) {
                    ut.errorPass(name, err);
                } else {
                    fail_count += 1;
                    ut.errorFail(name, err);
                }
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
        const name = "Base91.encode";
        const test_cases = [_]struct {
            data: []const u8,
            options: conv.Base91.Defaults,
            expected: []const u8,
            expected_error: ?conv.Base91.Error,
        }{
            .{ .data = "", .options = .{}, .expected = "", .expected_error = null },
            .{ .data = "f", .options = .{}, .expected = "LB", .expected_error = null },
            .{ .data = "foobar", .options = .{}, .expected = "dr/2s)uC", .expected_error = null },
            .{ .data = "ABC\u{1f427}", .options = .{}, .expected = "fG^FqWzqK", .expected_error = null },
            .{ .data = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#\x24%&()*+,./:;<=>?@[]^_\x60{|}~\x22", .options = .{ .escape = false }, .expected = "fG^F%w_o%5qOdwQbFrzd[5eYAP;gMP+f#G(Ic,5ph#77&xrmlrjgs@DZ7UB>xQGrgw_,\x24k_i\x24Js@Tj\x24MaRDa7dq)L1<[3vwV[|O/7%q{{9G\x60C/LM", .expected_error = null },
            .{ .data = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#\x24%&()*+,./:;<=>?@[]^_\x60{|}~\x22", .options = .{ .escape = true }, .expected = "fG^F%w_o%5qOdwQbFrzd[5eYAP;gMP+f#G(Ic,5ph#77&xrmlrjgs@DZ7UB>xQGrgw_,-dk_i-dJs@Tj-dMaRDa7dq)L1<[3vwV[|O/7%q{{9G-gC/LM", .expected_error = null },
            .{ .data = "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2A\x2B\x2C\x2D\x2E\x2F\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3A\x3B\x3C\x3D\x3E\x3F\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4A\x4B\x4C\x4D\x4E\x4F\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5A\x5B\x5C\x5D\x5E\x5F\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6A\x6B\x6C\x6D\x6E\x6F\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7A\x7B\x7C\x7D\x7E\x7F\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF", .options = .{ .escape = true }, .expected = ":C#(:C?hVB-dMSiVEwndBAMZRxwFfBB;IW<}YQV!A_v-dY_c%zr4cYQPFl0,@heMAJ<:N[*T+/SFGr*-gb4PD}vgYqU>cW0P*1NwV,O{cQ5u0m900[8@n4,wh?DP<2+~jQSW6nmLm1o.J,?jTs%2<WF%qb=oh|}.C+W-gEI!bv-qXJ5KIV<G+aX]c[z-d8)@aR67gb7p(-gr4kHjOraEr8:A8y0G9KsDm7jpa{fh>hT8%;@!9;s>JX?#GT<W+vbf-gA2a^wkFZCr<:V-d}SR##&<^lr<Jn?_K5qh.JyLp+99&B_6vZ&x[uhn}L@sh3}g__~#", .expected_error = null },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            if (conv.Base91.encode(&allocator, test_case.data, test_case.options)) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, test_case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareStringSlice(name, test_case.expected, result);
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
        const name = "Hex.encode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            expected_error: ?conv.Hex.Error,
        }{
            .{ .data = "", .expected = "", .expected_error = null },
            .{ .data = "A", .expected = "41", .expected_error = null },
            .{ .data = "AA", .expected = "4141", .expected_error = null },
            .{ .data = "AAA", .expected = "414141", .expected_error = null },
            .{ .data = "AAAA", .expected = "41414141", .expected_error = null },
            .{ .data = "ABC\u{1f427}", .expected = "414243F09F90A7", .expected_error = null },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            if (conv.Hex.encode(&allocator, test_case.data, .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, test_case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareStringSlice(name, test_case.expected, result);
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                if (test_case.expected_error != null and err == test_case.expected_error.?) {
                    ut.errorPass(name, err);
                } else {
                    fail_count += 1;
                    ut.errorFail(name, err);
                }
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
        const name = "Hex.decode";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
            expected_error: ?conv.Hex.Error,
        }{
            .{ .data = "\x00", .expected = "", .expected_error = error.InvalidInputLength },
            .{ .data = "\x00\x00", .expected = "", .expected_error = error.InvalidInput },
            .{ .data = "", .expected = "", .expected_error = null },
            .{ .data = "41", .expected = "A", .expected_error = null },
            .{ .data = "4141", .expected = "AA", .expected_error = null },
            .{ .data = "414141", .expected = "AAA", .expected_error = null },
            .{ .data = "41414141", .expected = "AAAA", .expected_error = null },
            .{ .data = "414243F09F90A7", .expected = "ABC\u{1f427}", .expected_error = null },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            if (conv.Hex.decode(&allocator, test_case.data, .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, test_case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareStringSlice(name, test_case.expected, result);
                    allocator.free(result);
                    //----------------------------------------
                }
                //----------------------------------------
            } else |err| {
                //----------------------------------------
                if (test_case.expected_error != null and err == test_case.expected_error.?) {
                    ut.errorPass(name, err);
                } else {
                    fail_count += 1;
                    ut.errorFail(name, err);
                }
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
        const name = "obfuscate_data";
        const test_cases = [_]struct {
            data: []const u8,
            expected: []const u8,
        }{
            .{ .data = "", .expected = "" },
            .{ .data = "hello", .expected = "6922/" },
            .{ .data = "6922/", .expected = "hello" },
            .{ .data = "6922/", .expected = "hello" },
            .{ .data = "hello", .expected = "6922/" },
            .{ .data = &[_]u8{ 0x00, 0x1F, 0x20, 0x7E, 0x7F, 0x80, 0xFF }, .expected = &[_]u8{ 0x1F, 0x00, 0x7E, 0x20, 0x7F, 0xFF, 0x80 } },
            .{ .data = &[_]u8{ 0x1F, 0x00, 0x7E, 0x20, 0x7F, 0xFF, 0x80 }, .expected = &[_]u8{ 0x00, 0x1F, 0x20, 0x7E, 0x7F, 0x80, 0xFF } },
        };
        //----------------------------------------
        var fail_count: usize = 0;
        //----------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            if (conv.obfuscate_data(&allocator, test_case.data, .{})) |result| {
                //----------------------------------------
                if (!std.mem.eql(u8, result, test_case.expected)) {
                    //----------------------------------------
                    fail_count += 1;
                    //----------------------------------------
                    ut.compareByteSlice(name, test_case.expected, result);
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
