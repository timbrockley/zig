//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const unittest = @import("libs/unittest.zig");
const ds = @import("database-sqlite.zig");
const c = ds.c;
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
const DATABASE_FILEPATH = "test-sqlite.db";
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
const StringsColumn = struct {
    name: []const u8 = "",
    value: []const u8 = "",
};
//--------------------------------------------------------------------------------
const FixedRow = struct {
    id: i64 = 0,
    value1: []const u8 = "",
    value2: []const u8 = "",
    integer: i64 = 0,
    float: f64 = 0,
    blob: []const u8 = "",
    blob_optional: ?[]const u8 = "",
};
//--------------------------------------------------------------------------------
const RowMap = std.StringHashMap(ds.ColumnValue);
//--------------------------------------------------------------------------------
const Context = struct {
    allocator: std.mem.Allocator,

    string_columns: std.ArrayList(StringsColumn) = .empty,
    fixed_rows: std.ArrayList(FixedRow) = .empty,
    row_maps: std.ArrayList(RowMap) = .empty,

    fn deinit(context: *Context) void {
        for (context.string_columns.items) |string_row| {
            context.allocator.free(string_row.name);
            context.allocator.free(string_row.value);
        }
        context.string_columns.deinit(context.allocator);

        for (context.fixed_rows.items) |fixed_row| {
            context.allocator.free(fixed_row.value1);
            context.allocator.free(fixed_row.value2);
            context.allocator.free(fixed_row.blob);
            if (fixed_row.blob_optional) |b| context.allocator.free(b);
        }
        context.fixed_rows.deinit(context.allocator);

        for (context.row_maps.items) |*row| {
            var it = row.iterator();
            while (it.next()) |entry| {
                context.allocator.free(entry.key_ptr.*);
                switch (entry.value_ptr.*) {
                    .string => |s| context.allocator.free(s),
                    .bytes => |b| context.allocator.free(b),
                    else => {},
                }
            }
            row.deinit();
        }
        context.row_maps.deinit(context.allocator);
    }
};
//--------------------------------------------------------------------------------
//################################################################################
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
    //################################################################################
    //--------------------------------------------------------------------------------
    var sqlitedb = try ds.init();
    defer sqlitedb.deinit();
    //--------------------------------------------------------------------------------
    sqlitedb.connect(DATABASE_FILEPATH) catch {
        std.debug.print("connect: {d}: {s}\n", .{ sqlitedb.errorCode(), sqlitedb.errorMessage() });
        return c.SQLITE_ERROR;
    };
    // defer sqlitedb.close();
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        const len: usize = 32;

        const raw1 = sqlitedb.sqliteMalloc64(len);
        // defer sqlitedb.sqliteFree(raw1);

        const ptr1: [*]u8 = @ptrCast(raw1);
        const buffer1 = ptr1[0..len];
        const partial1 = buffer1[0..3];
        @memcpy(partial1, "ABC");

        // std.debug.print("{s}\n", .{partial});
        try ut.compareStringSlice("malloc64", partial1, "ABC", .{ .src = @src() });
        try ut.compareStringSlice("malloc64", buffer1[0..3], "ABC", .{ .src = @src() });

        const raw2 = sqlitedb.sqliteRealloc64(ptr1, len * 2);
        defer sqlitedb.sqliteFree(raw2);

        const ptr2: [*]u8 = @ptrCast(raw2);
        const buffer2 = ptr2[0..len];
        const partial2 = buffer2[0..3];
        @memcpy(partial2, "ABC");

        // std.debug.print("{s}\n", .{partial});
        try ut.compareStringSlice("realloc64", partial2, "ABC", .{ .src = @src() });
        try ut.compareStringSlice("realloc64", buffer2[0..3], "ABC", .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    {
        const len: usize = 32;

        var ptr1 = sqlitedb.allocateBytes(len);
        // defer sqlitedb.freeBytes(ptr1);

        const buffer1 = ptr1[0..len];
        const partial1 = buffer1[0..3];
        @memcpy(partial1, "123");

        // std.debug.print("{s}\n", .{partial});
        try ut.compareStringSlice("allocateBytes", partial1, "123", .{ .src = @src() });
        try ut.compareStringSlice("allocateBytes", buffer1[0..3], "123", .{ .src = @src() });

        // reallocate memory
        const ptr2 = sqlitedb.reallocateBytes(ptr1, len * 2);
        defer sqlitedb.freeBytes(ptr2);

        const buffer2 = ptr2[0..len];
        const partial2 = buffer2[0..3];
        @memcpy(partial2, "ABC");

        try ut.compareStringSlice("reallocateBytes", partial2, "ABC", .{ .src = @src() });
        try ut.compareStringSlice("reallocateBytes", buffer2[0..3], "ABC", .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        try ut.compareBool("checkTableName", false, sqlitedb.checkTableName(""), .{ .src = @src() });
        try ut.compareBool("checkTableName", false, sqlitedb.checkTableName("1"), .{ .src = @src() });
        try ut.compareBool("checkTableName", false, sqlitedb.checkTableName("#"), .{ .src = @src() });
        try ut.compareBool("checkTableName", false, sqlitedb.checkTableName("A#"), .{ .src = @src() });
        try ut.compareBool("checkTableName", false, sqlitedb.checkTableName("A-"), .{ .src = @src() });
        try ut.compareBool("checkTableName", true, sqlitedb.checkTableName("_A"), .{ .src = @src() });
        try ut.compareBool("checkTableName", true, sqlitedb.checkTableName("_1"), .{ .src = @src() });
        try ut.compareBool("checkTableName", true, sqlitedb.checkTableName("A"), .{ .src = @src() });
        try ut.compareBool("checkTableName", true, sqlitedb.checkTableName("A1_A2"), .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    std.debug.print("database open: db_handle = {any}\n", .{sqlitedb.db_handle});
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    {
        const sql = "PRAGMA journal_mode=WAL;";
        var errmsg: [*c]u8 = null;
        const rc = sqlitedb.sqliteExec(sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
            std.debug.print("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }

        try ut.printLine();
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "DROP TABLE IF EXISTS test;";
        var errmsg: [*c]u8 = null;
        const rc = sqlitedb.sqliteExec(sql, callback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
            std.debug.print("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, value1 VARCHAR(255) DEFAULT '' NOT NULL, value2 VARCHAR(255) DEFAULT '' NOT NULL, integer INTEGER DEFAULT 0 NOT NULL, float REAL DEFAULT 0 NOT NULL, blob BLOB, blob_optional BLOB);";
        var errmsg: [*c]u8 = null;
        const rc = sqlitedb.sqliteExec(sql, callback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
            std.debug.print("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "INSERT INTO test (value1, integer) VALUES('value1', 1);";
        var errmsg: [*c]u8 = null;
        const rc = sqlitedb.sqliteExec(sql, callback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
            std.debug.print("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "INSERT INTO test (value2, float, blob, blob_optional) VALUES('value2', 2.2, X'F09F90A7', 'X');";
        var errmsg: [*c]u8 = null;
        const rc = sqlitedb.sqliteExec(sql, callback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
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
        const rc = sqlitedb.sqliteGetTable(
            sql,
            &results,
            &row_count,
            &column_count,
            &errmsg,
        );
        //----------------------------------------
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
            std.debug.print("sqliteGetTable: {s}\n", .{errmsg});
            return @intCast(rc);
        }
        //----------------------------------------
        defer sqlitedb.sqliteFreeTable(results);
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
        try ut.compareInteger("sqliteGetTable: columns_count", _columns_count, 7, .{ .src = @src() });
        try ut.compareInteger("sqliteGetTable: column_cells", column_cells, 14, .{ .src = @src() });
        try ut.compareInteger("sqliteGetTable: total_cells", total_cells, 21, .{ .src = @src() });

        const header_index: usize = 0;
        try ut.compareCString("sqliteGetTable", results[header_index + 0], "id", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[header_index + 1], "value1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[header_index + 2], "value2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[header_index + 3], "integer", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[header_index + 4], "float", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[header_index + 5], "blob", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[header_index + 6], "blob_optional", .{ .src = @src() });
        var row_index: usize = header_index + _columns_count;
        try ut.compareCString("sqliteGetTable", results[row_index + 0], "1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 1], "value1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 2], "", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 3], "1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 4], "0.0", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 5], "", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 6], "", .{ .src = @src() });
        row_index += _columns_count;
        try ut.compareCString("sqliteGetTable", results[row_index + 0], "2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 1], "", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 2], "value2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 3], "0", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 4], "2.2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 5], "\xF0\x9F\x90\xA7", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 6], "X", .{ .src = @src() });
        //--------------------------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        const sql = "SELECT * FROM test;";
        var errmsg: [*c]u8 = null;
        const rc = sqlitedb.sqliteExec(sql, callback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
            std.debug.print("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        const sql = "SELECT * FROM test;";

        sqlitedb.queryCallback(
            sql,
            &newCallback,
            &context,
        ) catch {
            std.debug.print("queryCallback: {d}: {s}\n", .{ sqlitedb.errorCode(), sqlitedb.errorMessage() });
            return c.SQLITE_ERROR;
        };
    }
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        var stmt_handle: ?*anyopaque = null;
        //------------------------------------------------------------
        const sql = "INSERT INTO test (value1, value2, integer, float, blob) VALUES(?, ?, ?, ?, ?);";
        //------------------------------------------------------------
        var rc = sqlitedb.sqlitePrepare(sql, &stmt_handle);
        if (rc != c.SQLITE_OK) {
            std.debug.print("sqlitePrepare: ({d}) {s}\n", .{ rc, sqlitedb.sqliteErrmsg() });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        defer _ = sqlitedb.sqliteFinalize(stmt_handle);
        //------------------------------------------------------------
        const value1 = "new_value1";
        const value2 = "new_value2";
        const integer = 3;
        const float = 3.3;
        const blob = "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7";
        //------------------------------------------------------------
        rc = sqlitedb.sqliteBindText(
            stmt_handle,
            1,
            value1.ptr,
            @intCast(value1.len),
            null,
        );
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqlitedb.sqliteBindText(
                stmt_handle,
                2,
                value2.ptr,
                @intCast(value2.len),
                null,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqlitedb.sqliteBindInt64(
                stmt_handle,
                3,
                integer,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqlitedb.sqliteBindDouble(
                stmt_handle,
                4,
                float,
            );
        }
        //------------------------------------------------------------
        // used to testing - will be overridden later
        if (rc == c.SQLITE_OK) {
            rc = sqlitedb.sqliteBindNull(
                stmt_handle,
                5,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqlitedb.sqliteBindBlob(
                stmt_handle,
                5,
                blob.ptr,
                blob.len,
                null,
            );
        }
        //------------------------------------------------------------
        if (rc != c.SQLITE_OK) {
            std.debug.print("sqliteBind: ({d}) {s}\n", .{ rc, sqlitedb.sqliteErrmsg() });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        if (sqlitedb.sqliteStep(stmt_handle) != c.SQLITE_DONE) {
            std.debug.print("sqliteStep: ({d}) {s}\n", .{ rc, sqlitedb.sqliteErrmsg() });
            return @intCast(rc);
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        var stmt_handle: ?*anyopaque = null;
        //------------------------------------------------------------
        const sql = "SELECT * FROM test;";
        //------------------------------------------------------------
        var rc = sqlitedb.sqlitePrepare(sql, &stmt_handle);
        if (rc != c.SQLITE_OK) {
            std.debug.print("sqlitePrepare: ({d}) {s}\n", .{ rc, sqlitedb.sqliteErrmsg() });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        defer _ = sqlitedb.sqliteFinalize(stmt_handle);
        //------------------------------------------------------------
        const column_count: usize = @intCast(sqlitedb.sqliteColumnCount(stmt_handle));
        //----------------------------------------
        try ut.compareInteger("sqliteColumnCount", column_count, 7, .{ .src = @src() });
        //------------------------------------------------------------
        var row: usize = 0;
        //----------------------------------------
        while (true) {
            //------------------------------------------------------------
            rc = sqlitedb.sqliteStep(stmt_handle);
            //------------------------------------------------------------
            if (rc == c.SQLITE_ROW) {
                //------------------------------------------------------------
                const id: i64 = sqlitedb.sqliteColumnInt64(stmt_handle, 0);
                const value1: [*c]const u8 = sqlitedb.sqliteColumnText(stmt_handle, 1);
                const value2: [*c]const u8 = sqlitedb.sqliteColumnText(stmt_handle, 2);
                const integer: i64 = sqlitedb.sqliteColumnInt64(stmt_handle, 3);
                const float: f64 = sqlitedb.sqliteColumnDouble(stmt_handle, 4);
                //----------------------------------------
                var blob: []const u8 = "NULL";
                if (sqlitedb.sqliteColumnBlob(stmt_handle, 5)) |raw| {
                    const ptr: [*]const u8 = @ptrCast(raw);
                    const len = sqlitedb.sqliteColumnBytes(stmt_handle, 5);
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
                std.debug.print("{s}\n", .{sqlitedb.sqliteErrmsg()});
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
        const row_count = try sqlitedb.getRowCount("test");
        try ut.compareInteger("getRowCount", row_count, 3, .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    {
        const column_count = try sqlitedb.getColumnCount("test");
        try ut.compareInteger("getColumnCount", column_count, 7, .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const table_name = "test";

        var sqlite_columns_table = ds.SQLiteColumnsTable{};
        defer sqlitedb.freeSQLiteColumnsTable(&sqlite_columns_table);

        sqlitedb.getSQLiteColumnsTable(
            table_name,
            &sqlite_columns_table,
        ) catch {
            std.debug.print("getSQLiteColumnsTable: {d}: {s}\n", .{ sqlitedb.errorCode(), sqlitedb.errorMessage() });
            return c.SQLITE_ERROR;
        };
        //------------------------------------------------------------
        try ut.compareInteger("getSQLiteColumnsTable: row_count", sqlite_columns_table.row_count, 3, .{ .src = @src() });
        try ut.compareInteger("getSQLiteColumnsTable: column_count", sqlite_columns_table.column_count, 7, .{ .src = @src() });
        //------------------------------------------------------------
        if (sqlite_columns_table.row_count < 2) {
            std.log.err("invalid row_count", .{});
        } else {
            //------------------------------------------------------------
            const columns = sqlite_columns_table.sqlite_columns.?;
            //------------------------------------------------------------
            for (0..sqlite_columns_table.row_count) |row_index| {
                //----------------------------------------
                for (0..sqlite_columns_table.column_count) |column_index| {
                    //----------------------------------------
                    const table_index = row_index * sqlite_columns_table.column_count + column_index;

                    const column = columns[table_index];

                    if (column.column_type == .SQLITE_NULL) {
                        std.debug.print(
                            "{s} = NULL | ",
                            .{column.name},
                        );
                    } else if (column.column_type == .SQLITE_TEXT or column.column_type == .SQLITE_BLOB) {
                        std.debug.print(
                            "{s} = {s} | ",
                            .{ std.mem.span(column.name), column.ptr[0..column.len] },
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

            var column_index: usize = 0;
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[column_index].index, 0, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: id", sqlite_columns[column_index].name, "id", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[column_index].integer, 1, .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: value1", sqlite_columns[column_index].index, 1, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: value1", sqlite_columns[column_index].name, "value1", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: value1", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len], "value1", .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: value2", sqlite_columns[column_index].index, 2, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: value2", sqlite_columns[column_index].name, "value2", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: value2", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len], "", .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[column_index].index, 3, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: integer", sqlite_columns[column_index].name, "integer", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[column_index].integer, 1, .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: float", sqlite_columns[column_index].index, 4, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: float", sqlite_columns[column_index].name, "float", .{ .src = @src() });
            try ut.compareFloat("getSQLiteColumnsTable: float", 0, sqlite_columns[column_index].float, .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: blob", sqlite_columns[column_index].index, 5, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob", sqlite_columns[column_index].name, "blob", .{ .src = @src() });
            if (sqlite_columns[column_index].column_type == .SQLITE_NULL) {
                try ut.pass("getSQLiteColumnsTable: blob", "", .{ .src = @src() });
            } else {
                try ut.compareStringSlice("getSQLiteColumnsTable: blob", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len], "", .{ .src = @src() });
            }

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: blob_optional", sqlite_columns[column_index].index, 6, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob_optional", sqlite_columns[6].name, "blob_optional", .{ .src = @src() });
            if (sqlite_columns[column_index].column_type == .SQLITE_NULL) {
                try ut.pass("getSQLiteColumnsTable: blob_optional", "", .{ .src = @src() });
            } else {
                try ut.compareStringSlice("getSQLiteColumnsTable: blob_optional", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len], "", .{ .src = @src() });
            }

            //------------------------------------------------------------

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[column_index].index, 0, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: id", sqlite_columns[column_index].name, "id", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[column_index].integer, 2, .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: value1", sqlite_columns[column_index].index, 1, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: value1", sqlite_columns[column_index].name, "value1", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: value1", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len], "", .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: value2", sqlite_columns[column_index].index, 2, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: value2", sqlite_columns[column_index].name, "value2", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: value2", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len], "value2", .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[column_index].index, 3, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: integer", sqlite_columns[column_index].name, "integer", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[column_index].integer, 0, .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: float", sqlite_columns[column_index].index, 4, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: float", sqlite_columns[column_index].name, "float", .{ .src = @src() });
            try ut.compareFloat("getSQLiteColumnsTable: float", 2.2, sqlite_columns[column_index].float, .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: blob", sqlite_columns[column_index].index, 5, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob", sqlite_columns[column_index].name, "blob", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: blob", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len], "\xF0\x9F\x90\xA7", .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: blob_optional", sqlite_columns[column_index].index, 6, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob_optional", sqlite_columns[column_index].name, "blob_optional", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: blob_optional", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len], "X", .{ .src = @src() });

            //------------------------------------------------------------

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[column_index].index, 0, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: id", sqlite_columns[column_index].name, "id", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: id", sqlite_columns[column_index].integer, 3, .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: value1", sqlite_columns[column_index].index, 1, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: value1", sqlite_columns[column_index].name, "value1", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: value1", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len], "new_value1", .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: value2", sqlite_columns[column_index].index, 2, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: value2", sqlite_columns[column_index].name, "value2", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: value2", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len], "new_value2", .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[column_index].index, 3, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: integer", sqlite_columns[column_index].name, "integer", .{ .src = @src() });
            try ut.compareInteger("getSQLiteColumnsTable: integer", sqlite_columns[column_index].integer, 3, .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: float", sqlite_columns[column_index].index, 4, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: float", sqlite_columns[column_index].name, "float", .{ .src = @src() });
            try ut.compareFloat("getSQLiteColumnsTable: float", 3.3, sqlite_columns[column_index].float, .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: blob", sqlite_columns[column_index].index, 5, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob", sqlite_columns[column_index].name, "blob", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: blob", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len], "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", .{ .src = @src() });

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: blob_optional", sqlite_columns[column_index].index, 6, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob_optional", sqlite_columns[20].name, "blob_optional", .{ .src = @src() });
            if (sqlite_columns[column_index].column_type == .SQLITE_NULL) {
                try ut.pass("getSQLiteColumnsTable: blob_optional", "", .{ .src = @src() });
            } else {
                try ut.compareStringSlice("getSQLiteColumnsTable: blob_optional", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len], "", .{ .src = @src() });
            }

            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        sqlitedb.close();
        std.debug.print("database closed\n", .{});
    }
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    try ut.stderr_writeAll("\nCONTEXT CHECKS (should work after database closed)\n\n");
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    const name = context.string_columns.items[0].name;
    const value = context.string_columns.items[0].value;

    try ut.compareStringSlice("sqliteExec/callback", name, "journal_mode", .{ .src = @src() });
    try ut.compareStringSlice("sqliteExec/callback", value, "wal", .{ .src = @src() });
    //--------------------------------------------------------------------------------
    if (context.fixed_rows.items.len >= 2) {
        //----------------------------------------------------------------------
        var fixed_rows: FixedRow = undefined;

        fixed_rows = context.fixed_rows.items[0];

        try ut.compareInteger("queryCallback/newCallback (fixed_rows)", fixed_rows.id, 1, .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", fixed_rows.value1, "value1", .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", fixed_rows.value2, "", .{ .src = @src() });
        try ut.compareInteger("queryCallback/newCallback (fixed_rows)", fixed_rows.integer, 1, .{ .src = @src() });
        try ut.compareFloat("queryCallback/newCallback (fixed_rows)", 0, fixed_rows.float, .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", fixed_rows.blob, "", .{ .src = @src() });
        if (fixed_rows.blob_optional == null) {
            try ut.compareNull("queryCallback/newCallback (fixed_rows)", fixed_rows.blob_optional, .{ .src = @src() });
        } else {
            try ut.fail("queryCallback/newCallback (fixed_rows)", "expected a null", .{ .src = @src() });
        }

        fixed_rows = context.fixed_rows.items[1];

        try ut.compareInteger("queryCallback/newCallback (fixed_rows)", fixed_rows.id, 2, .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", fixed_rows.value1, "", .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", fixed_rows.value2, "value2", .{ .src = @src() });
        try ut.compareInteger("queryCallback/newCallback (fixed_rows)", fixed_rows.integer, 0, .{ .src = @src() });
        try ut.compareFloat("queryCallback/newCallback (fixed_rows)", 2.2, fixed_rows.float, .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", fixed_rows.blob, "\xF0\x9F\x90\xA7", .{ .src = @src() });
        if (fixed_rows.blob_optional == null) {
            try ut.fail("queryCallback/newCallback (fixed_rows)", "expected a string", .{ .src = @src() });
        } else {
            try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", fixed_rows.blob_optional.?, "X", .{ .src = @src() });
        }

        //----------------------------------------------------------------------
    } else {
        //----------------------------------------------------------------------
        std.debug.print("\n", .{});
        std.log.err("!!! newCallback error (fixed_rows) !!!", .{});
        std.debug.print("\n", .{});
        //----------------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    if (context.row_maps.items.len >= 2) {
        //----------------------------------------------------------------------
        var row_map: RowMap = undefined;

        row_map = context.row_maps.items[0];

        try ut.compareInteger("queryCallback/newCallback (row_maps)", (row_map.get("id").?).integer, 1, .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback (row_maps)", (row_map.get("value1").?).string, "value1", .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback (row_maps)", (row_map.get("value2").?).string, "", .{ .src = @src() });
        try ut.compareInteger("queryCallback/newCallback (row_maps)", (row_map.get("integer").?).integer, 1, .{ .src = @src() });
        try ut.compareFloat("queryCallback/newCallback (row_maps)", 0, (row_map.get("float").?).float, .{ .src = @src() });
        switch (row_map.get("blob").?) {
            .null => try ut.compareNull("queryCallback/newCallback (row_maps)", null, .{ .src = @src() }),
            else => try ut.fail("queryCallback/newCallback (row_maps)", "expected a null", .{ .src = @src() }),
        }
        switch (row_map.get("blob_optional").?) {
            .null => try ut.compareNull("queryCallback/newCallback (row_maps)", null, .{ .src = @src() }),
            else => try ut.fail("queryCallback/newCallback (row_maps)", "expected a null", .{ .src = @src() }),
        }

        row_map = context.row_maps.items[1];

        try ut.compareInteger("queryCallback/newCallback (row_maps)", (row_map.get("id").?).integer, 2, .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback (row_maps)", (row_map.get("value1").?).string, "", .{ .src = @src() });
        try ut.compareStringSlice("queryCallback/newCallback (row_maps)", (row_map.get("value2").?).string, "value2", .{ .src = @src() });
        try ut.compareInteger("queryCallback/newCallback (row_maps)", (row_map.get("integer").?).integer, 0, .{ .src = @src() });
        try ut.compareFloat("queryCallback/newCallback (row_maps)", 2.2, (row_map.get("float").?).float, .{ .src = @src() });
        switch (row_map.get("blob").?) {
            .bytes => |b| try ut.compareByteSlice("queryCallback/newCallback (row_maps)", "\xF0\x9F\x90\xA7", b, .{ .src = @src() }),
            else => try ut.fail("queryCallback/newCallback (row_maps)", "expected bytes", .{ .src = @src() }),
        }
        try ut.compareStringSlice("queryCallback/newCallback (row_maps)", (row_map.get("blob_optional").?).string, "X", .{ .src = @src() });
        //----------------------------------------------------------------------
    } else {
        //----------------------------------------------------------------------
        std.debug.print("\n", .{});
        std.log.err("!!! newCallback error (row_maps) !!!", .{});
        std.debug.print("\n", .{});
        //----------------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    try ut.printSummary();
    //--------------------------------------------------------------------------------
    //################################################################################
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
        context.string_columns.append(context.allocator, string_column) catch return c.SQLITE_ERROR;
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
    columns_ptr: [*]ds.SQLiteColumn,
    column_count: usize,
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
    for (columns_ptr[0..column_count]) |column| {
        //----------------------------------------
        std.debug.print("{s} = ", .{std.mem.span(column.name)});

        if (column.column_type == .SQLITE_NULL) {
            std.debug.print("NULL | ", .{});
        } else if (column.column_type == .SQLITE_TEXT or column.column_type == .SQLITE_BLOB) {
            std.debug.print("{s} | ", .{column.ptr[0..column.len]});
        } else if (column.column_type == .SQLITE_INTEGER) {
            std.debug.print("{d} | ", .{column.integer});
        } else if (column.column_type == .SQLITE_FLOAT) {
            std.debug.print("{d} | ", .{column.float});
        } else {
            std.debug.print("UNKNOWN_COLUMN_TYPE | ", .{});
        }
        //----------------------------------------
    }
    //----------------------------------------
    std.debug.print("\n", .{});
    //----------------------------------------
    var current_row = FixedRow{};
    //----------------------------------------
    ds.updateRow(
        context.allocator,
        &current_row,
        columns_ptr[0..column_count],
    ) catch return c.SQLITE_ERROR;
    //----------------------------------------
    context.fixed_rows.append(context.allocator, current_row) catch return c.SQLITE_ERROR;
    //----------------------------------------
    var row = RowMap.init(context.allocator);
    //----------------------------------------
    ds.updateRowMap(
        context.allocator,
        &row,
        columns_ptr[0..column_count],
    ) catch return c.SQLITE_ERROR;
    //----------------------------------------
    context.row_maps.append(context.allocator, row) catch return c.SQLITE_ERROR;
    //----------------------------------------
    return c.SQLITE_OK;
    //----------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
