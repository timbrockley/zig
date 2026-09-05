const std = @import("std");
//------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    const ChaCha20Poly1305 = std.crypto.aead.chacha_poly.ChaCha20Poly1305;
    const tag_length = ChaCha20Poly1305.tag_length;
    //------------------------------------------------------------
    // zero values for testing purposes
    var key: [32]u8 = [_]u8{0} ** 32;
    var nonce: [12]u8 = [_]u8{0} ** 12;
    //------------------------------------------------------------
    var data = "test1234".*;
    var encrypted: [data.len]u8 = undefined;
    var decrypted: [data.len]u8 = undefined;
    //------------------------------------------------------------
    {
        const aad: []const u8 = "";

        var tag: [tag_length]u8 = undefined;

        ChaCha20Poly1305.encrypt(&encrypted, &tag, &data, aad, nonce, key);

        std.debug.print("data:      {s}\n", .{data});
        std.debug.print("encrypted: {any}\n", .{encrypted});
        std.debug.print("tag:       {any}\n", .{tag});

        try ChaCha20Poly1305.decrypt(&decrypted, &encrypted, tag, aad, nonce, key);

        std.debug.print("decrypted: {s}\n", .{decrypted});
    }
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    {
        init.io.random(&key);
        init.io.random(&nonce);

        const aad: []const u8 = "Session-ID-42";

        var tag: [tag_length]u8 = undefined;

        ChaCha20Poly1305.encrypt(&encrypted, &tag, &data, aad, nonce, key);

        std.debug.print("data:      {s}\n", .{data});
        std.debug.print("encrypted: {any}\n", .{encrypted});
        std.debug.print("tag:       {any}\n", .{tag});

        try ChaCha20Poly1305.decrypt(&decrypted, &encrypted, tag, aad, nonce, key);

        std.debug.print("decrypted: {s}\n", .{decrypted});
    }
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
}
//------------------------------------------------------------
