//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
const MAX_ERRMSG: usize = 256;
const MAX_TABLE_NAME: usize = 256;
//--------------------------------------------------------------------------------
db_handle: ?*anyopaque = null,
rc: c_int = c.SQLITE_OK,
errmsg: [MAX_ERRMSG:0]u8 = [_:0]u8{0} ** MAX_ERRMSG,
//--------------------------------------------------------------------------------
pub const SQLiteDB = @This();
pub const Self = @This();
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub const SQLiteColumnType = enum(c_int) { SQLITE_UNKNOWN = 0, SQLITE_INTEGER = 1, SQLITE_FLOAT = 2, SQLITE_TEXT = 3, SQLITE_BLOB = 4, SQLITE_NULL = 5 };
//--------------------------------------------------------------------------------
pub const SQLiteColumn = extern struct {
    index: usize = 0,
    name: [*:0]const u8 = "",
    column_type: SQLiteColumnType = .SQLITE_UNKNOWN,
    ptr: [*]const u8 = "",
    len: usize = 0,
    integer: i64 = 0,
    float: f64 = 0,
};
//--------------------------------------------------------------------------------
pub const SQLiteColumnsTable = extern struct {
    //----------------------------------------
    sqlite_columns: ?[*]SQLiteColumn = null,
    column_data: ?[*]u8 = null,
    //----------------------------------------
    row_count: usize = 0,
    column_count: usize = 0,
    //----------------------------------------
};
//--------------------------------------------------------------------------------
pub const ColumnValue = union(enum) {
    null: void,
    integer: i64,
    float: f64,
    string: []const u8,
};
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Open shared sqlite library and return new self instance.
pub fn init() !Self {
    //------------------------------------------------------------
    try openLibrary();
    //------------------------------------------------------------
    return .{};
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Reset self instance and close library.
pub fn deinit(_: *Self) void {
    //------------------------------------------------------------
    closeLibrary();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Open database and update db_handle.
pub fn connect(self: *Self, filepath: [*:0]const u8) !void {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    var db_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    const rc = c.sqlite3_open(filepath, &db_handle);
    if (rc != c.SQLITE_OK) {
        //------------------------------------------------------------
        self.setErrorMessage(rc, "failed to open database");
        //------------------------------------------------------------
        return switch (rc) {
            c.SQLITE_BUSY => return error.Busy,
            c.SQLITE_LOCKED => return error.Locked,
            else => return error.OpenFailed,
        };
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    self.db_handle = db_handle;
    //--------------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Close database and reset db_handle.
pub fn close(self: *Self) void {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    _ = c.sqlite3_close(self.db_handle);
    self.db_handle = null;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns last database error message.
pub fn sqliteErrmsg(self: *Self) [*c]const u8 {
    //------------------------------------------------------------
    return c.sqlite3_errmsg(self.db_handle);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Updates result, row_count and column_count or errmsg if an error occurs.
pub fn sqliteGetTable(self: *Self, sql: [*c]const u8, results: [*c][*c][*c]u8, row_count: [*c]c_int, column_count: [*c]c_int, errmsg: [*c][*c]u8) c_int {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    const rc = c.sqlite3_get_table(self.db_handle, sql, results, row_count, column_count, errmsg);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, errmsg.*.?);
    //------------------------------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory allocated by sqliteGetTable.
pub fn sqliteFreeTable(self: *Self, results: [*c][*c]u8) void {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    c.sqlite3_free_table(results);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Runs query and run callback function to deal with data for each row.
/// Optional context pointer can be used by callback function to maintain state.
pub fn sqliteExec(self: *Self, sql: [*c]const u8, callback: ?*const fn (?*anyopaque, c_int, [*c][*c]u8, [*c][*c]u8) callconv(.c) c_int, ctx: ?*anyopaque, errmsg: [*c][*c]u8) c_int {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    const rc = c.sqlite3_exec(self.db_handle, sql, callback, ctx, errmsg);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, errmsg.*.?);
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
// Provides a statement handle for use by calling code.
pub fn sqlitePrepare(self: *Self, sql: [*c]const u8, stmt_handle: *?*anyopaque) c_int {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        stmt_handle.* = null;
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    const rc = c.sqlite3_prepare_v2(self.db_handle, sql, -1, stmt_handle, null);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        stmt_handle.* = null;
        return self.returnErrorCode(rc, c.sqlite3_errmsg(self.db_handle));
    }
    //------------------------------------------------------------
    return c.SQLITE_OK;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Clears bindings on prepared statement.
pub fn sqliteClearBindings(self: *Self, stmt_handle: ?*anyopaque) c_int {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        stmt_handle.* = null;
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    if (stmt_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid stmt_handle");
    }
    //------------------------------------------------------------
    const rc = c.sqlite3_clear_bindings(stmt_handle);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, c.sqlite3_errmsg(self.db_handle));
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds blob data to a column.
pub fn sqliteBindBlob(self: *Self, stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) c_int {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    if (stmt_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid stmt_handle");
    }
    //------------------------------------------------------------
    const rc = c.sqlite3_bind_blob(stmt_handle, iCol, ptr, len, destructor_function);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, c.sqlite3_errmsg(self.db_handle));
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds text data to a column.
pub fn sqliteBindText(self: *Self, stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) c_int {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    if (stmt_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid stmt_handle");
    }
    //------------------------------------------------------------
    const rc = c.sqlite3_bind_text(stmt_handle, iCol, ptr, len, destructor_function);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, c.sqlite3_errmsg(self.db_handle));
    //------------------------------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds in i64 to a column.
pub fn sqliteBindInt64(self: *Self, stmt_handle: ?*anyopaque, iCol: c_int, integer: i64) c_int {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    if (stmt_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid stmt_handle");
    }
    //------------------------------------------------------------
    const rc = c.sqlite3_bind_int64(stmt_handle, iCol, integer);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, c.sqlite3_errmsg(self.db_handle));
    //------------------------------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds an f64 to a column.
pub fn sqliteBindDouble(self: *Self, stmt_handle: ?*anyopaque, iCol: c_int, float: f64) c_int {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    if (stmt_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid stmt_handle");
    }
    //------------------------------------------------------------
    const rc = c.sqlite3_bind_double(stmt_handle, iCol, float);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, c.sqlite3_errmsg(self.db_handle));
    //------------------------------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds a null value to a column.
pub fn sqliteBindNull(self: *Self, stmt_handle: ?*anyopaque, iCol: c_int) c_int {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    if (stmt_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid stmt_handle");
    }
    //------------------------------------------------------------
    const rc = c.sqlite3_bind_null(stmt_handle, iCol);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, c.sqlite3_errmsg(self.db_handle));
    //------------------------------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns column name.
pub fn sqliteColumnName(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) [*c]const u8 {
    //------------------------------------------------------------
    return c.sqlite3_column_name(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns column type.
pub fn sqliteColumnType(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) c_int {
    //------------------------------------------------------------
    return c.sqlite3_column_type(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a BLOB of bytes.
pub fn sqliteColumnBlob(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) [*c]const u8 {
    //------------------------------------------------------------
    return c.sqlite3_column_blob(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a UTF-8 text result (zero terminated).
pub fn sqliteColumnText(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) [*c]const u8 {
    //------------------------------------------------------------
    return c.sqlite3_column_text(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns an i64 integer.
pub fn sqliteColumnInt64(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) i64 {
    //------------------------------------------------------------
    return c.sqlite3_column_int64(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns an f64 float value.
pub fn sqliteColumnDouble(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) f64 {
    //------------------------------------------------------------
    return c.sqlite3_column_double(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of bytes in column.
pub fn sqliteColumnBytes(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) usize {
    //------------------------------------------------------------
    return @intCast(c.sqlite3_column_bytes(stmt_handle, iCol));
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns provided by statement.
pub fn sqliteColumnCount(_: *Self, stmt_handle: ?*anyopaque) c_int {
    //------------------------------------------------------------
    return c.sqlite3_column_count(stmt_handle);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns in current row (ONLY during SQLITE_ROW stage).
pub fn sqliteDataCount(_: *Self, stmt_handle: ?*anyopaque) c_int {
    //------------------------------------------------------------
    return c.sqlite3_data_count(stmt_handle);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Runs c.sqlite3_step using statement handle.
pub fn sqliteStep(self: *Self, stmt_handle: ?*anyopaque) c_int {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    if (stmt_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid stmt_handle");
    }
    //------------------------------------------------------------
    const rc = c.sqlite3_step(stmt_handle);
    //------------------------------------------------------------
    self.setErrorMessage(rc, c.sqlite3_errmsg(self.db_handle));
    //------------------------------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Resets prepared statement handle (does not clear bindings).
pub fn sqliteReset(self: *Self, stmt_handle: ?*anyopaque) c_int {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    if (stmt_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid stmt_handle");
    }
    //------------------------------------------------------------
    const rc = c.sqlite3_reset(stmt_handle);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, c.sqlite3_errmsg(self.db_handle));
    //------------------------------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Finalises prepared statement handle.
pub fn sqliteFinalize(self: *Self, stmt_handle: ?*anyopaque) c_int {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    if (stmt_handle == null) {
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid stmt_handle");
    }
    //------------------------------------------------------------
    const rc = c.sqlite3_finalize(stmt_handle);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, c.sqlite3_errmsg(self.db_handle));
    //------------------------------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Returns a pointer to a block of memory at least N bytes.
pub fn sqliteMalloc64(_: *Self, len: c_ulonglong) ?*anyopaque {
    //------------------------------------------------------------
    return c.sqlite3_malloc64(len);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a reallocated block of memory at least N bytes (old block freed by sqlite).
pub fn sqliteRealloc64(_: *Self, ptr: ?*anyopaque, len: c_ulonglong) ?*anyopaque {
    //------------------------------------------------------------
    return c.sqlite3_realloc64(ptr, len);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory previously allocated using c.sqlite3_malloc/c.sqlite3_malloc64.
pub fn sqliteFree(_: *Self, ptr: ?*anyopaque) void {
    //------------------------------------------------------------
    c.sqlite3_free(ptr);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Returns a pointer to a block of memory at least N bytes.
pub fn allocateBytes(_: *Self, len: usize) [*]u8 {
    //------------------------------------------------------------
    const raw_ptr = c.sqlite3_malloc64(@intCast(len));
    //------------------------------------------------------------
    return @ptrCast(raw_ptr);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a reallocated block of memory at least N bytes (old block freed by sqlite).
pub fn reallocateBytes(_: *Self, ptr: ?*anyopaque, len: usize) [*]u8 {
    //------------------------------------------------------------
    const raw_ptr = c.sqlite3_realloc64(ptr, @intCast(len));
    //------------------------------------------------------------
    return @ptrCast(raw_ptr);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a reallocated block of memory at least N bytes (old block freed by sqlite).
pub fn freeBytes(_: *Self, ptr: ?*anyopaque) void {
    //------------------------------------------------------------
    c.sqlite3_free(ptr);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Prepares a statement then steps through each row and runs callback each time.
/// Optional context pointer can be used by callback function to maintain state.
pub fn queryCallback(
    self: *Self,
    sql: [*c]const u8,
    callback: ?*const fn (?*anyopaque, [*]SQLiteColumn, usize) callconv(.c) c_int,
    ctx: ?*anyopaque,
) !void {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnError(c.SQLITE_MISUSE, "invalid db_handle", error.InvalidDBHandle);
    }
    //------------------------------------------------------------
    var stmt_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    var rc = self.sqlitePrepare(sql, &stmt_handle);
    if (rc != c.SQLITE_OK) {
        return self.returnError(rc, c.sqlite3_errmsg(self.db_handle), error.SQLitePepareError);
    }
    //------------------------------------------------------------
    defer _ = self.sqliteFinalize(stmt_handle);
    //------------------------------------------------------------
    const column_count: usize = @intCast(self.sqliteColumnCount(stmt_handle));
    //------------------------------------------------------------
    const total_bytes: usize = column_count * @sizeOf(SQLiteColumn);
    const raw_ptr = self.sqliteMalloc64(@intCast(total_bytes)) orelse {
        return self.returnError(
            c.SQLITE_NOMEM,
            "c.sqlite3_malloc64 error",
            error.SQLiteMalloc64Error,
        );
    };
    defer self.sqliteFree(raw_ptr);
    //------------------------------------------------------------
    const columns: [*]SQLiteColumn = @ptrCast(@alignCast(raw_ptr));
    const columns_ptr = columns;
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        rc = self.sqliteStep(stmt_handle);
        //------------------------------------------------------------
        if (rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            if (callback) |cb| {
                //------------------------------------------------------------
                for (0..column_count) |index| {
                    //------------------------------------------------------------
                    columns_ptr[index] = .{};
                    //----------------------------------------
                    try self.updateSQLiteColumn(
                        stmt_handle,
                        index,
                        &columns_ptr[index],
                    );
                    //----------------------------------------
                }
                //------------------------------------------------------------
                const return_code = cb(ctx, columns_ptr, column_count);
                if (return_code != c.SQLITE_OK) {
                    //----------------------------------------
                    return self.returnError(
                        return_code,
                        "callback aborted",
                        error.CallbackAborted,
                    );
                    //----------------------------------------
                }
                //------------------------------------------------------------
            }
            //------------------------------------------------------------
        } else if (rc == c.SQLITE_DONE) {
            //------------------------------------------------------------
            break;
            //------------------------------------------------------------
        } else {
            //------------------------------------------------------------
            return self.returnError(
                rc,
                c.sqlite3_errmsg(self.db_handle),
                error.SQLiteStepError,
            );
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Prepares a statement then steps through each row and outputs to flat array of columns.
pub fn getSQLiteColumnsTable(self: *Self, table_name: [*c]const u8, table_ptr: *SQLiteColumnsTable) !void {
    //------------------------------------------------------------
    self.clearError();
    //--------------------------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnError(c.SQLITE_MISUSE, "invalid db_handle", error.InvalidDBHandle);
    }
    //------------------------------------------------------------
    table_ptr.row_count = try getRowCount(self, table_name);
    //------------------------------------------------------------
    var stmt_handle: ?*anyopaque = null;
    //----------------------------------------
    var buffer: [MAX_TABLE_NAME:0]u8 = undefined;
    _ = c.sqlite3_snprintf(@intCast(buffer.len), &buffer, "SELECT * FROM %s;", table_name);
    //------------------------------------------------------------
    var rc: c_int = 0;
    //------------------------------------------------------------
    rc = c.sqlite3_prepare_v2(self.db_handle, @as([*:0]const u8, &buffer), -1, &stmt_handle, null);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        return self.returnError(
            rc,
            c.sqlite3_errmsg(self.db_handle),
            error.SQLitePrepareError,
        );
        //----------------------------------------
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt_handle);
    //----------------------------------------
    table_ptr.column_count = @intCast(c.sqlite3_column_count(stmt_handle));
    if (table_ptr.column_count == 0) return;
    //----------------------------------------
    const total_sqlite_column_bytes: usize = table_ptr.row_count * table_ptr.column_count * @sizeOf(SQLiteColumn);
    //----------------------------------------
    const total_backed_bytes = try getTotalColumnDataBytes(self, table_name);
    //------------------------------------------------------------
    const sqlite_columns_ptr = c.sqlite3_malloc64(total_sqlite_column_bytes);
    if (sqlite_columns_ptr == null) {
        return self.returnError(
            c.SQLITE_NOMEM,
            "c.sqlite3_malloc64 failed: sqlite_columns_ptr",
            error.SQLiteMalloc64Error,
        );
    }
    table_ptr.sqlite_columns = @ptrCast(@alignCast(sqlite_columns_ptr));
    const sqlite_columns = table_ptr.sqlite_columns.?;
    //------------------------------------------------------------
    const backed_mem_ptr = c.sqlite3_malloc64(total_backed_bytes);
    if (backed_mem_ptr == null) {
        return self.returnError(
            c.SQLITE_NOMEM,
            "c.sqlite3_malloc64 failed: backed_mem_ptr",
            error.SQLiteMalloc64Error,
        );
    }
    table_ptr.column_data = @ptrCast(@alignCast(backed_mem_ptr));
    const column_data = table_ptr.column_data.?;
    //------------------------------------------------------------
    var current_row: usize = 0;
    var data_index: usize = 0;
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        rc = c.sqlite3_step(stmt_handle);
        //------------------------------------------------------------
        if (rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            for (0..table_ptr.column_count) |column_index| {
                //------------------------------------------------------------
                const table_index: usize = current_row * table_ptr.column_count + column_index;
                //----------------------------------------
                var sqlite_column = SQLiteColumn{};
                //----------------------------------------
                try updateSQLiteColumn(self, stmt_handle, column_index, &sqlite_column);
                //----------------------------------------
                const name_len = std.mem.len(sqlite_column.name);
                //----------------------------------------
                const name_dest = column_data[data_index .. data_index + name_len];
                @memcpy(name_dest, sqlite_column.name[0..name_len]);
                column_data[data_index + name_len] = 0;
                sqlite_column.name = @ptrCast(&column_data[data_index]);
                data_index += name_len + 1;
                //----------------------------------------
                if (sqlite_column.column_type == .SQLITE_TEXT or sqlite_column.column_type == .SQLITE_BLOB) {
                    //------------------------------------------------------------
                    const column_dest = column_data[data_index .. data_index + sqlite_column.len];
                    @memcpy(column_dest, sqlite_column.ptr[0..sqlite_column.len]);
                    sqlite_column.ptr = @ptrCast(&column_data[data_index]);
                    data_index += sqlite_column.len;
                    //------------------------------------------------------------
                }
                //------------------------------------------------------------
                sqlite_columns[table_index] = sqlite_column;
                //------------------------------------------------------------
            }
            //------------------------------------------------------------
            current_row += 1;
            //------------------------------------------------------------
        } else if (rc == c.SQLITE_DONE) {
            //------------------------------------------------------------
            break;
            //------------------------------------------------------------
        } else {
            //------------------------------------------------------------
            return self.returnError(
                rc,
                c.sqlite3_errmsg(self.db_handle),
                error.SQLiteStepError,
            );
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory created by getSQLiteColumnsTable.
pub fn freeSQLiteColumnsTable(self: *Self, table_ptr: ?*SQLiteColumnsTable) void {
    //------------------------------------------------------------
    self.clearError();
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
/// Returns total backed bytes required for name an blob data.
pub fn getTotalColumnDataBytes(self: *Self, table_name: [*c]const u8) !usize {
    //------------------------------------------------------------
    self.clearError();
    //--------------------------------------------------------------------------------
    var total_backed_bytes: usize = 0;
    //------------------------------------------------------------
    var stmt_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    var buffer: [MAX_TABLE_NAME:0]u8 = undefined;
    _ = c.sqlite3_snprintf(@intCast(buffer.len), &buffer, "SELECT * FROM %s;", table_name);
    //------------------------------------------------------------
    var rc = c.sqlite3_prepare_v2(self.db_handle, @as([*:0]const u8, &buffer), -1, &stmt_handle, null);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        //------------------------------------------------------------
        return self.returnError(rc, c.sqlite3_errmsg(self.db_handle), error.SQLitePrepareError);
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt_handle);
    //------------------------------------------------------------
    const column_count: usize = @intCast(c.sqlite3_column_count(stmt_handle));
    if (column_count == 0) return 0;
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        rc = c.sqlite3_step(stmt_handle);
        //------------------------------------------------------------
        if (rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            for (0..column_count) |column_index| {
                //------------------------------------------------------------
                const iCol: c_int = @intCast(column_index);
                //------------------------------------------------------------
                const name = c.sqlite3_column_name(stmt_handle, iCol);
                const name_len = std.mem.len(name);
                //------------------------------------------------------------
                total_backed_bytes += name_len + 1;
                //------------------------------------------------------------
                const column_type = c.sqlite3_column_type(stmt_handle, iCol);
                //------------------------------------------------------------
                const len: usize = @intCast(c.sqlite3_column_bytes(stmt_handle, iCol));
                //------------------------------------------------------------
                if (column_type == c.SQLITE_TEXT or column_type == c.SQLITE_BLOB) {
                    total_backed_bytes += len;
                }
                //------------------------------------------------------------
            }
            //------------------------------------------------------------
        } else if (rc == c.SQLITE_DONE) {
            //------------------------------------------------------------
            break;
            //------------------------------------------------------------
        } else {
            //------------------------------------------------------------
            return self.returnError(rc, c.sqlite3_errmsg(self.db_handle), error.SQLiteStepError);
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    return total_backed_bytes;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of rows in a table.
pub fn getRowCount(self: *Self, table_name: [*c]const u8) !usize {
    //------------------------------------------------------------
    self.clearError();
    //--------------------------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnError(c.SQLITE_MISUSE, "invalid db_handle", error.InvalidDBHandle);
    }
    //------------------------------------------------------------
    var stmt_handle: ?*anyopaque = null;
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
        self.db_handle,
        @as([*:0]const u8, &buffer),
        -1,
        &stmt_handle,
        null,
    );
    if (rc != c.SQLITE_OK) {
        return self.returnError(rc, c.sqlite3_errmsg(self.db_handle), error.SQLitePrepareError);
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt_handle);
    //------------------------------------------------------------
    const step_rc = c.sqlite3_step(stmt_handle);
    if (step_rc != c.SQLITE_ROW) {
        return self.returnError(step_rc, c.sqlite3_errmsg(self.db_handle), error.SQLiteStepError);
    }
    //------------------------------------------------------------
    return @intCast(c.sqlite3_column_int64(stmt_handle, 0));
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns in a table.
pub fn getColumnCount(self: *Self, table_name: [*c]const u8) !usize {
    //------------------------------------------------------------
    self.clearError();
    //--------------------------------------------------------------------------------
    if (self.db_handle == null) {
        //------------------------------------------------------------
        return self.returnError(c.SQLITE_MISUSE, "invalid db_handle", error.InvalidDBHandle);
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    var stmt_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    var buffer: [MAX_TABLE_NAME:0]u8 = undefined;
    _ = c.sqlite3_snprintf(@intCast(buffer.len), &buffer, "SELECT * FROM %s LIMIT 1;", table_name);
    //------------------------------------------------------------
    const rc = c.sqlite3_prepare_v2(self.db_handle, @as([*:0]const u8, &buffer), -1, &stmt_handle, null);
    if (rc != c.SQLITE_OK) {
        //------------------------------------------------------------
        return self.returnError(rc, c.sqlite3_errmsg(self.db_handle), error.SQLitePrepareError);
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt_handle);
    //------------------------------------------------------------
    const step_rc = c.sqlite3_step(stmt_handle);
    if (step_rc != c.SQLITE_ROW) {
        //------------------------------------------------------------
        return self.returnError(step_rc, c.sqlite3_errmsg(self.db_handle), error.SQLiteStepError);
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    return @intCast(c.sqlite3_column_count(stmt_handle));
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Update SQLite column values.
pub fn updateSQLiteColumn(self: *Self, stmt_handle: ?*anyopaque, index: usize, column: *SQLiteColumn) !void {
    //------------------------------------------------------------
    self.clearError();
    //--------------------------------------------------------------------------------
    if (stmt_handle == null) {
        return self.returnError(c.SQLITE_MISUSE, "invalid stmt_handle", error.InvalidStmtHandle);
    }
    //------------------------------------------------------------
    const iCol: c_int = @intCast(index);
    //------------------------------------------------------------
    const name = c.sqlite3_column_name(stmt_handle, iCol);
    //------------------------------------------------------------
    const column_type: SQLiteColumnType = @enumFromInt(c.sqlite3_column_type(stmt_handle, iCol));
    //------------------------------------------------------------
    const raw_ptr = c.sqlite3_column_blob(stmt_handle, iCol);
    const len: usize = @intCast(c.sqlite3_column_bytes(stmt_handle, iCol));
    const integer = @as(i64, c.sqlite3_column_int64(stmt_handle, iCol));
    const float = @as(f64, c.sqlite3_column_double(stmt_handle, iCol));
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
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Update each SQLiteColumn in a row.
pub fn updateRow(
    allocator: std.mem.Allocator,
    row: anytype,
    columns: []SQLiteColumn,
) !void {
    //------------------------------------------------------------
    const Struct = @TypeOf(row.*);
    //------------------------------------------------------------
    for (columns) |column| {
        //------------------------------------------------------------
        const name = std.mem.span(column.name);
        //----------------------------------------
        inline for (std.meta.fields(Struct)) |field| {
            //----------------------------------------
            if (std.mem.eql(u8, name, field.name)) {
                //----------------------------------------
                switch (@typeInfo(field.type)) {
                    //----------------------------------------
                    .optional => {
                        if (column.column_type == .SQLITE_NULL) {
                            @field(row.*, field.name) = null;
                        } else {
                            switch (@typeInfo(@typeInfo(field.type).optional.child)) {
                                .int => @field(row.*, field.name) = @intCast(column.integer),
                                .float => @field(row.*, field.name) = column.float,
                                .pointer => @field(row.*, field.name) =
                                    try allocator.dupe(u8, column.ptr[0..column.len]),
                                else => return error.UnknownOptionalColumnType,
                            }
                        }
                    },
                    .int => @field(row.*, field.name) = @intCast(column.integer),
                    .float => @field(row.*, field.name) = column.float,
                    .pointer => {
                        @field(row.*, field.name) =
                            try allocator.dupe(u8, column.ptr[0..column.len]);
                    },
                    else => return error.UnknownColumnType,
                    //----------------------------------------
                }
                //----------------------------------------
                break;
                //----------------------------------------
            }
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Update each SQLiteColumn in a row map.
pub fn updateRowMap(
    allocator: std.mem.Allocator,
    row: *std.StringHashMap(ColumnValue),
    columns: []SQLiteColumn,
) !void {
    //------------------------------------------------------------
    for (columns) |column| {
        //------------------------------------------------------------
        const key = try allocator.dupe(u8, std.mem.span(column.name));
        //------------------------------------------------------------
        const value: ColumnValue = switch (column.column_type) {
            .SQLITE_NULL => .{ .null = {} },
            .SQLITE_INTEGER => .{ .integer = column.integer },
            .SQLITE_FLOAT => .{ .float = column.float },
            .SQLITE_TEXT, .SQLITE_BLOB => .{ .string = try allocator.dupe(u8, column.ptr[0..column.len]) },
            else => return error.UnknownColumnType,
        };
        //------------------------------------------------------------
        try row.put(key, value);
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// sets rc and errmsg then returns an rc.
pub fn returnErrorCode(self: *Self, rc: c_int, errmsg: [*:0]const u8) c_int {
    //------------------------------------------------------------
    self.setErrorMessage(rc, errmsg);
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// sets rc and errmsg then returns an error.
pub fn returnError(self: *Self, rc: c_int, errmsg: [*:0]const u8, err: anyerror) anyerror {
    //------------------------------------------------------------
    self.setErrorMessage(rc, errmsg);
    //------------------------------------------------------------
    return err;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// sets rc and errmsg then returns an error.
pub fn returnFormattedError(self: *Self, rc: c_int, comptime fmt: []const u8, args: anytype, err: anyerror) anyerror {
    //------------------------------------------------------------
    self.setFormattedErrorMessage(rc, fmt, args);
    //------------------------------------------------------------
    return err;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// clears rc and errmsg.
pub fn clearError(self: *Self) void {
    //------------------------------------------------------------
    self.rc = c.SQLITE_OK;
    //------------------------------------------------------------
    @memset(&self.errmsg, 0);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// sets rc and errmsg.
pub fn setErrorMessage(self: *Self, rc: c_int, errmsg: [*:0]const u8) void {
    //------------------------------------------------------------
    self.rc = rc;
    //------------------------------------------------------------
    @memset(&self.errmsg, 0);
    //------------------------------------------------------------
    if (errmsg[0] == 0) return;
    //------------------------------------------------------------
    var index: usize = 0;
    while (index < self.errmsg.len - 1) : (index += 1) {
        if (errmsg[index] == 0) break;
        self.errmsg[index] = errmsg[index];
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// sets rc and errmsg using passed in format and arguments.
pub fn setFormattedErrorMessage(self: *Self, rc: c_int, comptime fmt: []const u8, args: anytype) void {
    //------------------------------------------------------------
    self.rc = rc;
    //------------------------------------------------------------
    @memset(&self.errmsg, 0);
    //------------------------------------------------------------
    const max = self.errmsg.len - 1;
    _ = std.fmt.bufPrint(self.errmsg[0..max], fmt, args) catch {};
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// returns rc.
pub fn errorCode(self: *Self) c_int {
    //------------------------------------------------------------
    return self.rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// returns errmsg.
pub fn errorMessage(self: *Self) [*:0]const u8 {
    //------------------------------------------------------------
    return @as([*:0]const u8, &self.errmsg);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub const c = struct {
    //--------------------------------------------------------------------------------
    pub const SQLITE_INTEGER = @as(c_int, 1);
    pub const SQLITE_FLOAT = @as(c_int, 2);
    pub const SQLITE_TEXT = @as(c_int, 3);
    pub const SQLITE_BLOB = @as(c_int, 4);
    pub const SQLITE_NULL = @as(c_int, 5);
    //--------------------------------------------------------------------------------
    pub const SQLITE_OK = @as(c_int, 0);
    pub const SQLITE_ERROR = @as(c_int, 1);
    pub const SQLITE_INTERNAL = @as(c_int, 2);
    pub const SQLITE_PERM = @as(c_int, 3);
    pub const SQLITE_ABORT = @as(c_int, 4);
    pub const SQLITE_BUSY = @as(c_int, 5);
    pub const SQLITE_LOCKED = @as(c_int, 6);
    pub const SQLITE_NOMEM = @as(c_int, 7);
    pub const SQLITE_READONLY = @as(c_int, 8);
    pub const SQLITE_INTERRUPT = @as(c_int, 9);
    pub const SQLITE_IOERR = @as(c_int, 10);
    pub const SQLITE_CORRUPT = @as(c_int, 11);
    pub const SQLITE_NOTFOUND = @as(c_int, 12);
    pub const SQLITE_FULL = @as(c_int, 13);
    pub const SQLITE_CANTOPEN = @as(c_int, 14);
    pub const SQLITE_PROTOCOL = @as(c_int, 15);
    pub const SQLITE_EMPTY = @as(c_int, 16);
    pub const SQLITE_SCHEMA = @as(c_int, 17);
    pub const SQLITE_TOOBIG = @as(c_int, 18);
    pub const SQLITE_CONSTRAINT = @as(c_int, 19);
    pub const SQLITE_MISMATCH = @as(c_int, 20);
    pub const SQLITE_MISUSE = @as(c_int, 21);
    pub const SQLITE_NOLFS = @as(c_int, 22);
    pub const SQLITE_AUTH = @as(c_int, 23);
    pub const SQLITE_FORMAT = @as(c_int, 24);
    pub const SQLITE_RANGE = @as(c_int, 25);
    pub const SQLITE_NOTADB = @as(c_int, 26);
    pub const SQLITE_NOTICE = @as(c_int, 27);
    pub const SQLITE_WARNING = @as(c_int, 28);
    pub const SQLITE_ROW = @as(c_int, 100);
    pub const SQLITE_DONE = @as(c_int, 101);
    //--------------------------------------------------------------------------------
    pub const sqlite3 = anyopaque;
    pub const sqlite3_stmt = anyopaque;
    //--------------------------------------------------------------------------------
    pub var sqlite3_bind_blob: *const fn (stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) c_int = undefined;
    pub var sqlite3_bind_double: *const fn (stmt_handle: ?*anyopaque, iCol: c_int, float: f64) callconv(.c) c_int = undefined;
    pub var sqlite3_bind_int64: *const fn (stmt_handle: ?*anyopaque, iCol: c_int, integer: i64) callconv(.c) c_int = undefined;
    pub var sqlite3_bind_null: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int = undefined;
    pub var sqlite3_bind_text: *const fn (stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) c_int = undefined;
    pub var sqlite3_clear_bindings: *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int = undefined;
    pub var sqlite3_close: *const fn (db_handle: ?*anyopaque) callconv(.c) c_int = undefined;
    pub var sqlite3_column_blob: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_column_bytes: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int = undefined;
    pub var sqlite3_column_count: *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int = undefined;
    pub var sqlite3_column_double: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) f64 = undefined;
    pub var sqlite3_column_int64: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) i64 = undefined;
    pub var sqlite3_column_name: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_column_text: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_column_type: *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int = undefined;
    pub var sqlite3_data_count: *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int = undefined;
    pub var sqlite3_errmsg: *const fn (db_handle: ?*anyopaque) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_exec: *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, callback: ?*const fn (?*anyopaque, c_int, [*c][*c]u8, [*c][*c]u8) callconv(.c) c_int, ctx: ?*anyopaque, errmsg: [*c][*c]u8) callconv(.c) c_int = undefined;
    pub var sqlite3_finalize: *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int = undefined;
    pub var sqlite3_free: *const fn (ptr: ?*anyopaque) callconv(.c) void = undefined;
    pub var sqlite3_free_table: *const fn (results: [*c][*c]u8) callconv(.c) void = undefined;
    pub var sqlite3_get_table: *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, results: [*c][*c][*c]u8, row_count: [*c]c_int, column_count: [*c]c_int, errmsg: [*c][*c]u8) callconv(.c) c_int = undefined;
    pub var sqlite3_malloc64: *const fn (len: c_ulonglong) callconv(.c) ?*anyopaque = undefined;
    pub var sqlite3_mprintf: *const fn ([*c]const u8, ...) callconv(.c) [*c]u8 = undefined;
    pub var sqlite3_open: *const fn (filepath: [*:0]const u8, db_handle: *?*anyopaque) callconv(.c) c_int = undefined;
    pub var sqlite3_prepare_v2: *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, nByte: c_int, ppStmt: *?*anyopaque, pzTail: [*c][*c]const u8) callconv(.c) c_int = undefined;
    pub var sqlite3_realloc64: *const fn (ptr: ?*anyopaque, len: c_ulonglong) callconv(.c) ?*anyopaque = undefined;
    pub var sqlite3_reset: *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int = undefined;
    pub var sqlite3_snprintf: *const fn (c_int, [*c]u8, [*c]const u8, ...) callconv(.c) [*c]u8 = undefined;
    pub var sqlite3_step: *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int = undefined;
    //--------------------------------------------------------------------------------
};
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
var libsqlite: ?std.DynLib = null;
//--------------------------------------------------------------------------------
/// Open shared library.
pub fn openLibrary() !void {
    //------------------------------------------------------------
    if (libsqlite == null) {
        //------------------------------------------------------------
        libsqlite = std.DynLib.open("libsqlite3.so") catch return error.LibraryNotFound;
        //------------------------------------------------------------
        var lib = libsqlite orelse return error.LibraryNotOpen;
        //------------------------------------------------------------
        inline for (comptime std.meta.declarations(c)) |declaration| {
            if (comptime !std.mem.startsWith(u8, declaration.name, "sqlite3_")) continue;
            if (comptime @TypeOf(@field(c, declaration.name)) == type) continue;
            const T = @TypeOf(@field(c, declaration.name));
            @field(c, declaration.name) =
                lib.lookup(T, declaration.name) orelse return error.InvalidFunction;
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Close shared library.
pub fn closeLibrary() void {
    //------------------------------------------------------------
    if (libsqlite != null) libsqlite.?.close();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
