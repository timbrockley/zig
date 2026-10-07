//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const unittest = @import("libs/unittest.zig");
const c = @import("sqlite3.zig");
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
const DATABASE_FILEPATH = "test-sqlite.db";
//--------------------------------------------------------------------------------
pub const SQLiteColumnType = enum(c_int) {
    SQLITE_UNKNOWN = 0,
    SQLITE_INTEGER = 1,
    SQLITE_FLOAT = 2,
    SQLITE_TEXT = 3,
    SQLITE_BLOB = 4,
    SQLITE_NULL = 5,
};
//--------------------------------------------------------------------------------
pub const SQLiteColumn = extern struct {
    index: i32 = 0,
    name: [*:0]const u8 = "",
    column_type: SQLiteColumnType = .SQLITE_UNKNOWN,
    unsigned: bool = false,
    integer: i64 = 0,
    float: f64 = 0,
    ptr: [*]const u8 = "",
    len: i32 = 0,
};
//--------------------------------------------------------------------------------
const StringsColumn = struct {
    name: []u8 = "",
    value: []u8 = "",
};
//--------------------------------------------------------------------------------
const FixedRowColumnType = enum { id, uint64, integer, float, text, blob, blob_nullable };
const FixedRow = struct {
    id: i64 = 0,
    uint64: u64 = 0,
    integer: i64 = 0,
    float: f64 = 0,
    text: []u8 = "",
    blob: []u8 = "",
    blob_nullable: ?[]u8 = null,
};
//--------------------------------------------------------------------------------
const Context = struct {
    allocator: std.mem.Allocator,

    string_rows: std.ArrayList(StringsColumn) = .empty,
    fixed_rows: std.ArrayList(FixedRow) = .empty,

    fn deinit(context: *Context) void {
        for (context.string_rows.items) |string_row| {
            context.allocator.free(string_row.name);
            context.allocator.free(string_row.value);
        }
        context.string_rows.deinit(context.allocator);

        for (context.fixed_rows.items) |fixed_row| {
            context.allocator.free(fixed_row.text);
            context.allocator.free(fixed_row.blob);
            if (fixed_row.blob_nullable) |b| {
                context.allocator.free(b);
            }
        }
        context.fixed_rows.deinit(context.allocator);
    }
};
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn main(init: std.process.Init) !u8 {
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    var ut = try unittest.init(.{ .io = init.io, .show_passes = false, .skip_after_fail = true });
    //--------------------------------------------------------------------------------
    var context = Context{ .allocator = init.gpa };
    defer context.deinit();
    //--------------------------------------------------------------------------------
    var db_handle: ?*anyopaque = null;
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        const len: usize = 32;

        const raw1 = sqliteMalloc64(len);
        // defer sqliteFree(raw1);

        const ptr1: [*]u8 = @ptrCast(raw1);
        const buffer1 = ptr1[0..len];
        const partial1 = buffer1[0..3];
        @memcpy(partial1, "ABC");

        // std.debug.print("{s}\n", .{partial});
        try ut.compareStringSlice("sqliteMalloc64", partial1, "ABC", .{ .src = @src() });
        try ut.compareStringSlice("sqliteMalloc64", buffer1[0..3], "ABC", .{ .src = @src() });

        const raw2 = sqliteRealloc64(ptr1, len * 2);
        defer sqliteFree(raw2);

        const ptr2: [*]u8 = @ptrCast(raw2);
        const buffer2 = ptr2[0..len];
        const partial2 = buffer2[0..3];
        @memcpy(partial2, "ABC");

        // std.debug.print("{s}\n", .{partial});
        try ut.compareStringSlice("sqliteRealloc64", partial2, "ABC", .{ .src = @src() });
        try ut.compareStringSlice("sqliteRealloc64", buffer2[0..3], "ABC", .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        try ut.compareBool("checkTableName", false, checkTableName(""), .{ .src = @src() });
        try ut.compareBool("checkTableName", false, checkTableName("1"), .{ .src = @src() });
        try ut.compareBool("checkTableName", false, checkTableName("#"), .{ .src = @src() });
        try ut.compareBool("checkTableName", false, checkTableName("A#"), .{ .src = @src() });
        try ut.compareBool("checkTableName", false, checkTableName("A-"), .{ .src = @src() });
        try ut.compareBool("checkTableName", true, checkTableName("_A"), .{ .src = @src() });
        try ut.compareBool("checkTableName", true, checkTableName("_1"), .{ .src = @src() });
        try ut.compareBool("checkTableName", true, checkTableName("A"), .{ .src = @src() });
        try ut.compareBool("checkTableName", true, checkTableName("A1_A2"), .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        const rc = sqliteOpen(DATABASE_FILEPATH, &db_handle);
        if (rc != c.SQLITE_OK or db_handle == null) {
            std.log.err("failed to open database: ({d}) {s}\n", .{ rc, sqliteErrmsg(db_handle) });
            return c.SQLITE_ERROR;
        }
        // std.debug.print("database open: db_handle = {*}\n", .{db_handle});
        // try ut.printLine();
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "PRAGMA journal_mode=WAL;";
        var errmsg: [*c]u8 = null;
        const rc = sqliteExec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.log.err("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
        try ut.printLine();
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "DROP TABLE IF EXISTS test;";
        var errmsg: [*c]u8 = null;
        const rc = sqliteExec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.log.err("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, uint64 INTEGER UNSIGNED DEFAULT 0 NOT NULL, integer INTEGER DEFAULT 0 NOT NULL, float REAL DEFAULT 0 NOT NULL, text VARCHAR(255) DEFAULT '' NOT NULL, blob BLOB DEFAULT '' NOT NULL, blob_nullable BLOB);";
        var errmsg: [*c]u8 = null;
        const rc = sqliteExec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.log.err("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "INSERT INTO test (uint64, integer, float, text, blob, blob_nullable) VALUES(1, 1, 1.1, 'text1', X'626C6F6231', X'F09F90A7');";
        var errmsg: [*c]u8 = null;
        const rc = sqliteExec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.log.err("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "INSERT INTO test (uint64, integer, float, text, blob) VALUES(2, 2, 2.2, 'text2', X'626C6F6232');";
        var errmsg: [*c]u8 = null;
        const rc = sqliteExec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.log.err("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //--------------------------------------------------------------------------------
        var results: [*c][*c]u8 = undefined;
        var row_count: i32 = 0;
        var column_count: i32 = 0;
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const sql = "SELECT * FROM test;";
        const rc = sqliteGetTable(
            db_handle,
            sql,
            &results,
            &row_count,
            &column_count,
            &errmsg,
        );
        //----------------------------------------
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.log.err("sqliteGetTable: {s}\n", .{errmsg});
            return @intCast(rc);
        }
        //----------------------------------------
        defer sqliteFreeTable(results);
        //----------------------------------------
        const _row_count: usize = @intCast(row_count);
        const _columns_count: usize = @intCast(column_count);
        //----------------------------------------
        const column_cells = _row_count * _columns_count;
        const total_cells = column_cells + _columns_count;
        try ut.compareInteger("sqliteGetTable: row_count", _row_count, 2, .{ .src = @src() });
        try ut.compareInteger("sqliteGetTable: columns_count", _columns_count, 7, .{ .src = @src() });
        try ut.compareInteger("sqliteGetTable: column_cells", column_cells, 14, .{ .src = @src() });
        try ut.compareInteger("sqliteGetTable: total_cells", total_cells, 21, .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[0], "id", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[1], "uint64", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[2], "integer", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[3], "float", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[4], "text", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[5], "blob", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[6], "blob_nullable", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[7], "1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[8], "1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[9], "1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[10], "1.1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[11], "text1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[12], "blob1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[13], "\xF0\x9F\x90\xA7", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[14], "2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[15], "2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[16], "2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[17], "2.2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[18], "text2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[19], "blob2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[20], "", .{ .src = @src() });
        //--------------------------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        const sql = "SELECT * FROM test;";
        var errmsg: [*c]u8 = null;
        const rc = sqliteExec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.log.err("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    {
        const sql = "SELECT * FROM test;";
        var errmsg: [*c]u8 = null;
        const rc = querySQLiteColumns(
            db_handle,
            sql,
            &queryCallback,
            &context,
            &errmsg,
        );
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.log.err("querySQLiteColumns: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    // try ut.printLine();
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        var errmsg: [*c]u8 = null;
        var stmt_handle: ?*anyopaque = null;
        //------------------------------------------------------------
        const sql = "INSERT INTO test (uint64, integer, float, text, blob) VALUES(?, ?, ?, ?, ?);";
        //----------------------------
        errmsg = null;
        var rc = sqlitePrepare(db_handle, sql, &stmt_handle, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.log.err("sqlitePrepare: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        defer _ = sqliteFinalize(stmt_handle);
        //------------------------------------------------------------
        const uint64 = 0xFFFF_FFFF_FFFF_FFFF;
        const integer = 3;
        const float = 3.3;
        const text = "text3";
        const blob = "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7";
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqliteBindUInt64(
                stmt_handle,
                1,
                uint64,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqliteBindInt64(
                stmt_handle,
                2,
                integer,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqliteBindDouble(
                stmt_handle,
                3,
                float,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqliteBindText(
                stmt_handle,
                4,
                text.ptr,
                @intCast(text.len),
                null,
            );
        }
        //------------------------------------------------------------
        // used to testing - will be overridden later
        if (rc == c.SQLITE_OK) {
            rc = sqliteBindNull(
                stmt_handle,
                5,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqliteBindBlob(
                stmt_handle,
                5,
                blob.ptr,
                blob.len,
                null,
            );
        }
        //------------------------------------------------------------
        if (rc != c.SQLITE_OK) {
            std.log.err("sqliteBind: ({d}) {s}\n", .{ rc, sqliteErrmsg(db_handle) });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        if (sqliteStep(stmt_handle) != c.SQLITE_DONE) {
            std.log.err("sqliteStep: ({d}) {s}\n", .{ rc, sqliteErrmsg(db_handle) });
            return @intCast(rc);
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        var errmsg: [*c]u8 = null;
        var stmt_handle: ?*anyopaque = null;
        //------------------------------------------------------------
        const sql = "SELECT * FROM test;";
        //------------------------------------------------------------
        errmsg = null;
        var rc = sqlitePrepare(db_handle, sql, &stmt_handle, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.log.err("sqlitePrepare: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        defer _ = sqliteFinalize(stmt_handle);
        //------------------------------------------------------------
        const column_count: usize = @intCast(sqliteColumnCount(stmt_handle));
        //----------------------------------------
        const expected_column_count = 7;
        try ut.compareInteger("sqliteColumnCount", column_count, expected_column_count, .{ .src = @src() });
        //------------------------------------------------------------
        var row: usize = 0;
        //----------------------------------------
        while (true) {
            //------------------------------------------------------------
            rc = sqliteStep(stmt_handle);
            //------------------------------------------------------------
            if (rc == c.SQLITE_ROW) {
                //------------------------------------------------------------
                const id: i64 = sqliteColumnInt64(stmt_handle, 0);
                const uint64: u64 = sqliteColumnUInt64(stmt_handle, 1);
                const integer: i64 = sqliteColumnInt64(stmt_handle, 2);
                const float: f64 = sqliteColumnDouble(stmt_handle, 3);
                const text: [*c]const u8 = sqliteColumnText(stmt_handle, 4);
                //----------------------------------------
                var blob: []const u8 = "NULL";
                if (sqliteColumnBlob(stmt_handle, 5)) |raw| {
                    const ptr: [*]const u8 = @ptrCast(raw);
                    const len: usize = @intCast(sqliteColumnBytes(stmt_handle, 5));
                    blob = ptr[0..len];
                } else {}
                //----------------------------------------
                const unsigned_uint64 = isUnsigned(stmt_handle, 1);
                const unsigned_integer = isUnsigned(stmt_handle, 2);
                //----------------------------------------
                if (row == 2) {
                    //----------------------------------------
                    try ut.compareInteger("sqliteBindInt64/sqliteColumnInt64", id, 3, .{ .src = @src() });
                    try ut.compareInteger("sqliteBindUInt64/sqliteColumnUInt64", uint64, 0xFFFF_FFFF_FFFF_FFFF, .{ .src = @src() });
                    try ut.compareInteger("sqliteBindInt64/sqliteColumnInt64", integer, 3, .{ .src = @src() });
                    try ut.compareFloat("sqliteBindDouble/sqliteColumnDouble", 3.3, float, .{ .src = @src() });
                    try ut.compareCString("sqliteBindText/sqliteColumnText", text, "text3", .{ .src = @src() });
                    try ut.compareStringSlice("sqliteBindNull/sqliteBindBlob/sqliteColumnBlob", blob, "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", .{ .src = @src() });
                    //----------------------------------------
                    try ut.compareBool("isUnsigned", unsigned_uint64, true, .{ .src = @src() });
                    try ut.compareBool("isUnsigned", unsigned_integer, false, .{ .src = @src() });
                    //----------------------------------------
                }
                //---------------------------
                row += 1;
                //------------------------------------------------------------
            } else if (rc == c.SQLITE_DONE) {
                //----------------------------------------
                break;
                //----------------------------------------
            } else {
                //----------------------------------------
                std.log.err("{s}\n", .{sqliteErrmsg(db_handle)});
                return @intCast(rc);
                //----------------------------------------
            }
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        var errmsg: [*c]u8 = null;
        const row_count = getRowCount(db_handle, "test", &errmsg);
        if (errmsg != null) {
            defer sqliteFree(errmsg);
            return c.SQLITE_ERROR;
        }
        try ut.compareInteger("getRowCount", row_count, 3, .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    {
        var errmsg: [*c]u8 = null;
        const column_count = getColumnCount(db_handle, "test", &errmsg);
        if (errmsg != null) {
            defer sqliteFree(errmsg);
            std.log.err("getColumnCount: {s}\n", .{errmsg.?});
            return c.SQLITE_ERROR;
        }
        try ut.compareInteger("getColumnCount", column_count, 7, .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const sql = "SELECT * FROM test;";
        //------------------------------------------------------------
        var table_context: ?*anyopaque = null;
        var sqlite_columns: [*c]SQLiteColumn = null;
        var row_count: i32 = 0;
        var column_count: i32 = 0;
        var errmsg: [*c]u8 = null;
        //------------------------------------------------------------
        const rc = getSQLiteColumnsTable(
            db_handle,
            sql,
            &table_context,
            &sqlite_columns,
            &row_count,
            &column_count,
            &errmsg,
        );
        defer freeSQLiteColumnsTable(table_context);
        //------------------------------------------------------------
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.log.err("getSQLiteColumnsTable: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        try ut.compareInteger("getSQLiteColumnsTable: row_count", row_count, 3, .{ .src = @src() });
        try ut.compareInteger("getSQLiteColumnsTable: column_count", column_count, 7, .{ .src = @src() });
        //------------------------------------------------------------
        if (row_count < 2) {
            std.log.err("invalid row_count", .{});
        } else {
            //------------------------------------------------------------
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[0].index, 0, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: id", sqlite_columns[0].name, "id", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[0].integer, 1, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: uint64", sqlite_columns[1].index, 1, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: uint64", sqlite_columns[1].name, "uint64", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: uint64", sqlite_columns[1].integer, 1, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[2].index, 2, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: integer", sqlite_columns[2].name, "integer", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[2].integer, 1, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: float", sqlite_columns[3].index, 3, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: float", sqlite_columns[3].name, "float", .{ .src = @src() });
            try ut.compareFloat("getSQLiteColumnsTable: float", 1.1, sqlite_columns[3].float, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: text", sqlite_columns[4].index, 4, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: text", sqlite_columns[4].name, "text", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: text", sqlite_columns[4].ptr[0..@intCast(sqlite_columns[4].len)], "text1", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: blob", sqlite_columns[5].index, 5, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob", sqlite_columns[5].name, "blob", .{ .src = @src() });
            if (sqlite_columns[5].column_type == .SQLITE_NULL) {
                try ut.compareStringSlice("getSQLiteColumnsTable: blob", "", "", .{ .src = @src() });
            } else {
                try ut.compareStringSlice("getSQLiteColumnsTable: blob", sqlite_columns[5].ptr[0..@intCast(sqlite_columns[5].len)], "blob1", .{ .src = @src() });
            }

            try ut.compareInteger("getSQLiteColumnsTable: blob_nullable", sqlite_columns[6].index, 6, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob_nullable", sqlite_columns[6].name, "blob_nullable", .{ .src = @src() });
            if (sqlite_columns[6].column_type == .SQLITE_NULL) {
                try ut.compareStringSlice("blob_nullable", "", "", .{ .src = @src() });
            } else {
                try ut.compareStringSlice("getSQLiteColumnsTable: blob_nullable", sqlite_columns[6].ptr[0..@intCast(sqlite_columns[6].len)], "\xF0\x9F\x90\xA7", .{ .src = @src() });
            }
            //------------------------------------------------------------
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[7].index, 0, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: id", sqlite_columns[7].name, "id", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[7].integer, 2, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: uint64", sqlite_columns[8].index, 1, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: uint64", sqlite_columns[8].name, "uint64", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: uint64", sqlite_columns[8].integer, 2, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[9].index, 2, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: integer", sqlite_columns[9].name, "integer", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[9].integer, 2, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: float", sqlite_columns[10].index, 3, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: float", sqlite_columns[10].name, "float", .{ .src = @src() });
            try ut.compareFloat("getSQLiteColumnsTable: float", 2.2, sqlite_columns[10].float, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: test", sqlite_columns[11].index, 4, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: test", sqlite_columns[11].name, "text", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: test", sqlite_columns[11].ptr[0..@intCast(sqlite_columns[11].len)], "text2", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: blob", sqlite_columns[12].index, 5, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob", sqlite_columns[12].name, "blob", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: blob", sqlite_columns[12].ptr[0..@intCast(sqlite_columns[12].len)], "blob2", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: blob_nullable", sqlite_columns[13].index, 6, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob_nullable", sqlite_columns[13].name, "blob_nullable", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: blob_nullable", sqlite_columns[13].ptr[0..@intCast(sqlite_columns[13].len)], "", .{ .src = @src() });
            //------------------------------------------------------------
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[14].index, 0, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: id", sqlite_columns[14].name, "id", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[14].integer, 3, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: uint64", sqlite_columns[15].index, 1, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: uint64", sqlite_columns[15].name, "uint64", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: uint64", @as(u64, @bitCast(sqlite_columns[15].integer)), 0xFFFF_FFFF_FFFF_FFFF, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[16].index, 2, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: integer", sqlite_columns[16].name, "integer", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[16].integer, 3, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: float", sqlite_columns[17].index, 3, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: float", sqlite_columns[17].name, "float", .{ .src = @src() });
            try ut.compareFloat("getSQLiteColumnsTable: float", 3.3, sqlite_columns[17].float, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: text", sqlite_columns[18].index, 4, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: text", sqlite_columns[18].name, "text", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: text", sqlite_columns[18].ptr[0..@intCast(sqlite_columns[18].len)], "text3", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: blob", sqlite_columns[19].index, 5, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob", sqlite_columns[19].name, "blob", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: blob", sqlite_columns[19].ptr[0..@intCast(sqlite_columns[19].len)], "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: blob_nullable", sqlite_columns[20].index, 6, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob_nullable", sqlite_columns[20].name, "blob_nullable", .{ .src = @src() });
            if (sqlite_columns[20].column_type == .SQLITE_NULL) {
                try ut.compareStringSlice("blob_nullable", "", "", .{ .src = @src() });
            } else {
                try ut.compareStringSlice("getSQLiteColumnsTable: blob_nullable", sqlite_columns[20].ptr[0..@intCast(sqlite_columns[20].len)], "", .{ .src = @src() });
            }
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        sqliteClose(db_handle);
        // std.debug.print("database closed\n", .{});
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    // CONTEXT CHECKS (should work after database closed)
    //--------------------------------------------------------------------------------
    const name = context.string_rows.items[0].name;
    const value = context.string_rows.items[0].value;

    try ut.compareStringSlice("sqliteExec/execCallback", name, "journal_mode", .{ .src = @src() });
    try ut.compareStringSlice("sqliteExec/execCallback", value, "wal", .{ .src = @src() });
    //--------------------------------------------------------------------------------
    if (context.fixed_rows.items.len >= 2) {
        //----------------------------------------------------------------------
        var fixed_rows: FixedRow = undefined;

        fixed_rows = context.fixed_rows.items[0];

        try ut.compareInteger("querySQLiteColumns/queryCallback", fixed_rows.id, 1, .{ .src = @src() });
        try ut.compareInteger("querySQLiteColumns/queryCallback", fixed_rows.uint64, 1, .{ .src = @src() });
        try ut.compareInteger("querySQLiteColumns/queryCallback", fixed_rows.integer, 1, .{ .src = @src() });
        try ut.compareFloat("querySQLiteColumns/queryCallback", 1.1, fixed_rows.float, .{ .src = @src() });
        try ut.compareStringSlice("querySQLiteColumns/queryCallback", fixed_rows.text, "text1", .{ .src = @src() });
        try ut.compareStringSlice("querySQLiteColumns/queryCallback", fixed_rows.blob, "blob1", .{ .src = @src() });

        if (fixed_rows.blob_nullable == null) {
            try ut.fail("querySQLiteColumns/queryCallback (fixed_rows)", "expected a blob but got null", .{ .src = @src() });
        } else {
            try ut.compareStringSlice("querySQLiteColumns/queryCallback", fixed_rows.blob_nullable.?, "\xF0\x9F\x90\xA7", .{ .src = @src() });
        }

        fixed_rows = context.fixed_rows.items[1];

        try ut.compareInteger("querySQLiteColumns/queryCallback", fixed_rows.id, 2, .{ .src = @src() });
        try ut.compareInteger("querySQLiteColumns/queryCallback", fixed_rows.uint64, 2, .{ .src = @src() });
        try ut.compareInteger("querySQLiteColumns/queryCallback", fixed_rows.integer, 2, .{ .src = @src() });
        try ut.compareStringSlice("querySQLiteColumns/queryCallback", fixed_rows.text, "text2", .{ .src = @src() });
        try ut.compareFloat("querySQLiteColumns/queryCallback", 2.2, fixed_rows.float, .{ .src = @src() });
        try ut.compareStringSlice("querySQLiteColumns/queryCallback", fixed_rows.blob, "blob2", .{ .src = @src() });

        if (fixed_rows.blob_nullable == null) {
            try ut.compareNull("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.blob_nullable, .{ .src = @src() });
        } else {
            try ut.fail("querySQLiteColumns/queryCallback (fixed_rows)", "expected a null", .{ .src = @src() });
        }

        //----------------------------------------------------------------------
    } else {
        //----------------------------------------------------------------------
        std.debug.print("\n", .{});
        std.log.err("!!! newCallback error !!!", .{});
        std.debug.print("\n", .{});
        //----------------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    try ut.printSummary();
    //--------------------------------------------------------------------------------
    return c.SQLITE_OK;
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn execCallback(
    ctx: ?*anyopaque,
    argc: i32,
    argv: [*c][*c]u8,
    azColName: [*c][*c]u8,
) callconv(.c) i32 {
    //----------------------------------------
    var context: *Context = undefined;
    //----------------------------------------
    // optional context pointer - null if not used
    if (ctx) |ctx_ptr| {
        //----------------------------------------
        context = @ptrCast(@alignCast(ctx_ptr));
        //----------------------------------------
        var string_column = StringsColumn{};
        const name = std.mem.span(azColName[0]);
        const value = std.mem.span(azColName[1]);
        //----------------------------------------
        string_column.name = context.allocator.dupe(u8, name) catch return c.SQLITE_ERROR;
        string_column.value = context.allocator.dupe(u8, value) catch return c.SQLITE_ERROR;
        //----------------------------------------
        context.string_rows.append(context.allocator, string_column) catch return c.SQLITE_ERROR;
        //----------------------------------------
    }
    //----------------------------------------
    for (0..@intCast(argc)) |i| {
        //----------------------------------------
        if (argv[i] == null) {
            std.debug.print("{s} = NULL | ", .{azColName[i]});
        } else {
            std.debug.print("{s} = {s} | ", .{ azColName[i], argv[i] });
            //----------------------------------------
        }
    }
    //----------------------------------------
    std.debug.print("\n", .{});
    //----------------------------------------
    return c.SQLITE_OK;
    //----------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn queryCallback(
    ctx: ?*anyopaque,
    columns: [*]SQLiteColumn,
    column_count: i32,
) callconv(.c) i32 {
    //----------------------------------------
    var context: *Context = undefined;
    //----------------------------------------
    // optional context pointer - null if not used
    if (ctx) |ctx_ptr| {
        context = @ptrCast(@alignCast(ctx_ptr));
    } else {
        std.log.err("invalid context", .{});
        return c.SQLITE_ERROR;
    }
    //----------------------------------------
    var current_row = FixedRow{};
    //----------------------------------------
    for (columns[0..@intCast(column_count)]) |column| {
        //----------------------------------------
        const name = std.mem.span(column.name);
        //----------------------------------------
        if (std.meta.stringToEnum(FixedRowColumnType, name)) |fixed_column| {
            switch (fixed_column) {
                .id => current_row.id = @intCast(column.integer),
                .uint64 => current_row.uint64 = @bitCast(column.integer),
                .integer => current_row.integer = column.integer,
                .float => current_row.float = column.float,
                .text => {
                    if (column.len > 0) current_row.text = context.allocator.dupe(u8, column.ptr[0..@intCast(column.len)]) catch return c.SQLITE_ERROR;
                },
                .blob => {
                    if (column.len > 0) current_row.blob = context.allocator.dupe(u8, column.ptr[0..@intCast(column.len)]) catch return c.SQLITE_ERROR;
                },
                .blob_nullable => {
                    if (column.len > 0) current_row.blob_nullable = context.allocator.dupe(u8, column.ptr[0..@intCast(column.len)]) catch return c.SQLITE_ERROR;
                },
            }
        } else {
            std.log.warn("unknown column type: {s}", .{name});
        }
        //----------------------------------------
    }
    //----------------------------------------
    context.fixed_rows.append(context.allocator, current_row) catch return c.SQLITE_ERROR;
    //----------------------------------------
    return c.SQLITE_OK;
    //----------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
extern fn checkTableName(table_name: [*c]const u8) bool;
//--------------------------------------------------------------------------------
extern fn getSQLiteColumnsTable(db_handle: ?*anyopaque, sql: [*c]const u8, table_context: *?*anyopaque, sqlite_columns: *[*c]SQLiteColumn, row_count: *i32, column_count: *i32, errmsg: [*c][*c]u8) callconv(.c) i32;
extern fn freeSQLiteColumnsTable(table_context: ?*anyopaque) callconv(.c) void;
extern fn querySQLiteColumns(db_handle: ?*anyopaque, sql: [*c]const u8, callback: ?*const fn (?*anyopaque, [*]SQLiteColumn, i32) callconv(.c) i32, ctx: ?*anyopaque, errmsg: [*c][*c]u8) callconv(.c) i32;
extern fn updateSQLiteColumn(stmt_handle: ?*anyopaque, iCol: i32, column: *SQLiteColumn) callconv(.c) i32;
extern fn isUnsigned(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) bool;
extern fn getRowCount(db_handle: ?*anyopaque, table_name: [*c]const u8, errmsg: [*c][*c]u8) callconv(.c) i32;
extern fn getColumnCount(db_handle: ?*anyopaque, table_name: [*c]const u8, errmsg: [*c][*c]u8) callconv(.c) i32;
//--------------------------------------------------------------------------------
extern fn sqliteClearBindings(stmt_handle: ?*anyopaque) callconv(.c) i32;
extern fn sqliteBindBlob(stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i32, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) i32;
extern fn sqliteBindBlobUInt64(stmt_handle: ?*anyopaque, iCol: i32, uint64: u64, buffer: ?*[8]u8) callconv(.c) i32;
extern fn sqliteBindDouble(stmt_handle: ?*anyopaque, iCol: i32, float: f64) callconv(.c) i32;
extern fn sqliteBindInt(stmt_handle: ?*anyopaque, iCol: i32, int32: i32) callconv(.c) i32;
extern fn sqliteBindInt64(stmt_handle: ?*anyopaque, iCol: i32, int64: i64) callconv(.c) i32;
extern fn sqliteBindUInt64(stmt_handle: ?*anyopaque, iCol: i32, uint64: u64) callconv(.c) i32;
extern fn sqliteBindNull(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32;
extern fn sqliteBindText(stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i32, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) i32;
extern fn sqliteClose(db_handle: ?*anyopaque) callconv(.c) void;
extern fn sqliteColumnBlob(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8;
extern fn sqliteColumnBlobUInt64(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) u64;
extern fn sqliteColumnBytes(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32;
extern fn sqliteColumnCount(stmt_handle: ?*anyopaque) callconv(.c) i32;
extern fn sqliteColumnDouble(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) f64;
extern fn sqliteColumnInt(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32;
extern fn sqliteColumnInt64(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i64;
extern fn sqliteColumnText(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8;
extern fn sqliteColumnType(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32;
extern fn sqliteColumnUInt64(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) u64;
extern fn sqliteDataCount(stmt_handle: ?*anyopaque) callconv(.c) i32;
extern fn sqliteColumnDecltype(stmt_handle: ?*anyopaque, iCol: i32) [*c]const u8;
extern fn sqliteErrmsg(db_handle: ?*anyopaque) callconv(.c) [*c]const u8;
extern fn sqliteExec(db_handle: ?*anyopaque, sql: [*c]const u8, callback: ?*const fn (?*anyopaque, i32, [*c][*c]u8, [*c][*c]u8) callconv(.c) i32, ctx: ?*anyopaque, errmsg: [*c][*c]u8) callconv(.c) i32;
extern fn sqliteFinalize(stmt_handle: ?*anyopaque) callconv(.c) i32;
extern fn sqliteFree(ptr: ?*anyopaque) callconv(.c) void;
extern fn sqliteFreeTable(results: [*c][*c]u8) callconv(.c) void;
extern fn sqliteGetTable(db_handle: ?*anyopaque, sql: [*c]const u8, results: [*c][*c][*c]u8, row_count: [*c]i32, column_count: [*c]i32, errmsg: [*c][*c]u8) callconv(.c) i32;
extern fn sqliteMalloc64(len: u64) callconv(.c) ?*anyopaque;
extern fn sqliteOpen(filepath: [*:0]const u8, db_handle: *?*anyopaque) callconv(.c) i32;
extern fn sqlitePrepare(db_handle: ?*anyopaque, sql: [*c]const u8, stmt_handle: *?*anyopaque, errmsg: [*c][*c]u8) callconv(.c) i32;
extern fn sqliteRealloc64(ptr: ?*anyopaque, len: u64) callconv(.c) ?*anyopaque;
extern fn sqliteReset(stmt_handle: ?*anyopaque) callconv(.c) i32;
extern fn sqliteStep(stmt_handle: ?*anyopaque) callconv(.c) i32;
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
