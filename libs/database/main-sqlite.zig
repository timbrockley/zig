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
    name: []u8 = "",
    value: []u8 = "",
};
//--------------------------------------------------------------------------------
const FixedRow = struct {
    id: i64 = 0,
    uint64: u64 = 0,
    integer: i64 = 0,
    float: f64 = 0,
    text: []u8 = "",
    blob: []u8 = "",
    blob_nullable: ?[]u8 = "",
};
//--------------------------------------------------------------------------------
const RowMap = std.StringHashMap(ds.SQLiteColumnValue);
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
            context.allocator.free(fixed_row.text);
            context.allocator.free(fixed_row.blob);
            if (fixed_row.blob_nullable) |b| context.allocator.free(b);
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
    var ut = try unittest.init(.{ .io = init.io, .show_passes = false, .skip_after_fail = true });
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
        std.log.err("connect: {d}: {s}\n", .{ sqlitedb.errorCode(), sqlitedb.errorMessage() });
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
        try ut.compareStringSlice("sqliteMalloc64", partial1, "ABC", .{ .src = @src() });
        try ut.compareStringSlice("sqliteMalloc64", buffer1[0..3], "ABC", .{ .src = @src() });

        const raw2 = sqlitedb.sqliteRealloc64(ptr1, len * 2);
        defer sqlitedb.sqliteFree(raw2);

        const ptr2: [*]u8 = @ptrCast(raw2);
        const buffer2 = ptr2[0..len];
        const partial2 = buffer2[0..3];
        @memcpy(partial2, "ABC");

        // std.debug.print("{s}\n", .{partial});
        try ut.compareStringSlice("sqliteRealloc64", partial2, "ABC", .{ .src = @src() });
        try ut.compareStringSlice("sqliteRealloc64", buffer2[0..3], "ABC", .{ .src = @src() });
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
        try ut.compareBool("checkTableName", false, ds.checkTableName(""), .{ .src = @src() });
        try ut.compareBool("checkTableName", false, ds.checkTableName("1"), .{ .src = @src() });
        try ut.compareBool("checkTableName", false, ds.checkTableName("#"), .{ .src = @src() });
        try ut.compareBool("checkTableName", false, ds.checkTableName("A#"), .{ .src = @src() });
        try ut.compareBool("checkTableName", false, ds.checkTableName("A-"), .{ .src = @src() });
        try ut.compareBool("checkTableName", true, ds.checkTableName("_A"), .{ .src = @src() });
        try ut.compareBool("checkTableName", true, ds.checkTableName("_1"), .{ .src = @src() });
        try ut.compareBool("checkTableName", true, ds.checkTableName("A"), .{ .src = @src() });
        try ut.compareBool("checkTableName", true, ds.checkTableName("A1_A2"), .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    // std.debug.print("database open: db_handle = {any}\n", .{sqlitedb.db_handle});
    // try ut.printLine();
    //--------------------------------------------------------------------------------
    {
        const sql = "PRAGMA journal_mode=WAL;";
        var errmsg: [*c]u8 = null;
        const rc = sqlitedb.sqliteExec(sql, execCallback, &context, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
            std.log.err("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
        try ut.printLine();
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "DROP TABLE IF EXISTS test;";
        var errmsg: [*c]u8 = null;
        const rc = sqlitedb.sqliteExec(sql, execCallback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
            std.log.err("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, uint64 INTEGER UNSIGNED DEFAULT 0 NOT NULL, integer INTEGER DEFAULT 0 NOT NULL, float REAL DEFAULT 0 NOT NULL, text VARCHAR(255) DEFAULT '' NOT NULL, blob BLOB DEFAULT '' NOT NULL, blob_nullable BLOB);";
        var errmsg: [*c]u8 = null;
        const rc = sqlitedb.sqliteExec(sql, execCallback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
            std.log.err("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "INSERT INTO test (uint64, integer, float, text, blob, blob_nullable) VALUES(1, 1, 1.1, 'text1', X'626C6F6231', X'F09F90A7');";
        var errmsg: [*c]u8 = null;
        const rc = sqlitedb.sqliteExec(sql, execCallback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
            std.log.err("sqliteExec: {s}\n", .{errmsg});
            return @intCast(rc);
        }
    }
    //--------------------------------------------------------------------------------
    {
        const sql = "INSERT INTO test (uint64, integer, float, text, blob) VALUES(2, 2, 2.2, 'text2', X'626C6F6232');";
        var errmsg: [*c]u8 = null;
        const rc = sqlitedb.sqliteExec(sql, execCallback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
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
            std.log.err("sqliteGetTable: {s}\n", .{errmsg});
            return @intCast(rc);
        }
        //----------------------------------------
        defer sqlitedb.sqliteFreeTable(results);
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

        const header_index: usize = 0;
        try ut.compareCString("sqliteGetTable", results[header_index + 0], "id", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[header_index + 1], "uint64", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[header_index + 2], "integer", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[header_index + 3], "float", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[header_index + 4], "text", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[header_index + 5], "blob", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[header_index + 6], "blob_nullable", .{ .src = @src() });
        var row_index: usize = header_index + _columns_count;
        try ut.compareCString("sqliteGetTable", results[row_index + 0], "1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 1], "1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 2], "1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 3], "1.1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 4], "text1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 5], "blob1", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 6], "\xF0\x9F\x90\xA7", .{ .src = @src() });

        row_index += _columns_count;
        try ut.compareCString("sqliteGetTable", results[row_index + 0], "2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 1], "2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 2], "2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 3], "2.2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 4], "text2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 5], "blob2", .{ .src = @src() });
        try ut.compareCString("sqliteGetTable", results[row_index + 6], "", .{ .src = @src() });
        //--------------------------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        const sql = "SELECT * FROM test;";
        var errmsg: [*c]u8 = null;
        const rc = sqlitedb.sqliteExec(sql, execCallback, null, &errmsg);
        if (rc != c.SQLITE_OK) {
            defer sqlitedb.sqliteFree(errmsg);
            std.log.err("sqliteExec: {s}\n", .{errmsg});
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

        sqlitedb.querySQLiteColumns(
            sql,
            &queryCallback,
            &context,
        ) catch {
            std.log.err("querySQLiteColumns: {d}: {s}\n", .{ sqlitedb.errorCode(), sqlitedb.errorMessage() });
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
        const sql = "INSERT INTO test (uint64, integer, float, text, blob) VALUES(?, ?, ?, ?, ?);";
        //------------------------------------------------------------
        var rc = sqlitedb.sqlitePrepare(sql, &stmt_handle);
        if (rc != c.SQLITE_OK) {
            std.log.err("sqlitePrepare: ({d}) {s}\n", .{ rc, sqlitedb.sqliteErrmsg() });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        defer _ = sqlitedb.sqliteFinalize(stmt_handle);
        //------------------------------------------------------------
        const uint64 = 0xFFFF_FFFF_FFFF_FFFF;
        const integer = 3;
        const float = 3.3;
        const text = "text3";
        const blob = "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7";
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqlitedb.sqliteBindUInt64(
                stmt_handle,
                1,
                uint64,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqlitedb.sqliteBindInt64(
                stmt_handle,
                2,
                integer,
            );
        }
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqlitedb.sqliteBindDouble(
                stmt_handle,
                3,
                float,
            );
        }
        //------------------------------------------------------------
        rc = sqlitedb.sqliteBindText(
            stmt_handle,
            4,
            text.ptr,
            @intCast(text.len),
            null,
        );
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
            std.log.err("sqliteBind: ({d}) {s}\n", .{ rc, sqlitedb.sqliteErrmsg() });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        if (sqlitedb.sqliteStep(stmt_handle) != c.SQLITE_DONE) {
            std.log.err("sqliteStep: ({d}) {s}\n", .{ rc, sqlitedb.sqliteErrmsg() });
            return @intCast(rc);
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        var stmt_handle: ?*anyopaque = null;
        //------------------------------------------------------------
        const sql = "SELECT * FROM test;";
        //------------------------------------------------------------
        var rc = sqlitedb.sqlitePrepare(sql, &stmt_handle);
        if (rc != c.SQLITE_OK) {
            std.log.err("sqlitePrepare: ({d}) {s}\n", .{ rc, sqlitedb.sqliteErrmsg() });
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
                const uint64: u64 = sqlitedb.sqliteColumnUInt64(stmt_handle, 1);
                const integer: i64 = sqlitedb.sqliteColumnInt64(stmt_handle, 2);
                const float: f64 = sqlitedb.sqliteColumnDouble(stmt_handle, 3);
                //----------------------------------------
                const text: [*c]const u8 = sqlitedb.sqliteColumnText(stmt_handle, 4);
                //----------------------------------------
                var blob: []const u8 = "NULL";
                if (sqlitedb.sqliteColumnBlob(stmt_handle, 5)) |raw| {
                    const ptr: [*]const u8 = @ptrCast(raw);
                    const len: usize = @intCast(sqlitedb.sqliteColumnBytes(stmt_handle, 5));
                    blob = ptr[0..len];
                } else {}
                //----------------------------------------
                var blob_nullable: ?[]const u8 = null;
                if (sqlitedb.sqliteColumnBlob(stmt_handle, 6)) |raw| {
                    const ptr: [*]const u8 = @ptrCast(raw);
                    const len: usize = @intCast(sqlitedb.sqliteColumnBytes(stmt_handle, 6));
                    blob_nullable = ptr[0..len];
                } else {}
                //----------------------------------------
                const unsigned_uint64 = sqlitedb.isUnsigned(stmt_handle, 1);
                const unsigned_integer = sqlitedb.isUnsigned(stmt_handle, 2);
                //----------------------------------------
                if (row == 2) {
                    //----------------------------------------
                    try ut.compareInteger("sqliteBindInt64/sqliteColumnInt64", id, 3, .{ .src = @src() });
                    try ut.compareInteger("sqliteBindUInt64/sqliteColumnUInt64", uint64, 0xFFFF_FFFF_FFFF_FFFF, .{ .src = @src() });
                    try ut.compareInteger("sqliteBindInt64/sqliteColumnInt64", integer, 3, .{ .src = @src() });
                    try ut.compareFloat("sqliteBindDouble/sqliteColumnDouble", 3.3, float, .{ .src = @src() });
                    try ut.compareCString("sqliteBindText/sqliteColumnText", text, "text3", .{ .src = @src() });
                    try ut.compareStringSlice("sqliteBindBlob/sqliteColumnBlob", blob, "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", .{ .src = @src() });
                    if (blob_nullable) |b| {
                        try ut.compareStringSlice("sqliteBindBlob/sqliteColumnBlob", b, "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", .{ .src = @src() });
                    } else {
                        try ut.compareNull("sqliteBindNull/sqliteColumnBlob", blob_nullable, .{ .src = @src() });
                    }
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
                std.log.err("{s}\n", .{sqlitedb.sqliteErrmsg()});
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
        //------------------------------------------------------------
        var stmt_handle: ?*anyopaque = null;
        //------------------------------------------------------------
        const sql = "INSERT INTO test (uint64, blob) VALUES(?, ?);";
        //------------------------------------------------------------
        var rc = sqlitedb.sqlitePrepare(sql, &stmt_handle);
        if (rc != c.SQLITE_OK) {
            std.log.err("sqlitePrepare: ({d}) {s}\n", .{ rc, sqlitedb.sqliteErrmsg() });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        defer _ = sqlitedb.sqliteFinalize(stmt_handle);
        //------------------------------------------------------------
        const uint64 = 0xF09F90A7F09F90A7;
        //------------------------------------------------------------
        if (rc == c.SQLITE_OK) {
            rc = sqlitedb.sqliteBindUInt64(
                stmt_handle,
                1,
                uint64,
            );
        }
        //------------------------------------------------------------
        var buffer: [8]u8 = undefined;
        if (rc == c.SQLITE_OK) {
            rc = sqlitedb.sqliteBindBlobUInt64(
                stmt_handle,
                2,
                uint64,
                &buffer,
            );
        }
        //------------------------------------------------------------
        if (rc != c.SQLITE_OK) {
            std.log.err("sqliteBind: ({d}) {s}\n", .{ rc, sqlitedb.sqliteErrmsg() });
            return @intCast(rc);
        }
        //------------------------------------------------------------
        if (sqlitedb.sqliteStep(stmt_handle) != c.SQLITE_DONE) {
            std.log.err("sqliteStep: ({d}) {s}\n", .{ rc, sqlitedb.sqliteErrmsg() });
            return @intCast(rc);
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        var stmt_handle: ?*anyopaque = null;
        //------------------------------------------------------------
        const sql = "SELECT * FROM test;";
        //------------------------------------------------------------
        var rc = sqlitedb.sqlitePrepare(sql, &stmt_handle);
        if (rc != c.SQLITE_OK) {
            std.log.err("sqlitePrepare: ({d}) {s}\n", .{ rc, sqlitedb.sqliteErrmsg() });
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
                const uint64: u64 = sqlitedb.sqliteColumnUInt64(stmt_handle, 1);
                const integer: i64 = sqlitedb.sqliteColumnInt64(stmt_handle, 2);
                const float: f64 = sqlitedb.sqliteColumnDouble(stmt_handle, 3);
                const text: [*c]const u8 = sqlitedb.sqliteColumnText(stmt_handle, 4);
                //----------------------------------------
                var blob: []const u8 = "NULL";
                if (sqlitedb.sqliteColumnBlob(stmt_handle, 5)) |raw| {
                    const ptr: [*]const u8 = @ptrCast(raw);
                    const len: usize = @intCast(sqlitedb.sqliteColumnBytes(stmt_handle, 5));
                    blob = ptr[0..len];
                } else {}
                //----------------------------------------
                var blob_nullable: ?[]const u8 = null;
                if (sqlitedb.sqliteColumnBlob(stmt_handle, 6)) |raw| {
                    const ptr: [*]const u8 = @ptrCast(raw);
                    const len: usize = @intCast(sqlitedb.sqliteColumnBytes(stmt_handle, 6));
                    blob_nullable = ptr[0..len];
                } else {}
                //----------------------------------------
                if (row == 2) {
                    //----------------------------------------
                    try ut.compareInteger("sqliteBindInt64/sqliteColumnInt64", id, 3, .{ .src = @src() });
                    try ut.compareInteger("sqliteBindUInt64/sqliteColumnUInt64", uint64, 0xFFFF_FFFF_FFFF_FFFF, .{ .src = @src() });
                    try ut.compareInteger("sqliteBindInt64/sqliteColumnInt64", integer, 3, .{ .src = @src() });
                    try ut.compareFloat("sqliteBindDouble/sqliteColumnDouble", 3.3, float, .{ .src = @src() });
                    try ut.compareCString("sqliteBindText/sqliteColumnText", text, "text3", .{ .src = @src() });
                    try ut.compareStringSlice("sqliteBindBlob/sqliteColumnBlob", blob, "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", .{ .src = @src() });
                    if (blob_nullable) |b| {
                        try ut.compareStringSlice("sqliteBindBlob/sqliteColumnBlob", b, "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", .{ .src = @src() });
                    } else {
                        try ut.compareNull("sqliteBindNull/sqliteColumnBlob", blob_nullable, .{ .src = @src() });
                    }
                    //----------------------------------------
                    var sqlite_row = FixedRow{};
                    //----------------------------------------
                    try sqlitedb.getSQLiteRow(context.allocator, stmt_handle, &sqlite_row);
                    //----------------------------------------
                    try ut.compareInteger("getSQLiteRow", sqlite_row.id, 3, .{ .src = @src() });
                    try ut.compareInteger("getSQLiteRow", sqlite_row.uint64, 0xFFFF_FFFF_FFFF_FFFF, .{ .src = @src() });
                    try ut.compareInteger("getSQLiteRow", sqlite_row.integer, 3, .{ .src = @src() });
                    try ut.compareFloat("getSQLiteRow", sqlite_row.float, 3.3, .{ .src = @src() });
                    try ut.compareStringSlice("getSQLiteRow", sqlite_row.text, "text3", .{ .src = @src() });
                    try ut.compareStringSlice("getSQLiteRow", sqlite_row.blob, "\xF0\x9F\x90\xA7\xF0\x9F\x90\xA7", .{ .src = @src() });
                    try ut.compareNull("getSQLiteRow", sqlite_row.blob_nullable, .{ .src = @src() });
                    //----------------------------------------
                    context.allocator.free(sqlite_row.text);
                    context.allocator.free(sqlite_row.blob);
                    if (sqlite_row.blob_nullable) |b| context.allocator.free(b);
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
                std.log.err("{s}\n", .{sqlitedb.sqliteErrmsg()});
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
        const row_count = try sqlitedb.getTableRowCount("test");
        try ut.compareInteger("getTableRowCount", row_count, 4, .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    {
        const row_count = try sqlitedb.getRowCount("SELECT * FROM test;");
        try ut.compareInteger("getRowCount", row_count, 4, .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    {
        const column_count = try sqlitedb.getColumnCount("SELECT * FROM test LIMIT 1;");
        try ut.compareInteger("getColumnCount", column_count, 7, .{ .src = @src() });
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const sql = "SELECT * FROM test;";
        //------------------------------------------------------------
        const table = sqlitedb.getSQLiteColumnsTable(
            sql,
        ) catch {
            std.log.err("getSQLiteColumnsTable: {d}: {s}\n", .{ sqlitedb.errorCode(), sqlitedb.errorMessage() });
            return c.SQLITE_ERROR;
        };
        defer sqlitedb.freeSQLiteColumnsTable(table);
        //------------------------------------------------------------
        const sqlite_columns = table.sqlite_columns.items;
        //------------------------------------------------------------
        try ut.compareInteger("getSQLiteColumnsTable: row_count", table.row_count, 4, .{ .src = @src() });
        try ut.compareInteger("getSQLiteColumnsTable: column_count", table.column_count, 7, .{ .src = @src() });
        //------------------------------------------------------------
        if (table.row_count < 2) {
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
            try ut.compareFloat("getSQLiteColumnsTable: float", sqlite_columns[5].float, 0, .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: text", sqlite_columns[4].index, 4, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: text", sqlite_columns[4].name, "text", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: text", sqlite_columns[4].ptr[0..@intCast(sqlite_columns[4].len)], "text1", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: blob", sqlite_columns[5].index, 5, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob", sqlite_columns[5].name, "blob", .{ .src = @src() });

            try ut.compareInteger("getSQLiteColumnsTable: blob_nullable", sqlite_columns[6].index, 6, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: blob_nullable", sqlite_columns[6].name, "blob_nullable", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: blob_nullable", sqlite_columns[6].ptr[0..@intCast(sqlite_columns[6].len)], "\xF0\x9F\x90\xA7", .{ .src = @src() });
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

            try ut.compareInteger("text", sqlite_columns[11].index, 4, .{ .src = @src() });
            try ut.compareCString("getSQLiteColumnsTable: text", sqlite_columns[11].name, "text", .{ .src = @src() });
            try ut.compareStringSlice("getSQLiteColumnsTable: text", sqlite_columns[11].ptr[0..@intCast(sqlite_columns[11].len)], "text2", .{ .src = @src() });

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
            try ut.compareStringSlice("getSQLiteColumnsTable: blob_nullable", sqlite_columns[20].ptr[0..@intCast(sqlite_columns[20].len)], "", .{ .src = @src() });
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    {
        sqlitedb.close();
        // std.debug.print("database closed\n", .{});
        // try ut.printLine();
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    // CONTEXT CHECKS (should work after database closed)
    //--------------------------------------------------------------------------------
    const name = context.string_columns.items[0].name;
    const value = context.string_columns.items[0].value;

    try ut.compareStringSlice("sqliteExec/execCallback", name, "journal_mode", .{ .src = @src() });
    try ut.compareStringSlice("sqliteExec/execCallback", value, "wal", .{ .src = @src() });
    //--------------------------------------------------------------------------------
    if (context.fixed_rows.items.len >= 2) {
        //----------------------------------------------------------------------
        var fixed_rows: FixedRow = undefined;

        fixed_rows = context.fixed_rows.items[0];

        try ut.compareInteger("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.id, 1, .{ .src = @src() });
        try ut.compareInteger("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.uint64, 1, .{ .src = @src() });
        try ut.compareInteger("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.integer, 1, .{ .src = @src() });
        try ut.compareFloat("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.float, 1.1, .{ .src = @src() });
        try ut.compareStringSlice("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.text, "text1", .{ .src = @src() });
        try ut.compareStringSlice("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.blob, "blob1", .{ .src = @src() });

        if (fixed_rows.blob_nullable == null) {
            try ut.fail("querySQLiteColumns/queryCallback (fixed_rows)", "expected a blob but got null", .{ .src = @src() });
        } else {
            try ut.compareStringSlice("querySQLiteColumns/queryCallback", fixed_rows.blob_nullable.?, "\xF0\x9F\x90\xA7", .{ .src = @src() });
        }

        fixed_rows = context.fixed_rows.items[1];

        try ut.compareInteger("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.id, 2, .{ .src = @src() });
        try ut.compareInteger("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.uint64, 2, .{ .src = @src() });
        try ut.compareInteger("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.integer, 2, .{ .src = @src() });
        try ut.compareFloat("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.float, 2.2, .{ .src = @src() });
        try ut.compareStringSlice("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.text, "text2", .{ .src = @src() });
        try ut.compareStringSlice("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.blob, "blob2", .{ .src = @src() });

        if (fixed_rows.blob_nullable == null) {
            try ut.compareNull("querySQLiteColumns/queryCallback (fixed_rows)", fixed_rows.blob_nullable, .{ .src = @src() });
        } else {
            try ut.fail("querySQLiteColumns/queryCallback (fixed_rows)", "expected a null", .{ .src = @src() });
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

        try ut.compareInteger("querySQLiteColumns/queryCallback (row_maps)", (row_map.get("id").?).integer, 1, .{ .src = @src() });
        try ut.compareInteger("querySQLiteColumns/queryCallback (row_maps)", (row_map.get("uint64").?).uint64, 1, .{ .src = @src() });
        try ut.compareInteger("querySQLiteColumns/queryCallback (row_maps)", (row_map.get("integer").?).integer, 1, .{ .src = @src() });
        try ut.compareFloat("querySQLiteColumns/queryCallback (row_maps)", (row_map.get("float").?).float, 1.1, .{ .src = @src() });
        try ut.compareStringSlice("querySQLiteColumns/queryCallback (row_maps)", (row_map.get("text").?).string, "text1", .{ .src = @src() });

        switch (row_map.get("blob").?) {
            .bytes => |b| try ut.compareByteSlice("querySQLiteColumns/queryCallback (row_maps)", "blob1", b, .{ .src = @src() }),
            else => try ut.fail("querySQLiteColumns/queryCallback (row_maps)", "expected bytes", .{ .src = @src() }),
        }

        switch (row_map.get("blob_nullable").?) {
            .bytes => |b| try ut.compareByteSlice("querySQLiteColumns/queryCallback (row_maps)", "\xF0\x9F\x90\xA7", b, .{ .src = @src() }),
            else => try ut.fail("querySQLiteColumns/queryCallback (row_maps)", "expected bytes", .{ .src = @src() }),
        }

        row_map = context.row_maps.items[1];

        try ut.compareInteger("querySQLiteColumns/queryCallback (row_maps)", (row_map.get("id").?).integer, 2, .{ .src = @src() });
        try ut.compareInteger("querySQLiteColumns/queryCallback (row_maps)", (row_map.get("uint64").?).uint64, 2, .{ .src = @src() });
        try ut.compareInteger("querySQLiteColumns/queryCallback (row_maps)", (row_map.get("integer").?).integer, 2, .{ .src = @src() });
        try ut.compareFloat("querySQLiteColumns/queryCallback (row_maps)", (row_map.get("float").?).float, 2.2, .{ .src = @src() });
        try ut.compareStringSlice("querySQLiteColumns/queryCallback (row_maps)", (row_map.get("text").?).string, "text2", .{ .src = @src() });

        switch (row_map.get("blob").?) {
            .bytes => |b| try ut.compareByteSlice("querySQLiteColumns/queryCallback (row_maps)", "blob2", b, .{ .src = @src() }),
            else => try ut.fail("querySQLiteColumns/queryCallback (row_maps)", "expected bytes", .{ .src = @src() }),
        }

        switch (row_map.get("blob_nullable").?) {
            .null => try ut.compareNull("querySQLiteColumns/queryCallback (row_maps)", null, .{ .src = @src() }),
            else => try ut.fail("querySQLiteColumns/queryCallback (row_maps)", "expected a null", .{ .src = @src() }),
        }

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
pub fn queryCallback(
    ctx: ?*anyopaque,
    columns_ptr: [*]ds.SQLiteColumn,
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
    for (columns_ptr[0..@intCast(column_count)]) |column| {
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
    }
    //----------------------------------------
    std.debug.print("\n", .{});
    //----------------------------------------
    var current_row = FixedRow{};
    //----------------------------------------
    ds.updateRow(
        context.allocator,
        &current_row,
        columns_ptr[0..@intCast(column_count)],
    ) catch return c.SQLITE_ERROR;
    //----------------------------------------
    context.fixed_rows.append(context.allocator, current_row) catch return c.SQLITE_ERROR;
    //----------------------------------------
    var row = RowMap.init(context.allocator);
    //----------------------------------------
    ds.updateRowMap(
        context.allocator,
        &row,
        columns_ptr[0..@intCast(column_count)],
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
