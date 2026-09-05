//--------------------------------------------------------------------------------
//
// sudo apt install -y libsqlite3-dev
//
//--------------------------------------------------------------------------------
const std = @import("std");
const c = @cImport({
    @cInclude("sqlite3.h");
});
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
    var db_handle: ?*c.sqlite3 = null;
    //------------------------------------------------------------
    defer _ = c.sqlite3_close(db_handle);
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
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
    std.debug.print("{s}\n", .{"-" ** 80});
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
    std.debug.print("{s}\n", .{"-" ** 80});
    //--------------------------------------------------------------------------------
    return c.SQLITE_OK;
    //--------------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
