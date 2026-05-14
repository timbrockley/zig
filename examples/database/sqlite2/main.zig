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
const DATABASE_FILENAME = "test2.db";
//--------------------------------------------------------------------------------
pub fn main() !u8 {
    //------------------------------------------------------------
    var db: ?*c.sqlite3 = null;
    const rc = c.sqlite3_open(DATABASE_FILENAME, &db);
    //------------------------------------------------------------
    defer _ = c.sqlite3_close(db);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        std.debug.print("cannot open database: {s}\n", .{c.sqlite3_errmsg(db)});
        return c.SQLITE_ERROR;
    }
    //------------------------------------------------------------
    {
        const sql = "PRAGMA journal_mode=WAL;";
        try sqliteQuery(db, sql);
    }
    //------------------------------------------------------------
    {
        const sql = "DROP TABLE IF EXISTS cars;";
        try sqliteQuery(db, sql);
    }
    //------------------------------------------------------------
    {
        const sql = "CREATE TABLE IF NOT EXISTS cars (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price FLOAT, year INTEGER);";
        try sqliteQuery(db, sql);
    }
    //------------------------------------------------------------
    {
        const sql = "INSERT INTO cars (name, price, year) VALUES('NAME_TEXT', 123.456, 2026);";
        try sqliteQuery(db, sql);
    }
    //------------------------------------------------------------
    {
        const sql = "SELECT * FROM cars;";
        try sqliteQuery(db, sql);
    }
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    return c.SQLITE_OK;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
fn sqliteQuery(db: ?*c.sqlite3, sql: [*:0]const u8) !void {
    //------------------------------------------------------------
    var rc: c_int = 0;
    var stmt: ?*c.sqlite3_stmt = null;
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    std.debug.print("{s}\n", .{sql});
    //------------------------------------------------------------
    rc = c.sqlite3_prepare_v2(db, sql, -1, &stmt, null);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        std.debug.print(
            "prepare failed rc={} msg={s}\n",
            .{
                rc,
                c.sqlite3_errmsg(db),
            },
        );
        return error.PrepareFailed;
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt);
    //------------------------------------------------------------
    const col_count: usize = @intCast(c.sqlite3_column_count(stmt));
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        rc = c.sqlite3_step(stmt);
        //------------------------------------------------------------
        if (rc == c.SQLITE_ROW) {
            for (0..col_count) |i| {
                //------------------------------------------------------------
                const idx: c_int = @intCast(i);
                //------------------------------------------------------------
                printColumn(stmt, idx);
                //------------------------------------------------------------
            }
            //------------------------------------------------------------
        } else if (rc == c.SQLITE_DONE) {
            break;
        } else {
            std.debug.print(
                "step failed rc={} msg={s}\n",
                .{
                    rc,
                    c.sqlite3_errmsg(db),
                },
            );
            return error.StepFailed;
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
fn sqliteTypeName(typ: c_int) []const u8 {
    return switch (typ) {
        c.SQLITE_INTEGER => "INTEGER", // c_int(1)
        c.SQLITE_FLOAT => "FLOAT", // c_int(2)
        c.SQLITE_TEXT => "TEXT", // c_int(3)
        c.SQLITE_BLOB => "BLOB", // c_int(4)
        c.SQLITE_NULL => "NULL", // c_int(5)
        else => "UNKNOWN",
    };
}
//--------------------------------------------------------------------------------
fn printColumn(stmt: ?*c.sqlite3_stmt, idx: c_int) void {
    //------------------------------------------------------------
    const name = c.sqlite3_column_name(stmt, idx);
    const ptr = c.sqlite3_column_text(stmt, idx);
    const len: usize = @intCast(c.sqlite3_column_bytes(stmt, idx));
    const typ = c.sqlite3_column_type(stmt, idx);
    //------------------------------------------------------------
    if (ptr == null or typ == c.SQLITE_NULL) {
        std.debug.print("{d}: {s}: value=NULL\n", .{ idx, name });
        return;
    }
    //------------------------------------------------------------
    const p = ptr.?;
    const bytes = p[0..len];
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    std.debug.print(
        "{d}: {s}: ptr={*}, len={}, type={d}: {s}, ",
        .{ idx, name, ptr, len, typ, sqliteTypeName(typ) },
    );
    //------------------------------------------------------------
    switch (typ) {
        //------------------------------------------------------------
        c.SQLITE_INTEGER => {
            // const value = std.fmt.parseInt(i64, bytes, 10) catch 0;
            const value = @as(i64, c.sqlite3_column_int64(stmt, idx));
            std.debug.print("value={}\n", .{value});
        },
        //------------------------------------------------------------
        c.SQLITE_FLOAT => {
            // const value = std.fmt.parseFloat(f64, bytes) catch 0;
            const value = @as(f64, c.sqlite3_column_double(stmt, idx));
            std.debug.print("value={}\n", .{value});
        },
        //------------------------------------------------------------
        c.SQLITE_TEXT => {
            std.debug.print("value={s}\n", .{bytes});
        },
        //------------------------------------------------------------
        c.SQLITE_BLOB => {
            std.debug.print("value={any}\n", .{bytes});
        },
        //------------------------------------------------------------
        c.SQLITE_NULL => {
            std.debug.print("value=SQLITE_NULL\n", .{});
        },
        //------------------------------------------------------------
        else => {
            std.debug.print("value={any}\n", .{bytes});
        },
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
