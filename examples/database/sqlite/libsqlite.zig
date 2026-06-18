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
pub const SQLiteColumnType = enum(c_int) { SQLITE_UNKOWN = 0, SQLITE_INTEGER = 1, SQLITE_FLOAT = 2, SQLITE_TEXT = 3, SQLITE_BLOB = 4, SQLITE_NULL = 5 };
//--------------------------------------------------------------------------------
pub const SQLiteColumn = extern struct {
    index: usize = 0,
    name: [*:0]const u8 = "",
    column_type: SQLiteColumnType = .SQLITE_UNKOWN,
    ptr: [*]const u8 = "",
    len: usize = 0,
    integer: i64 = 0,
    float: f64 = 0,
};
//--------------------------------------------------------------------------------
pub const SQLiteColumnsContext = extern struct {
    //----------------------------------------
    sqlite_columns: ?[*]SQLiteColumn = null,
    backing_bytes: ?[*]u8 = null,
    //----------------------------------------
    row_count: usize = 0,
    column_count: usize = 0,
    //----------------------------------------
};
//--------------------------------------------------------------------------------
pub export fn sqliteColumnsDeinit(ctx: ?*SQLiteColumnsContext) callconv(.c) void {
    //----------------------------------------
    if (ctx == null) return;
    //----------------------------------------
    if (ctx.?.sqlite_columns) |ptr| {
        c.sqlite3_free(ptr);
    }
    //----------------------------------------
    if (ctx.?.backing_bytes) |ptr| {
        c.sqlite3_free(ptr);
    }
    //----------------------------------------
    ctx.?.* = .{};
    //----------------------------------------
}
//--------------------------------------------------------------------------------
const MAX_TABLE_NAME = 256;
//--------------------------------------------------------------------------------
const Self = @This();
//--------------------------------------------------------------------------------
/// Open database at filepath location.
/// Database handle stored as usize in db_handle argument.
pub fn sqliteOpen(
    filepath: [*:0]const u8,
    db_handle: *?*anyopaque,
    errmsg: *?[*:0]u8,
) callconv(.c) c_int {
    //----------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //----------------------------------------
    var db: ?*c.sqlite3 = null;
    //----------------------------------------
    const rc = c.sqlite3_open(filepath, &db);
    if (rc != c.SQLITE_OK) {
        db_handle.* = null;
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return rc;
    }
    //----------------------------------------
    db_handle.* = @ptrCast(db);
    //----------------------------------------
    return rc;
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Close database referred to by db_handle.
pub fn sqliteClose(db_handle: ?*anyopaque) callconv(.c) void {
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
pub fn sqliteErrmsg(db_handle: ?*anyopaque) callconv(.c) [*c]const u8 {
    //------------------------------------------------------------
    if (db_handle == null) return "invalid db_handle";
    //----------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //----------------------------------------
    return c.sqlite3_errmsg(db);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Updates result, row_count and column_count or errmsg if an error occurs.
pub fn sqliteGetTable(
    db_handle: ?*anyopaque,
    sql: [*c]const u8,
    results: [*c][*c][*c]u8,
    row_count: [*c]c_int,
    column_count: [*c]c_int,
    errmsg: [*c][*c]u8,
) callconv(.c) c_int {
    //----------------------------------------
    if (db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return c.SQLITE_ERROR;
    }
    //----------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //----------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //----------------------------------------
    return c.sqlite3_get_table(db, sql, results, row_count, column_count, errmsg);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory allocated by sqlite3_get_table.
pub fn sqliteFreeTable(results: [*c][*c]u8) callconv(.c) void {
    //----------------------------------------
    c.sqlite3_free_table(results);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Runs query and run callback function to deal with data for each row.
/// Optional context pointer can be used by callback function to maintain state.
pub fn sqliteExec(
    db_handle: ?*anyopaque,
    sql: [*c]const u8,
    callback: ?*const fn (?*anyopaque, c_int, [*c][*c]u8, [*c][*c]u8) callconv(.c) c_int,
    ctx: ?*anyopaque,
    errmsg: [*c][*c]u8,
) callconv(.c) c_int {
    //----------------------------------------
    if (db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return c.SQLITE_ERROR;
    }
    //----------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //----------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //----------------------------------------
    return c.sqlite3_exec(db, sql, callback, ctx, errmsg);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Prepares a statment then steps through each row and runs callback each time.
/// Optional context pointer can be used by callback function to maintain state.
pub fn sqliteQuery(
    db_handle: ?*anyopaque,
    sql: [*c]const u8,
    columns: *?[*]SQLiteColumn,
    column_count: *usize,
    callback: ?*const fn (?*anyopaque, [*]SQLiteColumn, usize) callconv(.c) c_int,
    ctx: ?*anyopaque,
    errmsg: *?[*:0]u8,
) callconv(.c) c_int {
    //------------------------------------------------------------
    if (db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return c.SQLITE_ERROR;
    }
    //----------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //----------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //----------------------------------------
    var rc: c_int = 0;
    var stmt: ?*c.sqlite3_stmt = null;
    //------------------------------------------------------------
    rc = c.sqlite3_prepare_v2(db, sql, -1, &stmt, null);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return rc;
        //----------------------------------------
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt);
    //----------------------------------------
    const stmt_handle: ?*anyopaque = @ptrCast(stmt.?);
    //----------------------------------------
    column_count.* = @intCast(c.sqlite3_column_count(stmt));
    //------------------------------------------------------------
    const total_bytes: usize = column_count.* * @sizeOf(SQLiteColumn);
    const raw_ptr = c.sqlite3_malloc(@intCast(total_bytes)) orelse {
        errmsg.* = c.sqlite3_mprintf("sqlite3_malloc64 failed: raw_ptr");
        return c.SQLITE_NOMEM;
    };
    columns.* = @ptrCast(@alignCast(raw_ptr));
    const columns_ptr = columns.*.?;
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        rc = c.sqlite3_step(stmt);
        //------------------------------------------------------------
        if (rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            if (callback) |cb| {
                //------------------------------------------------------------
                for (0..column_count.*) |index| {
                    //------------------------------------------------------------
                    columns_ptr[index] = .{};
                    //----------------------------------------
                    const update_rc = sqliteUpdateColumn(stmt_handle, index, &columns_ptr[index]);
                    if (update_rc != c.SQLITE_OK) {
                        //----------------------------------------
                        errmsg.* = c.sqlite3_mprintf("sqliteUpdateColumn error: index = %d", index);
                        return update_rc;
                        //----------------------------------------
                    }
                    //----------------------------------------
                }
                //------------------------------------------------------------
                const return_code = cb(ctx, columns_ptr, column_count.*);
                if (return_code != c.SQLITE_OK) {
                    //----------------------------------------
                    errmsg.* = c.sqlite3_mprintf("query aborted: index = %d", return_code);
                    return return_code;
                    //----------------------------------------
                }
                //------------------------------------------------------------
            }
            //------------------------------------------------------------
        } else if (rc == c.SQLITE_DONE) {
            //----------------------------------------
            break;
            //----------------------------------------
        } else {
            //----------------------------------------
            errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
            return rc;
            //----------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    return c.SQLITE_OK;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
// Provides a statement handle for use by calling code.
pub fn sqlitePrepare(
    db_handle: ?*anyopaque,
    sql: [*c]const u8,
    stmt_handle: *?*anyopaque,
    errmsg: *?[*:0]u8,
) callconv(.c) c_int {
    //----------------------------------------
    if (db_handle == null) {
        stmt_handle.* = null;
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return c.SQLITE_ERROR;
    }
    //----------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //----------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //----------------------------------------
    var stmt: ?*c.sqlite3_stmt = null;
    //----------------------------------------
    const rc = c.sqlite3_prepare_v2(db, sql, -1, &stmt, null);
    //----------------------------------------
    if (rc != c.SQLITE_OK) {
        stmt_handle.* = null;
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return rc;
    }
    //----------------------------------------
    stmt_handle.* = @ptrCast(stmt.?);
    //----------------------------------------
    return c.SQLITE_OK;
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Runs sqlite3_stmt using statement handle.
pub fn sqliteStep(stmt_handle: ?*anyopaque) callconv(.c) c_int {
    //----------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_step(stmt);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Resets prepared statement handle (does not clear bindings).
pub fn sqliteReset(stmt_handle: ?*anyopaque) callconv(.c) c_int {
    //----------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_reset(stmt);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Clears bindings on prepared statement.
pub fn sqliteClearBindings(stmt_handle: ?*anyopaque) callconv(.c) c_int {
    //----------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_clear_bindings(stmt);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds blob data to a column.
pub fn sqliteBindBlob(stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) c_int {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_bind_blob(stmt, iCol, ptr, @intCast(len), destructor_function);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds text data to a column.
pub fn sqliteBindText(stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) c_int {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_bind_text(stmt, iCol, ptr, @intCast(len), destructor_function);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds in i64 to a column.
pub fn sqliteBindInt64(stmt_handle: ?*anyopaque, iCol: c_int, integer: i64) c_int {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_bind_int64(stmt, iCol, integer);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds an f64 to a column.
pub fn sqliteBindDouble(stmt_handle: ?*anyopaque, iCol: c_int, float: f64) c_int {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_bind_double(stmt, iCol, float);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds a null value to a column.
pub fn sqliteBindNull(stmt_handle: ?*anyopaque, iCol: c_int) c_int {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_bind_null(stmt, iCol);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns column type.
pub fn sqliteColumnType(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_column_type(stmt, iCol);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a BLOB of bytes.
pub fn sqliteColumnBlob(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8 {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    const raw_ptr = c.sqlite3_column_blob(stmt, iCol);
    return @ptrCast(raw_ptr);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a UTF-8 text result (zero terminated).
pub fn sqliteColumnText(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8 {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_column_text(stmt, iCol);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns an i64 integer.
pub fn sqliteColumnInt64(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) i64 {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_column_int64(stmt, iCol);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns an f64 float value.
pub fn sqliteColumnDouble(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) f64 {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_column_double(stmt, iCol);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of bytes in column.
pub fn sqliteColumnBytes(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_column_bytes(stmt, iCol);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Finalises prepared statement handle.
pub fn sqliteFinalize(stmt_handle: ?*anyopaque) callconv(.c) c_int {
    //----------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_finalize(stmt);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns provided by statment.
pub fn sqliteColumnCount(stmt_handle: ?*anyopaque) callconv(.c) c_int {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_column_count(stmt);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns in current row (ONLY during SQLITE_ROW stage).
pub fn sqliteDataCount(stmt_handle: ?*anyopaque) callconv(.c) c_int {
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_data_count(stmt);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Prepares a statment then steps through each row and outputs to flat array of columns.
pub fn getTableColumns(
    db_handle: ?*anyopaque,
    table_name: [*c]const u8,
    ctx: *SQLiteColumnsContext,
    errmsg: *?[*:0]u8,
) callconv(.c) c_int {
    //------------------------------------------------------------
    if (db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return c.SQLITE_ERROR;
    }
    //------------------------------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //------------------------------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //------------------------------------------------------------
    ctx.row_count = getRowCount(db_handle, table_name, errmsg);
    if (errmsg.* != null) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return c.SQLITE_ERROR;
        //----------------------------------------
    }
    //------------------------------------------------------------
    var stmt: ?*c.sqlite3_stmt = null;
    //----------------------------------------
    var buffer: [MAX_TABLE_NAME:0]u8 = undefined;
    _ = c.sqlite3_snprintf(@intCast(buffer.len), &buffer, "SELECT * FROM %w;", table_name);
    //------------------------------------------------------------
    var rc: c_int = 0;
    //------------------------------------------------------------
    rc = c.sqlite3_prepare_v2(db, @as([*:0]const u8, &buffer), -1, &stmt, null);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return rc;
        //----------------------------------------
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt);
    //----------------------------------------
    const stmt_handle: ?*anyopaque = @ptrCast(stmt.?);
    //----------------------------------------
    ctx.column_count = @intCast(c.sqlite3_column_count(stmt));
    if (ctx.column_count == 0) return c.SQLITE_OK;
    //----------------------------------------
    const total_sqlite_column_bytes: usize = ctx.row_count * ctx.column_count * @sizeOf(SQLiteColumn);

    const total_backed_bytes = getTotalBackedBytes(db_handle, table_name, errmsg);
    if (errmsg.* != null) {
        return c.SQLITE_ERROR;
    }
    //------------------------------------------------------------
    const sqlite_columns_ptr = c.sqlite3_malloc64(total_sqlite_column_bytes);
    if (sqlite_columns_ptr == null) {
        errmsg.* = c.sqlite3_mprintf("sqlite3_malloc64 failed: sqlite_columns_ptr");
        return c.SQLITE_NOMEM;
    }
    ctx.sqlite_columns = @ptrCast(@alignCast(sqlite_columns_ptr));
    const sqlite_columns = ctx.sqlite_columns.?;
    //----------------------------------------
    const backed_mem_ptr = c.sqlite3_malloc64(total_backed_bytes);
    if (backed_mem_ptr == null) {
        errmsg.* = c.sqlite3_mprintf("sqlite3_malloc64 failed: backed_mem_ptr");
        return c.SQLITE_NOMEM;
    }
    ctx.backing_bytes = @ptrCast(@alignCast(backed_mem_ptr));
    const backing_bytes = ctx.backing_bytes.?;
    //------------------------------------------------------------
    var current_row: usize = 0;
    var backing_index: usize = 0;
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        rc = c.sqlite3_step(stmt);
        //------------------------------------------------------------
        if (rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            for (0..ctx.column_count) |column_index| {
                //------------------------------------------------------------
                const table_index: usize = current_row * ctx.column_count + column_index;
                //----------------------------------------
                var sqlite_column = SQLiteColumn{};
                //----------------------------------------
                const update_rc = sqliteUpdateColumn(stmt_handle, column_index, &sqlite_column);
                if (update_rc != c.SQLITE_OK) {
                    //----------------------------------------
                    errmsg.* = c.sqlite3_mprintf("sqliteUpdateColumn error: index = %d", column_index);
                    return update_rc;
                    //----------------------------------------
                }
                //----------------------------------------
                const name_len = std.mem.len(sqlite_column.name);

                const name_dest = backing_bytes[backing_index .. backing_index + name_len];
                @memcpy(name_dest, sqlite_column.name[0..name_len]);
                backing_bytes[backing_index + name_len] = 0x00;
                sqlite_column.name = @ptrCast(&backing_bytes[backing_index]);
                backing_index += name_len + 1;
                //----------------------------------------
                if (sqlite_column.column_type == .SQLITE_TEXT or sqlite_column.column_type == .SQLITE_BLOB) {
                    //----------------------------------------
                    const column_dest = backing_bytes[backing_index .. backing_index + sqlite_column.len];
                    @memcpy(column_dest, sqlite_column.ptr[0..sqlite_column.len]);
                    sqlite_column.ptr = @ptrCast(&backing_bytes[backing_index]);
                    backing_index += sqlite_column.len;
                    //----------------------------------------
                }
                //----------------------------------------
                sqlite_columns[table_index] = sqlite_column;
                //----------------------------------------
            }
            //------------------------------------------------------------
            current_row += 1;
            //------------------------------------------------------------
        } else if (rc == c.SQLITE_DONE) {
            //----------------------------------------
            break;
            //----------------------------------------
        } else {
            //----------------------------------------
            errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
            return rc;
            //----------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    return c.SQLITE_OK;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Update column values.
pub fn sqliteUpdateColumn(stmt_handle: ?*anyopaque, index: usize, column: *SQLiteColumn) callconv(.c) c_int {
    //------------------------------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    const iCol: c_int = @intCast(index);
    //----------------------------------------
    const name = c.sqlite3_column_name(stmt, iCol);
    //------------------------------------------------------------
    const column_type: SQLiteColumnType = @enumFromInt(c.sqlite3_column_type(stmt, iCol));
    //------------------------------------------------------------
    const raw_ptr = c.sqlite3_column_blob(stmt, iCol);
    const len: usize = @intCast(c.sqlite3_column_bytes(stmt, iCol));
    const integer = @as(i64, c.sqlite3_column_int64(stmt, iCol));
    const float = @as(f64, c.sqlite3_column_double(stmt, iCol));
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
        column.*.ptr = @ptrCast(raw_ptr);
        column.*.len = len;
    }
    //------------------------------------------------------------
    return c.SQLITE_OK;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns total backed bytes required for name an blob data.
pub fn getTotalBackedBytes(
    db_handle: ?*anyopaque,
    table_name: [*c]const u8,
    errmsg: *?[*:0]u8,
) callconv(.c) usize {
    //------------------------------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //------------------------------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //------------------------------------------------------------
    var total_backed_bytes: usize = 0;
    //------------------------------------------------------------
    var stmt: ?*c.sqlite3_stmt = null;
    //----------------------------------------
    var buffer: [MAX_TABLE_NAME:0]u8 = undefined;
    _ = c.sqlite3_snprintf(@intCast(buffer.len), &buffer, "SELECT * FROM %w;", table_name);
    //------------------------------------------------------------
    var rc = c.sqlite3_prepare_v2(db, @as([*:0]const u8, &buffer), -1, &stmt, null);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return 0;
        //----------------------------------------
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt);
    //----------------------------------------
    const column_count: usize = @intCast(c.sqlite3_column_count(stmt));
    if (column_count == 0) return 0;
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        rc = c.sqlite3_step(stmt);
        //------------------------------------------------------------
        if (rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            for (0..column_count) |column_index| {
                //----------------------------------------
                const iCol: c_int = @intCast(column_index);
                //----------------------------------------
                const name = c.sqlite3_column_name(stmt, iCol);
                const name_len = std.mem.len(name);
                //----------------------------------------
                total_backed_bytes += name_len + 1;
                //----------------------------------------
                const column_type = c.sqlite3_column_type(stmt, iCol);
                //----------------------------------------
                const len: usize = @intCast(c.sqlite3_column_bytes(stmt, iCol));
                //----------------------------------------
                if (column_type == c.SQLITE_TEXT or column_type == c.SQLITE_BLOB) {
                    total_backed_bytes += len;
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
    return total_backed_bytes;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a block of memory at least N bytes.
pub fn sqliteMalloc64(len: c_ulonglong) callconv(.c) ?*anyopaque {
    //----------------------------------------
    return c.sqlite3_malloc64(len);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a reallocated block of memory at least N bytes (old block freed by sqlite).
pub fn sqliteRealloc64(ptr: ?*anyopaque, len: c_ulonglong) callconv(.c) ?*anyopaque {
    //----------------------------------------
    return c.sqlite3_realloc64(ptr, len);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory previously allocated using sqlite3_malloc/sqlite3_malloc64.
pub fn sqliteFree(ptr: ?*anyopaque) callconv(.c) void {
    //----------------------------------------
    c.sqlite3_free(ptr);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a block of memory at least N bytes.
pub fn allocateBytes(len: usize) callconv(.c) [*]u8 {
    //----------------------------------------
    const raw_ptr = c.sqlite3_malloc64(@intCast(len));
    //----------------------------------------
    return @ptrCast(raw_ptr);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a reallocated block of memory at least N bytes (old block freed by sqlite).
pub fn reallocateBytes(ptr: ?*anyopaque, len: usize) callconv(.c) [*]u8 {
    //----------------------------------------
    const raw_ptr = c.sqlite3_realloc64(ptr, @intCast(len));
    //----------------------------------------
    return @ptrCast(raw_ptr);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory previously allocated using allocateBytes.
pub fn freeBytes(ptr: ?*anyopaque) callconv(.c) void {
    //----------------------------------------
    c.sqlite3_free(ptr);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of rows in a table.
pub fn getRowCount(
    db_handle: ?*anyopaque,
    table_name: [*c]const u8,
    errmsg: *?[*:0]u8,
) callconv(.c) usize {
    //----------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //----------------------------------------
    if (db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return 0;
    }
    //----------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //----------------------------------------
    var stmt: ?*c.sqlite3_stmt = null;
    //----------------------------------------
    var buffer: [MAX_TABLE_NAME:0]u8 = undefined;
    _ = c.sqlite3_snprintf(
        @intCast(buffer.len),
        &buffer,
        "SELECT COUNT(*) FROM %w;",
        table_name,
    );
    //----------------------------------------
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
    //----------------------------------------
    defer _ = c.sqlite3_finalize(stmt);
    //----------------------------------------
    const step_rc = c.sqlite3_step(stmt);
    if (step_rc != c.SQLITE_ROW) {
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return 0;
    }
    //----------------------------------------
    return @intCast(c.sqlite3_column_int64(stmt, 0));
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns in a table.
pub fn getColumnCount(
    db_handle: ?*anyopaque,
    table_name: [*c]const u8,
    errmsg: *?[*:0]u8,
) callconv(.c) usize {
    //----------------------------------------
    if (errmsg.* != null) errmsg.* = null;
    //----------------------------------------
    if (db_handle == null) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return 0;
        //----------------------------------------
    }
    //----------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //----------------------------------------
    var stmt: ?*c.sqlite3_stmt = null;
    //----------------------------------------
    var buffer: [MAX_TABLE_NAME:0]u8 = undefined;
    _ = c.sqlite3_snprintf(@intCast(buffer.len), &buffer, "SELECT * FROM %w LIMIT 1;", table_name);
    //----------------------------------------
    const rc = c.sqlite3_prepare_v2(db, @as([*:0]const u8, &buffer), -1, &stmt, null);
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return 0;
        //----------------------------------------
    }
    //----------------------------------------
    defer _ = c.sqlite3_finalize(stmt);
    //----------------------------------------
    const step_rc = c.sqlite3_step(stmt);
    if (step_rc != c.SQLITE_ROW) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return 0;
        //----------------------------------------
    }
    //----------------------------------------
    return @intCast(c.sqlite3_column_count(stmt));
    //----------------------------------------
}
//--------------------------------------------------------------------------------
