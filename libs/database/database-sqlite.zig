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
rc: i32 = c.SQLITE_OK,
errmsg: [MAX_ERRMSG:0]u8 = [_:0]u8{0} ** MAX_ERRMSG,
//--------------------------------------------------------------------------------
pub const SQLiteDB = @This();
pub const Self = @This();
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub const SQLiteColumnType = enum(i32) { SQLITE_UNKNOWN = 0, SQLITE_INTEGER = 1, SQLITE_FLOAT = 2, SQLITE_TEXT = 3, SQLITE_BLOB = 4, SQLITE_NULL = 5 };
//--------------------------------------------------------------------------------
pub const SQLiteColumn = extern struct {
    index: i32 = 0,
    name: [*:0]const u8 = "",
    column_type: SQLiteColumnType = .SQLITE_UNKNOWN,
    ptr: [*]const u8 = "",
    len: i32 = 0,
    integer: i64 = 0,
    float: f64 = 0,
};
//--------------------------------------------------------------------------------
pub const SQLiteColumnsTable = struct {
    //----------------------------------------
    arena_allocator: std.heap.ArenaAllocator,
    //----------------------------------------
    sqlite_columns: std.ArrayList(SQLiteColumn) = .empty,
    //----------------------------------------
    row_count: i32 = 0,
    column_count: i32 = 0,
    //----------------------------------------
};
//--------------------------------------------------------------------------------
pub const ColumnValue = union(enum) {
    null: void,
    integer: i64,
    float: f64,
    string: []const u8,
    bytes: []u8,
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
    //------------------------------------------------------------
    self.db_handle = db_handle;
    //------------------------------------------------------------
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
pub fn sqliteGetTable(
    self: *Self,
    sql: [*c]const u8,
    results: [*c][*c][*c]u8,
    row_count: [*c]i32,
    column_count: [*c]i32,
    errmsg: [*c][*c]u8,
) i32 {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    if (sql == null or sql[0] == 0) {
        errmsg.* = c.sqlite3_mprintf("invalid sqlite query");
        return self.returnErrorCode(c.SQLITE_ERROR, "invalid sqlite query");
    }
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
pub fn sqliteExec(
    self: *Self,
    sql: [*c]const u8,
    callback: ?*const fn (ctx: ?*anyopaque, argc: i32, argv: [*c][*c]u8, azColName: [*c][*c]u8) callconv(.c) i32,
    ctx: ?*anyopaque,
    errmsg: [*c][*c]u8,
) i32 {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    if (sql == null or sql[0] == 0) {
        errmsg.* = c.sqlite3_mprintf("invalid sqlite query");
        return self.returnErrorCode(c.SQLITE_ERROR, "invalid sqlite query");
    }
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
pub fn sqlitePrepare(self: *Self, sql: [*c]const u8, stmt_handle: *?*anyopaque) i32 {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        stmt_handle.* = null;
        return self.returnErrorCode(c.SQLITE_MISUSE, "invalid db_handle");
    }
    //------------------------------------------------------------
    if (sql == null or sql[0] == 0) {
        return self.returnErrorCode(c.SQLITE_ERROR, "invalid sqlite query");
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
pub fn sqliteClearBindings(self: *Self, stmt_handle: ?*anyopaque) i32 {
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
pub fn sqliteBindBlob(self: *Self, stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i32, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) i32 {
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
pub fn sqliteBindText(self: *Self, stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i32, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) i32 {
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
pub fn sqliteBindInt64(self: *Self, stmt_handle: ?*anyopaque, iCol: i32, integer: i64) i32 {
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
pub fn sqliteBindDouble(self: *Self, stmt_handle: ?*anyopaque, iCol: i32, float: f64) i32 {
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
pub fn sqliteBindNull(self: *Self, stmt_handle: ?*anyopaque, iCol: i32) i32 {
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
pub fn sqliteColumnName(_: *Self, stmt_handle: ?*anyopaque, iCol: i32) [*c]const u8 {
    //------------------------------------------------------------
    return c.sqlite3_column_name(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns column type.
pub fn sqliteColumnType(_: *Self, stmt_handle: ?*anyopaque, iCol: i32) i32 {
    //------------------------------------------------------------
    return c.sqlite3_column_type(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a BLOB of bytes.
pub fn sqliteColumnBlob(_: *Self, stmt_handle: ?*anyopaque, iCol: i32) [*c]const u8 {
    //------------------------------------------------------------
    return c.sqlite3_column_blob(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a UTF-8 text result (zero terminated).
pub fn sqliteColumnText(_: *Self, stmt_handle: ?*anyopaque, iCol: i32) [*c]const u8 {
    //------------------------------------------------------------
    return c.sqlite3_column_text(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns an i32 integer.
pub fn sqliteColumnInt(_: *Self, stmt_handle: ?*anyopaque, iCol: i32) i32 {
    //------------------------------------------------------------
    return c.sqlite3_column_int64(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns an i64 integer.
pub fn sqliteColumnInt64(_: *Self, stmt_handle: ?*anyopaque, iCol: i32) i64 {
    //------------------------------------------------------------
    return c.sqlite3_column_int64(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns an f64 float value.
pub fn sqliteColumnDouble(_: *Self, stmt_handle: ?*anyopaque, iCol: i32) f64 {
    //------------------------------------------------------------
    return c.sqlite3_column_double(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of bytes in column.
pub fn sqliteColumnBytes(_: *Self, stmt_handle: ?*anyopaque, iCol: i32) i32 {
    //------------------------------------------------------------
    return c.sqlite3_column_bytes(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns provided by statement.
pub fn sqliteColumnCount(_: *Self, stmt_handle: ?*anyopaque) i32 {
    //------------------------------------------------------------
    return c.sqlite3_column_count(stmt_handle);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns in current row (ONLY during SQLITE_ROW stage).
pub fn sqliteDataCount(_: *Self, stmt_handle: ?*anyopaque) i32 {
    //------------------------------------------------------------
    return c.sqlite3_data_count(stmt_handle);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Runs c.sqlite3_step using statement handle.
pub fn sqliteStep(self: *Self, stmt_handle: ?*anyopaque) i32 {
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
pub fn sqliteReset(self: *Self, stmt_handle: ?*anyopaque) i32 {
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
pub fn sqliteFinalize(self: *Self, stmt_handle: ?*anyopaque) i32 {
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
pub fn sqliteMalloc64(_: *Self, len: u64) ?*anyopaque {
    //------------------------------------------------------------
    return c.sqlite3_malloc64(len);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a reallocated block of memory at least N bytes (old block freed by sqlite).
pub fn sqliteRealloc64(_: *Self, ptr: ?*anyopaque, len: u64) ?*anyopaque {
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
pub fn allocateBytes(_: *Self, len: u64) [*]u8 {
    //------------------------------------------------------------
    const raw_ptr = c.sqlite3_malloc64(len);
    //------------------------------------------------------------
    return @ptrCast(raw_ptr);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a reallocated block of memory at least N bytes (old block freed by sqlite).
pub fn reallocateBytes(_: *Self, ptr: ?*anyopaque, len: u64) [*]u8 {
    //------------------------------------------------------------
    const raw_ptr = c.sqlite3_realloc64(ptr, len);
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
/// Prepares a statement then steps through each row and outputs to flat array of columns.
pub fn getSQLiteColumnsTable(
    self: *Self,
    sql: [*c]const u8,
) !*SQLiteColumnsTable {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnError(c.SQLITE_MISUSE, "invalid db_handle", error.InvalidDBHandle);
    }
    //------------------------------------------------------------
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena_allocator.allocator();
    //------------------------------------------------------------
    const table = allocator.create(SQLiteColumnsTable) catch {
        return self.returnError(
            c.SQLITE_NOMEM,
            "alloc error: table",
            error.AllocatorCreateError,
        );
    };
    table.* = .{ .arena_allocator = arena_allocator };
    //------------------------------------------------------------
    var stmt_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    const rc = c.sqlite3_prepare_v2(self.db_handle, sql, -1, &stmt_handle, null);
    //------------------------------------------------------------
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        return self.returnSQLiteColumnsTableError(
            table,
            rc,
            c.sqlite3_errmsg(self.db_handle),
            error.SQLitePrepareError,
        );
        //----------------------------------------
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt_handle);
    //----------------------------------------
    table.column_count = c.sqlite3_column_count(stmt_handle);
    if (table.column_count == 0) return table;
    //----------------------------------------
    var column_name_ptrs = std.StringHashMap([*:0]u8).init(allocator);
    //------------------------------------------------------------
    table.row_count = 0;
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        const step_rc = c.sqlite3_step(stmt_handle);
        //------------------------------------------------------------
        if (step_rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            for (0..@intCast(table.column_count)) |column_index| {
                //------------------------------------------------------------
                var sqlite_column = SQLiteColumn{};
                //----------------------------------------
                try updateSQLiteColumn(self, stmt_handle, @intCast(column_index), &sqlite_column);
                //----------------------------------------
                const name = sqlite_column.name[0..std.mem.len(sqlite_column.name)];
                //----------------------------------------
                var name_dest: [*:0]u8 = undefined;
                if (column_name_ptrs.get(name)) |existing_ptr| {
                    name_dest = existing_ptr;
                } else {
                    const name_buffer = allocator.alloc(u8, name.len + 1) catch {
                        return self.returnSQLiteColumnsTableError(
                            table,
                            c.SQLITE_NOMEM,
                            "alloc error: name_buffer",
                            error.AllocationError,
                        );
                    };
                    @memcpy(name_buffer[0..name.len], name);
                    name_buffer[name.len] = 0;
                    name_dest = @ptrCast(name_buffer.ptr);
                    column_name_ptrs.put(name, name_dest) catch {
                        return self.returnSQLiteColumnsTableError(
                            table,
                            c.SQLITE_NOMEM,
                            "alloc error: column_name_ptrs",
                            error.AllocationError,
                        );
                    };
                }
                sqlite_column.name = name_dest;
                //------------------------------------------------------------
                if (sqlite_column.column_type == .SQLITE_TEXT or sqlite_column.column_type == .SQLITE_BLOB) {
                    //----------------------------------------
                    const len: usize = @intCast(sqlite_column.len);
                    const data_buffer = allocator.alloc(u8, len) catch {
                        return self.returnSQLiteColumnsTableError(
                            table,
                            c.SQLITE_NOMEM,
                            "alloc error: data_buffer",
                            error.AllocationError,
                        );
                    };
                    @memcpy(data_buffer, sqlite_column.ptr[0..len]);
                    sqlite_column.ptr = data_buffer.ptr;
                    //----------------------------------------
                }
                //------------------------------------------------------------
                table.sqlite_columns.append(allocator, sqlite_column) catch {
                    return self.returnSQLiteColumnsTableError(
                        table,
                        c.SQLITE_NOMEM,
                        "alloc error: table.sqlite_columns",
                        error.AllocationError,
                    );
                };
                //------------------------------------------------------------
            }
            //------------------------------------------------------------
            table.row_count += 1;
            //------------------------------------------------------------
        } else if (step_rc == c.SQLITE_DONE) {
            //------------------------------------------------------------
            break;
            //------------------------------------------------------------
        } else {
            //------------------------------------------------------------
            return self.returnSQLiteColumnsTableError(
                table,
                step_rc,
                c.sqlite3_errmsg(self.db_handle),
                error.SQLiteStepError,
            );
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    return table;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory, sets rc and errmsg then returns an error.
pub fn returnSQLiteColumnsTableError(self: *Self, table: *SQLiteColumnsTable, rc: i32, errmsg: [*:0]const u8, err: anyerror) anyerror {
    //------------------------------------------------------------
    self.freeSQLiteColumnsTable(table);
    //------------------------------------------------------------
    return self.returnError(rc, errmsg, err);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory created by getSQLiteColumnsTable
pub fn freeSQLiteColumnsTable(self: *Self, table: *SQLiteColumnsTable) void {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    table.arena_allocator.deinit();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Prepares a statement then steps through each row and runs callback each time.
/// Optional context pointer can be used by callback function to maintain state.
pub fn querySQLiteColumns(
    self: *Self,
    sql: [*c]const u8,
    callback: ?*const fn (ctx: ?*anyopaque, columns_ptr: [*]SQLiteColumn, column_count: i32) callconv(.c) i32,
    ctx: ?*anyopaque,
) !void {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnError(c.SQLITE_MISUSE, "invalid db_handle", error.InvalidDBHandle);
    }
    //------------------------------------------------------------
    if (sql == null or sql[0] == 0) {
        return self.returnError(c.SQLITE_ERROR, "invalid sqlite query", error.InvalidSQLiteQuery);
    }
    //------------------------------------------------------------
    var stmt_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    const rc = c.sqlite3_prepare_v2(self.db_handle, sql, -1, &stmt_handle, null);
    if (rc != c.SQLITE_OK) {
        return self.returnError(rc, c.sqlite3_errmsg(self.db_handle), error.SQLitePepareError);
    }
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt_handle);
    //------------------------------------------------------------
    const column_count: usize = @intCast(c.sqlite3_column_count(stmt_handle));
    if (column_count == 0) return;
    //------------------------------------------------------------
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const allocator = arena_allocator.allocator();
    //------------------------------------------------------------
    const sqlite_columns = allocator.alloc(SQLiteColumn, column_count) catch {
        return self.returnError(
            c.SQLITE_NOMEM,
            "alloc error: sqlite_columns",
            error.AllocatorCreateError,
        );
    };
    //------------------------------------------------------------
    const columns_ptr: [*]SQLiteColumn = sqlite_columns.ptr;
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        const step_rc = c.sqlite3_step(stmt_handle);
        //------------------------------------------------------------
        if (step_rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            if (callback) |cb| {
                //------------------------------------------------------------
                for (0..column_count) |column_index| {
                    //------------------------------------------------------------
                    columns_ptr[column_index] = .{};
                    //----------------------------------------
                    try self.updateSQLiteColumn(
                        stmt_handle,
                        @intCast(column_index),
                        &columns_ptr[column_index],
                    );
                    //----------------------------------------
                }
                //------------------------------------------------------------
                const return_code = cb(
                    ctx,
                    columns_ptr,
                    @intCast(column_count),
                );
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
        } else if (step_rc == c.SQLITE_DONE) {
            //------------------------------------------------------------
            break;
            //------------------------------------------------------------
        } else {
            //------------------------------------------------------------
            return self.returnError(
                step_rc,
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
/// Returns number of rows in a table.
pub fn getTableRowCount(self: *Self, table_name: [*c]const u8) !i32 {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnError(c.SQLITE_MISUSE, "invalid db_handle", error.InvalidDBHandle);
    }
    //------------------------------------------------------------
    if (!self.checkTableName(table_name)) {
        return self.returnError(c.SQLITE_ERROR, "invalid table_name", error.InvalidTableName);
    }
    //------------------------------------------------------------
    var stmt_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    var buffer: [MAX_TABLE_NAME:0]u8 = undefined;
    _ = try std.fmt.bufPrintSentinel(&buffer, "SELECT COUNT(*) FROM {s};", .{table_name}, 0);
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
    return c.sqlite3_column_int(stmt_handle, 0);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of rows in a sql query.
pub fn getRowCount(self: *Self, sql: [*c]const u8) !i32 {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnError(c.SQLITE_MISUSE, "invalid db_handle", error.InvalidDBHandle);
    }
    //------------------------------------------------------------
    var stmt_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    const rc = c.sqlite3_prepare_v2(
        self.db_handle,
        sql,
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
    var row_count: i32 = 0;
    //------------------------------------------------------------
    while (true) {
        const step_rc = c.sqlite3_step(stmt_handle);
        switch (step_rc) {
            c.SQLITE_ROW => row_count += 1,
            c.SQLITE_DONE => break,
            else => return self.returnError(step_rc, c.sqlite3_errmsg(self.db_handle), error.SQLiteStepError),
        }
    }
    //------------------------------------------------------------
    return row_count;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns in a sql query.
pub fn getColumnCount(self: *Self, sql: [*c]const u8) !i32 {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnError(c.SQLITE_MISUSE, "invalid db_handle", error.InvalidDBHandle);
    }
    //------------------------------------------------------------
    var stmt_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    const rc = c.sqlite3_prepare_v2(self.db_handle, sql, -1, &stmt_handle, null);
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
    return c.sqlite3_column_count(stmt_handle);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Update SQLite column values.
pub fn updateSQLiteColumn(
    self: *Self,
    stmt_handle: ?*anyopaque,
    index: i32,
    column: *SQLiteColumn,
) !void {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (stmt_handle == null) {
        return self.returnError(c.SQLITE_MISUSE, "invalid stmt_handle", error.InvalidStmtHandle);
    }
    //------------------------------------------------------------
    const name = c.sqlite3_column_name(stmt_handle, index);
    //------------------------------------------------------------
    const column_type: SQLiteColumnType = @enumFromInt(c.sqlite3_column_type(stmt_handle, index));
    //------------------------------------------------------------
    const raw_ptr = c.sqlite3_column_blob(stmt_handle, index);
    const len: i32 = c.sqlite3_column_bytes(stmt_handle, index);
    const integer: i64 = c.sqlite3_column_int64(stmt_handle, index);
    const float: f64 = c.sqlite3_column_double(stmt_handle, index);
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
                                .int => @field(row.*, field.name) = column.integer,
                                .float => @field(row.*, field.name) = column.float,
                                .pointer => @field(row.*, field.name) =
                                    try allocator.dupe(u8, column.ptr[0..@intCast(column.len)]),
                                else => return error.UnknownOptionalColumnType,
                            }
                        }
                    },
                    .int => @field(row.*, field.name) = column.integer,
                    .float => @field(row.*, field.name) = column.float,
                    .pointer => {
                        @field(row.*, field.name) =
                            try allocator.dupe(u8, column.ptr[0..@intCast(column.len)]);
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
            .SQLITE_TEXT => .{ .string = try allocator.dupe(u8, column.ptr[0..@intCast(column.len)]) },
            .SQLITE_BLOB => .{ .bytes = try allocator.dupe(u8, column.ptr[0..@intCast(column.len)]) },
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
/// Checks table name
pub fn checkTableName(_: *Self, table_name: [*c]const u8) bool {
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
/// Sets rc and errmsg then returns an rc.
pub fn returnErrorCode(self: *Self, rc: i32, errmsg: [*:0]const u8) i32 {
    //------------------------------------------------------------
    self.setErrorMessage(rc, errmsg);
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Sets rc and errmsg then returns an error.
pub fn returnError(self: *Self, rc: i32, errmsg: [*:0]const u8, err: anyerror) anyerror {
    //------------------------------------------------------------
    self.setErrorMessage(rc, errmsg);
    //------------------------------------------------------------
    return err;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Sets rc and errmsg then returns an error.
pub fn returnFormattedError(self: *Self, rc: i32, comptime fmt: []const u8, args: anytype, err: anyerror) anyerror {
    //------------------------------------------------------------
    self.setFormattedErrorMessage(rc, fmt, args);
    //------------------------------------------------------------
    return err;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Clears rc and errmsg.
pub fn clearError(self: *Self) void {
    //------------------------------------------------------------
    self.rc = c.SQLITE_OK;
    //------------------------------------------------------------
    @memset(&self.errmsg, 0);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Sets rc and errmsg.
pub fn setErrorMessage(self: *Self, rc: i32, errmsg: [*:0]const u8) void {
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
/// Sets rc and errmsg using passed in format and arguments.
pub fn setFormattedErrorMessage(self: *Self, rc: i32, comptime fmt: []const u8, args: anytype) void {
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
/// Returns rc.
pub fn errorCode(self: *Self) i32 {
    //------------------------------------------------------------
    return self.rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns errmsg.
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
    pub const SQLITE_INTEGER = @as(i32, 1);
    pub const SQLITE_FLOAT = @as(i32, 2);
    pub const SQLITE_TEXT = @as(i32, 3);
    pub const SQLITE_BLOB = @as(i32, 4);
    pub const SQLITE_NULL = @as(i32, 5);
    //--------------------------------------------------------------------------------
    pub const SQLITE_OK = @as(i32, 0);
    pub const SQLITE_ERROR = @as(i32, 1);
    pub const SQLITE_INTERNAL = @as(i32, 2);
    pub const SQLITE_PERM = @as(i32, 3);
    pub const SQLITE_ABORT = @as(i32, 4);
    pub const SQLITE_BUSY = @as(i32, 5);
    pub const SQLITE_LOCKED = @as(i32, 6);
    pub const SQLITE_NOMEM = @as(i32, 7);
    pub const SQLITE_READONLY = @as(i32, 8);
    pub const SQLITE_INTERRUPT = @as(i32, 9);
    pub const SQLITE_IOERR = @as(i32, 10);
    pub const SQLITE_CORRUPT = @as(i32, 11);
    pub const SQLITE_NOTFOUND = @as(i32, 12);
    pub const SQLITE_FULL = @as(i32, 13);
    pub const SQLITE_CANTOPEN = @as(i32, 14);
    pub const SQLITE_PROTOCOL = @as(i32, 15);
    pub const SQLITE_EMPTY = @as(i32, 16);
    pub const SQLITE_SCHEMA = @as(i32, 17);
    pub const SQLITE_TOOBIG = @as(i32, 18);
    pub const SQLITE_CONSTRAINT = @as(i32, 19);
    pub const SQLITE_MISMATCH = @as(i32, 20);
    pub const SQLITE_MISUSE = @as(i32, 21);
    pub const SQLITE_NOLFS = @as(i32, 22);
    pub const SQLITE_AUTH = @as(i32, 23);
    pub const SQLITE_FORMAT = @as(i32, 24);
    pub const SQLITE_RANGE = @as(i32, 25);
    pub const SQLITE_NOTADB = @as(i32, 26);
    pub const SQLITE_NOTICE = @as(i32, 27);
    pub const SQLITE_WARNING = @as(i32, 28);
    pub const SQLITE_ROW = @as(i32, 100);
    pub const SQLITE_DONE = @as(i32, 101);
    //--------------------------------------------------------------------------------
    pub const sqlite3 = anyopaque;
    pub const sqlite3_stmt = anyopaque;
    //--------------------------------------------------------------------------------
    pub var sqlite3_bind_blob: *const fn (stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i32, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) i32 = undefined;
    pub var sqlite3_bind_double: *const fn (stmt_handle: ?*anyopaque, iCol: i32, float: f64) callconv(.c) i32 = undefined;
    pub var sqlite3_bind_int64: *const fn (stmt_handle: ?*anyopaque, iCol: i32, integer: i64) callconv(.c) i32 = undefined;
    pub var sqlite3_bind_null: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32 = undefined;
    pub var sqlite3_bind_text: *const fn (stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i32, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) i32 = undefined;
    pub var sqlite3_clear_bindings: *const fn (stmt_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_close: *const fn (db_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_column_blob: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_column_bytes: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32 = undefined;
    pub var sqlite3_column_count: *const fn (stmt_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_column_double: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) f64 = undefined;
    pub var sqlite3_column_int: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32 = undefined;
    pub var sqlite3_column_int64: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i64 = undefined;
    pub var sqlite3_column_name: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_column_text: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_column_type: *const fn (stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32 = undefined;
    pub var sqlite3_data_count: *const fn (stmt_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_errmsg: *const fn (db_handle: ?*anyopaque) callconv(.c) [*c]const u8 = undefined;
    pub var sqlite3_exec: *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, callback: ?*const fn (?*anyopaque, i32, [*c][*c]u8, [*c][*c]u8) callconv(.c) i32, ctx: ?*anyopaque, errmsg: [*c][*c]u8) callconv(.c) i32 = undefined;
    pub var sqlite3_finalize: *const fn (stmt_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_free: *const fn (ptr: ?*anyopaque) callconv(.c) void = undefined;
    pub var sqlite3_free_table: *const fn (results: [*c][*c]u8) callconv(.c) void = undefined;
    pub var sqlite3_get_table: *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, results: [*c][*c][*c]u8, row_count: [*c]i32, column_count: [*c]i32, errmsg: [*c][*c]u8) callconv(.c) i32 = undefined;
    pub var sqlite3_malloc64: *const fn (len: u64) callconv(.c) ?*anyopaque = undefined;
    pub var sqlite3_mprintf: *const fn ([*c]const u8, ...) callconv(.c) [*c]u8 = undefined;
    pub var sqlite3_open: *const fn (filepath: [*:0]const u8, db_handle: *?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_prepare_v2: *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, nByte: i32, ppStmt: *?*anyopaque, pzTail: [*c][*c]const u8) callconv(.c) i32 = undefined;
    pub var sqlite3_realloc64: *const fn (ptr: ?*anyopaque, len: u64) callconv(.c) ?*anyopaque = undefined;
    pub var sqlite3_reset: *const fn (stmt_handle: ?*anyopaque) callconv(.c) i32 = undefined;
    pub var sqlite3_snprintf: *const fn (i32, [*c]u8, [*c]const u8, ...) callconv(.c) [*c]u8 = undefined;
    pub var sqlite3_step: *const fn (stmt_handle: ?*anyopaque) callconv(.c) i32 = undefined;
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
