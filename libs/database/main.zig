//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const unittest = @import("libs/unittest.zig");
const c = @import("c.zig");
const ds = @import("database-sqlite.zig");
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

    string_rows: std.ArrayList(StringsColumn) = .empty,
    fixed_rows: std.ArrayList(FixedRow) = .empty,
    row_maps: std.ArrayList(RowMap) = .empty,

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
            if (fixed_row.blob_optional) |b| context.allocator.free(b);
        }
        context.fixed_rows.deinit(context.allocator);

        for (context.row_maps.items) |*row| {
            var it = row.iterator();
            while (it.next()) |entry| {
                context.allocator.free(entry.key_ptr.*);
                switch (entry.value_ptr.*) {
                    .string => |s| context.allocator.free(s),
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
    var db = try ds.init();
    //--------------------------------------------------------------------------------
    var context = Context{ .allocator = init.gpa };
    defer context.deinit();
    //--------------------------------------------------------------------------------
    var ut = try unittest.init(.{ .io = init.io });
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        const len: usize = 32;

        const raw1 = db.sqliteMalloc64(len);
        // defer db.sqliteFree(raw1);

        const ptr1: [*]u8 = @ptrCast(raw1);
        const buffer1 = ptr1[0..len];
        const partial1 = buffer1[0..3];
        @memcpy(partial1, "ABC");

        // std.debug.print("{s}\n", .{partial});
        try ut.compareStringSlice("malloc64", "ABC", partial1);
        try ut.compareStringSlice("malloc64", "ABC", buffer1[0..3]);

        const raw2 = db.sqliteRealloc64(ptr1, len * 2);
        defer db.sqliteFree(raw2);

        const ptr2: [*]u8 = @ptrCast(raw2);
        const buffer2 = ptr2[0..len];
        const partial2 = buffer2[0..3];
        @memcpy(partial2, "ABC");

        // std.debug.print("{s}\n", .{partial});
        try ut.compareStringSlice("realloc64", "ABC", partial2);
        try ut.compareStringSlice("realloc64", "ABC", buffer2[0..3]);
    }
    //--------------------------------------------------------------------------------
    {
        const len: usize = 32;

        var ptr1 = db.allocateBytes(len);
        // defer db.freeBytes(ptr1);

        const buffer1 = ptr1[0..len];
        const partial1 = buffer1[0..3];
        @memcpy(partial1, "123");

        // std.debug.print("{s}\n", .{partial});
        try ut.compareStringSlice("allocateBytes", "123", partial1);
        try ut.compareStringSlice("allocateBytes", "123", buffer1[0..3]);

        // reallocate memory
        const ptr2 = db.reallocateBytes(ptr1, len * 2);
        defer db.freeBytes(ptr2);

        const buffer2 = ptr2[0..len];
        const partial2 = buffer2[0..3];
        @memcpy(partial2, "ABC");

        try ut.compareStringSlice("reallocateBytes", "ABC", partial2);
        try ut.compareStringSlice("reallocateBytes", "ABC", buffer2[0..3]);
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    db.connect(DATABASE_FILEPATH) catch {
        std.debug.print("connect error: {d}: {s}\n", .{ db.errorCode(), db.errorMessage() });
        return c.SQLITE_ERROR;
    };
    // defer db.close();
    std.debug.print("database open: db_handle = {any}\n", .{db.db_handle});
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    {
        const sql = "PRAGMA journal_mode=WAL;";
        var errmsg: [*c]u8 = null;
        const rc = db.sqliteExec(sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer db.sqliteFree(errmsg);
            std.debug.print("sqliteExec error: {s}\n", .{errmsg});
            return @intCast(rc);
        }

        try ut.printLine();
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "DROP TABLE IF EXISTS test;";
        var errmsg: [*c]u8 = null;
        const rc = db.sqliteExec(sql, callback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer db.sqliteFree(errmsg);
            std.debug.print("sqliteExec error: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, value1 VARCHAR(255) DEFAULT '' NOT NULL, value2 VARCHAR(255) DEFAULT '' NOT NULL, integer INTEGER DEFAULT 0 NOT NULL, float REAL DEFAULT 0 NOT NULL, blob BLOB, blob_optional BLOB);";
        var errmsg: [*c]u8 = null;
        const rc = db.sqliteExec(sql, callback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer db.sqliteFree(errmsg);
            std.debug.print("sqliteExec error: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "INSERT INTO test (value1, integer) VALUES('value1', 1);";
        var errmsg: [*c]u8 = null;
        const rc = db.sqliteExec(sql, callback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer db.sqliteFree(errmsg);
            std.debug.print("sqliteExec error: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "INSERT INTO test (value2, float, blob, blob_optional) VALUES('value2', 2.2, X'F09F90A7', 'X');";
        var errmsg: [*c]u8 = null;
        const rc = db.sqliteExec(sql, callback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer db.sqliteFree(errmsg);
            std.debug.print("sqliteExec error: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //--------------------------------------------------------------------------------
        var results: [*c][*c]u8 = undefined;
        var row_count: c_int = 0;
        var column_count: c_int = 0;
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const sql = "SELECT * FROM test;";
        const rc = db.sqliteGetTable(
            sql,
            &results,
            &row_count,
            &column_count,
            &errmsg,
        );
        //----------------------------------------
        if (rc != c.SQLITE_OK) {
            defer db.sqliteFree(errmsg);
            std.debug.print("sqliteGetTable error: {s}\n", .{errmsg});
            return @intCast(rc);
        }
        //----------------------------------------
        defer db.sqliteFreeTable(results);
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
        try ut.compareInteger("sqliteGetTable: row_count", 2, _row_count);
        try ut.compareInteger("sqliteGetTable: columns_count", 7, _columns_count);
        try ut.compareInteger("sqliteGetTable: column_cells", 14, column_cells);
        try ut.compareInteger("sqliteGetTable: total_cells", 21, total_cells);

        const header_index: usize = 0;
        try ut.compareCString("sqliteGetTable", "id", results[header_index + 0]);
        try ut.compareCString("sqliteGetTable", "value1", results[header_index + 1]);
        try ut.compareCString("sqliteGetTable", "value2", results[header_index + 2]);
        try ut.compareCString("sqliteGetTable", "integer", results[header_index + 3]);
        try ut.compareCString("sqliteGetTable", "float", results[header_index + 4]);
        try ut.compareCString("sqliteGetTable", "blob", results[header_index + 5]);
        try ut.compareCString("sqliteGetTable", "blob_optional", results[header_index + 6]);
        var row_index: usize = header_index + _columns_count;
        try ut.compareCString("sqliteGetTable", "1", results[row_index + 0]);
        try ut.compareCString("sqliteGetTable", "value1", results[row_index + 1]);
        try ut.compareCString("sqliteGetTable", "", results[row_index + 2]);
        try ut.compareCString("sqliteGetTable", "1", results[row_index + 3]);
        try ut.compareCString("sqliteGetTable", "0.0", results[row_index + 4]);
        try ut.compareCString("sqliteGetTable", "", results[row_index + 5]);
        try ut.compareCString("sqliteGetTable", "", results[row_index + 6]);
        row_index += _columns_count;
        try ut.compareCString("sqliteGetTable", "2", results[row_index + 0]);
        try ut.compareCString("sqliteGetTable", "", results[row_index + 1]);
        try ut.compareCString("sqliteGetTable", "value2", results[row_index + 2]);
        try ut.compareCString("sqliteGetTable", "0", results[row_index + 3]);
        try ut.compareCString("sqliteGetTable", "2.2", results[row_index + 4]);
        try ut.compareCString("sqliteGetTable", "\xF0\x9F\x90\xA7", results[row_index + 5]);
        try ut.compareCString("sqliteGetTable", "X", results[row_index + 6]);
        //--------------------------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------

    //################################################################################
    //--------------------------------------------------------------------------------
    {
        const sql = "SELECT * FROM test;";
        var errmsg: [*c]u8 = null;
        const rc = db.sqliteExec(sql, callback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer db.sqliteFree(errmsg);
            std.debug.print("sqliteExec error: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        var row: ?[*]ds.SQLiteColumn = null;
        defer if (row) |row_ptr| {
            db.sqliteFree(row_ptr);
        };

        var column_count: usize = 0;

        const sql = "SELECT * FROM test;";

        db.queryCallback(
            sql,
            &row,
            &column_count,
            &newCallback,
            &context,
        ) catch {
            std.debug.print("queryCallback error: {d}: {s}\n", .{ db.errorCode(), db.errorMessage() });
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
        var errmsg: [*c]u8 = null;
        var stmt_handle: ?*anyopaque = null;
        //------------------------------------------------------------
        const sql = "INSERT INTO test (value1, value2, integer, float, blob) VALUES(?, ?, ?, ?, ?);";
        //------------------------------------------------------------
        errmsg = null;
        var rc = db.sqlitePrepare(sql, &stmt_handle, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer db.sqliteFree(errmsg);
            std.debug.print("sqlitePrepare error: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        defer _ = db.sqliteFinalize(stmt_handle);
        //------------------------------------------------------------
        const value1 = "new_value1";
        const value2 = "new_value2";
        const integer = 3;
        const float = 3.3;
        const blob = "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7";
        //------------------------------------------------------------
        rc = db.sqliteBindText(
            stmt_handle,
            1,
            value1.ptr,
            @intCast(value1.len),
            null,
        );
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = db.sqliteBindText(
                stmt_handle,
                2,
                value2.ptr,
                @intCast(value2.len),
                null,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = db.sqliteBindInt64(
                stmt_handle,
                3,
                integer,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = db.sqliteBindDouble(
                stmt_handle,
                4,
                float,
            );
        }
        //------------------------------------------------------------
        // used to testing - will be overridden later
        if (rc == c.SQLITE_OK) {
            rc = db.sqliteBindNull(
                stmt_handle,
                5,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = db.sqliteBindBlob(
                stmt_handle,
                5,
                blob.ptr,
                blob.len,
                null,
            );
        }
        //------------------------------------------------------------
        if (rc != c.SQLITE_OK) {
            defer db.sqliteFree(errmsg);
            std.debug.print("sqliteBind error: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        if (db.sqliteStep(stmt_handle) != c.SQLITE_DONE) {
            std.debug.print("sqliteStep error: ({d}) {s}\n", .{ rc, errmsg });
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
        var rc = db.sqlitePrepare(sql, &stmt_handle, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer db.sqliteFree(errmsg);
            std.debug.print("sqlitePrepare error: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        defer _ = db.sqliteFinalize(stmt_handle);
        //------------------------------------------------------------
        const column_count: usize = @intCast(db.sqliteColumnCount(stmt_handle));
        //----------------------------------------
        try ut.compareInteger("sqliteColumnCount", 7, column_count);
        //------------------------------------------------------------
        var row: usize = 0;
        //----------------------------------------
        while (true) {
            //------------------------------------------------------------
            rc = db.sqliteStep(stmt_handle);
            //------------------------------------------------------------
            if (rc == c.SQLITE_ROW) {
                //------------------------------------------------------------
                const id: i64 = db.sqliteColumnInt64(stmt_handle, 0);
                const value1: [*c]const u8 = db.sqliteColumnText(stmt_handle, 1);
                const value2: [*c]const u8 = db.sqliteColumnText(stmt_handle, 2);
                const integer: i64 = db.sqliteColumnInt64(stmt_handle, 3);
                const float: f64 = db.sqliteColumnDouble(stmt_handle, 4);
                //----------------------------------------
                var blob: []const u8 = "NULL";
                if (db.sqliteColumnBlob(stmt_handle, 5)) |raw| {
                    const ptr: [*]const u8 = @ptrCast(raw);
                    const len = db.sqliteColumnBytes(stmt_handle, 5);
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
                    try ut.compareInteger("sqliteBindInt64/sqliteColumnInt64", 3, id);
                    try ut.compareStringSlice("sqliteBindText/sqliteColumnText", "new_value1", std.mem.span(value1));
                    try ut.compareStringSlice("sqliteBindText/sqliteColumnText", "new_value2", std.mem.span(value2));
                    try ut.compareInteger("sqliteBindInt64/sqliteColumnInt64", 3, integer);
                    try ut.compareFloat("sqliteBindDouble/sqliteColumnDouble", 3.3, float);
                    try ut.compareStringSlice("sqliteBindNull/sqliteBindBlob/sqliteColumnBlob", "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", blob);
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
                std.debug.print("{s}\n", .{db.sqliteErrmsg()});
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
        const row_count = db.getRowCount("test", &errmsg);
        if (errmsg != null) {
            defer db.sqliteFree(errmsg);
            return 1;
        }
        try ut.compareInteger("getRowCount", 3, row_count);
    }
    //--------------------------------------------------------------------------------
    {
        var errmsg: ?[*:0]u8 = null;
        const column_count = db.getColumnCount("test", &errmsg);
        if (errmsg != null) {
            defer db.sqliteFree(errmsg);
            std.debug.print("getColumnCount error: {s}\n", .{errmsg.?});
            return 1;
        }
        try ut.compareInteger("getColumnCount", 7, column_count);
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const table_name = "test";

        var sqlite_columns_table = ds.SQLiteColumnsTable{};
        defer db.freeSQLiteColumnsTable(&sqlite_columns_table);

        db.getSQLiteColumnsTable(
            table_name,
            &sqlite_columns_table,
        ) catch {
            std.debug.print("getSQLiteColumnsTable error: {d}: {s}\n", .{ db.errorCode(), db.errorMessage() });
            return c.SQLITE_ERROR;
        };
        //------------------------------------------------------------
        try ut.compareInteger("getSQLiteColumnsTable: row_count", 3, sqlite_columns_table.row_count);
        try ut.compareInteger("getSQLiteColumnsTable: column_count", 7, sqlite_columns_table.column_count);
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
            try ut.compareInteger("getSQLiteColumnsTable: id", 0, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: id", "id", sqlite_columns[column_index].name);
            try ut.compareInteger("getSQLiteColumnsTable: id", 1, sqlite_columns[column_index].integer);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: value1", 1, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: value1", "value1", sqlite_columns[column_index].name);
            try ut.compareStringSlice("getSQLiteColumnsTable: value1", "value1", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len]);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: value2", 2, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: value2", "value2", sqlite_columns[column_index].name);
            try ut.compareStringSlice("getSQLiteColumnsTable: value2", "", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len]);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: integer", 3, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: integer", "integer", sqlite_columns[column_index].name);
            try ut.compareInteger("getSQLiteColumnsTable: integer", 1, sqlite_columns[column_index].integer);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: float", 4, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: float", "float", sqlite_columns[column_index].name);
            try ut.compareFloat("getSQLiteColumnsTable: float", 0, sqlite_columns[column_index].float);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: blob", 5, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: blob", "blob", sqlite_columns[column_index].name);
            if (sqlite_columns[column_index].column_type == .SQLITE_NULL) {
                try ut.pass("getSQLiteColumnsTable: blob", "");
            } else {
                try ut.compareStringSlice("getSQLiteColumnsTable: blob", "", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len]);
            }

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: blob_optional", 6, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: blob_optional", "blob_optional", sqlite_columns[6].name);
            if (sqlite_columns[column_index].column_type == .SQLITE_NULL) {
                try ut.pass("getSQLiteColumnsTable: blob_optional", "");
            } else {
                try ut.compareStringSlice("getSQLiteColumnsTable: blob_optional", "", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len]);
            }

            //------------------------------------------------------------

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: id", 0, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: id", "id", sqlite_columns[column_index].name);
            try ut.compareInteger("getSQLiteColumnsTable: id", 2, sqlite_columns[column_index].integer);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: value1", 1, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: value1", "value1", sqlite_columns[column_index].name);
            try ut.compareStringSlice("getSQLiteColumnsTable: value1", "", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len]);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: value2", 2, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: value2", "value2", sqlite_columns[column_index].name);
            try ut.compareStringSlice("getSQLiteColumnsTable: value2", "value2", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len]);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: integer", 3, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: integer", "integer", sqlite_columns[column_index].name);
            try ut.compareInteger("getSQLiteColumnsTable: integer", 0, sqlite_columns[column_index].integer);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: float", 4, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: float", "float", sqlite_columns[column_index].name);
            try ut.compareFloat("getSQLiteColumnsTable: float", 2.2, sqlite_columns[column_index].float);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: blob", 5, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: blob", "blob", sqlite_columns[column_index].name);
            try ut.compareStringSlice("getSQLiteColumnsTable: blob", "\xF0\x9F\x90\xA7", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len]);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: blob_optional", 6, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: blob_optional", "blob_optional", sqlite_columns[column_index].name);
            try ut.compareStringSlice("getSQLiteColumnsTable: blob_optional", "X", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len]);

            //------------------------------------------------------------

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: id", 0, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: id", "id", sqlite_columns[column_index].name);
            try ut.compareInteger("getSQLiteColumnsTable: id", 3, sqlite_columns[column_index].integer);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: value1", 1, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: value1", "value1", sqlite_columns[column_index].name);
            try ut.compareStringSlice("getSQLiteColumnsTable: value1", "new_value1", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len]);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: value2", 2, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: value2", "value2", sqlite_columns[column_index].name);
            try ut.compareStringSlice("getSQLiteColumnsTable: value2", "new_value2", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len]);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: integer", 3, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: integer", "integer", sqlite_columns[column_index].name);
            try ut.compareInteger("getSQLiteColumnsTable: integer", 3, sqlite_columns[column_index].integer);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: float", 4, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: float", "float", sqlite_columns[column_index].name);
            try ut.compareFloat("getSQLiteColumnsTable: float", 3.3, sqlite_columns[column_index].float);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: blob", 5, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: blob", "blob", sqlite_columns[column_index].name);
            try ut.compareStringSlice("getSQLiteColumnsTable: blob", "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len]);

            column_index += 1;
            try ut.compareInteger("getSQLiteColumnsTable: blob_optional", 6, sqlite_columns[column_index].index);
            try ut.compareCString("getSQLiteColumnsTable: blob_optional", "blob_optional", sqlite_columns[20].name);
            if (sqlite_columns[column_index].column_type == .SQLITE_NULL) {
                try ut.pass("getSQLiteColumnsTable: blob_optional", "");
            } else {
                try ut.compareStringSlice("getSQLiteColumnsTable: blob_optional", "", sqlite_columns[column_index].ptr[0..sqlite_columns[column_index].len]);
            }

            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        db.close();
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
    const name = context.string_rows.items[0].name;
    const value = context.string_rows.items[0].value;

    try ut.compareStringSlice("sqliteExec/callback", "journal_mode", name);
    try ut.compareStringSlice("sqliteExec/callback", "wal", value);
    //--------------------------------------------------------------------------------
    if (context.fixed_rows.items.len >= 2) {
        //----------------------------------------------------------------------
        var fixed_rows: FixedRow = undefined;

        fixed_rows = context.fixed_rows.items[0];

        try ut.compareInteger("queryCallback/newCallback (fixed_rows)", 1, fixed_rows.id);
        try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", "value1", fixed_rows.value1);
        try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", "", fixed_rows.value2);
        try ut.compareInteger("queryCallback/newCallback (fixed_rows)", 1, fixed_rows.integer);
        try ut.compareFloat("queryCallback/newCallback (fixed_rows)", 0, fixed_rows.float);
        try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", "", fixed_rows.blob);
        if (fixed_rows.blob_optional == null) {
            try ut.compareNull("queryCallback/newCallback (fixed_rows)", fixed_rows.blob_optional);
        } else {
            try ut.fail("queryCallback/newCallback (fixed_rows)", "expected a null");
        }

        fixed_rows = context.fixed_rows.items[1];

        try ut.compareInteger("queryCallback/newCallback (fixed_rows)", 2, fixed_rows.id);
        try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", "", fixed_rows.value1);
        try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", "value2", fixed_rows.value2);
        try ut.compareInteger("queryCallback/newCallback (fixed_rows)", 0, fixed_rows.integer);
        try ut.compareFloat("queryCallback/newCallback (fixed_rows)", 2.2, fixed_rows.float);
        try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", "\xF0\x9F\x90\xA7", fixed_rows.blob);
        if (fixed_rows.blob_optional == null) {
            try ut.fail("queryCallback/newCallback (fixed_rows)", "expected a string");
        } else {
            try ut.compareStringSlice("queryCallback/newCallback (fixed_rows)", "X", fixed_rows.blob_optional.?);
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

        try ut.compareInteger("queryCallback/newCallback (row_maps)", 1, (row_map.get("id").?).integer);
        try ut.compareStringSlice("queryCallback/newCallback (row_maps)", "value1", (row_map.get("value1").?).string);
        try ut.compareStringSlice("queryCallback/newCallback (row_maps)", "", (row_map.get("value2").?).string);
        try ut.compareInteger("queryCallback/newCallback (row_maps)", 1, (row_map.get("integer").?).integer);
        try ut.compareFloat("queryCallback/newCallback (row_maps)", 0, (row_map.get("float").?).float);
        switch (row_map.get("blob").?) {
            .null => try ut.compareNull("queryCallback/newCallback (row_maps)", null),
            else => try ut.fail("queryCallback/newCallback (row_maps)", "expected a null"),
        }
        switch (row_map.get("blob_optional").?) {
            .null => try ut.compareNull("queryCallback/newCallback (row_maps)", null),
            else => try ut.fail("queryCallback/newCallback (row_maps)", "expected a null"),
        }

        row_map = context.row_maps.items[1];

        try ut.compareInteger("queryCallback/newCallback (row_maps)", 2, (row_map.get("id").?).integer);
        try ut.compareStringSlice("queryCallback/newCallback (row_maps)", "", (row_map.get("value1").?).string);
        try ut.compareStringSlice("queryCallback/newCallback (row_maps)", "value2", (row_map.get("value2").?).string);
        try ut.compareInteger("queryCallback/newCallback (row_maps)", 0, (row_map.get("integer").?).integer);
        try ut.compareFloat("queryCallback/newCallback (row_maps)", 2.2, (row_map.get("float").?).float);
        switch (row_map.get("blob").?) {
            .string => |s| try ut.compareStringSlice("queryCallback/newCallback (row_maps)", "\xF0\x9F\x90\xA7", s),
            else => try ut.fail("queryCallback/newCallback (row_maps)", "expected a string"),
        }
        try ut.compareStringSlice("queryCallback/newCallback (row_maps)", "X", (row_map.get("blob_optional").?).string);
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
    argc: c_int,
    argv: [*c][*c]u8,
    azColName: [*c][*c]u8,
) callconv(.c) c_int {
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
    columns: [*]ds.SQLiteColumn,
    column_count: usize,
) callconv(.c) c_int {
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
    for (columns[0..column_count]) |column| {
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
        columns[0..column_count],
    ) catch return c.SQLITE_ERROR;
    //----------------------------------------
    context.fixed_rows.append(context.allocator, current_row) catch return c.SQLITE_ERROR;
    //----------------------------------------
    var row = RowMap.init(context.allocator);
    //----------------------------------------
    ds.updateRowMap(
        context.allocator,
        &row,
        columns[0..column_count],
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
