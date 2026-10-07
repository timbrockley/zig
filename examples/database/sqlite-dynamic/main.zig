//--------------------------------------------------------------------------------
// sudo apt install -y libsqlite3-dev
//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const DATABASE_FILEPATH = "test1.db";
//--------------------------------------------------------------------------------
const Context = struct { count: usize = 0 };
//--------------------------------------------------------------------------------
pub fn main() !u8 {
    //--------------------------------------------------------------------------------
    // optionl context - if not used then null can be passed
    var context = Context{}; // passed by reference if used
    //--------------------------------------------------------------------------------
    try init();
    defer deinit();
    //------------------------------------------------------------
    var db_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    defer _ = c.sqlite3_close(db_handle);
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{@as([80]u8, @splat('-'))});
    //------------------------------------------------------------
    {
        //----------------------------------------
        const rc = c.sqlite3_open(DATABASE_FILEPATH, &db_handle);
        if (rc != c.SQLITE_OK) {
            std.debug.print("sqlite3_open: {s}\n", .{c.sqlite3_errmsg(db_handle)});
            return c.SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "PRAGMA journal_mode=WAL;";
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = c.sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer c.sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return c.SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "DROP TABLE IF EXISTS test;";
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = c.sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer c.sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return c.SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(255));";
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = c.sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer c.sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return c.SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql =
            \\INSERT INTO test (name) VALUES ('name1');
            \\INSERT INTO test (name) VALUES ('name2');
        ;
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = c.sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer c.sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return c.SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "SELECT * FROM test;";
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = c.sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer c.sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return c.SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    std.debug.print("counter = {d}\n", .{context.count});
    std.debug.print("{s}\n", .{@as([80]u8, @splat('-'))});
    //--------------------------------------------------------------------------------
    return c.SQLITE_OK;
    //--------------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
fn execCallback(
    ctx: ?*anyopaque,
    argc: c_int,
    argv: [*c][*c]u8,
    azColName: [*c][*c]u8,
) callconv(.c) c_int {
    //--------------------------------------------------------------------------------
    // optional context pointer - null if not used
    if (ctx) |ctx_ptr| {
        const context: *Context = @ptrCast(@alignCast(ctx_ptr));
        context.count += 1;
    }
    //--------------------------------------------------------------------------------
    for (0..@intCast(argc)) |i| {
        //----------------------------------------
        if (argv[i] == null) {
            std.debug.print("{s} = NULL\n", .{azColName[i]});
        } else {
            std.debug.print("{s} = {s}\n", .{ azColName[i], argv[i] });
        }
        //----------------------------------------
    }
    std.debug.print("{s}\n", .{@as([80]u8, @splat('-'))});
    //--------------------------------------------------------------------------------
    return c.SQLITE_OK;
    //--------------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub const c = struct {
    //--------------------------------------------------------------------------------
    pub const SQLITE_INTEGER = @as(i32, 1);
    pub const SQLITE_FLOAT = @as(i32, 2);
    pub const SQLITE_TEXT = @as(i32, 3);
    pub const SQLITE_BLOB = @as(i32, 4);
    pub const SQLITE_NULL = @as(i32, 5);
    //--------------------------------------------------------------------------------
    pub const SQLITE_OK = @as(i32, 0);
    pub const SQLITE_ERROR = @as(i32, 1);
    pub const SQLITE_INTERNAL = @as(i32, 2);
    pub const SQLITE_PERM = @as(i32, 3);
    pub const SQLITE_ABORT = @as(i32, 4);
    pub const SQLITE_BUSY = @as(i32, 5);
    pub const SQLITE_LOCKED = @as(i32, 6);
    pub const SQLITE_NOMEM = @as(i32, 7);
    pub const SQLITE_READONLY = @as(i32, 8);
    pub const SQLITE_INTERRUPT = @as(i32, 9);
    pub const SQLITE_IOERR = @as(i32, 10);
    pub const SQLITE_CORRUPT = @as(i32, 11);
    pub const SQLITE_NOTFOUND = @as(i32, 12);
    pub const SQLITE_FULL = @as(i32, 13);
    pub const SQLITE_CANTOPEN = @as(i32, 14);
    pub const SQLITE_PROTOCOL = @as(i32, 15);
    pub const SQLITE_EMPTY = @as(i32, 16);
    pub const SQLITE_SCHEMA = @as(i32, 17);
    pub const SQLITE_TOOBIG = @as(i32, 18);
    pub const SQLITE_CONSTRAINT = @as(i32, 19);
    pub const SQLITE_MISMATCH = @as(i32, 20);
    pub const SQLITE_MISUSE = @as(i32, 21);
    pub const SQLITE_NOLFS = @as(i32, 22);
    pub const SQLITE_AUTH = @as(i32, 23);
    pub const SQLITE_FORMAT = @as(i32, 24);
    pub const SQLITE_RANGE = @as(i32, 25);
    pub const SQLITE_NOTADB = @as(i32, 26);
    pub const SQLITE_NOTICE = @as(i32, 27);
    pub const SQLITE_WARNING = @as(i32, 28);
    pub const SQLITE_ROW = @as(i32, 100);
    pub const SQLITE_DONE = @as(i32, 101);
    //--------------------------------------------------------------------------------
    pub const sqlite3 = anyopaque;
    pub const sqlite3_stmt = anyopaque;
    //--------------------------------------------------------------------------------
    pub var sqlite3_bind_blob: *const fn (stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i32, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) i32 = undefined;
    pub var sqlite3_bind_double: *const fn (stmt_handle: ?*anyopaque, iCol: i32, float: f64) callconv(.c) i32 = undefined;
    pub var sqlite3_bind_int: *const fn (stmt_handle: ?*anyopaque, iCol: i32, int32: i32) callconv(.c) i32 = undefined;
    pub var sqlite3_bind_int64: *const fn (stmt_handle: ?*anyopaque, iCol: i32, int64: i64) callconv(.c) i32 = undefined;
    pub var sqlite3_bind_null: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32 = undefined;
    pub var sqlite3_bind_text: *const fn (stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i32, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) i32 = undefined;
    pub var sqlite3_clear_bindings: *const fn (stmt_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_close: *const fn (db_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_column_blob: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_column_bytes: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32 = undefined;
    pub var sqlite3_column_count: *const fn (stmt_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_column_double: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) f64 = undefined;
    pub var sqlite3_column_int: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32 = undefined;
    pub var sqlite3_column_int64: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i64 = undefined;
    pub var sqlite3_column_name: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_column_text: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_column_type: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32 = undefined;
    pub var sqlite3_column_decltype: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_data_count: *const fn (stmt_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_errmsg: *const fn (db_handle: ?*anyopaque) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_exec: *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, callback: ?*const fn (?*anyopaque, i32, [*c][*c]u8, [*c][*c]u8) callconv(.c) i32, ctx: ?*anyopaque, errmsg: [*c][*c]u8) callconv(.c) i32 = undefined;
    pub var sqlite3_finalize: *const fn (stmt_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_free: *const fn (ptr: ?*anyopaque) callconv(.c) void = undefined;
    pub var sqlite3_free_table: *const fn (results: [*c][*c]u8) callconv(.c) void = undefined;
    pub var sqlite3_get_table: *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, results: [*c][*c][*c]u8, row_count: [*c]i32, column_count: [*c]i32, errmsg: [*c][*c]u8) callconv(.c) i32 = undefined;
    pub var sqlite3_malloc64: *const fn (len: u64) callconv(.c) ?*anyopaque = undefined;
    pub var sqlite3_mprintf: *const fn ([*c]const u8, ...) callconv(.c) [*c]u8 = undefined;
    pub var sqlite3_open: *const fn (filepath: [*:0]const u8, db_handle: *?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_prepare_v2: *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, nByte: i32, ppStmt: *?*anyopaque, pzTail: [*c][*c]const u8) callconv(.c) i32 = undefined;
    pub var sqlite3_realloc64: *const fn (ptr: ?*anyopaque, len: u64) callconv(.c) ?*anyopaque = undefined;
    pub var sqlite3_reset: *const fn (stmt_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_snprintf: *const fn (i32, [*c]u8, [*c]const u8, ...) callconv(.c) [*c]u8 = undefined;
    pub var sqlite3_step: *const fn (stmt_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    //--------------------------------------------------------------------------------
};
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
    inline for (comptime @typeInfo(c).@"struct".decl_names) |decl_name| {
        //------------------------------------------------------------
        if (comptime !std.mem.startsWith(u8, decl_name, "sqlite3_")) continue;
        if (comptime @TypeOf(@field(c, decl_name)) == type) continue;
        const T = @TypeOf(@field(c, decl_name));
        @field(c, decl_name) =
            lib.lookup(T, decl_name) orelse return error.InvalidFunction;
        //------------------------------------------------------------
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
