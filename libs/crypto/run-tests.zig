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
        const name = "obfuscateV0";
        const data = "Hello";
        const expected = "V922/";

        if (obf.obfuscateV0(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareByteSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV0Encode";
        const data = "Aq\x16\x15\x12~|zwB>qF";
        const expected = "]---t-n-r-s-q-d-a-b-g--X";

        if (obf.obfuscateV0Encode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareByteSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV0Decode";
        const data = "]---t-n-r-s-q-d-a-b-g-X";
        const expected = "Aq\x16\x15\x12~|zwB>qF";

        if (obf.obfuscateV0Decode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareByteSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV0BaseEncode";
        const data = "A>|\u{1f427}";
        const expected = "B!sp>n=%=";

        if (obf.obfuscateV0BaseEncode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV0BaseDecode";
        const data = "B!sp>n=%=";
        const expected = "A>|\u{1f427}";

        if (obf.obfuscateV0BaseDecode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV0Base64Encode";
        const data = "A>|\u{1f427}";
        const expected = "XWAij+Dv2A==";

        if (obf.obfuscateV0Base64Encode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV0Base64Decode";
        const data = "XWAij+Dv2A==";
        const expected = "A>|\u{1f427}";

        if (obf.obfuscateV0Base64Decode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV0Base64UrlEncode";
        const data = "A>|\u{1f427}";
        const expected = "XWAij-Dv2A";

        if (obf.obfuscateV0Base64UrlEncode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV0Base64UrlDecode";
        const data = "XWAij-Dv2A";
        const expected = "A>|\u{1f427}";

        if (obf.obfuscateV0Base64UrlDecode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV0Base91Encode";
        const data = "A>|\u{1f427}";
        const expected = "CBx+](ZyN";

        if (obf.obfuscateV0Base91Encode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV0Base91Decode";
        const data = "CBx+](ZyN";
        const expected = "A>|\u{1f427}";

        if (obf.obfuscateV0Base91Decode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV4";
        const data = "ABC";
        const expected = "]\x5C[";

        if (obf.obfuscateV4(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareByteSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV4";
        const data = "test BBB>>>www|||qqq 123XXX";
        const expected = "*\x27+\x22~-\x5C-\x60m\x60k\x279\x22*\x22\x5C-\x5C~\x60l\x27FFF";

        if (obf.obfuscateV4(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareByteSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "slideByteV4";

        const data = "\x00\x1F\x20\x7E\x7F\x80\xFF";
        const expected = "\x00\x1F\x7E\x20\x7F\x80\xFF";

        var result: [data.len]u8 = undefined;
        for (data, 0..) |byte, index| result[index] = obf.slideByteV4(byte);

        ut.compareByteSlice(name, expected, result[0..]);
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV4Encode";
        const data = "\x00 ABC \n \r \x22 \x7C \x27 \x77 \x60 \x3E \u{65e5}\u{672c}\u{8a9e}\u{1f427}";
        const expected = "\x00\x7E\x5D\x7E\x5B\x7E\x5C\x6E\x97\x5C\x72\xE6\x7C\xAC\x5C\x71\xAA\x77\xF0\x5C\x61\x7E\x3E\x5C\x5C\x5C\x67\x7E\xE6\x7E\xA5\x7E\x9C\x7E\xE8\x7E\x9E\x7E\x9F\x90\xA7";

        if (obf.obfuscateV4Encode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareByteSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV4Decode";
        const data = "\x00\x7E\x5D\x7E\x5B\x7E\x5C\x6E\x97\x5C\x72\xE6\x7C\xAC\x5C\x71\xAA\x77\xF0\x5C\x61\x7E\x3E\x5C\x5C\x5C\x67\x7E\xE6\x7E\xA5\x7E\x9C\x7E\xE8\x7E\x9E\x7E\x9F\x90\xA7";
        const expected = "\x00 ABC \n \r \x22 \x7C \x27 \x77 \x60 \x3E \u{65e5}\u{672c}\u{8a9e}\u{1f427}";

        if (obf.obfuscateV4Decode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareByteSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV4BaseEncode";
        const data = "test BBB>>>www|||qqq 123";
        const expected = "1RTdoLS#jYBz<=j0WQD%/&^c,LXKyA";

        if (obf.obfuscateV4BaseEncode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV4BaseDecode";
        const data = "1RTdoLS#jYBz<=j0WQD%/&^c,LXKyA";
        const expected = "test BBB>>>www|||qqq 123";

        if (obf.obfuscateV4BaseDecode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV4Base64Encode";
        const data = "test BBB>>>www|||qqq 123";
        const expected = "KicrIn4tXC1gbWBrJzkiKiJcLVx+YGwn";

        if (obf.obfuscateV4Base64Encode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV4Base64Decode";
        const data = "KicrIn4tXC1gbWBrJzkiKiJcLVx+YGwn";
        const expected = "test BBB>>>www|||qqq 123";

        if (obf.obfuscateV4Base64Decode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV4Base64UrlEncode";
        const data = "test BBB>>>www|||qqq 123";
        const expected = "KicrIn4tXC1gbWBrJzkiKiJcLVx-YGwn";

        if (obf.obfuscateV4Base64UrlEncode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV4Base64UrlDecode";
        const data = "KicrIn4tXC1gbWBrJzkiKiJcLVx-YGwn";
        const expected = "test BBB>>>www|||qqq 123";

        if (obf.obfuscateV4Base64UrlDecode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV4Base91Encode";
        const data = "\x00 ABC \n \r \x22 \x7C \x27 \x77 \x60 \x3E \u{65e5}\u{672c}\u{8a9e}\u{1f427}";
        const expected = "k_U1f-dD7z,v1tyRM0&7}%}@)-gQN2<9wsK{o%oVQ|n+^";

        if (obf.obfuscateV4Base91Encode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV4Base91Decode";
        const data = "k_U1f-dD7z,v1tyRM0&7}%}@)-gQN2<9wsK{o%oVQ|n+^";
        const expected = "\x00 ABC \n \r \x22 \x7C \x27 \x77 \x60 \x3E \u{65e5}\u{672c}\u{8a9e}\u{1f427}";

        if (obf.obfuscateV4Base91Decode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5";
        const data = "\x00\x20\x80";
        const expected = "\x1F\x7E\xFF";

        if (obf.obfuscateV5(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareByteSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5";
        const data = "test BBB>>>www|||qqqzzz 123 \x00\x09\x0A ~~~";
        const expected = "\x2A\x2D\x2B\x2D\x7E\x24\x5C\x7E\x60\x6C\x60\x7E\x27\x16\x22\x7E\x22\x39\x2D\x2A\x24\x5C\x24\x5C\x6D\x60\x6B\x27\x1F\x27\x15\x22\x20\x20\x20";

        if (obf.obfuscateV5(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareByteSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5";
        const data = "\x2A\x2D\x2B\x2D\x7E\x24\x5C\x7E\x60\x6C\x60\x7E\x27\x16\x22\x7E\x22\x39\x2D\x2A\x24\x5C\x24\x5C\x6D\x60\x6B\x27\x1F\x27\x15\x22\x20\x20\x20";
        const expected = "test BBB>>>www|||qqqzzz 123 \x00\x09\x0A ~~~";

        if (obf.obfuscateV5(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareByteSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "slideByteV5";

        const data = "\x00\x1F\x20\x7E\x7F\x80\xFF";
        const expected = "\x1F\x00\x7E\x20\x7F\xFF\x80";

        var result: [data.len]u8 = undefined;
        for (data, 0..) |byte, index| result[index] = obf.slideByteV5(byte);

        ut.compareByteSlice(name, expected, result[0..]);
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5Encode";
        const data = "test BBB>>>www|||qqqzzz 123 ~~~";
        const expected = "*-q+--~---b-d-g~-gl-a~-q9-q*---b-d-b-d-gm-ak-a-s-s-s";

        if (obf.obfuscateV5Encode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareByteSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5Decode";
        const data = "*-q+--~---b-d-g~-gl-a~-q9-q*---b-d-b-d-gm-ak-a-s-s-s";
        const expected = "test BBB>>>www|||qqqzzz 123 ~~~";

        if (obf.obfuscateV5Decode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareByteSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5BaseEncode";
        const data = "test BBB>>>www|||qqq 123 ABC @ XYZ";
        const expected = "1S62)LYnA-BxU2H0[Lzi.zv8,LX&atLXKG1LREUl:::";

        if (obf.obfuscateV5BaseEncode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5BaseDecode";
        const data = "1S62)LYnA-BxU2H0[Lzi.zv8,LX&atLXKG1LREUl:::";
        const expected = "test BBB>>>www|||qqq 123 ABC @ XYZ";

        if (obf.obfuscateV5BaseDecode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5Base64Encode";
        const data = "test BBB>>>www|||qqq 123 ABC @ XYZ";
        const expected = "Ki0rLX5tXGtgXWBbJ14iRiI5LSp+XGxcfmBcJ34nfiJFRA==";

        if (obf.obfuscateV5Base64Encode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5Base64Decode";
        const data = "Ki0rLX5tXGtgXWBbJ14iRiI5LSp+XGxcfmBcJ34nfiJFRA==";
        const expected = "test BBB>>>www|||qqq 123 ABC @ XYZ";

        if (obf.obfuscateV5Base64Decode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5Base64UrlEncode";
        const data = "test BBB>>>www|||qqq 123 ABC @ XYZ";
        const expected = "Ki0rLX5tXGtgXWBbJ14iRiI5LSp-XGxcfmBcJ34nfiJFRA";

        if (obf.obfuscateV5Base64UrlEncode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5Base64UrlDecode";
        const data = "Ki0rLX5tXGtgXWBbJ14iRiI5LSp-XGxcfmBcJ34nfiJFRA";
        const expected = "test BBB>>>www|||qqq 123 ABC @ XYZ";

        if (obf.obfuscateV5Base64UrlDecode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5Base91Encode";
        const data = "ABC \u{00a9} \u{65e5}\u{672c}\u{8a9e}\u{1f427}";
        const expected = "qJ2;cr&^qnDj+zd:q8k{}Rw9N";

        if (obf.obfuscateV5Base91Encode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    {
        const name = "obfuscateV5Base91Decode";
        const data = "qJ2;cr&^qnDj+zd:q8k{}Rw9N";
        const expected = "ABC \u{00a9} \u{65e5}\u{672c}\u{8a9e}\u{1f427}";

        if (obf.obfuscateV5Base91Decode(&allocator, data)) |result| {
            //----------------------------------------
            ut.compareStringSlice(name, expected, result);
            allocator.free(result);
            //----------------------------------------
        } else |err| {
            //----------------------------------------
            ut.errorFail(name, err);
            //----------------------------------------
        }
    }
    //----------------------------------------------------------------------------
    ut.printSummary();
    //----------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
