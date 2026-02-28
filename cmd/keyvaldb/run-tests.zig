//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
const std = @import("std");
const unittest = @import("libs/unittest26057.zig");
const keyvaldb = @import("main.zig");
//--------------------------------------------------------------------------------
const BRIGHT_ORANGE = "\x1B[38;5;214m";
const RESET = "\x1B[0m";
//--------------------------------------------------------------------------------
var ut: unittest = undefined;
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub fn main(init: std.process.Init) !void {
    //----------------------------------------------------------------------------
    ut = try unittest.init(.{ .io = init.io });
    //------------------------------------------------------------
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) std.debug.print("{s}!!! MEMORY LEAK DETECTED !!!{s}\n\n", .{ BRIGHT_ORANGE, RESET });
    const allocator = gpa.allocator();
    //----------------------------------------------------------------------------
    var kvdb = try keyvaldb.init(.{ .allocator = allocator, .processInit = init });
    //----------------------------------------------------------------------------
    const database_name = "test";
    const config_filename = ".keyvaldb.conf";
    //----------------------------------------------------------------------------
    const dir = std.Io.Dir.cwd();
    //----------------------------------------------------------------------------
    // delete database directory or file if it exists
    if (std.Io.Dir.cwd().statFile(init.io, database_name, .{})) |stat| {
        if (stat.kind == .directory or stat.kind == .file or stat.kind == .sym_link) try dir.deleteTree(init.io, database_name);
    } else |_| {}
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    try ut.compareStringSlice("config_filename", config_filename, keyvaldb.config_filename);
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    // createDatabase
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        // create file to test createDatabase returns error
        //------------------------------------------------------------
        const file = try dir.createFile(init.io, database_name, .{ .read = true, .truncate = true });
        defer file.close(init.io);
        //------------------------------------------------------------
        try ut.compareStringResultError(
            "createDatabase: error.InvalidDatabaseFilepath",
            kvdb.createDatabase(database_name),
            "",
            error.InvalidDatabaseFilepath,
        );
        //------------------------------------------------------------
        try dir.deleteTree(init.io, database_name);
        //------------------------------------------------------------
        try dir.createDirPath(init.io, database_name);
        //------------------------------------------------------------
        // create directory to test createDatabase returns error
        //------------------------------------------------------------
        try ut.compareStringResultError(
            "createDatabase: error.InvalidConfigFile",
            kvdb.createDatabase(database_name),
            "",
            error.InvalidConfigFile,
        );
        //------------------------------------------------------------
        try dir.deleteTree(init.io, database_name);
        //------------------------------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const home_directory = if (init.environ_map.get("HOME")) |home| home else "";
        //------------------------------------------------------------
        const test_cases = [_]struct { name: []const u8, directory: []const u8, expected_result: []const u8, expected_error: ?anyerror }{
            .{ .name = "createDatabase: error.InvalidDirectoryLocation", .directory = "", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "createDatabase: error.InvalidDirectoryLocation", .directory = "/", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "createDatabase: error.InvalidDirectoryLocation", .directory = "/root", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "createDatabase: error.InvalidDirectoryLocation", .directory = "/tmp", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "createDatabase: error.InvalidDirectoryLocation", .directory = "~", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "createDatabase: error.InvalidDirectoryLocation", .directory = home_directory, .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "createDatabase: test", .directory = "test", .expected_result = "", .expected_error = null },
            .{ .name = "createDatabase: error.DatabaseAlreadyExists", .directory = "test", .expected_result = "", .expected_error = error.DatabaseAlreadyExists },
        };
        //------------------------------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            try ut.compareStringResultError(
                test_case.name,
                kvdb.createDatabase(test_case.directory),
                test_case.expected_result,
                test_case.expected_error,
            );
            //------------------------------------------------------------
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    // repairDatabase
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        // database should already exist - no repair required
        //------------------------------------------------------------
        try ut.compareStringResultError(
            "repairDatabase: already exists - repair not required",
            kvdb.repairDatabase(database_name),
            "",
            null,
        );
        //------------------------------------------------------------
        // remove config file to test if repairDatabase creates it
        //------------------------------------------------------------
        const config_filepath = try std.fs.path.join(allocator, &[_][]const u8{ database_name, config_filename });
        defer allocator.free(config_filepath);
        try dir.deleteTree(init.io, config_filepath);
        //------------------------------------------------------------
        try ut.compareStringResultError(
            "repairDatabase: config file removed - repair required",
            kvdb.repairDatabase(database_name),
            "",
            null,
        );
        //------------------------------------------------------------
        // check if config file created by repairDatabase
        if (std.Io.Dir.cwd().statFile(init.io, config_filepath, .{})) |_| {
            try ut.pass("repairDatabase: config_filepath successfully created", "");
        } else |err| {
            try ut.errorFail("repairDatabase: config_filepath", err);
        }
        //------------------------------------------------------------
    }
    //----------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const test_cases = [_]struct { name: []const u8, directory: []const u8, expected_result: []const u8, expected_error: ?anyerror }{
            .{ .name = "repairDatabase: error.InvalidDirectoryLocation", .directory = "", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "repairDatabase: error.InvalidDirectoryLocation", .directory = "/", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "repairDatabase: error.DatabaseAlreadyExists", .directory = "test1", .expected_result = "", .expected_error = error.DatabaseDoesNotExist },
        };
        //------------------------------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            try ut.compareStringResultError(
                test_case.name,
                kvdb.repairDatabase(test_case.directory),
                test_case.expected_result,
                test_case.expected_error,
            );
            //----------------------------------------
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    // setKey
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const test_cases = [_]struct { name: []const u8, directory: []const u8, key: []const u8, value: []const u8, expected_result: []const u8, expected_error: ?anyerror }{
            .{ .name = "setKey: error.InvalidDirectoryLocation", .directory = "", .key = "", .value = "", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "setKey: error.InvalidDirectoryLocation", .directory = "/", .key = "", .value = "", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "setKey: error.DatabaseDoesNotExist", .directory = "test1", .key = "", .value = "", .expected_result = "", .expected_error = error.DatabaseDoesNotExist },
            .{ .name = "setKey: error.InvalidKeyName", .directory = "test", .key = "", .value = "", .expected_result = "", .expected_error = error.InvalidKeyName },
            .{ .name = "setKey: error.InvalidKeyName", .directory = "test", .key = "#", .value = "", .expected_result = "", .expected_error = error.InvalidKeyName },
            .{ .name = "setKey: test k1 v1", .directory = "test", .key = "k1", .value = "v1", .expected_result = "", .expected_error = null },
            .{ .name = "setKey: test k2 v2", .directory = "test", .key = "k2", .value = "v2", .expected_result = "", .expected_error = null },
            .{ .name = "setKey: test k3 v3", .directory = "test", .key = "k3", .value = "v3", .expected_result = "", .expected_error = null },
        };
        //------------------------------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            try ut.compareStringResultError(
                test_case.name,
                kvdb.setKey(test_case.directory, test_case.key, test_case.value),
                test_case.expected_result,
                test_case.expected_error,
            );
            //----------------------------------------
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    // getKey
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const test_cases = [_]struct { name: []const u8, directory: []const u8, key: []const u8, expected_result: []const u8, expected_error: ?anyerror }{
            .{ .name = "getKey: error.InvalidDirectoryLocation", .directory = "", .key = "", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "getKey: error.InvalidDirectoryLocation", .directory = "/", .key = "", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "getKey: error.DatabaseDoesNotExist", .directory = "test1", .key = "", .expected_result = "", .expected_error = error.DatabaseDoesNotExist },
            .{ .name = "getKey: error.InvalidKeyName", .directory = "test", .key = "", .expected_result = "", .expected_error = error.InvalidKeyName },
            .{ .name = "getKey: error.InvalidKeyName", .directory = "test", .key = "#", .expected_result = "", .expected_error = error.InvalidKeyName },
            .{ .name = "getKey: test k1", .directory = "test", .key = "k1", .expected_result = "v1", .expected_error = null },
            .{ .name = "getKey: test k2", .directory = "test", .key = "k2", .expected_result = "v2", .expected_error = null },
            .{ .name = "getKey: test k3", .directory = "test", .key = "k3", .expected_result = "v3", .expected_error = null },
        };
        //------------------------------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            const result_error = kvdb.getKey(test_case.directory, test_case.key);
            //----------------------------------------
            try ut.compareStringResultError(
                test_case.name,
                result_error,
                test_case.expected_result,
                test_case.expected_error,
            );
            //----------------------------------------
            if (result_error) |result| {
                defer allocator.free(result);
            } else |_| {}
            //----------------------------------------
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    // removeKey
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const test_cases = [_]struct { name: []const u8, directory: []const u8, key: []const u8, expected_result: []const u8, expected_error: ?anyerror }{
            .{ .name = "removeKey: error.InvalidDirectoryLocation", .directory = "", .key = "", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "removeKey: error.InvalidDirectoryLocation", .directory = "/", .key = "", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "removeKey: error.DatabaseDoesNotExist", .directory = "test1", .key = "", .expected_result = "", .expected_error = error.DatabaseDoesNotExist },
            .{ .name = "removeKey: error.InvalidKeyName", .directory = "test", .key = "", .expected_result = "", .expected_error = error.InvalidKeyName },
            .{ .name = "removeKey: error.InvalidKeyName", .directory = "test", .key = "#", .expected_result = "", .expected_error = error.InvalidKeyName },
            .{ .name = "removeKey: test k2", .directory = "test", .key = "k2", .expected_result = "", .expected_error = null },
        };
        //------------------------------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            try ut.compareStringResultError(
                test_case.name,
                kvdb.removeKey(test_case.directory, test_case.key),
                test_case.expected_result,
                test_case.expected_error,
            );
            //----------------------------------------
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    // listKeys
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const test_cases = [_]struct { name: []const u8, directory: []const u8, expected_result: []const u8, expected_error: ?anyerror }{
            .{ .name = "listKeys: error.InvalidDirectoryLocation", .directory = "", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "listKeys: error.InvalidDirectoryLocation", .directory = "/", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "listKeys: error.DatabaseDoesNotExist", .directory = "test1", .expected_result = "", .expected_error = error.DatabaseDoesNotExist },
            .{ .name = "listKeys: test", .directory = "test", .expected_result = "\x0AKEY\x20\x20VALUE\x0Ak1\x20\x20\x20v1\x0Ak3\x20\x20\x20v3\x0A\x0A", .expected_error = null },
        };
        //------------------------------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            const result_error = kvdb.listKeys(test_case.directory);
            //----------------------------------------
            try ut.compareStringResultError(
                test_case.name,
                result_error,
                test_case.expected_result,
                test_case.expected_error,
            );
            //----------------------------------------
            if (result_error) |result| {
                defer allocator.free(result);
            } else |_| {}
            //----------------------------------------
        }
        //------------------------------------------------------------
        _ = kvdb.removeKey(database_name, "k1") catch {};
        _ = kvdb.removeKey(database_name, "k2") catch {};
        _ = kvdb.removeKey(database_name, "k3") catch {};
        _ = kvdb.removeKey(database_name, "k4") catch {};
        //------------------------------------------------------------
        const result_error = kvdb.listKeys(database_name);
        //----------------------------------------
        try ut.compareStringResultError("listKeys", result_error, "no key-value pairs exist\n", null);
        //----------------------------------------
        if (result_error) |result| {
            defer allocator.free(result);
        } else |_| {}
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    // dropDatabase
    //--------------------------------------------------------------------------------
    {
        //------------------------------------------------------------
        const test_cases = [_]struct { name: []const u8, directory: []const u8, expected_result: []const u8, expected_error: ?anyerror }{
            .{ .name = "dropDatabase: error.InvalidDirectoryLocation", .directory = "", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "dropDatabase: error.InvalidDirectoryLocation", .directory = "/", .expected_result = "", .expected_error = error.InvalidDirectoryLocation },
            .{ .name = "dropDatabase: error.DatabaseDoesNotExist", .directory = "test1", .expected_result = "", .expected_error = error.DatabaseDoesNotExist },
            .{ .name = "dropDatabase: test", .directory = "test", .expected_result = "", .expected_error = null },
        };
        //------------------------------------------------------------
        inline for (test_cases) |test_case| {
            //----------------------------------------
            try ut.compareStringResultError(
                test_case.name,
                kvdb.dropDatabase(test_case.directory),
                test_case.expected_result,
                test_case.expected_error,
            );
            //----------------------------------------
        }
        //------------------------------------------------------------
        // check if database directory has been deleted by dropDatabase
        if (std.Io.Dir.cwd().statFile(init.io, database_name, .{})) |_| {
            try ut.fail("dropDatabase: database directory has not been deleted", "");
        } else |err| {
            try ut.compareError("dropDatabase: error.FileNotFound", err, error.FileNotFound);
        }
        //------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
    try ut.printSummary();
    //--------------------------------------------------------------------------------
    //################################################################################
    //--------------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
