//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
//
// sudo apt install -y libsqlite3-dev
//
//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const c = @cImport({
    @cInclude("sqlite3.h");
});
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
const MAX_TABLE_NAME = 256;
//--------------------------------------------------------------------------------
const Self = @This();
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Open database at filepath location.
pub export fn sqliteOpen(
    filepath: [*:0]const u8,
    db_handle: *?*anyopaque,
) callconv(.c) i32 {
    //----------------------------------------
    var db: ?*c.sqlite3 = null;
    //----------------------------------------
    const rc = c.sqlite3_open(filepath, &db);
    //----------------------------------------
    if (rc == c.SQLITE_OK) db_handle.* = @ptrCast(db);
    //----------------------------------------
    return rc;
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Close database referred to by db_handle.
pub export fn sqliteClose(db_handle: ?*anyopaque) callconv(.c) void {
    //----------------------------------------
    if (db_handle == null) return;
    //----------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //----------------------------------------
    _ = c.sqlite3_close(db);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns last database error message.
pub export fn sqliteErrmsg(db_handle: ?*anyopaque) callconv(.c) [*c]const u8 {
    //------------------------------------------------------------
    if (db_handle == null) return "invalid db_handle";
    //----------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //----------------------------------------
    return c.sqlite3_errmsg(db);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Updates result, row_count and column_count or errmsg if an error occurs.
pub export fn sqliteGetTable(
    db_handle: ?*anyopaque,
    sql: [*c]const u8,
    results: [*c][*c][*c]u8,
    row_count: [*c]i32,
    column_count: [*c]i32,
    errmsg: [*c][*c]u8,
) callconv(.c) i32 {
    //------------------------------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //------------------------------------------------------------
    if (db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return c.SQLITE_MISUSE;
    }
    //------------------------------------------------------------
    if (sql == null or sql[0] == 0) {
        errmsg.* = c.sqlite3_mprintf("invalid sqlite query");
        return c.SQLITE_ERROR;
    }
    //------------------------------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //------------------------------------------------------------
    return c.sqlite3_get_table(db, sql, results, row_count, column_count, errmsg);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory allocated by sqliteGetTable.
pub export fn sqliteFreeTable(results: [*c][*c]u8) callconv(.c) void {
    //------------------------------------------------------------
    c.sqlite3_free_table(results);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Runs a query and runs callback function to deal with data for each row.
/// Optional context pointer can be used by callback function to maintain state.
pub export fn sqliteExec(
    db_handle: ?*anyopaque,
    sql: [*c]const u8,
    callback: ?*const fn (?*anyopaque, i32, [*c][*c]u8, [*c][*c]u8) callconv(.c) i32,
    ctx: ?*anyopaque,
    errmsg: [*c][*c]u8,
) callconv(.c) i32 {
    //------------------------------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //------------------------------------------------------------
    if (db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return c.SQLITE_MISUSE;
    }
    //------------------------------------------------------------
    if (sql == null or sql[0] == 0) {
        errmsg.* = c.sqlite3_mprintf("invalid sqlite query");
        return c.SQLITE_ERROR;
    }
    //------------------------------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //------------------------------------------------------------
    return c.sqlite3_exec(db, sql, callback, ctx, errmsg);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
// Provides a statement handle for use by calling code.
pub export fn sqlitePrepare(
    db_handle: ?*anyopaque,
    sql: [*c]const u8,
    stmt_handle: *?*anyopaque,
    errmsg: *?[*:0]u8,
) callconv(.c) i32 {
    //------------------------------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //------------------------------------------------------------
    if (db_handle == null) {
        stmt_handle.* = null;
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return c.SQLITE_MISUSE;
    }
    //------------------------------------------------------------
    if (sql == null or sql[0] == 0) {
        errmsg.* = c.sqlite3_mprintf("invalid sqlite query");
        return c.SQLITE_ERROR;
    }
    //------------------------------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //------------------------------------------------------------
    var stmt: ?*c.sqlite3_stmt = null;
    //------------------------------------------------------------
    const rc = c.sqlite3_prepare_v2(db, sql, -1, &stmt, null);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        stmt_handle.* = null;
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return rc;
    }
    //------------------------------------------------------------
    stmt_handle.* = @ptrCast(stmt.?);
    //------------------------------------------------------------
    return c.SQLITE_OK;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Clears bindings on prepared statement.
pub export fn sqliteClearBindings(stmt_handle: ?*anyopaque) callconv(.c) i32 {
    //------------------------------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_clear_bindings(stmt);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds blob data to a column.
pub export fn sqliteBindBlob(stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i64, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) i32 {
    //----------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_bind_blob(stmt, iCol, ptr, @intCast(len), destructor_function);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds text data to a column.
pub export fn sqliteBindText(stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i64, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) i32 {
    //------------------------------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_bind_text(stmt, iCol, ptr, @intCast(len), destructor_function);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds in i64 to a column.
pub export fn sqliteBindInt64(stmt_handle: ?*anyopaque, iCol: i32, integer: i64) callconv(.c) i32 {
    //------------------------------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_bind_int64(stmt, iCol, integer);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds an f64 to a column.
pub export fn sqliteBindDouble(stmt_handle: ?*anyopaque, iCol: i32, float: f64) callconv(.c) i32 {
    //------------------------------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_bind_double(stmt, iCol, float);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds a null value to a column.
pub export fn sqliteBindNull(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32 {
    //------------------------------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_bind_null(stmt, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns column name.
pub export fn sqliteColumnName(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8 {
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_column_name(stmt, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns column type.
pub export fn sqliteColumnType(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32 {
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_column_type(stmt, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a BLOB of bytes.
pub export fn sqliteColumnBlob(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8 {
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    const raw_ptr = c.sqlite3_column_blob(stmt, iCol);
    return @ptrCast(raw_ptr);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a UTF-8 text result (zero terminated).
pub export fn sqliteColumnText(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8 {
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_column_text(stmt, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns an i64 integer.
pub export fn sqliteColumnInt64(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i64 {
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_column_int64(stmt, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns an f64 float value.
pub export fn sqliteColumnDouble(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) f64 {
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_column_double(stmt, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of bytes in column.
pub export fn sqliteColumnBytes(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32 {
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_column_bytes(stmt, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns provided by statement.
pub export fn sqliteColumnCount(stmt_handle: ?*anyopaque) callconv(.c) i32 {
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_column_count(stmt);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns in current row (ONLY during SQLITE_ROW stage).
pub export fn sqliteDataCount(stmt_handle: ?*anyopaque) callconv(.c) i32 {
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_data_count(stmt);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Runs sqlite3_step using statement handle.
pub export fn sqliteStep(stmt_handle: ?*anyopaque) callconv(.c) i32 {
    //------------------------------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_step(stmt);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Resets prepared statement handle (does not clear bindings).
pub export fn sqliteReset(stmt_handle: ?*anyopaque) callconv(.c) i32 {
    //------------------------------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_reset(stmt);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Finalises prepared statement handle.
pub export fn sqliteFinalize(stmt_handle: ?*anyopaque) callconv(.c) i32 {
    //------------------------------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_finalize(stmt);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Returns a pointer to a block of memory at least N bytes.
pub export fn sqliteMalloc64(len: u64) callconv(.c) ?*anyopaque {
    //------------------------------------------------------------
    return c.sqlite3_malloc64(len);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a reallocated block of memory at least N bytes (old block freed by sqlite).
pub export fn sqliteRealloc64(ptr: ?*anyopaque, len: u64) callconv(.c) ?*anyopaque {
    //------------------------------------------------------------
    return c.sqlite3_realloc64(ptr, len);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory previously allocated using sqlite3_malloc64.
pub export fn sqliteFree(ptr: ?*anyopaque) callconv(.c) void {
    //------------------------------------------------------------
    c.sqlite3_free(ptr);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Prepares a statement then steps through each row and runs callback each time.
/// Optional context pointer can be used by callback function to maintain state.
pub export fn queryCallback(
    db_handle: ?*anyopaque,
    sql: [*c]const u8,
    callback: ?*const fn (?*anyopaque, [*]SQLiteColumn, i32) callconv(.c) i32,
    ctx: ?*anyopaque,
    errmsg: *?[*:0]u8,
) callconv(.c) i32 {
    //------------------------------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //------------------------------------------------------------
    if (db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return c.SQLITE_MISUSE;
    }
    //------------------------------------------------------------
    if (sql == null or sql[0] == 0) {
        errmsg.* = c.sqlite3_mprintf("invalid sqlite query");
        return c.SQLITE_ERROR;
    }
    //------------------------------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //------------------------------------------------------------
    var stmt: ?*c.sqlite3_stmt = null;
    //------------------------------------------------------------
    const rc = c.sqlite3_prepare_v2(db, sql, -1, &stmt, null);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return rc;
        //----------------------------------------
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt);
    //------------------------------------------------------------
    const stmt_handle: ?*anyopaque = @ptrCast(stmt.?);
    //------------------------------------------------------------
    const column_count: usize = @intCast(c.sqlite3_column_count(stmt));
    if (column_count == 0) {
        errmsg.* = c.sqlite3_mprintf("column count is zero");
        return c.SQLITE_ERROR;
    }
    //------------------------------------------------------------
    const total_bytes: u64 = @intCast(column_count * @sizeOf(SQLiteColumn));
    //------------------------------------------------------------
    const raw_ptr = c.sqlite3_malloc64(total_bytes) orelse {
        errmsg.* = c.sqlite3_mprintf("sqlite3_malloc64 failed");
        return c.SQLITE_NOMEM;
    };
    defer c.sqlite3_free(raw_ptr);
    //------------------------------------------------------------
    const columns_ptr: [*]SQLiteColumn = @ptrCast(@alignCast(raw_ptr));
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        const step_rc = c.sqlite3_step(stmt);
        //------------------------------------------------------------
        if (step_rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            if (callback) |cb| {
                //------------------------------------------------------------
                for (0..column_count) |column_index| {
                    //------------------------------------------------------------
                    columns_ptr[column_index] = .{};
                    //------------------------------------------------------------
                    const update_rc = updateSQLiteColumn(stmt_handle, @intCast(column_index), &columns_ptr[column_index]);
                    if (update_rc != c.SQLITE_OK) {
                        //----------------------------------------
                        errmsg.* = c.sqlite3_mprintf("updateSQLiteColumn error: index = %d", column_index);
                        return update_rc;
                        //----------------------------------------
                    }
                    //------------------------------------------------------------
                }
                //------------------------------------------------------------
                const return_code = cb(ctx, columns_ptr, @intCast(column_count));
                if (return_code != c.SQLITE_OK) {
                    //----------------------------------------
                    errmsg.* = c.sqlite3_mprintf("queryCallback aborted (%d)", return_code);
                    return return_code;
                    //----------------------------------------
                }
                //------------------------------------------------------------
            }
            //------------------------------------------------------------
        } else if (step_rc == c.SQLITE_DONE) {
            //----------------------------------------
            break;
            //----------------------------------------
        } else {
            //----------------------------------------
            errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
            return step_rc;
            //----------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    return c.SQLITE_OK;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Prepares a statement then steps through each row and outputs to flat array of columns.
pub export fn getSQLiteColumnsTable(
    db_handle: ?*anyopaque,
    table_name: [*c]const u8,
    table_ptr: *SQLiteColumnsTable,
    errmsg: *?[*:0]u8,
) callconv(.c) i32 {
    //------------------------------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //------------------------------------------------------------
    if (db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return c.SQLITE_MISUSE;
    }
    //------------------------------------------------------------
    if (!checkTableName(table_name)) {
        errmsg.* = c.sqlite3_mprintf("invalid table_name");
        return c.SQLITE_ERROR;
    }
    //------------------------------------------------------------
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const temp_allocator = arena_allocator.allocator();
    //------------------------------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //------------------------------------------------------------
    table_ptr.row_count = getRowCount(db_handle, table_name, errmsg);
    if (errmsg.* != null) {
        //----------------------------------------
        return c.SQLITE_ERROR;
        //----------------------------------------
    }
    //------------------------------------------------------------
    var stmt: ?*c.sqlite3_stmt = null;
    //----------------------------------------
    var buffer: [MAX_TABLE_NAME:0]u8 = undefined;
    _ = c.sqlite3_snprintf(@intCast(buffer.len), &buffer, "SELECT * FROM %s;", table_name);
    //------------------------------------------------------------
    const rc = c.sqlite3_prepare_v2(db, @as([*:0]const u8, &buffer), -1, &stmt, null);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return rc;
        //----------------------------------------
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt);
    //------------------------------------------------------------
    const stmt_handle: ?*anyopaque = @ptrCast(stmt.?);
    //------------------------------------------------------------
    table_ptr.column_count = @intCast(c.sqlite3_column_count(stmt));
    if (table_ptr.column_count == 0) return c.SQLITE_OK;
    //------------------------------------------------------------
    const total_sqlite_column_bytes: u64 = @intCast(table_ptr.row_count * table_ptr.column_count * @sizeOf(SQLiteColumn));
    //------------------------------------------------------------
    const sqlite_columns_ptr = c.sqlite3_malloc64(total_sqlite_column_bytes);
    if (sqlite_columns_ptr == null) {
        errmsg.* = c.sqlite3_mprintf("sqlite3_malloc64 failed: sqlite_columns_ptr");
        return c.SQLITE_NOMEM;
    }
    table_ptr.sqlite_columns = @ptrCast(@alignCast(sqlite_columns_ptr));
    const sqlite_columns = table_ptr.sqlite_columns.?;
    //------------------------------------------------------------
    const total_data_bytes: u64 = @intCast(getTotalColumnDataBytes(db_handle, table_name, errmsg));
    if (errmsg.* != null) {
        return c.SQLITE_ERROR;
    }
    //------------------------------------------------------------
    const column_data_ptr = c.sqlite3_malloc64(total_data_bytes);
    if (column_data_ptr == null) {
        errmsg.* = c.sqlite3_mprintf("sqlite3_malloc64 failed: column_data_ptr");
        return c.SQLITE_NOMEM;
    }
    table_ptr.column_data = @ptrCast(@alignCast(column_data_ptr));
    const column_data = table_ptr.column_data.?;
    //------------------------------------------------------------
    var column_name_ptrs = std.StringHashMap([*:0]u8).init(temp_allocator);
    defer column_name_ptrs.deinit();
    //------------------------------------------------------------
    var current_row: usize = 0;
    var data_index: usize = 0;
    const column_count: usize = @intCast(table_ptr.column_count);
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        const step_rc = c.sqlite3_step(stmt);
        //------------------------------------------------------------
        if (step_rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            for (0..column_count) |column_index| {
                //------------------------------------------------------------
                const table_index: usize = current_row * column_count + column_index;
                //----------------------------------------
                var sqlite_column = SQLiteColumn{};
                //----------------------------------------
                const update_rc = updateSQLiteColumn(stmt_handle, @intCast(column_index), &sqlite_column);
                if (update_rc != c.SQLITE_OK) {
                    //----------------------------------------
                    errmsg.* = c.sqlite3_mprintf("updateSQLiteColumn error: column_index = %d", column_index);
                    return update_rc;
                    //----------------------------------------
                }
                //----------------------------------------
                const name_len = std.mem.len(sqlite_column.name);
                //----------------------------------------
                var name_dest: [*:0]u8 = undefined;
                if (column_name_ptrs.get(sqlite_column.name[0..name_len])) |existing_ptr| {
                    name_dest = existing_ptr;
                } else {
                    name_dest = @ptrCast(&column_data[data_index]);
                    column_name_ptrs.put(sqlite_column.name[0..name_len], name_dest) catch {
                        errmsg.* = c.sqlite3_mprintf("getSQLiteColumnsTable error: column_name_ptrs.put");
                        return c.SQLITE_ERROR;
                    };
                    @memcpy(name_dest, sqlite_column.name[0..name_len]);
                    column_data[data_index + name_len] = 0;
                    data_index += name_len + 1;
                }
                sqlite_column.name = name_dest;
                //----------------------------------------
                if (sqlite_column.column_type == .SQLITE_TEXT or sqlite_column.column_type == .SQLITE_BLOB) {
                    //----------------------------------------
                    const len: usize = @intCast(sqlite_column.len);
                    const column_dest = column_data[data_index .. data_index + len];
                    @memcpy(column_dest, sqlite_column.ptr[0..len]);
                    sqlite_column.ptr = @ptrCast(&column_data[data_index]);
                    data_index += len;
                    //----------------------------------------
                }
                //----------------------------------------
                sqlite_columns[table_index] = sqlite_column;
                //----------------------------------------
            }
            //------------------------------------------------------------
            current_row += 1;
            //------------------------------------------------------------
        } else if (step_rc == c.SQLITE_DONE) {
            //----------------------------------------
            break;
            //----------------------------------------
        } else {
            //----------------------------------------
            errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
            return step_rc;
            //----------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    return c.SQLITE_OK;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory created by getSQLiteColumnsTable
pub export fn freeSQLiteColumnsTable(table_ptr: ?*SQLiteColumnsTable) callconv(.c) void {
    //------------------------------------------------------------
    if (table_ptr == null) return;
    //------------------------------------------------------------
    if (table_ptr.?.sqlite_columns) |ptr| {
        c.sqlite3_free(ptr);
    }
    //------------------------------------------------------------
    if (table_ptr.?.column_data) |ptr| {
        c.sqlite3_free(ptr);
    }
    //------------------------------------------------------------
    table_ptr.?.* = .{};
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns total bytes required for name an blob data.
pub export fn getTotalColumnDataBytes(
    db_handle: ?*anyopaque,
    table_name: [*c]const u8,
    errmsg: *?[*:0]u8,
) callconv(.c) i64 {
    //------------------------------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //------------------------------------------------------------
    if (db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return 0;
    }
    //------------------------------------------------------------
    if (!checkTableName(table_name)) {
        errmsg.* = c.sqlite3_mprintf("invalid table_name");
        return 0;
    }
    //------------------------------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //------------------------------------------------------------
    var total_data_bytes: i64 = 0;
    //------------------------------------------------------------
    var stmt: ?*c.sqlite3_stmt = null;
    //------------------------------------------------------------
    var buffer: [MAX_TABLE_NAME:0]u8 = undefined;
    _ = c.sqlite3_snprintf(@intCast(buffer.len), &buffer, "SELECT * FROM %s;", table_name);
    //------------------------------------------------------------
    var rc = c.sqlite3_prepare_v2(db, @as([*:0]const u8, &buffer), -1, &stmt, null);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return 0;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt);
    //------------------------------------------------------------
    const column_count: usize = @intCast(c.sqlite3_column_count(stmt));
    if (column_count == 0) return 0;
    //------------------------------------------------------------
    var row_index: usize = 0;
    //------------------------------------------------------------
    while (true) : (row_index += 1) {
        //------------------------------------------------------------
        rc = c.sqlite3_step(stmt);
        //------------------------------------------------------------
        if (rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            for (0..column_count) |column_index| {
                //----------------------------------------
                const iCol: i32 = @intCast(column_index);
                //----------------------------------------
                if (row_index == 0) {
                    //----------------------------------------
                    const name = c.sqlite3_column_name(stmt, iCol);
                    const name_len = std.mem.len(name);
                    //----------------------------------------
                    total_data_bytes += @as(i64, @intCast(name_len)) + 1;
                    //----------------------------------------
                }
                //----------------------------------------
                const column_type = c.sqlite3_column_type(stmt, iCol);
                //----------------------------------------
                const len: i64 = @intCast(c.sqlite3_column_bytes(stmt, iCol));
                //----------------------------------------
                if (column_type == c.SQLITE_TEXT or column_type == c.SQLITE_BLOB) {
                    total_data_bytes += len;
                }
                //----------------------------------------
            }
            //------------------------------------------------------------
        } else if (rc == c.SQLITE_DONE) {
            //----------------------------------------
            break;
            //----------------------------------------
        } else {
            //----------------------------------------
            errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
            return 0;
            //----------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    return total_data_bytes;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Update SQLite column values.
pub export fn updateSQLiteColumn(stmt_handle: ?*anyopaque, index: i64, column: *SQLiteColumn) callconv(.c) i32 {
    //----------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    const iCol: i32 = @intCast(index);
    //----------------------------------------
    const name = c.sqlite3_column_name(stmt, iCol);
    //------------------------------------------------------------
    const column_type: SQLiteColumnType = @enumFromInt(c.sqlite3_column_type(stmt, iCol));
    //------------------------------------------------------------
    const raw_ptr = c.sqlite3_column_blob(stmt, iCol);
    const len: i64 = @intCast(c.sqlite3_column_bytes(stmt, iCol));
    const integer: i64 = @intCast(c.sqlite3_column_int64(stmt, iCol));
    const float: f64 = c.sqlite3_column_double(stmt, iCol);
    //------------------------------------------------------------
    column.* = .{
        .index = index,
        .name = name,
        .column_type = column_type,
        .ptr = "",
        .len = 0,
        .integer = integer,
        .float = float,
    };
    //------------------------------------------------------------
    if (column_type == .SQLITE_TEXT or column_type == .SQLITE_BLOB) {
        column.*.ptr = if (raw_ptr != null) @ptrCast(raw_ptr) else "";
        column.*.len = len;
    }
    //------------------------------------------------------------
    return c.SQLITE_OK;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Returns number of rows in a table.
pub export fn getRowCount(
    db_handle: ?*anyopaque,
    table_name: [*c]const u8,
    errmsg: *?[*:0]u8,
) callconv(.c) i64 {
    //------------------------------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //------------------------------------------------------------
    if (db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return 0;
    }
    //------------------------------------------------------------
    if (!checkTableName(table_name)) {
        errmsg.* = c.sqlite3_mprintf("invalid table_name");
        return 0;
    }
    //------------------------------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //------------------------------------------------------------
    var stmt: ?*c.sqlite3_stmt = null;
    //------------------------------------------------------------
    var buffer: [MAX_TABLE_NAME:0]u8 = undefined;
    _ = c.sqlite3_snprintf(
        @intCast(buffer.len),
        &buffer,
        "SELECT COUNT(*) FROM %s;",
        table_name,
    );
    //------------------------------------------------------------
    const rc = c.sqlite3_prepare_v2(
        db,
        @as([*:0]const u8, &buffer),
        -1,
        &stmt,
        null,
    );
    if (rc != c.SQLITE_OK) {
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return 0;
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt);
    //------------------------------------------------------------
    const step_rc = c.sqlite3_step(stmt);
    if (step_rc != c.SQLITE_ROW) {
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return 0;
    }
    //------------------------------------------------------------
    return c.sqlite3_column_int64(stmt, 0);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns in a table.
pub export fn getColumnCount(
    db_handle: ?*anyopaque,
    table_name: [*c]const u8,
    errmsg: *?[*:0]u8,
) callconv(.c) i64 {
    //------------------------------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //------------------------------------------------------------
    if (db_handle == null) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return 0;
        //----------------------------------------
    }
    //------------------------------------------------------------
    if (!checkTableName(table_name)) {
        errmsg.* = c.sqlite3_mprintf("invalid table_name");
        return 0;
    }
    //------------------------------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //------------------------------------------------------------
    var stmt: ?*c.sqlite3_stmt = null;
    //------------------------------------------------------------
    var buffer: [MAX_TABLE_NAME:0]u8 = undefined;
    _ = c.sqlite3_snprintf(@intCast(buffer.len), &buffer, "SELECT * FROM %s LIMIT 1;", table_name);
    //------------------------------------------------------------
    const rc = c.sqlite3_prepare_v2(db, @as([*:0]const u8, &buffer), -1, &stmt, null);
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return 0;
        //----------------------------------------
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt);
    //------------------------------------------------------------
    const step_rc = c.sqlite3_step(stmt);
    if (step_rc != c.SQLITE_ROW) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return 0;
        //----------------------------------------
    }
    //------------------------------------------------------------
    return @intCast(c.sqlite3_column_count(stmt));
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Checks table name
pub export fn checkTableName(table_name: [*c]const u8) callconv(.c) bool {
    //------------------------------------------------------------
    if (table_name == null) return false;
    if (table_name[0] == 0) return false;
    //------------------------------------------------------------
    switch (table_name[0]) {
        'A'...'Z', 'a'...'z', '_' => {},
        else => return false,
    }
    //------------------------------------------------------------
    var index: usize = 1;
    while (table_name[index] != 0) : (index += 1) {
        switch (table_name[index]) {
            'A'...'Z', 'a'...'z', '0'...'9', '_' => continue,
            else => return false,
        }
    }
    //------------------------------------------------------------
    return true;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
