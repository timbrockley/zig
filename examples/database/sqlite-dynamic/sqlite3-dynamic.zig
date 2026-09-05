//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub const SQLITE_INTEGER = @as(c_int, 1);
pub const SQLITE_FLOAT = @as(c_int, 2);
pub const SQLITE_TEXT = @as(c_int, 3);
pub const SQLITE_BLOB = @as(c_int, 4);
pub const SQLITE_NULL = @as(c_int, 5);
//--------------------------------------------------------------------------------
pub const SQLITE_OK = @as(c_int, 0);
pub const SQLITE_ERROR = @as(c_int, 1);
pub const SQLITE_INTERNAL = @as(c_int, 2);
pub const SQLITE_PERM = @as(c_int, 3);
pub const SQLITE_ABORT = @as(c_int, 4);
pub const SQLITE_BUSY = @as(c_int, 5);
pub const SQLITE_LOCKED = @as(c_int, 6);
pub const SQLITE_NOMEM = @as(c_int, 7);
pub const SQLITE_READONLY = @as(c_int, 8);
pub const SQLITE_INTERRUPT = @as(c_int, 9);
pub const SQLITE_IOERR = @as(c_int, 10);
pub const SQLITE_CORRUPT = @as(c_int, 11);
pub const SQLITE_NOTFOUND = @as(c_int, 12);
pub const SQLITE_FULL = @as(c_int, 13);
pub const SQLITE_CANTOPEN = @as(c_int, 14);
pub const SQLITE_PROTOCOL = @as(c_int, 15);
pub const SQLITE_EMPTY = @as(c_int, 16);
pub const SQLITE_SCHEMA = @as(c_int, 17);
pub const SQLITE_TOOBIG = @as(c_int, 18);
pub const SQLITE_CONSTRAINT = @as(c_int, 19);
pub const SQLITE_MISMATCH = @as(c_int, 20);
pub const SQLITE_MISUSE = @as(c_int, 21);
pub const SQLITE_NOLFS = @as(c_int, 22);
pub const SQLITE_AUTH = @as(c_int, 23);
pub const SQLITE_FORMAT = @as(c_int, 24);
pub const SQLITE_RANGE = @as(c_int, 25);
pub const SQLITE_NOTADB = @as(c_int, 26);
pub const SQLITE_NOTICE = @as(c_int, 27);
pub const SQLITE_WARNING = @as(c_int, 28);
pub const SQLITE_ROW = @as(c_int, 100);
pub const SQLITE_DONE = @as(c_int, 101);
//--------------------------------------------------------------------------------
pub const sqlite3 = anyopaque;
pub const sqlite3_stmt = anyopaque;
//--------------------------------------------------------------------------------
pub var sqlite3_bind_blob: *const fn (stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) c_int = undefined;
pub var sqlite3_bind_double: *const fn (stmt_handle: ?*anyopaque, iCol: c_int, float: f64) callconv(.c) c_int = undefined;
pub var sqlite3_bind_int64: *const fn (stmt_handle: ?*anyopaque, iCol: c_int, integer: i64) callconv(.c) c_int = undefined;
pub var sqlite3_bind_null: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int = undefined;
pub var sqlite3_bind_text: *const fn (stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) c_int = undefined;
pub var sqlite3_clear_bindings: *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int = undefined;
pub var sqlite3_close: *const fn (db_handle: ?*anyopaque) callconv(.c) c_int = undefined;
pub var sqlite3_column_blob: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8 = undefined;
pub var sqlite3_column_bytes: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int = undefined;
pub var sqlite3_column_count: *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int = undefined;
pub var sqlite3_column_double: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) f64 = undefined;
pub var sqlite3_column_int64: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) i64 = undefined;
pub var sqlite3_column_name: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8 = undefined;
pub var sqlite3_column_text: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8 = undefined;
pub var sqlite3_column_type: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int = undefined;
pub var sqlite3_data_count: *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int = undefined;
pub var sqlite3_errmsg: *const fn (db_handle: ?*anyopaque) callconv(.c) [*c]const u8 = undefined;
pub var sqlite3_exec: *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, callback: ?*const fn (ctx: ?*anyopaque, argc: i32, argv: [*c][*c]u8, azColName: [*c][*c]u8) callconv(.c) c_int, ctx: ?*anyopaque, errmsg: [*c][*c]u8) callconv(.c) c_int = undefined;
pub var sqlite3_finalize: *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int = undefined;
pub var sqlite3_free: *const fn (ptr: ?*anyopaque) callconv(.c) void = undefined;
pub var sqlite3_free_table: *const fn (results: [*c][*c]u8) callconv(.c) void = undefined;
pub var sqlite3_get_table: *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, results: [*c][*c][*c]u8, row_count: [*c]c_int, column_count: [*c]c_int, errmsg: [*c][*c]u8) callconv(.c) c_int = undefined;
pub var sqlite3_malloc64: *const fn (len: c_ulonglong) callconv(.c) ?*anyopaque = undefined;
pub var sqlite3_mprintf: *const fn ([*c]const u8, ...) callconv(.c) [*c]u8 = undefined;
pub var sqlite3_open: *const fn (filepath: [*:0]const u8, db_handle: *?*anyopaque) callconv(.c) c_int = undefined;
pub var sqlite3_prepare_v2: *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, nByte: c_int, ppStmt: *?*anyopaque, pzTail: [*c][*c]const u8) callconv(.c) c_int = undefined;
pub var sqlite3_realloc64: *const fn (ptr: ?*anyopaque, len: c_ulonglong) callconv(.c) ?*anyopaque = undefined;
pub var sqlite3_reset: *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int = undefined;
pub var sqlite3_snprintf: *const fn (c_int, [*c]u8, [*c]const u8, ...) callconv(.c) [*c]u8 = undefined;
pub var sqlite3_step: *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int = undefined;
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
var libsqlite: ?std.DynLib = null;
//--------------------------------------------------------------------------------
pub fn init() !void {
    //------------------------------------------------------------
    libsqlite = std.DynLib.open("libsqlite3.so") catch return error.LibraryNotFound;
    //------------------------------------------------------------
    var lib = libsqlite orelse return error.LibraryNotOpen;
    //------------------------------------------------------------
    inline for (comptime std.meta.declarations(@This())) |declaration| {
        if (comptime !std.mem.startsWith(u8, declaration.name, "sqlite3_")) continue;
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
    if (libsqlite != null) libsqlite.?.close();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
