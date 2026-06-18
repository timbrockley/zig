//--------------------------------------------------------------------------------
const std = @import("std");
const c = @cImport({
    @cInclude("sqlite3.h");
});
//--------------------------------------------------------------------------------
const unittest = @import("libs/unittest.zig");
const ls = @import("libsqlite.zig");
//--------------------------------------------------------------------------------
const DATABASE_FILEPATH = "test-sqlite.db";
//--------------------------------------------------------------------------------
const StringsColumn = struct {
    name: []const u8 = "",
    value: []const u8 = "",
};
//--------------------------------------------------------------------------------
const FixedRowColumnType = enum { id, value1, value2, integer, float, blobby };
const FixedRow = struct {
    id: i64 = 0,
    value1: []const u8 = "",
    value2: []const u8 = "",
    integer: i64 = 0,
    float: f64 = 0,
    blobby: []const u8 = "",
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
            context.allocator.free(fixed_row.blobby);
        }
        context.fixed_rows.deinit(context.allocator);
    }
};
//--------------------------------------------------------------------------------
pub fn main(init: std.process.Init) !u8 {
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    const filepath = DATABASE_FILEPATH;
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

        const raw1 = ls.sqliteMalloc64(len);
        // defer ls.sqliteFree(raw1);

        const ptr1: [*]u8 = @ptrCast(raw1);
        const buffer1 = ptr1[0..len];
        const partial1 = buffer1[0..3];
        @memcpy(partial1, "ABC");

        // std.debug.print("{s}\n", .{partial});
        try ut.compareStringSlice("sqliteMalloc64", "ABC", partial1);
        try ut.compareStringSlice("sqliteMalloc64", "ABC", buffer1[0..3]);

        const raw2 = ls.sqliteRealloc64(ptr1, len * 2);
        defer ls.sqliteFree(raw2);

        const ptr2: [*]u8 = @ptrCast(raw2);
        const buffer2 = ptr2[0..len];
        const partial2 = buffer2[0..3];
        @memcpy(partial2, "ABC");

        // std.debug.print("{s}\n", .{partial});
        try ut.compareStringSlice("sqliteRealloc64", "ABC", partial2);
        try ut.compareStringSlice("sqliteRealloc64", "ABC", buffer2[0..3]);
    }
    //--------------------------------------------------------------------------------
    {
        const len: usize = 32;

        var ptr1 = ls.allocateBytes(len);
        // defer ls.freeBytes(ptr1);

        const buffer1 = ptr1[0..len];
        const partial1 = buffer1[0..3];
        @memcpy(partial1, "123");

        // std.debug.print("{s}\n", .{partial});
        try ut.compareStringSlice("allocateBytes", "123", partial1);
        try ut.compareStringSlice("allocateBytes", "123", buffer1[0..3]);

        // reallocate memory
        const ptr2 = ls.reallocateBytes(ptr1, len * 2);
        defer ls.freeBytes(ptr2);

        const buffer2 = ptr2[0..len];
        const partial2 = buffer2[0..3];
        @memcpy(partial2, "ABC");

        try ut.compareStringSlice("reallocateBytes", "ABC", partial2);
        try ut.compareStringSlice("reallocateBytes", "ABC", buffer2[0..3]);
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        var errmsg: [*c]u8 = null;
        const rc = ls.sqliteOpen(filepath, &db_handle, &errmsg);
        if (rc != c.SQLITE_OK or db_handle == null) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("failed to open database: ({d}) {s}\n", .{ rc, errmsg });
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
        const rc = ls.sqliteExec(db_handle, sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("sqliteExec error: {s}\n", .{errmsg});
            return @intCast(rc);
        }

        try ut.printLine();
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "DROP TABLE IF EXISTS test;";
        var errmsg: [*c]u8 = null;
        const rc = ls.sqliteExec(db_handle, sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("sqliteExec error: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, value1 VARCHAR(255) DEFAULT '' NOT NULL, value2 VARCHAR(255) DEFAULT '' NOT NULL, integer INTEGER DEFAULT 0 NOT NULL, float REAL DEFAULT 0 NOT NULL, blobby BLOB);";
        var errmsg: [*c]u8 = null;
        const rc = ls.sqliteExec(db_handle, sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("sqliteExec error: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "INSERT INTO test (value1, integer) VALUES('value1', 1);";
        var errmsg: [*c]u8 = null;
        const rc = ls.sqliteExec(db_handle, sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("sqliteExec error: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "INSERT INTO test (value2, float, blobby) VALUES('value2', 2.2, X'F09F90A7');";
        var errmsg: [*c]u8 = null;
        const rc = ls.sqliteExec(db_handle, sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("sqliteExec error: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        var results: [*c][*c]u8 = undefined;
        var row_count: c_int = 0;
        var column_count: c_int = 0;

        var errmsg: [*c]u8 = null;
        const sql = "SELECT * FROM test;";
        const rc = ls.sqliteGetTable(
            db_handle,
            sql,
            &results,
            &row_count,
            &column_count,
            &errmsg,
        );

        if (rc != c.SQLITE_OK) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("sqliteGetTable error: {s}\n", .{errmsg});
            return @intCast(rc);
        }

        defer ls.sqliteFreeTable(results);

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
        try ut.compareInt("sqliteGetTable: row_count", 2, _row_count);
        try ut.compareInt("sqliteGetTable: columns_count", 6, _columns_count);
        try ut.compareInt("sqliteGetTable: column_cells", 12, column_cells);
        try ut.compareInt("sqliteGetTable: total_cells", 18, total_cells);
        try ut.compareCString("sqliteGetTable", "id", results[0]);
        try ut.compareCString("sqliteGetTable", "value1", results[1]);
        try ut.compareCString("sqliteGetTable", "value2", results[2]);
        try ut.compareCString("sqliteGetTable", "integer", results[3]);
        try ut.compareCString("sqliteGetTable", "float", results[4]);
        try ut.compareCString("sqliteGetTable", "blobby", results[5]);
        try ut.compareCString("sqliteGetTable", "1", results[6]);
        try ut.compareCString("sqliteGetTable", "value1", results[7]);
        try ut.compareCString("sqliteGetTable", "", results[8]);
        try ut.compareCString("sqliteGetTable", "1", results[9]);
        try ut.compareCString("sqliteGetTable", "0.0", results[10]);
        try ut.compareCString("sqliteGetTable", "", results[11]);
        try ut.compareCString("sqliteGetTable", "2", results[12]);
        try ut.compareCString("sqliteGetTable", "", results[13]);
        try ut.compareCString("sqliteGetTable", "value2", results[14]);
        try ut.compareCString("sqliteGetTable", "0", results[15]);
        try ut.compareCString("sqliteGetTable", "2.2", results[16]);
        try ut.compareCString("sqliteGetTable", "\xF0\x9F\x90\xA7", results[17]);
        //--------------------------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        const sql = "SELECT * FROM test;";
        var errmsg: [*c]u8 = null;
        const rc = ls.sqliteExec(db_handle, sql, callback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("sqliteExec error: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    try ut.printLine();
    //--------------------------------------------------------------------------------
    {
        var row: ?[*]ls.SQLiteColumn = null;
        defer if (row) |row_ptr| {
            c.sqlite3_free(row_ptr);
        };

        var column_count: usize = 0;

        const sql = "SELECT * FROM test;";
        var errmsg: [*c]u8 = null;
        const rc = ls.sqliteQuery(
            db_handle,
            sql,
            &row,
            &column_count,
            &newCallback,
            &context,
            &errmsg,
        );
        if (rc != c.SQLITE_OK) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("sqliteQuery error: ({d}) {s}\n", .{ rc, errmsg });
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
        const sql = "INSERT INTO test (value1, value2, integer, float, blobby) VALUES(?, ?, ?, ?, ?);";
        //------------------------------------------------------------
        errmsg = null;
        var rc = ls.sqlitePrepare(db_handle, sql, &stmt_handle, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("sqlitePrepare error: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        defer _ = ls.sqliteFinalize(stmt_handle);
        //------------------------------------------------------------
        const value1 = "new_value1";
        const value2 = "new_value2";
        const integer = 3;
        const float = 3.3;
        const blobby = "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7";
        //------------------------------------------------------------
        rc = ls.sqliteBindText(
            stmt_handle,
            1,
            value1.ptr,
            @intCast(value1.len),
            c.SQLITE_TRANSIENT,
        );
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = ls.sqliteBindText(
                stmt_handle,
                2,
                value2.ptr,
                @intCast(value2.len),
                c.SQLITE_TRANSIENT,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = ls.sqliteBindInt64(
                stmt_handle,
                3,
                integer,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = ls.sqliteBindDouble(
                stmt_handle,
                4,
                float,
            );
        }
        //------------------------------------------------------------
        // used to testing - will be overridden later
        if (rc == c.SQLITE_OK) {
            rc = ls.sqliteBindNull(
                stmt_handle,
                5,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = ls.sqliteBindBlob(
                stmt_handle,
                5,
                blobby.ptr,
                blobby.len,
                c.SQLITE_TRANSIENT,
            );
        }
        //------------------------------------------------------------
        if (rc != c.SQLITE_OK) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("sqliteBind error: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        if (ls.sqliteStep(stmt_handle) != c.SQLITE_DONE) {
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
        var rc = ls.sqlitePrepare(db_handle, sql, &stmt_handle, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("sqlitePrepare error: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        defer _ = ls.sqliteFinalize(stmt_handle);
        //------------------------------------------------------------
        const column_count: usize = @intCast(ls.sqliteColumnCount(stmt_handle));
        //----------------------------------------
        const expected_column_count = 6;
        try ut.compareInt("sqliteColumnCount", expected_column_count, column_count);
        //------------------------------------------------------------
        var row: usize = 0;
        //----------------------------------------
        while (true) {
            //------------------------------------------------------------
            rc = ls.sqliteStep(stmt_handle);
            //------------------------------------------------------------
            if (rc == c.SQLITE_ROW) {
                //------------------------------------------------------------
                // for (0..column_count) |index| {
                //     //------------------------------------------------------------
                //     const iCol: c_int = @intCast(index);
                //------------------------------------------------------------
                const id: i64 = ls.sqliteColumnInt64(stmt_handle, 0);
                const value1: [*c]const u8 = ls.sqliteColumnText(stmt_handle, 1);
                const value2: [*c]const u8 = ls.sqliteColumnText(stmt_handle, 2);
                const integer: i64 = ls.sqliteColumnInt64(stmt_handle, 3);
                const float: f64 = ls.sqliteColumnDouble(stmt_handle, 4);
                //----------------------------------------
                var blobby: []const u8 = "NULL";
                if (ls.sqliteColumnBlob(stmt_handle, 5)) |raw| {
                    const ptr: [*]const u8 = @ptrCast(raw);
                    const len: usize = @intCast(ls.sqliteColumnBytes(stmt_handle, 5));
                    blobby = ptr[0..len];
                } else {}
                //----------------------------------------
                std.debug.print("id: {d}, ", .{id});
                std.debug.print("value1: {s}, ", .{value1});
                std.debug.print("value2: {s}, ", .{value2});
                std.debug.print("integer: {d}, ", .{integer});
                std.debug.print("float: {d}, ", .{float});
                std.debug.print("blobby: {s}\n", .{blobby});
                //----------------------------------------
                if (row == 2) {
                    //----------------------------------------
                    try ut.printLine();
                    try ut.compareInt("sqliteBindInt64/sqliteColumnInt64", 3, @intCast(id));
                    try ut.compareStringSlice("sqliteBindText/sqliteColumnText", "new_value1", std.mem.span(value1));
                    try ut.compareStringSlice("sqliteBindText/sqliteColumnText", "new_value2", std.mem.span(value2));
                    try ut.compareInt("sqliteBindInt64/sqliteColumnInt64", 3, @intCast(integer));
                    try ut.compareFloat("sqliteBindDouble/sqliteColumnDouble", 3.3, float);
                    try ut.compareStringSlice("sqliteBindNull/sqliteBindBlob/sqliteColumnBlob", "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", blobby);
                    //----------------------------------------
                }
                //---------------------------
                row += 1;
                //-------------------------------------------------------------------------
                // }
                //------------------------------------------------------------
            } else if (rc == c.SQLITE_DONE) {
                //----------------------------------------
                break;
                //----------------------------------------
            } else {
                //----------------------------------------
                std.debug.print("{s}\n", .{ls.sqliteErrmsg(db_handle)});
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
        const row_count = ls.getRowCount(db_handle, "test", &errmsg);
        if (errmsg != null) {
            defer ls.sqliteFree(errmsg);
            return 1;
        }
        try ut.compareInt("getRowCount", 3, row_count);
    }
    //--------------------------------------------------------------------------------
    {
        var errmsg: ?[*:0]u8 = null;
        const column_count = ls.getColumnCount(db_handle, "test", &errmsg);
        if (errmsg != null) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("getColumnCount error: {s}\n", .{errmsg.?});
            return 1;
        }
        try ut.compareInt("getColumnCount", 6, column_count);
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const table_name = "test;";

        var ctx = ls.SQLiteColumnsContext{};
        defer ls.sqliteColumnsDeinit(&ctx);

        var errmsg: [*c]u8 = null;
        const rc = ls.getTableColumns(
            db_handle,
            table_name,
            &ctx,
            &errmsg,
        );
        if (rc != c.SQLITE_OK) {
            defer ls.sqliteFree(errmsg);
            std.debug.print("getTableColumns error: ({d}) {s}\n", .{ rc, errmsg });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        try ut.compareInt("getTableColumns: row_count", 3, @intCast(ctx.row_count));
        try ut.compareInt("getTableColumns: column_count", 6, @intCast(ctx.column_count));
        //------------------------------------------------------------
        if (ctx.row_count < 2) {
            std.log.err("invalid row_count", .{});
        } else {
            //------------------------------------------------------------
            const columns = ctx.sqlite_columns.?;
            //------------------------------------------------------------
            for (0..ctx.row_count) |row_index| {
                //----------------------------------------
                for (0..ctx.column_count) |column_index| {
                    //----------------------------------------
                    const table_index = row_index * ctx.column_count + column_index;

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

            const sqlite_columns = ctx.sqlite_columns.?;

            try ut.compareInt("getTableColumns: id", 0, @intCast(sqlite_columns[0].index));
            try ut.compareCString("getTableColumns: id", "id", sqlite_columns[0].name);
            try ut.compareInt("getTableColumns: id", 1, @intCast(sqlite_columns[0].integer));

            try ut.compareInt("getTableColumns: value1", 1, @intCast(sqlite_columns[1].index));
            try ut.compareCString("getTableColumns: value1", "value1", sqlite_columns[1].name);
            try ut.compareStringSlice("getTableColumns: value1", "value1", sqlite_columns[1].ptr[0..sqlite_columns[1].len]);

            try ut.compareInt("getTableColumns: value2", 2, @intCast(sqlite_columns[2].index));
            try ut.compareCString("getTableColumns: value2", "value2", sqlite_columns[2].name);
            try ut.compareStringSlice("getTableColumns: value2", "", sqlite_columns[2].ptr[0..sqlite_columns[2].len]);

            try ut.compareInt("getTableColumns: integer", 3, @intCast(sqlite_columns[3].index));
            try ut.compareCString("getTableColumns: integer", "integer", sqlite_columns[3].name);
            try ut.compareInt("getTableColumns: integer", 1, @intCast(sqlite_columns[3].integer));

            try ut.compareInt("getTableColumns: float", 4, @intCast(sqlite_columns[4].index));
            try ut.compareCString("getTableColumns: float", "float", sqlite_columns[4].name);
            try ut.compareFloat("getTableColumns: float", 0, sqlite_columns[4].float);

            try ut.compareInt("getTableColumns: blobby", 5, @intCast(sqlite_columns[5].index));
            try ut.compareCString("getTableColumns: blobby", "blobby", sqlite_columns[5].name);
            if (sqlite_columns[5].column_type == .SQLITE_NULL) {
                try ut.pass("getTableColumns: blobby", "");
            } else {
                try ut.compareStringSlice("getTableColumns: blobby", "", sqlite_columns[5].ptr[0..sqlite_columns[5].len]);
            }

            //------------------------------------------------------------

            try ut.compareInt("getTableColumns: id", 0, @intCast(sqlite_columns[6].index));
            try ut.compareCString("getTableColumns: id", "id", sqlite_columns[6].name);
            try ut.compareInt("getTableColumns: id", 2, @intCast(sqlite_columns[6].integer));

            try ut.compareInt("getTableColumns: value1", 1, @intCast(sqlite_columns[7].index));
            try ut.compareCString("getTableColumns: value1", "value1", sqlite_columns[7].name);
            try ut.compareStringSlice("getTableColumns: value1", "", sqlite_columns[7].ptr[0..sqlite_columns[7].len]);

            try ut.compareInt("getTableColumns: value2", 2, @intCast(sqlite_columns[8].index));
            try ut.compareCString("getTableColumns: value2", "value2", sqlite_columns[8].name);
            try ut.compareStringSlice("getTableColumns: value2", "value2", sqlite_columns[8].ptr[0..sqlite_columns[8].len]);

            try ut.compareInt("getTableColumns: integer", 3, @intCast(sqlite_columns[9].index));
            try ut.compareCString("getTableColumns: integer", "integer", sqlite_columns[9].name);
            try ut.compareInt("getTableColumns: integer", 0, @intCast(sqlite_columns[9].integer));

            try ut.compareInt("getTableColumns: float", 4, @intCast(sqlite_columns[10].index));
            try ut.compareCString("getTableColumns: float", "float", sqlite_columns[10].name);
            try ut.compareFloat("getTableColumns: float", 2.2, sqlite_columns[10].float);

            try ut.compareInt("getTableColumns: blobby", 5, @intCast(sqlite_columns[11].index));
            try ut.compareCString("getTableColumns: blobby", "blobby", sqlite_columns[11].name);
            try ut.compareStringSlice("getTableColumns: blobby", "\xF0\x9F\x90\xA7", sqlite_columns[11].ptr[0..sqlite_columns[11].len]);

            //------------------------------------------------------------

            try ut.compareInt("getTableColumns: id", 0, @intCast(sqlite_columns[12].index));
            try ut.compareCString("getTableColumns: id", "id", sqlite_columns[12].name);
            try ut.compareInt("getTableColumns: id", 3, @intCast(sqlite_columns[12].integer));

            try ut.compareInt("getTableColumns: value1", 1, @intCast(sqlite_columns[13].index));
            try ut.compareCString("getTableColumns: value1", "value1", sqlite_columns[13].name);
            try ut.compareStringSlice("getTableColumns: value1", "new_value1", sqlite_columns[13].ptr[0..sqlite_columns[13].len]);

            try ut.compareInt("getTableColumns: value2", 2, @intCast(sqlite_columns[14].index));
            try ut.compareCString("getTableColumns: value2", "value2", sqlite_columns[14].name);
            try ut.compareStringSlice("getTableColumns: value2", "new_value2", sqlite_columns[14].ptr[0..sqlite_columns[14].len]);

            try ut.compareInt("getTableColumns: integer", 3, @intCast(sqlite_columns[15].index));
            try ut.compareCString("getTableColumns: integer", "integer", sqlite_columns[15].name);
            try ut.compareInt("getTableColumns: integer", 3, @intCast(sqlite_columns[15].integer));

            try ut.compareInt("getTableColumns: float", 4, @intCast(sqlite_columns[16].index));
            try ut.compareCString("getTableColumns: float", "float", sqlite_columns[16].name);
            try ut.compareFloat("getTableColumns: float", 3.3, sqlite_columns[16].float);

            try ut.compareInt("getTableColumns: blobby", 5, @intCast(sqlite_columns[17].index));
            try ut.compareCString("getTableColumns: blobby", "blobby", sqlite_columns[17].name);
            try ut.compareStringSlice("getTableColumns: blobby", "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", sqlite_columns[17].ptr[0..sqlite_columns[17].len]);

            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        ls.sqliteClose(db_handle);
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

    try ut.compareStringSlice("sqliteExec/callback", "journal_mode", name);
    try ut.compareStringSlice("sqliteExec/callback", "wal", value);
    //--------------------------------------------------------------------------------
    if (context.fixed_rows.items.len >= 2) {
        //----------------------------------------------------------------------
        var fixed_rows: FixedRow = undefined;

        fixed_rows = context.fixed_rows.items[0];

        try ut.compareInt("sqliteQuery/newCallback", 1, @intCast(fixed_rows.id));
        try ut.compareStringSlice("sqliteQuery/newCallback", "value1", fixed_rows.value1);
        try ut.compareStringSlice("sqliteQuery/newCallback", "", fixed_rows.value2);
        try ut.compareInt("sqliteQuery/newCallback", 1, @intCast(fixed_rows.integer));
        try ut.compareFloat("sqliteQuery/newCallback", 0, fixed_rows.float);
        try ut.compareStringSlice("sqliteQuery/newCallback", "", fixed_rows.blobby);

        fixed_rows = context.fixed_rows.items[1];

        try ut.compareInt("sqliteQuery/newCallback", 2, @intCast(fixed_rows.id));
        try ut.compareStringSlice("sqliteQuery/newCallback", "", fixed_rows.value1);
        try ut.compareStringSlice("sqliteQuery/newCallback", "value2", fixed_rows.value2);
        try ut.compareInt("sqliteQuery/newCallback", 0, @intCast(fixed_rows.integer));
        try ut.compareFloat("sqliteQuery/newCallback", 2.2, fixed_rows.float);
        try ut.compareStringSlice("sqliteQuery/newCallback", "\xF0\x9F\x90\xA7", fixed_rows.blobby);
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
    columns: [*]ls.SQLiteColumn,
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
    var current_row = FixedRow{};
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
        const name = std.mem.span(column.name);
        //----------------------------------------
        if (std.meta.stringToEnum(FixedRowColumnType, name)) |fixed_column| {
            switch (fixed_column) {
                .id => current_row.id = @intCast(column.integer),
                .value1 => current_row.value1 = context.allocator.dupe(u8, column.ptr[0..column.len]) catch return c.SQLITE_ERROR,
                .value2 => current_row.value2 = context.allocator.dupe(u8, column.ptr[0..column.len]) catch return c.SQLITE_ERROR,
                .integer => current_row.integer = column.integer,
                .float => current_row.float = column.float,
                .blobby => current_row.blobby = context.allocator.dupe(u8, column.ptr[0..column.len]) catch return c.SQLITE_ERROR,
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
