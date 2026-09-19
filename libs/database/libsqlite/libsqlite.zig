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
};
//--------------------------------------------------------------------------------
const MAX_TABLE_NAME = 256;
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
    clearError(errmsg);
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
    callback: ?*const fn (ctx: ?*anyopaque, argc: i32, argv: [*c][*c]u8, azColName: [*c][*c]u8) callconv(.c) i32,
    ctx: ?*anyopaque,
    errmsg: [*c][*c]u8,
) callconv(.c) i32 {
    //------------------------------------------------------------
    clearError(errmsg);
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
    errmsg: [*c][*c]u8,
) callconv(.c) i32 {
    //------------------------------------------------------------
    clearError(errmsg);
    //------------------------------------------------------------
    if (db_handle == null) {
        //------------------------------------------------------------
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
pub export fn sqliteBindBlob(stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i32, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) i32 {
    //----------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    return c.sqlite3_bind_blob(stmt, iCol, ptr, len, destructor_function);
    //----------------------------------------
}
//--------------------------------------------------------------------------------
/// Binds text data to a column.
pub export fn sqliteBindText(stmt_handle: ?*anyopaque, iCol: i32, ptr: [*c]const u8, len: i32, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) i32 {
    //------------------------------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_bind_text(stmt, iCol, ptr, len, destructor_function);
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
/// Returns an i32 integer.
pub export fn sqliteColumnInt(stmt_handle: ?*anyopaque, iCol: i32) callconv(.c) i32 {
    //------------------------------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //------------------------------------------------------------
    return c.sqlite3_column_int(stmt, iCol);
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
/// Free errmsg memory if not null
pub fn clearError(errmsg: [*c][*c]u8) void {
    if (errmsg.* != null) {
        c.sqlite3_free(errmsg.*);
        errmsg.* = null;
    }
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
/// Prepares a statement then steps through each row and outputs to flat array of columns.
pub export fn getSQLiteColumnsTable(
    db_handle: ?*anyopaque,
    sql: [*c]const u8,
    table_context: *?*anyopaque,
    sqlite_columns: *[*c]SQLiteColumn,
    row_count: *i32,
    column_count: *i32,
    errmsg: [*c][*c]u8,
) callconv(.c) i32 {
    //------------------------------------------------------------
    clearError(errmsg);
    //------------------------------------------------------------
    if (db_handle == null) {
        errmsg.* = c.sqlite3_mprintf("invalid db_handle");
        return c.SQLITE_MISUSE;
    }
    //------------------------------------------------------------
    const db: *c.sqlite3 = @ptrCast(@alignCast(db_handle.?));
    //------------------------------------------------------------
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena_allocator.allocator();
    //------------------------------------------------------------
    const table_ctx = allocator.create(SQLiteColumnsTable) catch {
        errmsg.* = c.sqlite3_mprintf("alloc error: table_ctx");
        return c.SQLITE_NOMEM;
    };
    //------------------------------------------------------------
    table_ctx.* = .{
        .arena_allocator = arena_allocator,
        .sqlite_columns = .empty,
    };
    //------------------------------------------------------------
    var stmt: ?*c.sqlite3_stmt = null;
    //------------------------------------------------------------
    const prepare_rc = c.sqlite3_prepare_v2(db, sql, -1, &stmt, null);
    //------------------------------------------------------------
    if (prepare_rc != c.SQLITE_OK) {
        //----------------------------------------
        errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
        return prepare_rc;
        //----------------------------------------
    }
    //------------------------------------------------------------
    const stmt_handle: ?*anyopaque = @ptrCast(stmt.?);
    //------------------------------------------------------------
    defer _ = c.sqlite3_finalize(stmt);
    //----------------------------------------
    column_count.* = c.sqlite3_column_count(stmt);
    if (column_count.* == 0) {
        return c.SQLITE_OK;
    }
    //----------------------------------------
    var column_name_ptrs = std.StringHashMap([*:0]u8).init(allocator);
    //------------------------------------------------------------
    row_count.* = 0;
    //------------------------------------------------------------
    while (true) {
        //------------------------------------------------------------
        const step_rc = c.sqlite3_step(stmt);
        //------------------------------------------------------------
        if (step_rc == c.SQLITE_ROW) {
            //------------------------------------------------------------
            for (0..@intCast(column_count.*)) |column_index| {
                //------------------------------------------------------------
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
                const name = sqlite_column.name[0..std.mem.len(sqlite_column.name)];
                //----------------------------------------
                var name_dest: [*:0]u8 = undefined;
                if (column_name_ptrs.get(name)) |existing_ptr| {
                    name_dest = existing_ptr;
                } else {
                    const name_buffer = allocator.alloc(u8, name.len + 1) catch {
                        errmsg.* = c.sqlite3_mprintf("alloc error: name_buffer");
                        return c.SQLITE_NOMEM;
                    };
                    @memcpy(name_buffer[0..name.len], name);
                    name_buffer[name.len] = 0;
                    name_dest = @ptrCast(name_buffer.ptr);
                    column_name_ptrs.put(name, name_dest) catch {
                        errmsg.* = c.sqlite3_mprintf("alloc error: column_name_ptrs");
                        return c.SQLITE_NOMEM;
                    };
                }
                sqlite_column.name = name_dest;
                //------------------------------------------------------------
                if (sqlite_column.column_type == .SQLITE_TEXT or sqlite_column.column_type == .SQLITE_BLOB) {
                    //----------------------------------------
                    const len: usize = @intCast(sqlite_column.len);
                    const data_buffer = allocator.alloc(u8, len) catch {
                        errmsg.* = c.sqlite3_mprintf("alloc error: data_buffer");
                        return c.SQLITE_NOMEM;
                    };
                    @memcpy(data_buffer, sqlite_column.ptr[0..len]);
                    sqlite_column.ptr = data_buffer.ptr;
                    //----------------------------------------
                }
                //------------------------------------------------------------
                table_ctx.sqlite_columns.append(allocator, sqlite_column) catch {
                    errmsg.* = c.sqlite3_mprintf("alloc error: sqlite_columns");
                    return c.SQLITE_NOMEM;
                };
                //------------------------------------------------------------
            }
            //------------------------------------------------------------
            row_count.* += 1;
            //------------------------------------------------------------
        } else if (step_rc == c.SQLITE_DONE) {
            //------------------------------------------------------------
            break;
            //------------------------------------------------------------
        } else {
            //------------------------------------------------------------
            errmsg.* = c.sqlite3_mprintf("%s", c.sqlite3_errmsg(db));
            return step_rc;
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //------------------------------------------------------------
    table_context.* = table_ctx;
    sqlite_columns.* = table_ctx.sqlite_columns.items.ptr;
    //------------------------------------------------------------
    return c.SQLITE_OK;
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Frees memory created by getSQLiteColumnsTable
pub export fn freeSQLiteColumnsTable(table_context: *?*anyopaque) callconv(.c) void {
    //------------------------------------------------------------
    if (table_context.* == null) return;
    //------------------------------------------------------------
    const table_ctx: *SQLiteColumnsTable = @ptrCast(@alignCast(table_context));
    table_ctx.arena_allocator.deinit();
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Prepares a statement then steps through each row and runs callback each time.
/// Optional context pointer can be used by callback function to maintain state.
pub export fn querySQLiteColumns(
    db_handle: ?*anyopaque,
    sql: [*c]const u8,
    callback: ?*const fn (ctx: ?*anyopaque, columns_ptr: [*]SQLiteColumn, column_count: i32) callconv(.c) i32,
    ctx: ?*anyopaque,
    errmsg: [*c][*c]u8,
) callconv(.c) i32 {
    //------------------------------------------------------------
    clearError(errmsg);
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
    if (column_count == 0) return c.SQLITE_OK;
    //------------------------------------------------------------
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const allocator = arena_allocator.allocator();
    //------------------------------------------------------------
    const sqlite_columns = allocator.alloc(SQLiteColumn, column_count) catch {
        errmsg.* = c.sqlite3_mprintf("alloc error: sqlite_columns");
        return c.SQLITE_NOMEM;
    };
    //------------------------------------------------------------
    const columns_ptr: [*]SQLiteColumn = sqlite_columns.ptr;
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
                    const update_rc = updateSQLiteColumn(
                        stmt_handle,
                        @intCast(column_index),
                        &columns_ptr[column_index],
                    );
                    if (update_rc != c.SQLITE_OK) {
                        //----------------------------------------
                        errmsg.* = c.sqlite3_mprintf("updateSQLiteColumn error: index = %d", column_index);
                        return update_rc;
                        //----------------------------------------
                    }
                    //------------------------------------------------------------
                }
                //------------------------------------------------------------
                const return_code = cb(
                    ctx,
                    columns_ptr,
                    @intCast(column_count),
                );
                if (return_code != c.SQLITE_OK) {
                    //----------------------------------------
                    errmsg.* = c.sqlite3_mprintf("querySQLiteColumns aborted (%d)", return_code);
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
/// Update SQLite column values.
pub export fn updateSQLiteColumn(stmt_handle: ?*anyopaque, index: i32, column: *SQLiteColumn) callconv(.c) i32 {
    //----------------------------------------
    if (stmt_handle == null) return c.SQLITE_MISUSE;
    //----------------------------------------
    const stmt: *c.sqlite3_stmt = @ptrCast(@alignCast(stmt_handle));
    //----------------------------------------
    const name = c.sqlite3_column_name(stmt, index);
    //------------------------------------------------------------
    const column_type: SQLiteColumnType = @enumFromInt(c.sqlite3_column_type(stmt, index));
    //------------------------------------------------------------
    const raw_ptr = c.sqlite3_column_blob(stmt, index);
    const len: i32 = c.sqlite3_column_bytes(stmt, index);
    const integer: i64 = c.sqlite3_column_int64(stmt, index);
    const float: f64 = c.sqlite3_column_double(stmt, index);
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
    errmsg: [*c][*c]u8,
) callconv(.c) i32 {
    //------------------------------------------------------------
    clearError(errmsg);
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
    return c.sqlite3_column_int(stmt, 0);
    //------------------------------------------------------------
}
//--------------------------------------------------------------------------------
/// Returns number of columns in a table.
pub export fn getColumnCount(
    db_handle: ?*anyopaque,
    table_name: [*c]const u8,
    errmsg: [*c][*c]u8,
) callconv(.c) i32 {
    //------------------------------------------------------------
    clearError(errmsg);
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
    return c.sqlite3_column_count(stmt);
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
