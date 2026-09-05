//--------------------------------------------------------------------------------
// sudo apt install libmariadb-dev libmariadb-dev-compat
//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
pub const CLIENT_MULTI_STATEMENTS = @as(c_ulong, 1) << @as(c_int, 16);
//--------------------------------------------------------------------------------
pub const MYSQL = anyopaque;
pub const MYSQL_RES = anyopaque;
pub const MYSQL_ROW = [*c][*c]u8;
//--------------------------------------------------------------------------------
pub var mysql_close: *const fn (sock: ?*MYSQL) callconv(.c) void = undefined;
pub var mysql_error: *const fn (mysql: ?*MYSQL) callconv(.c) [*c]const u8 = undefined;
pub var mysql_fetch_row: *const fn (result: ?*MYSQL_RES) callconv(.c) MYSQL_ROW = undefined;
pub var mysql_field_count: *const fn (mysql: ?*MYSQL) callconv(.c) c_uint = undefined;
pub var mysql_free_result: *const fn (result: ?*MYSQL_RES) callconv(.c) void = undefined;
pub var mysql_init: *const fn (mysql: ?*MYSQL) callconv(.c) ?*MYSQL = undefined;
pub var mysql_next_result: *const fn (mysql: ?*MYSQL) callconv(.c) c_int = undefined;
pub var mysql_query: *const fn (mysql: ?*MYSQL, q: [*c]const u8) callconv(.c) c_int = undefined;
pub var mysql_real_connect: *const fn (mysql: ?*MYSQL, host: [*c]const u8, user: [*c]const u8, passwd: [*c]const u8, db: [*c]const u8, port: c_uint, unix_socket: [*c]const u8, clientflag: c_ulong) callconv(.c) ?*MYSQL = undefined;
pub var mysql_store_result: *const fn (mysql: ?*MYSQL) callconv(.c) ?*MYSQL_RES = undefined;
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
var libmysql: ?std.DynLib = null;
//--------------------------------------------------------------------------------
pub fn init() !void {
    //------------------------------------------------------------
    libmysql = std.DynLib.open("libmysqlclient.so") catch std.DynLib.open("libmariadb.so") catch return error.LibraryNotFound;
    //------------------------------------------------------------
    var lib = libmysql orelse return error.LibraryNotOpen;
    //------------------------------------------------------------
    inline for (comptime std.meta.declarations(@This())) |declaration| {
        if (comptime !std.mem.startsWith(u8, declaration.name, "mysql_")) continue;
        if (comptime @TypeOf(@field(@This(), declaration.name)) == type) continue;
        const T = @TypeOf(@field(@This(), declaration.name));
        @field(@This(), declaration.name) =
            lib.lookup(T, declaration.name) orelse return error.InvalidFunction;
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub fn deinit() void {
    //------------------------------------------------------------
    if (libmysql != null) libmysql.?.close();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
