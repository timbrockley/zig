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
const DATABASE_FILENAME = "test1.db";
//--------------------------------------------------------------------------------
const Context = struct { count: usize = 0 };
//--------------------------------------------------------------------------------
pub fn main() !u8 {
    //------------------------------------------------------------
    // optionl context - if not used then null can be passed
    var context = Context{}; // passed by reference if used
    //------------------------------------------------------------
    var db: ?*c.sqlite3 = null;
    var rc = c.sqlite3_open(DATABASE_FILENAME, &db);
    //------------------------------------------------------------
    defer _ = c.sqlite3_close(db);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        std.debug.print("cannot open database: {s}\n", .{c.sqlite3_errmsg(db)});
        return c.SQLITE_ERROR;
    }
    //------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "PRAGMA journal_mode=WAL;";
        //----------------------------------------
        var zErrMsg: [*c]u8 = null;
        rc = c.sqlite3_exec(db, sql, callback, &context, &zErrMsg);
        if (rc != c.SQLITE_OK) {
            defer c.sqlite3_free(zErrMsg);
            std.debug.print("SQL error: {s}\n", .{zErrMsg});
            return c.SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "DROP TABLE IF EXISTS cars;";
        //----------------------------------------
        var zErrMsg: [*c]u8 = null;
        rc = c.sqlite3_exec(db, sql, callback, &context, &zErrMsg);
        if (rc != c.SQLITE_OK) {
            defer c.sqlite3_free(zErrMsg);
            std.debug.print("SQL error: {s}\n", .{zErrMsg});
            return c.SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "CREATE TABLE IF NOT EXISTS cars (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(255));";
        //----------------------------------------
        var zErrMsg: [*c]u8 = null;
        rc = c.sqlite3_exec(db, sql, callback, &context, &zErrMsg);
        if (rc != c.SQLITE_OK) {
            defer c.sqlite3_free(zErrMsg);
            std.debug.print("SQL error: {s}\n", .{zErrMsg});
            return c.SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "INSERT INTO cars (name) VALUES('name1');";
        //----------------------------------------
        var zErrMsg: [*c]u8 = null;
        rc = c.sqlite3_exec(db, sql, callback, &context, &zErrMsg);
        if (rc != c.SQLITE_OK) {
            defer c.sqlite3_free(zErrMsg);
            std.debug.print("SQL error: {s}\n", .{zErrMsg});
            return c.SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "SELECT * FROM cars;";
        //----------------------------------------
        var zErrMsg: [*c]u8 = null;
        rc = c.sqlite3_exec(db, sql, callback, &context, &zErrMsg);
        if (rc != c.SQLITE_OK) {
            defer c.sqlite3_free(zErrMsg);
            std.debug.print("SQL error: {s}\n", .{zErrMsg});
            return c.SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //------------------------------------------------------------
    std.debug.print("\ncounter = {d}\n\n", .{context.count});
    //------------------------------------------------------------
    return c.SQLITE_OK;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
fn callback(
    ctx: ?*anyopaque,
    argc: c_int,
    argv: [*c][*c]u8,
    azColName: [*c][*c]u8,
) callconv(.c) c_int {
    //----------------------------------------
    // optional context pointer - null if not used
    if (ctx) |ctx_ptr| {
        const context: *Context = @ptrCast(@alignCast(ctx_ptr));
        context.count += 1;
    }
    //----------------------------------------
    for (0..@intCast(argc)) |i| {
        //----------------------------------------
        if (argv[i] == null) {
            std.debug.print("{s} = NULL\n", .{azColName[i]});
        } else {
            std.debug.print("{s} = {s}\n", .{ azColName[i], argv[i] });
        }
        //----------------------------------------
    }
    //----------------------------------------
    return c.SQLITE_OK;
    //----------------------------------------
}
//--------------------------------------------------------------------------------
