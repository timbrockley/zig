//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const unittest = @import("libs/unittest.zig");
const c = @import("libsqlite-sqlite3.zig");
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
const DATABASE_FILEPATH = "test-sqlite.db";
//--------------------------------------------------------------------------------
const StringsColumn = struct {
    name: []const u8 = "",
    value: []const u8 = "",
};
//--------------------------------------------------------------------------------
const FixedRowColumnType = enum { id, value1, value2, integer, float, blob };
const FixedRow = struct {
    id: i64 = 0,
    value1: []const u8 = "",
    value2: []const u8 = "",
    integer: i64 = 0,
    float: f64 = 0,
    blob: []const u8 = "",
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
            context.allocator.free(fixed_row.value1);
            context.allocator.free(fixed_row.value2);
            context.allocator.free(fixed_row.blob);
        }
        context.fixed_rows.deinit(context.allocator);
    }
};
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub const SQLiteColumnType = enum(i32) { SQLITE_UNKNOWN = 0, SQLITE_INTEGER = 1, SQLITE_FLOAT = 2, SQLITE_TEXT = 3, SQLITE_BLOB = 4, SQLITE_NULL = 5 };
//--------------------------------------------------------------------------------
pub const SQLiteColumn = extern struct {
    index: i64 = 0,
    name: [*:0]const u8 = "",
    column_type: SQLiteColumnType = .SQLITE_UNKNOWN,
    ptr: [*]const u8 = "",
    len: i64 = 0,
    integer: i64 = 0,
    float: f64 = 0,
};
//--------------------------------------------------------------------------------
pub const SQLiteColumnsTable = extern struct {
    //----------------------------------------
    sqlite_columns: ?[*]SQLiteColumn = null,
    column_data: ?[*]u8 = null,
    //----------------------------------------
    row_count: i64 = 0,
    column_count: i64 = 0,
    //----------------------------------------
};
//--------------------------------------------------------------------------------
pub fn main(init: std.process.Init) !u8 {
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    var ut = try unittest.init(.{ .io = init.io });
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
            std.debug.print("failed to open database: ({d}) {s}\n", .{ rc, sqliteErrmsg(db_handle) });
            return c.SQLITE_ERROR;
        }
        std.debug.print("database open: db_handle = {*}\n", .{db_handle});
    }
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    {
        const sql = "PRAGMA journal_mode=WAL;";
        var errmsg: [*c]u8 = null;
        const rc = sqliteExec(db_handle, sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.debug.print("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }

        try ut.printLine();
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "DROP TABLE IF EXISTS test;";
        var errmsg: [*c]u8 = null;
        const rc = sqliteExec(db_handle, sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.debug.print("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, value1 VARCHAR(255) DEFAULT '' NOT NULL, value2 VARCHAR(255) DEFAULT '' NOT NULL, integer INTEGER DEFAULT 0 NOT NULL, float REAL DEFAULT 0 NOT NULL, blob BLOB);";
        var errmsg: [*c]u8 = null;
        const rc = sqliteExec(db_handle, sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.debug.print("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "INSERT INTO test (value1, integer) VALUES('value1', 1);";
        var errmsg: [*c]u8 = null;
        const rc = sqliteExec(db_handle, sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.debug.print("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "INSERT INTO test (value2, float, blob) VALUES('value2', 2.2, X'F09F90A7');";
        var errmsg: [*c]u8 = null;
        const rc = sqliteExec(db_handle, sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.debug.print("sqliteExec: {s}\n", .{errmsg});
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
            std.debug.print("sqliteGetTable: {s}\n", .{errmsg});
            return @intCast(rc);
        }
        //----------------------------------------
        defer sqliteFreeTable(results);
        //----------------------------------------
        const _row_count: usize = @intCast(row_count);
        const _columns_count: usize = @intCast(column_count);
        //----------------------------------------
        for (0.._row_count + 1) |row_index| {
            //----------------------------------------
            for (0.._columns_count) |column_index| {
                const index: usize = row_index * _columns_count + column_index;

                const column = results[index];
                if (column != null) {
                    std.debug.print("{s} | ", .{
                        std.mem.span(column),
                    });
                } else {
                    std.debug.print("NULL | ", .{});
                }
            }
            std.debug.print("\n", .{});
            //----------------------------------------
        }
        //----------------------------------------
        try ut.printLine();
        //----------------------------------------
        const column_cells = _row_count * _columns_count;
        const total_cells = column_cells + _columns_count;
        try ut.compareInteger("sqliteGetTable: row_count", _row_count, 2, .{ .src = @src() });
        try ut.compareInteger("sqliteGetTable: columns_count", _columns_count, 6, .{ .src = @src() });
        try ut.compareInteger("sqliteGetTable: column_cells", column_cells, 12, .{ .src = @src() });
        try ut.compareInteger("sqliteGetTable: total_cells", total_cells, 18, .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[0], "id", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[1], "value1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[2], "value2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[3], "integer", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[4], "float", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[5], "blob", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[6], "1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[7], "value1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[8], "", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[9], "1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[10], "0.0", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[11], "", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[12], "2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[13], "", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[14], "value2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[15], "0", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[16], "2.2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[17], "\xF0\x9F\x90\xA7", .{ .src = @src() });
        //--------------------------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        const sql = "SELECT * FROM test;";
        var errmsg: [*c]u8 = null;
        const rc = sqliteExec(db_handle, sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.debug.print("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    {
        const sql = "SELECT * FROM test;";
        var errmsg: [*c]u8 = null;
        const rc = queryCallback(
            db_handle,
            sql,
            &newCallback,
            &context,
            &errmsg,
        );
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.debug.print("queryCallback: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        var errmsg: [*c]u8 = null;
        var stmt_handle: ?*anyopaque = null;
        //------------------------------------------------------------
        const sql = "INSERT INTO test (value1, value2, integer, float, blob) VALUES(?, ?, ?, ?, ?);";
        //----------------------------
        errmsg = null;
        var rc = sqlitePrepare(db_handle, sql, &stmt_handle, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.debug.print("sqlitePrepare: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        defer _ = sqliteFinalize(stmt_handle);
        //------------------------------------------------------------
        const value1 = "new_value1";
        const value2 = "new_value2";
        const integer = 3;
        const float = 3.3;
        const blob = "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7";
        //------------------------------------------------------------
        rc = sqliteBindText(
            stmt_handle,
            1,
            value1.ptr,
            @intCast(value1.len),
            null,
        );
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqliteBindText(
                stmt_handle,
                2,
                value2.ptr,
                @intCast(value2.len),
                null,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqliteBindInt64(
                stmt_handle,
                3,
                integer,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqliteBindDouble(
                stmt_handle,
                4,
                float,
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
            defer sqliteFree(errmsg);
            std.debug.print("sqliteBind: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        if (sqliteStep(stmt_handle) != c.SQLITE_DONE) {
            std.debug.print("sqliteStep: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
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
            std.debug.print("sqlitePrepare: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        defer _ = sqliteFinalize(stmt_handle);
        //------------------------------------------------------------
        const column_count: usize = @intCast(sqliteColumnCount(stmt_handle));
        //----------------------------------------
        const expected_column_count = 6;
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
                const value1: [*c]const u8 = sqliteColumnText(stmt_handle, 1);
                const value2: [*c]const u8 = sqliteColumnText(stmt_handle, 2);
                const integer: i64 = sqliteColumnInt64(stmt_handle, 3);
                const float: f64 = sqliteColumnDouble(stmt_handle, 4);
                //----------------------------------------
                var blob: []const u8 = "NULL";
                if (sqliteColumnBlob(stmt_handle, 5)) |raw| {
                    const ptr: [*]const u8 = @ptrCast(raw);
                    const len: usize = @intCast(sqliteColumnBytes(stmt_handle, 5));
                    blob = ptr[0..len];
                } else {}
                //----------------------------------------
                std.debug.print("id: {d}, ", .{id});
                std.debug.print("value1: {s}, ", .{value1});
                std.debug.print("value2: {s}, ", .{value2});
                std.debug.print("integer: {d}, ", .{integer});
                std.debug.print("float: {d}, ", .{float});
                std.debug.print("blob: {s}\n", .{blob});
                //----------------------------------------
                if (row == 2) {
                    //----------------------------------------
                    try ut.printLine();
                    try ut.compareInteger("sqliteBindInt64/sqliteColumnInt64", id, 3, .{ .src = @src() });
                    try ut.compareStringSlice("sqliteBindText/sqliteColumnText", std.mem.span(value1), "new_value1", .{ .src = @src() });
                    try ut.compareStringSlice("sqliteBindText/sqliteColumnText", std.mem.span(value2), "new_value2", .{ .src = @src() });
                    try ut.compareInteger("sqliteBindInt64/sqliteColumnInt64", integer, 3, .{ .src = @src() });
                    try ut.compareFloat("sqliteBindDouble/sqliteColumnDouble", 3.3, float, .{ .src = @src() });
                    try ut.compareStringSlice("sqliteBindNull/sqliteBindBlob/sqliteColumnBlob", blob, "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", .{ .src = @src() });
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
                std.debug.print("{s}\n", .{sqliteErrmsg(db_handle)});
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
        var errmsg: ?[*:0]u8 = null;
        const row_count = getRowCount(db_handle, "test", &errmsg);
        if (errmsg != null) {
            defer sqliteFree(errmsg);
            return 1;
        }
        try ut.compareInteger("getRowCount", row_count, 3, .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    {
        var errmsg: ?[*:0]u8 = null;
        const column_count = getColumnCount(db_handle, "test", &errmsg);
        if (errmsg != null) {
            defer sqliteFree(errmsg);
            std.debug.print("getColumnCount: {s}\n", .{errmsg.?});
            return 1;
        }
        try ut.compareInteger("getColumnCount", column_count, 6, .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    {
        var errmsg: ?[*:0]u8 = null;
        const total_data_bytes = getTotalColumnDataBytes(db_handle, "test", &errmsg);
        if (errmsg != null) {
            defer sqliteFree(errmsg);
            std.debug.print("getTotalColumnDataBytes: {s}\n", .{errmsg.?});
            return 1;
        }
        try ut.compareInteger("getTotalColumnDataBytes", total_data_bytes, 80, .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const table_name = "test";

        var sqlite_columns_table = SQLiteColumnsTable{};
        defer freeSQLiteColumnsTable(&sqlite_columns_table);

        var errmsg: [*c]u8 = null;
        const rc = getSQLiteColumnsTable(
            db_handle,
            table_name,
            &sqlite_columns_table,
            &errmsg,
        );
        if (rc != c.SQLITE_OK) {
            defer sqliteFree(errmsg);
            std.debug.print("getSQLiteColumnsTable: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        try ut.compareInteger("getSQLiteColumnsTable: row_count", sqlite_columns_table.row_count, 3, .{ .src = @src() });
        try ut.compareInteger("getSQLiteColumnsTable: column_count", sqlite_columns_table.column_count, 6, .{ .src = @src() });
        //------------------------------------------------------------
        if (sqlite_columns_table.row_count < 2) {
            std.log.err("invalid row_count", .{});
        } else {
            //------------------------------------------------------------
            const columns = sqlite_columns_table.sqlite_columns.?;
            const row_count: usize = @intCast(sqlite_columns_table.row_count);
            const column_count: usize = @intCast(sqlite_columns_table.column_count);
            //------------------------------------------------------------
            for (0..row_count) |row_index| {
                //----------------------------------------
                for (0..column_count) |column_index| {
                    //----------------------------------------
                    const table_index = row_index * column_count + column_index;

                    const column = columns[table_index];

                    if (column.column_type == .SQLITE_NULL) {
                        std.debug.print(
                            "{s} = NULL | ",
                            .{column.name},
                        );
                    } else if (column.column_type == .SQLITE_TEXT or column.column_type == .SQLITE_BLOB) {
                        const column_len: usize = @intCast(column.len);
                        std.debug.print(
                            "{s} = {s} | ",
                            .{ std.mem.span(column.name), column.ptr[0..column_len] },
                        );
                    } else if (column.column_type == .SQLITE_INTEGER) {
                        std.debug.print(
                            "{s} = {d} | ",
                            .{ std.mem.span(column.name), column.integer },
                        );
                    } else if (column.column_type == .SQLITE_FLOAT) {
                        std.debug.print(
                            "{s} = {d} | ",
                            .{ std.mem.span(column.name), column.float },
                        );
                    } else {
                        std.debug.print("UNKNOWN_COLUMN_TYPE | ", .{});
                    }
                    //----------------------------------------
                }
                //----------------------------------------
                std.debug.print("\n", .{});
                //----------------------------------------
            }
            //------------------------------------------------------------
            try ut.printLine();
            //------------------------------------------------------------

            const sqlite_columns = sqlite_columns_table.sqlite_columns.?;

            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[0].index, 0, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: id", sqlite_columns[0].name, "id", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[0].integer, 1, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: value1", sqlite_columns[1].index, 1, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: value1", sqlite_columns[1].name, "value1", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: value1", sqlite_columns[1].ptr[0..@intCast(sqlite_columns[1].len)], "value1", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: value2", sqlite_columns[2].index, 2, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: value2", sqlite_columns[2].name, "value2", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: value2", sqlite_columns[2].ptr[0..@intCast(sqlite_columns[2].len)], "", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[3].index, 3, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: integer", sqlite_columns[3].name, "integer", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[3].integer, 1, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: float", sqlite_columns[4].index, 4, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: float", sqlite_columns[4].name, "float", .{ .src = @src() });
            try ut.compareFloat("getSQLiteColumnsTable: float", 0, sqlite_columns[4].float, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: blob", sqlite_columns[5].index, 5, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob", sqlite_columns[5].name, "blob", .{ .src = @src() });
            if (sqlite_columns[5].column_type == .SQLITE_NULL) {
                try ut.pass("getSQLiteColumnsTable: blob", "", .{ .src = @src() });
            } else {
                try ut.compareStringSlice("getSQLiteColumnsTable: blob", sqlite_columns[5].ptr[0..@intCast(sqlite_columns[5].len)], "", .{ .src = @src() });
            }

            //------------------------------------------------------------

            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[6].index, 0, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: id", sqlite_columns[6].name, "id", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[6].integer, 2, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: value1", sqlite_columns[7].index, 1, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: value1", sqlite_columns[7].name, "value1", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: value1", sqlite_columns[7].ptr[0..@intCast(sqlite_columns[7].len)], "", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: value2", sqlite_columns[8].index, 2, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: value2", sqlite_columns[8].name, "value2", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: value2", sqlite_columns[8].ptr[0..@intCast(sqlite_columns[8].len)], "value2", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[9].index, 3, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: integer", sqlite_columns[9].name, "integer", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[9].integer, 0, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: float", sqlite_columns[10].index, 4, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: float", sqlite_columns[10].name, "float", .{ .src = @src() });
            try ut.compareFloat("getSQLiteColumnsTable: float", 2.2, sqlite_columns[10].float, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: blob", sqlite_columns[11].index, 5, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob", sqlite_columns[11].name, "blob", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: blob", sqlite_columns[11].ptr[0..@intCast(sqlite_columns[11].len)], "\xF0\x9F\x90\xA7", .{ .src = @src() });

            //------------------------------------------------------------

            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[12].index, 0, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: id", sqlite_columns[12].name, "id", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[12].integer, 3, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: value1", sqlite_columns[13].index, 1, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: value1", sqlite_columns[13].name, "value1", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: value1", sqlite_columns[13].ptr[0..@intCast(sqlite_columns[13].len)], "new_value1", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: value2", sqlite_columns[14].index, 2, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: value2", sqlite_columns[14].name, "value2", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: value2", sqlite_columns[14].ptr[0..@intCast(sqlite_columns[14].len)], "new_value2", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[15].index, 3, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: integer", sqlite_columns[15].name, "integer", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[15].integer, 3, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: float", sqlite_columns[16].index, 4, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: float", sqlite_columns[16].name, "float", .{ .src = @src() });
            try ut.compareFloat("getSQLiteColumnsTable: float", 3.3, sqlite_columns[16].float, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: blob", sqlite_columns[17].index, 5, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob", sqlite_columns[17].name, "blob", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: blob", sqlite_columns[17].ptr[0..@intCast(sqlite_columns[17].len)], "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", .{ .src = @src() });

            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        sqliteClose(db_handle);
        std.debug.print("database closed\n", .{});
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    try ut.stderr_writeAll("\nCONTEXT CHECKS (should work after database closed)\n\n");
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    const name = context.string_rows.items[0].name;
    const value = context.string_rows.items[0].value;

    try ut.compareStringSlice("sqliteExec/callback", name, "journal_mode", .{ .src = @src() });
    try ut.compareStringSlice("sqliteExec/callback", value, "wal", .{ .src = @src() });
    //--------------------------------------------------------------------------------
    if (context.fixed_rows.items.len >= 2) {
        //----------------------------------------------------------------------
        var fixed_rows: FixedRow = undefined;

        fixed_rows = context.fixed_rows.items[0];

        try ut.compareInteger("queryCallback/newCallback", fixed_rows.id, 1, .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback", fixed_rows.value1, "value1", .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback", fixed_rows.value2, "", .{ .src = @src() });
        try ut.compareInteger("queryCallback/newCallback", fixed_rows.integer, 1, .{ .src = @src() });
        try ut.compareFloat("queryCallback/newCallback", 0, fixed_rows.float, .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback", fixed_rows.blob, "", .{ .src = @src() });

        fixed_rows = context.fixed_rows.items[1];

        try ut.compareInteger("queryCallback/newCallback", fixed_rows.id, 2, .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback", fixed_rows.value1, "", .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback", fixed_rows.value2, "value2", .{ .src = @src() });
        try ut.compareInteger("queryCallback/newCallback", fixed_rows.integer, 0, .{ .src = @src() });
        try ut.compareFloat("queryCallback/newCallback", 2.2, fixed_rows.float, .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback", fixed_rows.blob, "\xF0\x9F\x90\xA7", .{ .src = @src() });
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
pub fn callback(
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
pub fn newCallback(
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
        std.debug.print("{s} = ", .{std.mem.span(column.name)});

        if (column.column_type == .SQLITE_NULL) {
            std.debug.print("NULL | ", .{});
        } else if (column.column_type == .SQLITE_TEXT or column.column_type == .SQLITE_BLOB) {
            std.debug.print("{s} | ", .{column.ptr[0..@intCast(column.len)]});
        } else if (column.column_type == .SQLITE_INTEGER) {
            std.debug.print("{d} | ", .{column.integer});
        } else if (column.column_type == .SQLITE_FLOAT) {
            std.debug.print("{d} | ", .{column.float});
        } else {
            std.debug.print("UNKNOWN_COLUMN_TYPE | ", .{});
        }
        //----------------------------------------
        const name = std.mem.span(column.name);
        //----------------------------------------
        if (std.meta.stringToEnum(FixedRowColumnType, name)) |fixed_column| {
            switch (fixed_column) {
                .id => current_row.id = @intCast(column.integer),
                .value1 => current_row.value1 = context.allocator.dupe(u8, column.ptr[0..@intCast(column.len)]) catch return c.SQLITE_ERROR,
                .value2 => current_row.value2 = context.allocator.dupe(u8, column.ptr[0..@intCast(column.len)]) catch return c.SQLITE_ERROR,
                .integer => current_row.integer = column.integer,
                .float => current_row.float = column.float,
                .blob => current_row.blob = context.allocator.dupe(u8, column.ptr[0..@intCast(column.len)]) catch return c.SQLITE_ERROR,
            }
        } else {
            std.log.warn("unknown column type: {s}", .{name});
        }
        //----------------------------------------
    }
    //----------------------------------------
    std.debug.print("\n", .{});
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
extern fn getSQLiteColumnsTable(db_handle: ?*anyopaque, table_name: [*c]const u8, table_ptr: *SQLiteColumnsTable, errmsg: *?[*:0]u8) callconv(.c) i32;
extern fn freeSQLiteColumnsTable(table_ptr: ?*SQLiteColumnsTable) callconv(.c) void;
extern fn getTotalColumnDataBytes(db_handle: ?*anyopaque, table_name: [*c]const u8, errmsg: *?[*:0]u8) callconv(.c) i64;
extern fn updateSQLiteColumn(stmt_handle: ?*anyopaque, index: i64, column: *SQLiteColumn) callconv(.c) i32;
extern fn getRowCount(db_handle: ?*anyopaque, table_name: [*c]const u8, errmsg: *?[*:0]u8) callconv(.c) i64;
extern fn getColumnCount(db_handle: ?*anyopaque, table_name: [*c]const u8, errmsg: *?[*:0]u8) callconv(.c) i64;
//--------------------------------------------------------------------------------
extern fn queryCallback(db_handle: ?*anyopaque, sql: [*c]const u8, callback: ?*const fn (?*anyopaque, [*]SQLiteColumn, i32) callconv(.c) i32, ctx: ?*anyopaque, errmsg: *?[*:0]u8) callconv(.c) i32;
//--------------------------------------------------------------------------------
extern fn sqliteClearBindings(stmt_handle: ?*anyopaque) callconv(.c) i32;
extern fn sqliteBindBlob(stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i32, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) i32;
extern fn sqliteBindDouble(stmt_handle: ?*anyopaque, iCol: i32, float: f64) callconv(.c) i32;
extern fn sqliteBindInt64(stmt_handle: ?*anyopaque, iCol: i32, integer: i64) callconv(.c) i32;
extern fn sqliteBindNull(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32;
extern fn sqliteBindText(stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i32, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) i32;
extern fn sqliteClose(db_handle: ?*anyopaque) callconv(.c) void;
extern fn sqliteColumnBlob(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8;
extern fn sqliteColumnBytes(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32;
extern fn sqliteColumnCount(stmt_handle: ?*anyopaque) callconv(.c) i32;
extern fn sqliteColumnDouble(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) f64;
extern fn sqliteColumnInt64(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i64;
extern fn sqliteColumnText(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8;
extern fn sqliteColumnType(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32;
extern fn sqliteDataCount(stmt_handle: ?*anyopaque) callconv(.c) i32;
extern fn sqliteErrmsg(db_handle: ?*anyopaque) callconv(.c) [*c]const u8;
extern fn sqliteExec(db_handle: ?*anyopaque, sql: [*c]const u8, callback: ?*const fn (?*anyopaque, i32, [*c][*c]u8, [*c][*c]u8) callconv(.c) i32, ctx: ?*anyopaque, errmsg: [*c][*c]u8) callconv(.c) i32;
extern fn sqliteFinalize(stmt_handle: ?*anyopaque) callconv(.c) i32;
extern fn sqliteFree(ptr: ?*anyopaque) callconv(.c) void;
extern fn sqliteFreeTable(results: [*c][*c]u8) callconv(.c) void;
extern fn sqliteGetTable(db_handle: ?*anyopaque, sql: [*c]const u8, results: [*c][*c][*c]u8, row_count: [*c]i32, column_count: [*c]i32, errmsg: [*c][*c]u8) callconv(.c) i32;
extern fn sqliteMalloc64(len: u64) callconv(.c) ?*anyopaque;
extern fn sqliteOpen(filepath: [*:0]const u8, db_handle: *?*anyopaque) callconv(.c) i32;
extern fn sqlitePrepare(db_handle: ?*anyopaque, sql: [*c]const u8, stmt_handle: *?*anyopaque, errmsg: *?[*:0]u8) callconv(.c) i32;
extern fn sqliteRealloc64(ptr: ?*anyopaque, len: u64) callconv(.c) ?*anyopaque;
extern fn sqliteReset(stmt_handle: ?*anyopaque) callconv(.c) i32;
extern fn sqliteStep(stmt_handle: ?*anyopaque) callconv(.c) i32;
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
