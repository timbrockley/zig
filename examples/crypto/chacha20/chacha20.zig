const std = @import("std");
//------------------------------------------------------------
/// ChaCha20 (IETF version) – pure implementation
/// Key: 32 bytes, Nonce: 12 bytes, Counter: u32
pub const ChaCha20 = struct {
    //------------------------------------------------------------
    /// generate one 64-byte keystream block
    pub fn block(key: *const [32]u8, counter: u32, nonce: *const [12]u8, out: *[64]u8) void {
        //------------------------------------------------------------
        var state: [16]u32 = undefined;
        //------------------------------------------------------------
        // constants
        state[0] = 0x61707865;
        state[1] = 0x3320646e;
        state[2] = 0x79622d32;
        state[3] = 0x6b206574;
        //------------------------------------------------------------
        // key (little-endian)
        state[4] = readU32LE(key[0..4]);
        state[5] = readU32LE(key[4..8]);
        state[6] = readU32LE(key[8..12]);
        state[7] = readU32LE(key[12..16]);
        state[8] = readU32LE(key[16..20]);
        state[9] = readU32LE(key[20..24]);
        state[10] = readU32LE(key[24..28]);
        state[11] = readU32LE(key[28..32]);
        //------------------------------------------------------------
        // counter
        state[12] = counter;
        //------------------------------------------------------------
        // nonce (little-endian)
        state[13] = readU32LE(nonce[0..4]);
        state[14] = readU32LE(nonce[4..8]);
        state[15] = readU32LE(nonce[8..12]);
        //------------------------------------------------------------
        // working copy
        var working = state;
        //------------------------------------------------------------
        // 20 rounds = 10 double rounds
        var i: usize = 0;
        while (i < 10) : (i += 1) {
            //------------------------------------------------------------
            // column rounds
            quarterRound(&working[0], &working[4], &working[8], &working[12]);
            quarterRound(&working[1], &working[5], &working[9], &working[13]);
            quarterRound(&working[2], &working[6], &working[10], &working[14]);
            quarterRound(&working[3], &working[7], &working[11], &working[15]);
            //------------------------------------------------------------
            // diagonal rounds
            quarterRound(&working[0], &working[5], &working[10], &working[15]);
            quarterRound(&working[1], &working[6], &working[11], &working[12]);
            quarterRound(&working[2], &working[7], &working[8], &working[13]);
            quarterRound(&working[3], &working[4], &working[9], &working[14]);
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
        // add original state
        for (&working, state) |*w, s| {
            w.* +%= s;
        }
        //------------------------------------------------------------
        // serialize little-endian
        //------------------------------------------------------------
        var j: usize = 0;
        while (j < 16) : (j += 1) {
            writeU32LE(out[j * 4 ..][0..4], working[j]);
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    /// encrypt / decrypt in-place (XOR with keystream)
    /// counter starts at the given value and is incremented for each block
    pub fn crypt(key: *const [32]u8, nonce: *const [12]u8, counter: u32, data: []u8) void {
        //------------------------------------------------------------
        var block_counter = counter;
        var offset: usize = 0;
        //------------------------------------------------------------
        while (offset < data.len) {
            //------------------------------------------------------------
            var keystream: [64]u8 = undefined;
            block(key, block_counter, nonce, &keystream);
            //------------------------------------------------------------
            const remaining = data.len - offset;
            const n = @min(remaining, 64);
            //------------------------------------------------------------
            for (0..n) |i| {
                data[offset + i] ^= keystream[i];
            }
            //------------------------------------------------------------
            offset += n;
            block_counter +%= 1;
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    // quarterRound
    //------------------------------------------------------------
    fn quarterRound(a: *u32, b: *u32, c: *u32, d: *u32) void {
        //------------------------------------------------------------
        a.* +%= b.*;
        d.* ^= a.*;
        d.* = std.math.rotl(u32, d.*, 16);

        c.* +%= d.*;
        b.* ^= c.*;
        b.* = std.math.rotl(u32, b.*, 12);

        a.* +%= b.*;
        d.* ^= a.*;
        d.* = std.math.rotl(u32, d.*, 8);

        c.* +%= d.*;
        b.* ^= c.*;
        b.* = std.math.rotl(u32, b.*, 7);
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    // readU32LE
    //------------------------------------------------------------
    fn readU32LE(bytes: *const [4]u8) u32 {
        return @as(u32, bytes[0]) |
            (@as(u32, bytes[1]) << 8) |
            (@as(u32, bytes[2]) << 16) |
            (@as(u32, bytes[3]) << 24);
    }
    //------------------------------------------------------------
    // writeU32LE
    //------------------------------------------------------------
    fn writeU32LE(out: *[4]u8, value: u32) void {
        out[0] = @truncate(value);
        out[1] = @truncate(value >> 8);
        out[2] = @truncate(value >> 16);
        out[3] = @truncate(value >> 24);
    }
    //------------------------------------------------------------
};
//------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    {
        var key: [32]u8 = [_]u8{0} ** 32;
        var nonce: [12]u8 = [_]u8{0} ** 12;

        var data = "test1234".*;
        std.debug.print("data: {s}\n", .{data});

        ChaCha20.crypt(&key, &nonce, 0, &data);
        std.debug.print("encrypted: {any}\n", .{data});

        ChaCha20.crypt(&key, &nonce, 0, &data);
        std.debug.print("decrypted: {s}\n", .{data});
    }
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    {
        var key: [32]u8 = undefined;
        var nonce: [12]u8 = undefined;

        init.io.random(&key);
        init.io.random(&nonce);

        var data = "test1234".*;
        std.debug.print("data: {s}\n", .{data});

        ChaCha20.crypt(&key, &nonce, 0, &data);
        std.debug.print("encrypted: {any}\n", .{data});

        ChaCha20.crypt(&key, &nonce, 0, &data);
        std.debug.print("decrypted: {s}\n", .{data});
    }
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
}
//------------------------------------------------------------
