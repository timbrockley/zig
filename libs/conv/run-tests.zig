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
        const name1 = "Base.encode";
        const name2 = "Base.decode";
        const data = "";
        const expected = "";
        //----------------------------------------
        if (conv.Base.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base.encode";
        const name2 = "Base.decode";
        const data = "A";
        const expected = "8q";
        //----------------------------------------
        if (conv.Base.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base.encode";
        const name2 = "Base.decode";
        const data = "AA";
        const expected = "8x]";
        //----------------------------------------
        if (conv.Base.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base.encode";
        const name2 = "Base.decode";
        const data = "AAA";
        const expected = "8x_i";
        //----------------------------------------
        if (conv.Base.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base.encode";
        const name2 = "Base.decode";
        const data = "AAAA";
        const expected = "8x_j)";
        //----------------------------------------
        if (conv.Base.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base.encode";
        const name2 = "Base.decode";
        const data = "ABC\u{1f427}";
        const expected = "8xix1W</w";
        //----------------------------------------
        if (conv.Base.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base64.encode";
        const name2 = "Base64.decode";
        const data = "";
        const expected = "";
        //----------------------------------------
        if (conv.Base64.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base64.decode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base64.encode";
        const name2 = "Base64.decode";
        const data = "hello world";
        const expected = "aGVsbG8gd29ybGQ=";
        //----------------------------------------
        if (conv.Base64.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base64.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base64.encode";
        const name2 = "Base64.decode";
        const data = "\x00\x1F\x20\x7E\x7F\x80\xFF";
        const expected = "AB8gfn+A/w==";
        //----------------------------------------
        if (conv.Base64.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base64.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base64.urlEncode";
        const name2 = "Base64.urlDecode";
        const data = "\x00\x1F\x20\x7E\x7F\x80\xFF";
        const expected = "AB8gfn-A_w";
        //----------------------------------------
        if (conv.Base64.urlEncode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base64.urlDecode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareByteSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
    }
    // //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name = "base64Value";
        const byte = '#';
        //----------------------------------------
        if (conv.Base64.base64Value(byte)) |_| {
            //----------------------------------------
            ut.fail(name, "test failed as it did not return an error");
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorPass(name, err); // should return an error
            //----------------------------------------
        }
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
        const name1 = "Base85.encode";
        const name2 = "Base85.decode";
        const data = "";
        const expected = "";
        //----------------------------------------
        if (conv.Base85.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base85.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base85.encode";
        const name2 = "Base85.decode";
        const data = "A";
        const expected = "5l";
        //----------------------------------------
        if (conv.Base85.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base85.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base85.encode";
        const name2 = "Base85.decode";
        const data = "AA";
        const expected = "5sY";
        //----------------------------------------
        if (conv.Base85.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base85.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base85.encode";
        const name2 = "Base85.decode";
        const data = "AAA";
        const expected = "5s[d";
        //----------------------------------------
        if (conv.Base85.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base85.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base85.encode";
        const name2 = "Base85.decode";
        const data = "AAAA";
        const expected = "5s[e&";
        //----------------------------------------
        if (conv.Base85.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base85.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base85.encode";
        const name2 = "Base85.decode";
        const data = "ABC\u{1f427}";
        const expected = "5sds.T9,r";
        //----------------------------------------
        if (conv.Base85.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base85.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base85.encode";
        const name2 = "Base85.decode";
        const data = "\x00\x00\x00\x00!#%&()*+,./:;<=>?@[]^_{|}0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        const expected = "<~z+X89[-n-Vr/1rS:4x5Yi5<rFY?=/&,I5!B21GgsI2~Nf~6:4.07Rp!@8kViP:/=|~;HxOp<~~C+>%(lMA7]@cBPD3sCi+}.E,fo>FEMbNG^4T~>";
        const encoded_data = "\n\t <~z+X89[-n-Vr/1rS:4x5Yi5<rFY?=/&,I5!B21GgsI2~Nf~6:4.07Rp!@8kViP:/=|~;HxOp<~~C+>%(lMA7]@cBPD3sCi+}.E,fo>FEMbNG^4T~> \t\n";
        //----------------------------------------
        if (conv.Base85.encode(&allocator, data, .{ .escape = true, .replace_zero = true, .trim = true, .wrap = true })) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base85.decode(&allocator, encoded_data, .{ .escape = true, .replace_zero = true, .trim = true, .wrap = true })) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base85.encode";
        const name2 = "Base85.decode";
        const data = "\x00";
        const expected = "<~!!~>";
        const encoded_data = "\n\t <~!!~> \t\n";
        //----------------------------------------
        if (conv.Base85.encode(&allocator, data, .{ .escape = true, .replace_zero = true, .trim = true, .wrap = true })) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base85.decode(&allocator, encoded_data, .{ .escape = true, .replace_zero = true, .trim = true, .wrap = true })) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base85.encode";
        const name2 = "Base85.decode";
        const data = "\xFF\xFF\xFF\xFF";
        const expected = "s8W-!";
        //----------------------------------------
        if (conv.Base85.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base85.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base91.encode";
        const name2 = "Base91.decode";
        const data = "test\u{1f427}ABC";
        const expected = "fPNKI?uDr:PD|C";
        //----------------------------------------
        if (conv.Base91.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base91.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base91.encode";
        const name2 = "Base91.decode";
        const data = "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2A\x2B\x2C\x2D\x2E\x2F\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3A\x3B\x3C\x3D\x3E\x3F\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4A\x4B\x4C\x4D\x4E\x4F\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5A\x5B\x5C\x5D\x5E\x5F\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6A\x6B\x6C\x6D\x6E\x6F\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7A\x7B\x7C\x7D\x7E\x7F\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF";
        const expected = ":C#(:C?hVB-dMSiVEwndBAMZRxwFfBB;IW<}YQV!A_v-dY_c%zr4cYQPFl0,@heMAJ<:N[*T+/SFGr*-gb4PD}vgYqU>cW0P*1NwV,O{cQ5u0m900[8@n4,wh?DP<2+~jQSW6nmLm1o.J,?jTs%2<WF%qb=oh|}.C+W-gEI!bv-qXJ5KIV<G+aX]c[z-d8)@aR67gb7p(-gr4kHjOraEr8:A8y0G9KsDm7jpa{fh>hT8%;@!9;s>JX?#GT<W+vbf-gA2a^wkFZCr<:V-d}SR##&<^lr<Jn?_K5qh.JyLp+99&B_6vZ&x[uhn}L@sh3}g__~#";
        //----------------------------------------
        if (conv.Base91.encode(&allocator, data, .{ .escape = true })) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base91.decode(&allocator, expected, .{ .escape = true })) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base91.encode";
        const name2 = "Base91.decode";
        const data = "\x9B\xC6\xF7\x92\x95\x51\xCF\xAA\x75\x86\x37\x66\x29\xC5\x12\x57\x2D\xDB\x7B\xAF\xF6\x4B\xB9\x58\x56\xE8\x81\xAE\x39\xF1\xAB\x3E\x4F\x98\x30\xE5\x40\x42\x0E\x74\x97\xDF\x43\xFA\x3B\x24\x05\xC1\x91\xB4\x04\x60\x20\xF5\x0F\x9E\x68\x6A\x46\x07\x4C\x70\xC8\xF0\x2E\x36\xC9\x6C\xE1\xF9\x93\xF3\xCD\xBE\x1A\xD8\xD7\x5C\xB0\x83\x73\x27\xD9\xE9\x6E\x1C\x03\x72\xB2\xA2\xB3\x5F\x63\x50\x6F\x52\xBC\x33\xB6\xE2\x15\xBD\x3A\xEE\x38\x19\xFB\x8F\xFF\xED\x6B\x87\xFE\x48\x84\x78\xAC\x02\x67\x0A\x85\x77\x90\x3F\x0B\x88\x69\x8B\xA9\x00\x13\x0D\xBF\xC4\x64\xA5\x10\x5D\xE3\xBB\xA1\x4A\xFC\xF4\xDC\xCA\x35\xC0\x9C\x3C\xA8\x22\xD6\xDD\xDE\x1D\xD5\x09\xE4\x7D\x26\x23\x25\x8C\xA6\xBA\x2A\x45\x44\xF8\x89\xEF\x1E\x34\x31\x8D\xB1\xB7\x53\x9F\xE0\x54\x9D\x08\x4D\x71\xA3\x06\x2B\x2F\x99\xD4\x2C\x6D\x5E\xA0\x16\x82\xAD\x7A\x62\x7F\xDA\x28\x47\x94\xE6\x49\x18\xB8\xC3\x3D\x9A\x80\x65\x61\x11\xEB\xD3\xF2\xA7\xA4\xC2\x1B\x14\xCC\x32\x8E\x7E\x8A\x5A\x7C\x1F\xB5\xD1\xCE\x17\x0C\x55\xEA\xD0\x59\xEC\x41\x4E\xD2\x01\xC7\x76\x96\x79\xE7\xFD\xCB\x21\x5B";
        const expected = "1S.&PPR{D;HJ|*yO/0OeL$K|i}1@l,#[/o0b]e+`+ac0gZBF~%P|~`:X^t}Y{0*hn7lu0/IkZB`(/IuQ^ZGg%`LUTk4lY}6giK9=#!]^Ayf+feP#sJ1:}5BVDg,e:e+^{+1~$~K(/X7M:F78%TmXF_z|}Bm6iRX\x22jSl1nj;u#;Kq:7gs&oQ%1(s@.7086^Xy;Na&wNpOe5WpGdAMCOE>dSKlL^?6tD`7KM6Or5Bf7at7L:2Q;f~9Mra}STEyBl\x22M]>>$V2rPGfb;]Pwd%DVu*,`nM49#L|=<<UFu]d1v[Hhu}MetE=>Rk[&hs+W";
        //----------------------------------------
        if (conv.Base91.encode(&allocator, data, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base91.decode(&allocator, expected, .{})) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //----------------------------------------
        const name1 = "Base91.encode";
        const name2 = "Base91.decode";
        const data = "May your trails be crooked, winding, lonesome, dangerous, leading to the most amazing view. May your mountains rise into and above the clouds.";
        const expected = "8D9KR-g0eLUd/ZQFl62>vb,1RL%%&~8bju-qsQ;mmaU=UfU)1T70<^rm?i;Ct)/p;R(&^m5PKimf2+H[QSd/[E<oTPgZh>DZ%y;#,aIl]U>vP:3pPIqSwPmLwre3:W.{6U)/wP;mYBxgP[UCsS)/[EOiqMgZR*Sk<Rd/=8jL=ibg7+b[C";
        //----------------------------------------
        if (conv.Base91.encode(&allocator, data, .{ .escape = true })) |result| {
            //----------------------------------------
            ut.compareStringSlice(name1, expected, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name1, err);
            //----------------------------------------
        }
        //----------------------------------------
        if (conv.Base91.decode(&allocator, expected, .{ .escape = true })) |result| {
            //----------------------------------------
            ut.compareStringSlice(name2, data, result);
            defer allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name2, err);
            //----------------------------------------
        }
        //----------------------------------------
    }
    //----------------------------------------------------------------------------
    ut.printSummary();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
