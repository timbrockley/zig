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
    var db_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    defer _ = sqlite3_close(db_handle);
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{@as([80]u8, @splat('-'))});
    //------------------------------------------------------------
    {
        //----------------------------------------
        const rc = sqlite3_open(DATABASE_FILEPATH, &db_handle);
        if (rc != SQLITE_OK) {
            std.debug.print("sqlite3_open: {s}\n", .{sqlite3_errmsg(db_handle)});
            return SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "PRAGMA journal_mode=WAL;";
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != SQLITE_OK) {
            defer sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "DROP TABLE IF EXISTS test;";
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != SQLITE_OK) {
            defer sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(255));";
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != SQLITE_OK) {
            defer sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return SQLITE_ERROR;
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
        const rc = sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != SQLITE_OK) {
            defer sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "SELECT * FROM test;";
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != SQLITE_OK) {
            defer sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    std.debug.print("counter = {d}\n", .{context.count});
    std.debug.print("{s}\n", .{@as([80]u8, @splat('-'))});
    //--------------------------------------------------------------------------------
    return SQLITE_OK;
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
    return SQLITE_OK;
    //--------------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
pub const SQLITE_INTEGER = @as(c_int, 1);
pub const SQLITE_FLOAT = @as(c_int, 2);
pub const SQLITE_BLOB = @as(c_int, 4);
pub const SQLITE_NULL = @as(c_int, 5);
pub const SQLITE_TEXT = @as(c_int, 3);
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
pub extern fn sqlite3_bind_blob(stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) c_int;
pub extern fn sqlite3_bind_double(stmt_handle: ?*anyopaque, iCol: c_int, float: f64) callconv(.c) c_int;
pub extern fn sqlite3_bind_int64(stmt_handle: ?*anyopaque, iCol: c_int, integer: i64) callconv(.c) c_int;
pub extern fn sqlite3_bind_null(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int;
pub extern fn sqlite3_bind_text(stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) c_int;
pub extern fn sqlite3_clear_bindings(stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_close(db_handle: ?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_column_blob(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8;
pub extern fn sqlite3_column_bytes(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int;
pub extern fn sqlite3_column_count(stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_column_double(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) f64;
pub extern fn sqlite3_column_int64(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) i64;
pub extern fn sqlite3_column_name(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8;
pub extern fn sqlite3_column_text(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8;
pub extern fn sqlite3_column_type(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int;
pub extern fn sqlite3_data_count(stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_errmsg(db_handle: ?*anyopaque) callconv(.c) [*c]const u8;
pub extern fn sqlite3_exec(db_handle: ?*anyopaque, sql: [*c]const u8, callback: ?*const fn (ctx: ?*anyopaque, argc: i32, argv: [*c][*c]u8, azColName: [*c][*c]u8) callconv(.c) c_int, ctx: ?*anyopaque, errmsg: [*c][*c]u8) callconv(.c) c_int;
pub extern fn sqlite3_finalize(stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_free(ptr: ?*anyopaque) callconv(.c) void;
pub extern fn sqlite3_free_table(results: [*c][*c]u8) callconv(.c) void;
pub extern fn sqlite3_get_table(db_handle: ?*anyopaque, sql: [*c]const u8, results: [*c][*c][*c]u8, row_count: [*c]c_int, column_count: [*c]c_int, errmsg: [*c][*c]u8) callconv(.c) c_int;
pub extern fn sqlite3_malloc64(len: c_ulonglong) callconv(.c) ?*anyopaque;
pub extern fn sqlite3_mprintf([*c]const u8, ...) callconv(.c) [*c]u8;
pub extern fn sqlite3_open(filepath: [*:0]const u8, db_handle: *?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_prepare_v2(db_handle: ?*anyopaque, sql: [*c]const u8, nByte: c_int, ppStmt: *?*anyopaque, pzTail: [*c][*c]const u8) callconv(.c) c_int;
pub extern fn sqlite3_realloc64(ptr: ?*anyopaque, len: c_ulonglong) callconv(.c) ?*anyopaque;
pub extern fn sqlite3_reset(stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_snprintf(c_int, [*c]u8, [*c]const u8, ...) callconv(.c) [*c]u8;
pub extern fn sqlite3_step(stmt_handle: ?*anyopaque) callconv(.c) c_int;
//--------------------------------------------------------------------------------
