//--------------------------------------------------------------------------------
// Copyright 2026, Tim Brockley. All rights reserved.
// This software is licensed under the MIT License.
//--------------------------------------------------------------------------------
// Zig library to access functions exported by libsqlite.so
//--------------------------------------------------------------------------------
const std = @import("std");
const c = @import("c.zig");
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
var libsqlite: ?std.DynLib = null;
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub const SQLiteDB = Self;
//--------------------------------------------------------------------------------
const Self = @This();
db_handle: ?*anyopaque = null,
rc: c_int = c.SQLITE_OK,
errmsg: [256:0]u8 = [_:0]u8{0} ** 256,
//--------------------------------------------------------------------------------
/// Link shared library and return new connection instance
pub fn init() !Self {
    //------------------------------------------------------------
    try linkSharedLibrary();
    //----------------------------------------
    return .{};
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// sets rc and errmsg then returns an error
pub fn returnError(self: *Self, rc: c_int, errmsg: [*:0]const u8, err: anyerror) anyerror {
    //------------------------------------------------------------
    self.setError(rc, errmsg);
    //----------------------------------------
    return err;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// sets rc and errmsg then returns an rc
pub fn returnErrorCode(self: *Self, rc: c_int, errmsg: [*:0]const u8) c_int {
    //------------------------------------------------------------
    self.setError(rc, errmsg);
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// sets rc and errmsg then returns an error
pub fn returnFormattedError(self: *Self, rc: c_int, comptime fmt: []const u8, args: anytype, err: anyerror) anyerror {
    //------------------------------------------------------------
    self.setFormattedError(rc, fmt, args);
    //----------------------------------------
    return err;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// clears rc and errmsg
pub fn clearError(self: *Self) void {
    //------------------------------------------------------------
    self.rc = c.SQLITE_OK;
    //----------------------------------------
    @memset(&self.errmsg, 0);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// sets rc and errmsg
pub fn setError(self: *Self, rc: c_int, errmsg: [*:0]const u8) void {
    //------------------------------------------------------------
    self.rc = rc;
    //----------------------------------------
    @memset(&self.errmsg, 0);
    //----------------------------------------
    const max = self.errmsg.len - 1;
    var index: usize = 0;
    while (index < max and errmsg[index] != 0) : (index += 1) {}
    //----------------------------------------
    @memcpy(self.errmsg[0..index], errmsg[0..index]);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// sets rc and errmsg using passed in format and arguments
pub fn setFormattedError(self: *Self, rc: c_int, comptime fmt: []const u8, args: anytype) void {
    //------------------------------------------------------------
    self.rc = rc;
    //----------------------------------------
    @memset(&self.errmsg, 0);
    //----------------------------------------
    const max = self.errmsg.len - 1;
    _ = std.fmt.bufPrint(self.errmsg[0..max], fmt, args) catch {};
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// returns rc
pub fn errorCode(self: *Self) c_int {
    //------------------------------------------------------------
    return self.rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// returns errmsg
pub fn errorMessage(self: *Self) [*:0]const u8 {
    //----------------------------------------
    return @as([*:0]const u8, &self.errmsg);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Open database and update db_handle
pub fn connect(self: *Self, filepath: [*:0]const u8) !void {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    var errmsg: [*c]u8 = null;
    var db_handle: ?*anyopaque = null;
    //----------------------------------------
    const rc = lsSqliteOpen(filepath, &db_handle, &errmsg);
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        defer lsSqliteFree(errmsg);
        //----------------------------------------
        self.setError(rc, errmsg);
        //----------------------------------------
        return switch (rc) {
            c.SQLITE_BUSY => return error.Busy,
            c.SQLITE_LOCKED => return error.Locked,
            else => return error.OpenFailed,
        };
        //----------------------------------------
    }
    //------------------------------------------------------------
    self.db_handle = db_handle;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Close database and reset db_handle
pub fn close(self: *Self) void {
    //------------------------------------------------------------
    lsSqliteClose(self.db_handle);
    self.db_handle = null;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns last database error message.
pub fn sqliteErrmsg(self: *Self) [*c]const u8 {
    //------------------------------------------------------------
    return lsSqliteErrmsg(self.db_handle);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Updates result, row_count and column_count or errmsg if an error occurs.
pub fn sqliteGetTable(self: *Self, sql: [*c]const u8, results: [*c][*c][*c]u8, row_count: [*c]c_int, column_count: [*c]c_int, errmsg: [*c][*c]u8) c_int {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    const rc = lsSqliteGetTable(self.db_handle, sql, results, row_count, column_count, errmsg);
    //----------------------------------------
    if (rc != c.SQLITE_OK) self.setError(rc, errmsg.*.?);
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory allocated by sqliteGetTable.
pub fn sqliteFreeTable(_: *Self, results: [*c][*c]u8) void {
    //------------------------------------------------------------
    lsSqliteFreeTable(results);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Runs query and run callback function to deal with data for each row.
/// Optional context pointer can be used by callback function to maintain state.
pub fn sqliteExec(self: *Self, sql: [*c]const u8, callback: ?*const fn (?*anyopaque, c_int, [*c][*c]u8, [*c][*c]u8) callconv(.c) c_int, ctx: ?*anyopaque, errmsg: [*c][*c]u8) c_int {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    const rc = lsSqliteExec(self.db_handle, sql, callback, ctx, errmsg);
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
pub fn sqlitePrepare(self: *Self, sql: [*c]const u8, stmt_handle: *?*anyopaque, errmsg: *?[*:0]u8) c_int {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    const rc = lsSqlitePrepare(self.db_handle, sql, stmt_handle, errmsg);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, errmsg.*.?);
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Clears bindings on prepared statement.
pub fn sqliteClearBindings(self: *Self, stmt_handle: ?*anyopaque) c_int {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    const rc = lsSqliteClearBindings(stmt_handle);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, lsSqliteErrmsg(self.db_handle));
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds blob data to a column.
pub fn sqliteBindBlob(self: *Self, stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) c_int {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    const rc = lsSqliteBindBlob(stmt_handle, iCol, ptr, len, destructor_function);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, lsSqliteErrmsg(self.db_handle));
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds text data to a column.
pub fn sqliteBindText(self: *Self, stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) c_int {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    const rc = lsSqliteBindText(stmt_handle, iCol, ptr, len, destructor_function);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, lsSqliteErrmsg(self.db_handle));
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds in i64 to a column.
pub fn sqliteBindInt64(self: *Self, stmt_handle: ?*anyopaque, iCol: c_int, integer: i64) c_int {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    const rc = lsSqliteBindInt64(stmt_handle, iCol, integer);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, lsSqliteErrmsg(self.db_handle));
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds an f64 to a column.
pub fn sqliteBindDouble(self: *Self, stmt_handle: ?*anyopaque, iCol: c_int, float: f64) c_int {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    const rc = lsSqliteBindDouble(stmt_handle, iCol, float);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, lsSqliteErrmsg(self.db_handle));
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds a null value to a column.
pub fn sqliteBindNull(self: *Self, stmt_handle: ?*anyopaque, iCol: c_int) c_int {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    const rc = lsSqliteBindNull(stmt_handle, iCol);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, lsSqliteErrmsg(self.db_handle));
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns column type.
pub fn sqliteColumnType(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) c_int {
    //------------------------------------------------------------
    return lsSqliteColumnType(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a BLOB of bytes.
pub fn sqliteColumnBlob(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) [*c]const u8 {
    //------------------------------------------------------------
    return lsSqliteColumnBlob(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a UTF-8 text result (zero terminated).
pub fn sqliteColumnText(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) [*c]const u8 {
    //------------------------------------------------------------
    return lsSqliteColumnText(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns an i64 integer.
pub fn sqliteColumnInt64(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) i64 {
    //------------------------------------------------------------
    return lsSqliteColumnInt64(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns an f64 float value.
pub fn sqliteColumnDouble(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) f64 {
    //------------------------------------------------------------
    return lsSqliteColumnDouble(stmt_handle, iCol);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of bytes in column.
pub fn sqliteColumnBytes(_: *Self, stmt_handle: ?*anyopaque, iCol: c_int) usize {
    //------------------------------------------------------------
    return @intCast(lsSqliteColumnBytes(stmt_handle, iCol));
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns provided by statment.
pub fn sqliteColumnCount(_: *Self, stmt_handle: ?*anyopaque) c_int {
    //------------------------------------------------------------
    return lsSqliteColumnCount(stmt_handle);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns in current row (ONLY during SQLITE_ROW stage).
pub fn sqliteDataCount(_: *Self, stmt_handle: ?*anyopaque) c_int {
    //------------------------------------------------------------
    return lsSqliteDataCount(stmt_handle);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Runs sqlite3_step using statement handle.
pub fn sqliteStep(self: *Self, stmt_handle: ?*anyopaque) c_int {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    const rc = lsSqliteStep(stmt_handle);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, lsSqliteErrmsg(self.db_handle));
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Resets prepared statement handle (does not clear bindings).
pub fn sqliteReset(self: *Self, stmt_handle: ?*anyopaque) c_int {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    const rc = lsSqliteReset(stmt_handle);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, lsSqliteErrmsg(self.db_handle));
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Finalises prepared statement handle.
pub fn sqliteFinalize(self: *Self, stmt_handle: ?*anyopaque) c_int {
    //------------------------------------------------------------
    self.clearError();
    //----------------------------------------
    const rc = lsSqliteFinalize(stmt_handle);
    //----------------------------------------
    if (rc != c.SQLITE_OK) return self.returnErrorCode(rc, lsSqliteErrmsg(self.db_handle));
    //----------------------------------------
    return rc;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Returns a pointer to a block of memory at least N bytes.
pub fn sqliteMalloc64(_: *Self, len: c_ulonglong) ?*anyopaque {
    //------------------------------------------------------------
    return lsSqliteMalloc64(len);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a reallocated block of memory at least N bytes (old block freed by sqlite).
pub fn sqliteRealloc64(_: *Self, ptr: ?*anyopaque, len: c_ulonglong) ?*anyopaque {
    //------------------------------------------------------------
    return lsSqliteRealloc64(ptr, len);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory previously allocated using sqlite3_malloc/sqlite3_malloc64.
pub fn sqliteFree(_: *Self, ptr: ?*anyopaque) void {
    //------------------------------------------------------------
    lsSqliteFree(ptr);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Returns a pointer to a block of memory at least N bytes.
pub fn allocateBytes(_: *Self, len: usize) [*]u8 {
    //------------------------------------------------------------
    return lsAllocateBytes(len);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a reallocated block of memory at least N bytes (old block freed by sqlite).
pub fn reallocateBytes(_: *Self, ptr: ?*anyopaque, len: usize) [*]u8 {
    //------------------------------------------------------------
    return lsReallocateBytes(ptr, len);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns a pointer to a reallocated block of memory at least N bytes (old block freed by sqlite).
pub fn freeBytes(_: *Self, ptr: ?*anyopaque) void {
    //------------------------------------------------------------
    lsFreeBytes(ptr);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Prepares a statment then steps through each row and runs callback each time.
/// Optional context pointer can be used by callback function to maintain state.
pub fn queryCallback(
    self: *Self,
    sql: [*c]const u8,
    columns: *?[*]SQLiteColumn,
    column_count: *usize,
    callback: ?*const fn (?*anyopaque, [*]SQLiteColumn, usize) callconv(.c) c_int,
    ctx: ?*anyopaque,
) !void {
    //------------------------------------------------------------
    self.clearError();
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnError(
            c.SQLITE_MISUSE,
            "invalid db_handle",
            error.InvalidDBHandle,
        );
    }
    //------------------------------------------------------------
    var errmsg: [*c]u8 = null;
    var stmt_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    var rc = self.sqlitePrepare(sql, &stmt_handle, &errmsg);
    if (rc != c.SQLITE_OK) {
        defer lsSqliteFree(errmsg);
        return self.returnError(rc, errmsg, error.PrepareError);
    }
    //------------------------------------------------------------
    defer _ = self.sqliteFinalize(stmt_handle);
    //------------------------------------------------------------
    column_count.* = @intCast(self.sqliteColumnCount(stmt_handle));
    //------------------------------------------------------------
    const total_bytes: usize = column_count.* * @sizeOf(SQLiteColumn);
    const raw_ptr = self.sqliteMalloc64(@intCast(total_bytes)) orelse {
        return self.returnError(
            c.SQLITE_ERROR,
            "sqlite3_malloc64 error",
            error.SQLiteMalloc64Error,
        );
    };
    columns.* = @ptrCast(@alignCast(raw_ptr));
    const columns_ptr = columns.*.?;
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        rc = self.sqliteStep(stmt_handle);
        //------------------------------------------------------------
        if (rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            if (callback) |cb| {
                //------------------------------------------------------------
                for (0..column_count.*) |index| {
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
                const return_code = cb(ctx, columns_ptr, column_count.*);
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
            //----------------------------------------
            break;
            //----------------------------------------
        } else {
            //----------------------------------------
            return self.returnError(
                rc,
                lsSqliteErrmsg(self.db_handle),
                error.SQLiteStepError,
            );
            //----------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Prepares a statment then steps through each row and outputs to flat array of columns.
pub fn getSQLiteColumnsTable(self: *Self, table_name: [*c]const u8, table_ptr: *SQLiteColumnsTable) !void {
    //------------------------------------------------------------
    if (self.db_handle == null) {
        return self.returnError(
            c.SQLITE_MISUSE,
            "invalid db_handle",
            error.InvalidDBHandle,
        );
    }
    //----------------------------------------
    var errmsg: [*c]u8 = null;
    //----------------------------------------
    const rc = lsGetSQLiteColumnsTable(self.db_handle, table_name, table_ptr, &errmsg);
    //----------------------------------------
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        defer lsSqliteFree(errmsg);
        return self.returnError(rc, errmsg, error.GetSQLiteColumnsTableError);
        //----------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory created by getSQLiteColumnsTable
pub fn freeSQLiteColumnsTable(_: *Self, table_ptr: ?*SQLiteColumnsTable) void {
    //------------------------------------------------------------
    lsFreeSQLiteColumnsTable(table_ptr);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns total backed bytes required for name an blob data.
pub fn getTotalColumnDataBytes(self: *Self, table_name: [*c]const u8, errmsg: *?[*:0]u8) usize {
    //------------------------------------------------------------
    const total_bytes = lsGetTotalColumnDataBytes(self.db_handle, table_name, errmsg);
    //----------------------------------------
    self.setError(c.SQLITE_OK, errmsg.* orelse "");
    //----------------------------------------
    return total_bytes;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Update SQLite column values.
pub fn updateSQLiteColumn(self: *Self, stmt_handle: ?*anyopaque, index: usize, column: *SQLiteColumn) !void {
    //------------------------------------------------------------
    const rc = lsUpdateSQLiteColumn(stmt_handle, index, column);
    if (rc != c.SQLITE_OK) {
        //----------------------------------------
        return self.returnFormattedError(
            rc,
            "updateSQLiteColumn error: index = {d}",
            .{index},
            error.UpdateSQLiteColumnError,
        );
        //----------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Update each SQLiteColumn in a row
pub fn updateRow(
    allocator: std.mem.Allocator,
    row: anytype,
    columns: []SQLiteColumn,
) !void {
    //------------------------------------------------------------
    const Struct = @TypeOf(row.*);
    //----------------------------------------
    for (columns) |column| {
        //----------------------------------------
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
            //----------------------------------------
        }
        //----------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Update each SQLiteColumn in a row map
pub fn updateRowMap(
    allocator: std.mem.Allocator,
    row: *std.StringHashMap(ColumnValue),
    columns: []SQLiteColumn,
) !void {
    //------------------------------------------------------------
    for (columns) |column| {
        //----------------------------------------
        const key = try allocator.dupe(u8, std.mem.span(column.name));
        //----------------------------------------
        const value: ColumnValue = switch (column.column_type) {
            .SQLITE_NULL => .{ .null = {} },
            .SQLITE_INTEGER => .{ .integer = column.integer },
            .SQLITE_FLOAT => .{ .float = column.float },
            .SQLITE_TEXT, .SQLITE_BLOB => .{ .string = try allocator.dupe(u8, column.ptr[0..column.len]) },
            else => return error.UnknownColumnType,
        };
        //----------------------------------------
        try row.put(key, value);
        //----------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Returns number of rows in a table.
pub fn getRowCount(self: *Self, table_name: [*c]const u8, errmsg: *?[*:0]u8) usize {
    //------------------------------------------------------------
    const count = lsGetRowCount(self.db_handle, table_name, errmsg);
    //----------------------------------------
    self.setError(c.SQLITE_OK, errmsg.* orelse "");
    //----------------------------------------
    return count;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns in a table.
pub fn getColumnCount(self: *Self, table_name: [*c]const u8, errmsg: *?[*:0]u8) usize {
    //------------------------------------------------------------
    const count = lsGetColumnCount(self.db_handle, table_name, errmsg);
    //----------------------------------------
    self.setError(c.SQLITE_OK, errmsg.* orelse "");
    //----------------------------------------
    return count;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Link shared library and load function
pub fn linkSharedLibrary() !void {
    //------------------------------------------------------------
    if (libsqlite == null) {
        //------------------------------------------------------------
        libsqlite = std.DynLib.open("./libsqlite.so") catch std.DynLib.open("./libs/libsqlite.so") catch return error.LibraryNotFound;
        //------------------------------------------------------------
        var lib_sqlite = libsqlite.?;
        //------------------------------------------------------------
        lsQueryCallback = lib_sqlite.lookup(fnQueryCallback, "queryCallback") orelse return error.InvalidFunction;
        lsGetSQLiteColumnsTable = lib_sqlite.lookup(fnGetSQLiteColumnsTable, "getSQLiteColumnsTable") orelse return error.InvalidFunction;
        lsFreeSQLiteColumnsTable = lib_sqlite.lookup(fnFreeSQLiteColumnsTable, "freeSQLiteColumnsTable") orelse return error.InvalidFunction;
        lsGetTotalColumnDataBytes = lib_sqlite.lookup(fnGetTotalColumnDataBytes, "getTotalColumnDataBytes") orelse return error.InvalidFunction;
        lsUpdateSQLiteColumn = lib_sqlite.lookup(fnUpdateSQLiteColumn, "updateSQLiteColumn") orelse return error.InvalidFunction;
        lsGetRowCount = lib_sqlite.lookup(fnGetRowCount, "getRowCount") orelse return error.InvalidFunction;
        lsGetColumnCount = lib_sqlite.lookup(fnGetColumnCount, "getColumnCount") orelse return error.InvalidFunction;
        //------------------------------------------------------------
        lsAllocateBytes = lib_sqlite.lookup(fnAllocateBytes, "allocateBytes") orelse return error.InvalidFunction;
        lsReallocateBytes = lib_sqlite.lookup(fnReallocateBytes, "reallocateBytes") orelse return error.InvalidFunction;
        lsFreeBytes = lib_sqlite.lookup(fnFreeBytes, "freeBytes") orelse return error.InvalidFunction;
        //------------------------------------------------------------
        lsSqliteBindBlob = lib_sqlite.lookup(fnSqliteBindBlob, "sqliteBindBlob") orelse return error.InvalidFunction;
        lsSqliteBindDouble = lib_sqlite.lookup(fnSqliteBindDouble, "sqliteBindDouble") orelse return error.InvalidFunction;
        lsSqliteBindInt64 = lib_sqlite.lookup(fnSqliteBindInt64, "sqliteBindInt64") orelse return error.InvalidFunction;
        lsSqliteBindNull = lib_sqlite.lookup(fnSqliteBindNull, "sqliteBindNull") orelse return error.InvalidFunction;
        lsSqliteBindText = lib_sqlite.lookup(fnSqliteBindText, "sqliteBindText") orelse return error.InvalidFunction;
        lsSqliteClearBindings = lib_sqlite.lookup(fnSqliteClearBindings, "sqliteClearBindings") orelse return error.InvalidFunction;
        lsSqliteClose = lib_sqlite.lookup(fnSqliteClose, "sqliteClose") orelse return error.InvalidFunction;
        lsSqliteColumnBlob = lib_sqlite.lookup(fnSqliteColumnBlob, "sqliteColumnBlob") orelse return error.InvalidFunction;
        lsSqliteColumnBytes = lib_sqlite.lookup(fnSqliteColumnBytes, "sqliteColumnBytes") orelse return error.InvalidFunction;
        lsSqliteColumnCount = lib_sqlite.lookup(fnSqliteColumnCount, "sqliteColumnCount") orelse return error.InvalidFunction;
        lsSqliteColumnDouble = lib_sqlite.lookup(fnSqliteColumnDouble, "sqliteColumnDouble") orelse return error.InvalidFunction;
        lsSqliteColumnInt64 = lib_sqlite.lookup(fnSqliteColumnInt64, "sqliteColumnInt64") orelse return error.InvalidFunction;
        lsSqliteColumnText = lib_sqlite.lookup(fnSqliteColumnText, "sqliteColumnText") orelse return error.InvalidFunction;
        lsSqliteColumnType = lib_sqlite.lookup(fnSqliteColumnType, "sqliteColumnType") orelse return error.InvalidFunction;
        lsSqliteDataCount = lib_sqlite.lookup(fnSqliteDataCount, "sqliteDataCount") orelse return error.InvalidFunction;
        lsSqliteErrmsg = lib_sqlite.lookup(fnSqliteErrmsg, "sqliteErrmsg") orelse return error.InvalidFunction;
        lsSqliteExec = lib_sqlite.lookup(fnSqliteExec, "sqliteExec") orelse return error.InvalidFunction;
        lsSqliteFinalize = lib_sqlite.lookup(fnSqliteFinalize, "sqliteFinalize") orelse return error.InvalidFunction;
        lsSqliteFree = lib_sqlite.lookup(fnSqliteFree, "sqliteFree") orelse return error.InvalidFunction;
        lsSqliteFreeTable = lib_sqlite.lookup(fnSqliteFreeTable, "sqliteFreeTable") orelse return error.InvalidFunction;
        lsSqliteGetTable = lib_sqlite.lookup(fnSqliteGetTable, "sqliteGetTable") orelse return error.InvalidFunction;
        lsSqliteMalloc64 = lib_sqlite.lookup(fnSqliteMalloc64, "sqliteMalloc64") orelse return error.InvalidFunction;
        lsSqliteOpen = lib_sqlite.lookup(fnSqliteOpen, "sqliteOpen") orelse return error.InvalidFunction;
        lsSqlitePrepare = lib_sqlite.lookup(fnSqlitePrepare, "sqlitePrepare") orelse return error.InvalidFunction;
        lsSqliteRealloc64 = lib_sqlite.lookup(fnSqliteRealloc64, "sqliteRealloc64") orelse return error.InvalidFunction;
        lsSqliteReset = lib_sqlite.lookup(fnSqliteReset, "sqliteReset") orelse return error.InvalidFunction;
        lsSqliteStep = lib_sqlite.lookup(fnSqliteStep, "sqliteStep") orelse return error.InvalidFunction;
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub const fnQueryCallback = *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, columns: *?[*]SQLiteColumn, column_count: *usize, callback: ?*const fn (?*anyopaque, [*]SQLiteColumn, usize) callconv(.c) c_int, ctx: ?*anyopaque, errmsg: *?[*:0]u8) callconv(.c) c_int;
pub const fnGetSQLiteColumnsTable = *const fn (db_handle: ?*anyopaque, table_name: [*c]const u8, table_ptr: *SQLiteColumnsTable, errmsg: *?[*:0]u8) callconv(.c) c_int;
pub const fnFreeSQLiteColumnsTable = *const fn (table_ptr: ?*SQLiteColumnsTable) callconv(.c) void;
pub const fnGetTotalColumnDataBytes = *const fn (db_handle: ?*anyopaque, table_name: [*c]const u8, errmsg: *?[*:0]u8) callconv(.c) usize;
pub const fnUpdateSQLiteColumn = *const fn (stmt_handle: ?*anyopaque, index: usize, column: *SQLiteColumn) callconv(.c) c_int;
pub const fnGetRowCount = *const fn (db_handle: ?*anyopaque, table_name: [*c]const u8, errmsg: *?[*:0]u8) callconv(.c) usize;
pub const fnGetColumnCount = *const fn (db_handle: ?*anyopaque, table_name: [*c]const u8, errmsg: *?[*:0]u8) callconv(.c) usize;
//--------------------------------------------------------------------------------
pub const fnAllocateBytes = *const fn (len: usize) callconv(.c) [*]u8;
pub const fnReallocateBytes = *const fn (ptr: ?*anyopaque, len: usize) callconv(.c) [*]u8;
pub const fnFreeBytes = *const fn (ptr: ?*anyopaque) callconv(.c) void;
//--------------------------------------------------------------------------------
pub const fnSqliteBindBlob = *const fn (stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) c_int;
pub const fnSqliteBindDouble = *const fn (stmt_handle: ?*anyopaque, iCol: c_int, float: f64) callconv(.c) c_int;
pub const fnSqliteBindInt64 = *const fn (stmt_handle: ?*anyopaque, iCol: c_int, integer: i64) callconv(.c) c_int;
pub const fnSqliteBindNull = *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int;
pub const fnSqliteBindText = *const fn (stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) c_int;
pub const fnSqliteClearBindings = *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub const fnSqliteClose = *const fn (db_handle: ?*anyopaque) callconv(.c) void;
pub const fnSqliteColumnBlob = *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8;
pub const fnSqliteColumnBytes = *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int;
pub const fnSqliteColumnCount = *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub const fnSqliteColumnDouble = *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) f64;
pub const fnSqliteColumnInt64 = *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) i64;
pub const fnSqliteColumnText = *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8;
pub const fnSqliteColumnType = *const fn (stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int;
pub const fnSqliteDataCount = *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub const fnSqliteErrmsg = *const fn (db_handle: ?*anyopaque) callconv(.c) [*c]const u8;
pub const fnSqliteExec = *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, callback: ?*const fn (?*anyopaque, c_int, [*c][*c]u8, [*c][*c]u8) callconv(.c) c_int, ctx: ?*anyopaque, errmsg: [*c][*c]u8) callconv(.c) c_int;
pub const fnSqliteFinalize = *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub const fnSqliteFree = *const fn (ptr: ?*anyopaque) callconv(.c) void;
pub const fnSqliteFreeTable = *const fn (results: [*c][*c]u8) callconv(.c) void;
pub const fnSqliteGetTable = *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, results: [*c][*c][*c]u8, row_count: [*c]c_int, column_count: [*c]c_int, errmsg: [*c][*c]u8) callconv(.c) c_int;
pub const fnSqliteMalloc64 = *const fn (len: c_ulonglong) callconv(.c) ?*anyopaque;
pub const fnSqliteOpen = *const fn (filepath: [*:0]const u8, db_handle: *?*anyopaque, errmsg: *?[*:0]u8) callconv(.c) c_int;
pub const fnSqlitePrepare = *const fn (db_handle: ?*anyopaque, sql: [*c]const u8, stmt_handle: *?*anyopaque, errmsg: *?[*:0]u8) callconv(.c) c_int;
pub const fnSqliteRealloc64 = *const fn (ptr: ?*anyopaque, len: c_ulonglong) callconv(.c) ?*anyopaque;
pub const fnSqliteReset = *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub const fnSqliteStep = *const fn (stmt_handle: ?*anyopaque) callconv(.c) c_int;
//--------------------------------------------------------------------------------
var lsQueryCallback: fnQueryCallback = undefined;
var lsGetSQLiteColumnsTable: fnGetSQLiteColumnsTable = undefined;
var lsFreeSQLiteColumnsTable: fnFreeSQLiteColumnsTable = undefined;
var lsGetTotalColumnDataBytes: fnGetTotalColumnDataBytes = undefined;
var lsUpdateSQLiteColumn: fnUpdateSQLiteColumn = undefined;
var lsGetRowCount: fnGetRowCount = undefined;
var lsGetColumnCount: fnGetColumnCount = undefined;
//--------------------------------------------------------------------------------
var lsAllocateBytes: fnAllocateBytes = undefined;
var lsReallocateBytes: fnReallocateBytes = undefined;
var lsFreeBytes: fnFreeBytes = undefined;
//--------------------------------------------------------------------------------
pub var lsSqliteBindBlob: fnSqliteBindBlob = undefined;
pub var lsSqliteBindDouble: fnSqliteBindDouble = undefined;
pub var lsSqliteBindInt64: fnSqliteBindInt64 = undefined;
pub var lsSqliteBindNull: fnSqliteBindNull = undefined;
pub var lsSqliteBindText: fnSqliteBindText = undefined;
pub var lsSqliteClearBindings: fnSqliteClearBindings = undefined;
pub var lsSqliteClose: fnSqliteClose = undefined;
pub var lsSqliteColumnBlob: fnSqliteColumnBlob = undefined;
pub var lsSqliteColumnBytes: fnSqliteColumnBytes = undefined;
pub var lsSqliteColumnCount: fnSqliteColumnCount = undefined;
pub var lsSqliteColumnDouble: fnSqliteColumnDouble = undefined;
pub var lsSqliteColumnInt64: fnSqliteColumnInt64 = undefined;
pub var lsSqliteColumnText: fnSqliteColumnText = undefined;
pub var lsSqliteColumnType: fnSqliteColumnType = undefined;
pub var lsSqliteDataCount: fnSqliteDataCount = undefined;
pub var lsSqliteErrmsg: fnSqliteErrmsg = undefined;
pub var lsSqliteExec: fnSqliteExec = undefined;
pub var lsSqliteFinalize: fnSqliteFinalize = undefined;
pub var lsSqliteFree: fnSqliteFree = undefined;
pub var lsSqliteFreeTable: fnSqliteFreeTable = undefined;
pub var lsSqliteGetTable: fnSqliteGetTable = undefined;
pub var lsSqliteMalloc64: fnSqliteMalloc64 = undefined;
pub var lsSqliteOpen: fnSqliteOpen = undefined;
pub var lsSqlitePrepare: fnSqlitePrepare = undefined;
pub var lsSqliteRealloc64: fnSqliteRealloc64 = undefined;
pub var lsSqliteReset: fnSqliteReset = undefined;
pub var lsSqliteStep: fnSqliteStep = undefined;
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
