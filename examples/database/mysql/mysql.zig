//--------------------------------------------------------------------------------
// sudo apt install libmariadb-dev libmariadb-dev-compat
// zig translate-c -lc /usr/include/mysql/mysql.h > mysql.zig
//--------------------------------------------------------------------------------
const __root = @This();
pub const __builtin = @import("std").zig.c_translation.builtins;
pub const __helpers = @import("std").zig.c_translation.helpers;
pub const struct___va_list_tag_1 = extern struct {
    unnamed_0: c_uint = 0,
    unnamed_1: c_uint = 0,
    unnamed_2: ?*anyopaque = null,
    unnamed_3: ?*anyopaque = null,
};
pub const __builtin_va_list = [1]struct___va_list_tag_1;
pub const va_list = __builtin_va_list;
pub const __gnuc_va_list = __builtin_va_list;
pub const ptrdiff_t = c_long;
pub const wchar_t = c_int;
pub const max_align_t = extern struct {
    __aro_max_align_ll: c_longlong = 0,
    __aro_max_align_ld: c_longdouble = 0,
};
pub const __u_char = u8;
pub const __u_short = c_ushort;
pub const __u_int = c_uint;
pub const __u_long = c_ulong;
pub const __int8_t = i8;
pub const __uint8_t = u8;
pub const __int16_t = c_short;
pub const __uint16_t = c_ushort;
pub const __int32_t = c_int;
pub const __uint32_t = c_uint;
pub const __int64_t = c_long;
pub const __uint64_t = c_ulong;
pub const __int_least8_t = __int8_t;
pub const __uint_least8_t = __uint8_t;
pub const __int_least16_t = __int16_t;
pub const __uint_least16_t = __uint16_t;
pub const __int_least32_t = __int32_t;
pub const __uint_least32_t = __uint32_t;
pub const __int_least64_t = __int64_t;
pub const __uint_least64_t = __uint64_t;
pub const __quad_t = c_long;
pub const __u_quad_t = c_ulong;
pub const __intmax_t = c_long;
pub const __uintmax_t = c_ulong;
pub const __dev_t = c_ulong;
pub const __uid_t = c_uint;
pub const __gid_t = c_uint;
pub const __ino_t = c_ulong;
pub const __ino64_t = c_ulong;
pub const __mode_t = c_uint;
pub const __nlink_t = c_ulong;
pub const __off_t = c_long;
pub const __off64_t = c_long;
pub const __pid_t = c_int;
pub const __fsid_t = extern struct {
    __val: [2]c_int = @import("std").mem.zeroes([2]c_int),
};
pub const __clock_t = c_long;
pub const __rlim_t = c_ulong;
pub const __rlim64_t = c_ulong;
pub const __id_t = c_uint;
pub const __time_t = c_long;
pub const __useconds_t = c_uint;
pub const __suseconds_t = c_long;
pub const __suseconds64_t = c_long;
pub const __daddr_t = c_int;
pub const __key_t = c_int;
pub const __clockid_t = c_int;
pub const __timer_t = ?*anyopaque;
pub const __blksize_t = c_long;
pub const __blkcnt_t = c_long;
pub const __blkcnt64_t = c_long;
pub const __fsblkcnt_t = c_ulong;
pub const __fsblkcnt64_t = c_ulong;
pub const __fsfilcnt_t = c_ulong;
pub const __fsfilcnt64_t = c_ulong;
pub const __fsword_t = c_long;
pub const __ssize_t = c_long;
pub const __syscall_slong_t = c_long;
pub const __syscall_ulong_t = c_ulong;
pub const __loff_t = __off64_t;
pub const __caddr_t = [*c]u8;
pub const __intptr_t = c_long;
pub const __socklen_t = c_uint;
pub const __sig_atomic_t = c_int;
pub const clock_t = __clock_t;
pub const time_t = __time_t;
pub const struct_tm = extern struct {
    tm_sec: c_int = 0,
    tm_min: c_int = 0,
    tm_hour: c_int = 0,
    tm_mday: c_int = 0,
    tm_mon: c_int = 0,
    tm_year: c_int = 0,
    tm_wday: c_int = 0,
    tm_yday: c_int = 0,
    tm_isdst: c_int = 0,
    tm_gmtoff: c_long = 0,
    tm_zone: [*c]const u8 = null,
    pub const mktime = __root.mktime;
    pub const asctime = __root.asctime;
    pub const asctime_r = __root.asctime_r;
    pub const timegm = __root.timegm;
    pub const timelocal = __root.timelocal;
    pub const r = __root.asctime_r;
};
pub const struct_timespec = extern struct {
    tv_sec: __time_t = 0,
    tv_nsec: __syscall_slong_t = 0,
    pub const nanosleep = __root.nanosleep;
    pub const timespec_get = __root.timespec_get;
    pub const get = __root.timespec_get;
};
pub const clockid_t = __clockid_t;
pub const timer_t = __timer_t;
pub const struct_itimerspec = extern struct {
    it_interval: struct_timespec = @import("std").mem.zeroes(struct_timespec),
    it_value: struct_timespec = @import("std").mem.zeroes(struct_timespec),
};
pub const struct_sigevent = opaque {};
pub const pid_t = __pid_t;
pub const struct___locale_data_2 = opaque {};
pub const struct___locale_struct = extern struct {
    __locales: [13]?*struct___locale_data_2 = @import("std").mem.zeroes([13]?*struct___locale_data_2),
    __ctype_b: [*c]const c_ushort = null,
    __ctype_tolower: [*c]const c_int = null,
    __ctype_toupper: [*c]const c_int = null,
    __names: [13][*c]const u8 = @import("std").mem.zeroes([13][*c]const u8),
};
pub const __locale_t = [*c]struct___locale_struct;
pub const locale_t = __locale_t;
pub extern fn clock() clock_t;
pub extern fn time(__timer: [*c]time_t) time_t;
pub extern fn difftime(__time1: time_t, __time0: time_t) f64;
pub extern fn mktime(__tp: [*c]struct_tm) time_t;
pub extern fn strftime(noalias __s: [*c]u8, __maxsize: usize, noalias __format: [*c]const u8, noalias __tp: [*c]const struct_tm) usize;
pub extern fn strftime_l(noalias __s: [*c]u8, __maxsize: usize, noalias __format: [*c]const u8, noalias __tp: [*c]const struct_tm, __loc: locale_t) usize;
pub extern fn gmtime(__timer: [*c]const time_t) [*c]struct_tm;
pub extern fn localtime(__timer: [*c]const time_t) [*c]struct_tm;
pub extern fn gmtime_r(noalias __timer: [*c]const time_t, noalias __tp: [*c]struct_tm) [*c]struct_tm;
pub extern fn localtime_r(noalias __timer: [*c]const time_t, noalias __tp: [*c]struct_tm) [*c]struct_tm;
pub extern fn asctime(__tp: [*c]const struct_tm) [*c]u8;
pub extern fn ctime(__timer: [*c]const time_t) [*c]u8;
pub extern fn asctime_r(noalias __tp: [*c]const struct_tm, noalias __buf: [*c]u8) [*c]u8;
pub extern fn ctime_r(noalias __timer: [*c]const time_t, noalias __buf: [*c]u8) [*c]u8;
pub extern var __tzname: [2][*c]u8;
pub extern var __daylight: c_int;
pub extern var __timezone: c_long;
pub extern var tzname: [2][*c]u8;
pub extern fn tzset() void;
pub extern var daylight: c_int;
pub extern var timezone: c_long;
pub extern fn timegm(__tp: [*c]struct_tm) time_t;
pub extern fn timelocal(__tp: [*c]struct_tm) time_t;
pub extern fn dysize(__year: c_int) c_int;
pub extern fn nanosleep(__requested_time: [*c]const struct_timespec, __remaining: [*c]struct_timespec) c_int;
pub extern fn clock_getres(__clock_id: clockid_t, __res: [*c]struct_timespec) c_int;
pub extern fn clock_gettime(__clock_id: clockid_t, __tp: [*c]struct_timespec) c_int;
pub extern fn clock_settime(__clock_id: clockid_t, __tp: [*c]const struct_timespec) c_int;
pub extern fn clock_nanosleep(__clock_id: clockid_t, __flags: c_int, __req: [*c]const struct_timespec, __rem: [*c]struct_timespec) c_int;
pub extern fn clock_getcpuclockid(__pid: pid_t, __clock_id: [*c]clockid_t) c_int;
pub extern fn timer_create(__clock_id: clockid_t, noalias __evp: ?*struct_sigevent, noalias __timerid: [*c]timer_t) c_int;
pub extern fn timer_delete(__timerid: timer_t) c_int;
pub extern fn timer_settime(__timerid: timer_t, __flags: c_int, noalias __value: [*c]const struct_itimerspec, noalias __ovalue: [*c]struct_itimerspec) c_int;
pub extern fn timer_gettime(__timerid: timer_t, __value: [*c]struct_itimerspec) c_int;
pub extern fn timer_getoverrun(__timerid: timer_t) c_int;
pub extern fn timespec_get(__ts: [*c]struct_timespec, __base: c_int) c_int;
pub const u_char = __u_char;
pub const u_short = __u_short;
pub const u_int = __u_int;
pub const u_long = __u_long;
pub const quad_t = __quad_t;
pub const u_quad_t = __u_quad_t;
pub const fsid_t = __fsid_t;
pub const loff_t = __loff_t;
pub const ino_t = __ino_t;
pub const dev_t = __dev_t;
pub const gid_t = __gid_t;
pub const mode_t = __mode_t;
pub const nlink_t = __nlink_t;
pub const uid_t = __uid_t;
pub const off_t = __off_t;
pub const id_t = __id_t;
pub const daddr_t = __daddr_t;
pub const caddr_t = __caddr_t;
pub const key_t = __key_t;
pub const ulong = c_ulong;
pub const ushort = c_ushort;
pub const uint = c_uint;
pub const u_int8_t = __uint8_t;
pub const u_int16_t = __uint16_t;
pub const u_int32_t = __uint32_t;
pub const u_int64_t = __uint64_t;
pub const register_t = c_int;
pub fn __bswap_16(arg___bsx: __uint16_t) callconv(.c) __uint16_t {
    var __bsx = arg___bsx;
    _ = &__bsx;
    return @byteSwap(@as(__uint16_t, __bsx));
}
pub fn __bswap_32(arg___bsx: __uint32_t) callconv(.c) __uint32_t {
    var __bsx = arg___bsx;
    _ = &__bsx;
    return @byteSwap(@as(__uint32_t, __bsx));
}
pub fn __bswap_64(arg___bsx: __uint64_t) callconv(.c) __uint64_t {
    var __bsx = arg___bsx;
    _ = &__bsx;
    return @byteSwap(@as(__uint64_t, __bsx));
}
pub fn __uint16_identity(arg___x: __uint16_t) callconv(.c) __uint16_t {
    var __x = arg___x;
    _ = &__x;
    return __x;
}
pub fn __uint32_identity(arg___x: __uint32_t) callconv(.c) __uint32_t {
    var __x = arg___x;
    _ = &__x;
    return __x;
}
pub fn __uint64_identity(arg___x: __uint64_t) callconv(.c) __uint64_t {
    var __x = arg___x;
    _ = &__x;
    return __x;
}
pub const __sigset_t = extern struct {
    __val: [16]c_ulong = @import("std").mem.zeroes([16]c_ulong),
};
pub const sigset_t = __sigset_t;
pub const struct_timeval = extern struct {
    tv_sec: __time_t = 0,
    tv_usec: __suseconds_t = 0,
};
pub const suseconds_t = __suseconds_t;
pub const __fd_mask = c_long;
pub const fd_set = extern struct {
    __fds_bits: [16]__fd_mask = @import("std").mem.zeroes([16]__fd_mask),
};
pub const fd_mask = __fd_mask;
pub extern fn select(__nfds: c_int, noalias __readfds: [*c]fd_set, noalias __writefds: [*c]fd_set, noalias __exceptfds: [*c]fd_set, noalias __timeout: [*c]struct_timeval) c_int;
pub extern fn pselect(__nfds: c_int, noalias __readfds: [*c]fd_set, noalias __writefds: [*c]fd_set, noalias __exceptfds: [*c]fd_set, noalias __timeout: [*c]const struct_timespec, noalias __sigmask: [*c]const __sigset_t) c_int;
pub const blksize_t = __blksize_t;
pub const blkcnt_t = __blkcnt_t;
pub const fsblkcnt_t = __fsblkcnt_t;
pub const fsfilcnt_t = __fsfilcnt_t;
const struct_unnamed_3 = extern struct {
    __low: c_uint = 0,
    __high: c_uint = 0,
};
pub const __atomic_wide_counter = extern union {
    __value64: c_ulonglong,
    __value32: struct_unnamed_3,
};
pub const struct___pthread_internal_list = extern struct {
    __prev: [*c]struct___pthread_internal_list = null,
    __next: [*c]struct___pthread_internal_list = null,
};
pub const __pthread_list_t = struct___pthread_internal_list;
pub const struct___pthread_internal_slist = extern struct {
    __next: [*c]struct___pthread_internal_slist = null,
};
pub const __pthread_slist_t = struct___pthread_internal_slist;
pub const struct___pthread_mutex_s = extern struct {
    __lock: c_int = 0,
    __count: c_uint = 0,
    __owner: c_int = 0,
    __nusers: c_uint = 0,
    __kind: c_int = 0,
    __spins: c_short = 0,
    __elision: c_short = 0,
    __list: __pthread_list_t = @import("std").mem.zeroes(__pthread_list_t),
};
pub const struct___pthread_rwlock_arch_t = extern struct {
    __readers: c_uint = 0,
    __writers: c_uint = 0,
    __wrphase_futex: c_uint = 0,
    __writers_futex: c_uint = 0,
    __pad3: c_uint = 0,
    __pad4: c_uint = 0,
    __cur_writer: c_int = 0,
    __shared: c_int = 0,
    __rwelision: i8 = 0,
    __pad1: [7]u8 = @import("std").mem.zeroes([7]u8),
    __pad2: c_ulong = 0,
    __flags: c_uint = 0,
};
pub const struct___pthread_cond_s = extern struct {
    __wseq: __atomic_wide_counter = @import("std").mem.zeroes(__atomic_wide_counter),
    __g1_start: __atomic_wide_counter = @import("std").mem.zeroes(__atomic_wide_counter),
    __g_size: [2]c_uint = @import("std").mem.zeroes([2]c_uint),
    __g1_orig_size: c_uint = 0,
    __wrefs: c_uint = 0,
    __g_signals: [2]c_uint = @import("std").mem.zeroes([2]c_uint),
    __unused_initialized_1: c_uint = 0,
    __unused_initialized_2: c_uint = 0,
};
pub const __tss_t = c_uint;
pub const __thrd_t = c_ulong;
pub const __once_flag = extern struct {
    __data: c_int = 0,
};
pub const pthread_t = c_ulong;
pub const pthread_mutexattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_condattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_key_t = c_uint;
pub const pthread_once_t = c_int;
pub const union_pthread_attr_t = extern union {
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_attr_t = union_pthread_attr_t;
pub const pthread_mutex_t = extern union {
    __data: struct___pthread_mutex_s,
    __size: [40]u8,
    __align: c_long,
};
pub const pthread_cond_t = extern union {
    __data: struct___pthread_cond_s,
    __size: [48]u8,
    __align: c_longlong,
};
pub const pthread_rwlock_t = extern union {
    __data: struct___pthread_rwlock_arch_t,
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_rwlockattr_t = extern union {
    __size: [8]u8,
    __align: c_long,
};
pub const pthread_spinlock_t = c_int;
pub const pthread_barrier_t = extern union {
    __size: [32]u8,
    __align: c_long,
};
pub const pthread_barrierattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const my_bool = u8;
pub const my_ulonglong = c_ulonglong;
pub const my_socket = c_int;
pub const STRING_RESULT: c_int = 0;
pub const REAL_RESULT: c_int = 1;
pub const INT_RESULT: c_int = 2;
pub const ROW_RESULT: c_int = 3;
pub const DECIMAL_RESULT: c_int = 4;
pub const enum_Item_result = c_uint;
pub const SHUTDOWN_DEFAULT: c_int = 0;
pub const KILL_QUERY: c_int = 254;
pub const KILL_CONNECTION: c_int = 255;
pub const enum_mysql_enum_shutdown_level = c_uint;
pub const COM_SLEEP: c_int = 0;
pub const COM_QUIT: c_int = 1;
pub const COM_INIT_DB: c_int = 2;
pub const COM_QUERY: c_int = 3;
pub const COM_FIELD_LIST: c_int = 4;
pub const COM_CREATE_DB: c_int = 5;
pub const COM_DROP_DB: c_int = 6;
pub const COM_REFRESH: c_int = 7;
pub const COM_SHUTDOWN: c_int = 8;
pub const COM_STATISTICS: c_int = 9;
pub const COM_PROCESS_INFO: c_int = 10;
pub const COM_CONNECT: c_int = 11;
pub const COM_PROCESS_KILL: c_int = 12;
pub const COM_DEBUG: c_int = 13;
pub const COM_PING: c_int = 14;
pub const COM_TIME: c_int = 15;
pub const COM_DELAYED_INSERT: c_int = 16;
pub const COM_CHANGE_USER: c_int = 17;
pub const COM_BINLOG_DUMP: c_int = 18;
pub const COM_TABLE_DUMP: c_int = 19;
pub const COM_CONNECT_OUT: c_int = 20;
pub const COM_REGISTER_SLAVE: c_int = 21;
pub const COM_STMT_PREPARE: c_int = 22;
pub const COM_STMT_EXECUTE: c_int = 23;
pub const COM_STMT_SEND_LONG_DATA: c_int = 24;
pub const COM_STMT_CLOSE: c_int = 25;
pub const COM_STMT_RESET: c_int = 26;
pub const COM_SET_OPTION: c_int = 27;
pub const COM_STMT_FETCH: c_int = 28;
pub const COM_DAEMON: c_int = 29;
pub const COM_UNSUPPORTED: c_int = 30;
pub const COM_RESET_CONNECTION: c_int = 31;
pub const COM_STMT_BULK_EXECUTE: c_int = 250;
pub const COM_RESERVED_1: c_int = 254;
pub const COM_END: c_int = 255;
pub const enum_enum_server_command = c_uint;
pub const struct_st_ma_pvio = opaque {};
pub const MARIADB_PVIO = struct_st_ma_pvio;
pub const struct_st_ma_connection_plugin = opaque {};
pub const struct_st_mariadb_net_extension_4 = opaque {};
pub const struct_st_net = extern struct {
    pvio: ?*MARIADB_PVIO = null,
    buff: [*c]u8 = null,
    buff_end: [*c]u8 = null,
    write_pos: [*c]u8 = null,
    read_pos: [*c]u8 = null,
    fd: my_socket = 0,
    remain_in_buf: c_ulong = 0,
    length: c_ulong = 0,
    buf_length: c_ulong = 0,
    where_b: c_ulong = 0,
    max_packet: c_ulong = 0,
    max_packet_size: c_ulong = 0,
    pkt_nr: c_uint = 0,
    compress_pkt_nr: c_uint = 0,
    write_timeout: c_uint = 0,
    read_timeout: c_uint = 0,
    retry_count: c_uint = 0,
    fcntl: c_int = 0,
    return_status: [*c]c_uint = null,
    reading_or_writing: u8 = 0,
    save_char: u8 = 0,
    unused_1: u8 = 0,
    tls_verify_status: u8 = 0,
    compress: my_bool = 0,
    unused_2: my_bool = 0,
    unused_3: [*c]u8 = null,
    last_errno: c_uint = 0,
    @"error": u8 = 0,
    unused_5: my_bool = 0,
    unused_6: my_bool = 0,
    last_error: [512]u8 = @import("std").mem.zeroes([512]u8),
    sqlstate: [6]u8 = @import("std").mem.zeroes([6]u8),
    extension: ?*struct_st_mariadb_net_extension_4 = null,
    pub const ma_net_init = __root.ma_net_init;
    pub const ma_net_end = __root.ma_net_end;
    pub const ma_net_clear = __root.ma_net_clear;
    pub const ma_net_flush = __root.ma_net_flush;
    pub const ma_net_write = __root.ma_net_write;
    pub const ma_net_write_buff = __root.ma_net_write_buff;
    pub const ma_net_write_command = __root.ma_net_write_command;
    pub const ma_net_real_write = __root.ma_net_real_write;
    pub const ma_net_read = __root.ma_net_read;
    pub const init = __root.ma_net_init;
    pub const end = __root.ma_net_end;
    pub const clear = __root.ma_net_clear;
    pub const flush = __root.ma_net_flush;
    pub const write = __root.ma_net_write;
    pub const command = __root.ma_net_write_command;
    pub const read = __root.ma_net_read;
};
pub const NET = struct_st_net;
pub const MYSQL_OPTION_MULTI_STATEMENTS_ON: c_int = 0;
pub const MYSQL_OPTION_MULTI_STATEMENTS_OFF: c_int = 1;
pub const enum_enum_mysql_set_option = c_uint;
pub const STATUS_TYPE: c_int = 0;
pub const SESSION_TRACK_TYPE: c_int = 1;
pub const enum_enum_mariadb_status_info = c_uint;
pub const SESSION_TRACK_SYSTEM_VARIABLES: c_int = 0;
pub const SESSION_TRACK_SCHEMA: c_int = 1;
pub const SESSION_TRACK_STATE_CHANGE: c_int = 2;
pub const SESSION_TRACK_GTIDS: c_int = 3;
pub const SESSION_TRACK_TRANSACTION_CHARACTERISTICS: c_int = 4;
pub const SESSION_TRACK_TRANSACTION_STATE: c_int = 5;
pub const enum_enum_session_state_type = c_uint;
pub const MYSQL_TYPE_DECIMAL: c_int = 0;
pub const MYSQL_TYPE_TINY: c_int = 1;
pub const MYSQL_TYPE_SHORT: c_int = 2;
pub const MYSQL_TYPE_LONG: c_int = 3;
pub const MYSQL_TYPE_FLOAT: c_int = 4;
pub const MYSQL_TYPE_DOUBLE: c_int = 5;
pub const MYSQL_TYPE_NULL: c_int = 6;
pub const MYSQL_TYPE_TIMESTAMP: c_int = 7;
pub const MYSQL_TYPE_LONGLONG: c_int = 8;
pub const MYSQL_TYPE_INT24: c_int = 9;
pub const MYSQL_TYPE_DATE: c_int = 10;
pub const MYSQL_TYPE_TIME: c_int = 11;
pub const MYSQL_TYPE_DATETIME: c_int = 12;
pub const MYSQL_TYPE_YEAR: c_int = 13;
pub const MYSQL_TYPE_NEWDATE: c_int = 14;
pub const MYSQL_TYPE_VARCHAR: c_int = 15;
pub const MYSQL_TYPE_BIT: c_int = 16;
pub const MYSQL_TYPE_TIMESTAMP2: c_int = 17;
pub const MYSQL_TYPE_DATETIME2: c_int = 18;
pub const MYSQL_TYPE_TIME2: c_int = 19;
pub const MYSQL_TYPE_JSON: c_int = 245;
pub const MYSQL_TYPE_NEWDECIMAL: c_int = 246;
pub const MYSQL_TYPE_ENUM: c_int = 247;
pub const MYSQL_TYPE_SET: c_int = 248;
pub const MYSQL_TYPE_TINY_BLOB: c_int = 249;
pub const MYSQL_TYPE_MEDIUM_BLOB: c_int = 250;
pub const MYSQL_TYPE_LONG_BLOB: c_int = 251;
pub const MYSQL_TYPE_BLOB: c_int = 252;
pub const MYSQL_TYPE_VAR_STRING: c_int = 253;
pub const MYSQL_TYPE_STRING: c_int = 254;
pub const MYSQL_TYPE_GEOMETRY: c_int = 255;
pub const MAX_NO_FIELD_TYPES: c_int = 256;
pub const enum_enum_field_types = c_uint;
pub extern var max_allowed_packet: c_ulong;
pub extern var net_buffer_length: c_ulong;
pub extern fn ma_net_init(net: [*c]NET, pvio: ?*MARIADB_PVIO) c_int;
pub extern fn ma_net_end(net: [*c]NET) void;
pub extern fn ma_net_clear(net: [*c]NET) void;
pub extern fn ma_net_flush(net: [*c]NET) c_int;
pub extern fn ma_net_write(net: [*c]NET, packet: [*c]const u8, len: usize) c_int;
pub extern fn ma_net_write_buff(net: [*c]NET, packet: [*c]const u8, len: usize) c_int;
pub extern fn ma_net_write_command(net: [*c]NET, command: u8, packet: [*c]const u8, len: usize, disable_flush: my_bool) c_int;
pub extern fn ma_net_real_write(net: [*c]NET, packet: [*c]const u8, len: usize) c_int;
pub extern fn ma_net_read(net: [*c]NET) c_ulong;
pub const struct_rand_struct = extern struct {
    seed1: c_ulong = 0,
    seed2: c_ulong = 0,
    max_value: c_ulong = 0,
    max_value_dbl: f64 = 0,
};
pub const struct_st_udf_args = extern struct {
    arg_count: c_uint = 0,
    arg_type: [*c]enum_Item_result = null,
    args: [*c][*c]u8 = null,
    lengths: [*c]c_ulong = null,
    maybe_null: [*c]u8 = null,
};
pub const UDF_ARGS = struct_st_udf_args;
pub const struct_st_udf_init = extern struct {
    maybe_null: my_bool = 0,
    decimals: c_uint = 0,
    max_length: c_uint = 0,
    ptr: [*c]u8 = null,
    const_item: my_bool = 0,
};
pub const UDF_INIT = struct_st_udf_init;
pub extern fn ma_scramble_323(to: [*c]u8, message: [*c]const u8, password: [*c]const u8) [*c]u8;
pub extern fn ma_scramble_41(buffer: [*c]const u8, scramble: [*c]const u8, password: [*c]const u8) void;
pub extern fn ma_hash_password(result: [*c]c_ulong, password: [*c]const u8, len: usize) void;
pub extern fn ma_make_scrambled_password(to: [*c]u8, password: [*c]const u8) void;
pub extern fn mariadb_load_defaults(conf_file: [*c]const u8, groups: [*c][*c]const u8, argc: [*c]c_int, argv: [*c][*c][*c]u8) void;
pub extern fn ma_thread_init() my_bool;
pub extern fn ma_thread_end() void;
pub const struct_st_list = extern struct {
    prev: [*c]struct_st_list = null,
    next: [*c]struct_st_list = null,
    data: ?*anyopaque = null,
    pub const list_add = __root.list_add;
    pub const list_delete = __root.list_delete;
    pub const list_reverse = __root.list_reverse;
    pub const list_free = __root.list_free;
    pub const list_length = __root.list_length;
    pub const list_walk = __root.list_walk;
    pub const add = __root.list_add;
    pub const delete = __root.list_delete;
    pub const reverse = __root.list_reverse;
    pub const free = __root.list_free;
    pub const length = __root.list_length;
    pub const walk = __root.list_walk;
};
pub const LIST = struct_st_list;
pub const list_walk_action = ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) c_int;
pub extern fn list_add(root: [*c]LIST, element: [*c]LIST) [*c]LIST;
pub extern fn list_delete(root: [*c]LIST, element: [*c]LIST) [*c]LIST;
pub extern fn list_cons(data: ?*anyopaque, root: [*c]LIST) [*c]LIST;
pub extern fn list_reverse(root: [*c]LIST) [*c]LIST;
pub extern fn list_free(root: [*c]LIST, free_data: c_uint) void;
pub extern fn list_length(list: [*c]LIST) c_uint;
pub extern fn list_walk(list: [*c]LIST, action: list_walk_action, argument: [*c]u8) c_int;
pub const _ISupper: c_int = 256;
pub const _ISlower: c_int = 512;
pub const _ISalpha: c_int = 1024;
pub const _ISdigit: c_int = 2048;
pub const _ISxdigit: c_int = 4096;
pub const _ISspace: c_int = 8192;
pub const _ISprint: c_int = 16384;
pub const _ISgraph: c_int = 32768;
pub const _ISblank: c_int = 1;
pub const _IScntrl: c_int = 2;
pub const _ISpunct: c_int = 4;
pub const _ISalnum: c_int = 8;
const enum_unnamed_5 = c_uint;
pub extern fn __ctype_b_loc() [*c][*c]const c_ushort;
pub extern fn __ctype_tolower_loc() [*c][*c]const __int32_t;
pub extern fn __ctype_toupper_loc() [*c][*c]const __int32_t;
pub extern fn isalnum(c_int) c_int;
pub extern fn isalpha(c_int) c_int;
pub extern fn iscntrl(c_int) c_int;
pub extern fn isdigit(c_int) c_int;
pub extern fn islower(c_int) c_int;
pub extern fn isgraph(c_int) c_int;
pub extern fn isprint(c_int) c_int;
pub extern fn ispunct(c_int) c_int;
pub extern fn isspace(c_int) c_int;
pub extern fn isupper(c_int) c_int;
pub extern fn isxdigit(c_int) c_int;
pub extern fn tolower(__c: c_int) c_int;
pub extern fn toupper(__c: c_int) c_int;
pub extern fn isblank(c_int) c_int;
pub extern fn isascii(__c: c_int) c_int;
pub extern fn toascii(__c: c_int) c_int;
pub extern fn _toupper(c_int) c_int;
pub extern fn _tolower(c_int) c_int;
pub extern fn isalnum_l(c_int, locale_t) c_int;
pub extern fn isalpha_l(c_int, locale_t) c_int;
pub extern fn iscntrl_l(c_int, locale_t) c_int;
pub extern fn isdigit_l(c_int, locale_t) c_int;
pub extern fn islower_l(c_int, locale_t) c_int;
pub extern fn isgraph_l(c_int, locale_t) c_int;
pub extern fn isprint_l(c_int, locale_t) c_int;
pub extern fn ispunct_l(c_int, locale_t) c_int;
pub extern fn isspace_l(c_int, locale_t) c_int;
pub extern fn isupper_l(c_int, locale_t) c_int;
pub extern fn isxdigit_l(c_int, locale_t) c_int;
pub extern fn isblank_l(c_int, locale_t) c_int;
pub extern fn __tolower_l(__c: c_int, __l: locale_t) c_int;
pub extern fn tolower_l(__c: c_int, __l: locale_t) c_int;
pub extern fn __toupper_l(__c: c_int, __l: locale_t) c_int;
pub extern fn toupper_l(__c: c_int, __l: locale_t) c_int;
pub const struct_ma_charset_info_st = extern struct {
    nr: c_uint = 0,
    state: c_uint = 0,
    csname: [*c]const u8 = null,
    name: [*c]const u8 = null,
    dir: [*c]const u8 = null,
    codepage: c_uint = 0,
    encoding: [*c]const u8 = null,
    char_minlen: c_uint = 0,
    char_maxlen: c_uint = 0,
    mb_charlen: ?*const fn (c: c_uint) callconv(.c) c_uint = null,
    mb_valid: ?*const fn (start: [*c]const u8, end: [*c]const u8) callconv(.c) c_uint = null,
    pub const mysql_cset_escape_quotes = __root.mysql_cset_escape_quotes;
    pub const mysql_cset_escape_slashes = __root.mysql_cset_escape_slashes;
    pub const quotes = __root.mysql_cset_escape_quotes;
    pub const slashes = __root.mysql_cset_escape_slashes;
};
pub const MARIADB_CHARSET_INFO = struct_ma_charset_info_st;
pub const mariadb_compiled_charsets: [*c]const MARIADB_CHARSET_INFO = @extern([*c]const MARIADB_CHARSET_INFO, .{
    .name = "mariadb_compiled_charsets",
});
pub extern var ma_default_charset_info: [*c]MARIADB_CHARSET_INFO;
pub extern var ma_charset_bin: [*c]MARIADB_CHARSET_INFO;
pub extern var ma_charset_latin1: [*c]MARIADB_CHARSET_INFO;
pub extern var ma_charset_utf8_general_ci: [*c]MARIADB_CHARSET_INFO;
pub extern var ma_charset_utf16le_general_ci: [*c]MARIADB_CHARSET_INFO;
pub extern fn find_compiled_charset(cs_number: c_uint) [*c]MARIADB_CHARSET_INFO;
pub extern fn find_compiled_charset_by_name(name: [*c]const u8) [*c]MARIADB_CHARSET_INFO;
pub extern fn mysql_cset_escape_quotes(cset: [*c]const MARIADB_CHARSET_INFO, newstr: [*c]u8, escapestr: [*c]const u8, escapestr_len: usize) usize;
pub extern fn mysql_cset_escape_slashes(cset: [*c]const MARIADB_CHARSET_INFO, newstr: [*c]u8, escapestr: [*c]const u8, escapestr_len: usize) usize;
pub extern fn madb_get_os_character_set() [*c]const u8;
pub const struct_st_ma_const_string = extern struct {
    str: [*c]const u8 = null,
    length: usize = 0,
    pub const mariadb_field_attr = __root.mariadb_field_attr;
    pub const attr = __root.mariadb_field_attr;
};
pub const MARIADB_CONST_STRING = struct_st_ma_const_string;
pub const struct_st_ma_const_data = extern struct {
    data: [*c]const u8 = null,
    length: usize = 0,
};
pub const MARIADB_CONST_DATA = struct_st_ma_const_data;
pub const struct_st_ma_used_mem = extern struct {
    next: [*c]struct_st_ma_used_mem = null,
    left: usize = 0,
    size: usize = 0,
};
pub const MA_USED_MEM = struct_st_ma_used_mem;
pub const struct_st_ma_mem_root = extern struct {
    free: [*c]MA_USED_MEM = null,
    used: [*c]MA_USED_MEM = null,
    pre_alloc: [*c]MA_USED_MEM = null,
    min_malloc: usize = 0,
    block_size: usize = 0,
    block_num: c_uint = 0,
    first_block_usage: c_uint = 0,
    error_handler: ?*const fn () callconv(.c) void = null,
};
pub const MA_MEM_ROOT = struct_st_ma_mem_root;
pub extern var mysql_port: c_uint;
pub extern var mysql_unix_port: [*c]u8;
pub extern var mariadb_deinitialize_ssl: c_uint;
pub const struct_st_mysql_field = extern struct {
    name: [*c]u8 = null,
    org_name: [*c]u8 = null,
    table: [*c]u8 = null,
    org_table: [*c]u8 = null,
    db: [*c]u8 = null,
    catalog: [*c]u8 = null,
    def: [*c]u8 = null,
    length: c_ulong = 0,
    max_length: c_ulong = 0,
    name_length: c_uint = 0,
    org_name_length: c_uint = 0,
    table_length: c_uint = 0,
    org_table_length: c_uint = 0,
    db_length: c_uint = 0,
    catalog_length: c_uint = 0,
    def_length: c_uint = 0,
    flags: c_uint = 0,
    decimals: c_uint = 0,
    charsetnr: c_uint = 0,
    type: enum_enum_field_types = @import("std").mem.zeroes(enum_enum_field_types),
    extension: ?*anyopaque = null,
};
pub const MYSQL_FIELD = struct_st_mysql_field;
pub const MYSQL_ROW = [*c][*c]u8;
pub const MYSQL_FIELD_OFFSET = c_uint;
pub extern var SQLSTATE_UNKNOWN: [*c]const u8;
pub const struct_st_mysql_rows = extern struct {
    next: [*c]struct_st_mysql_rows = null,
    data: MYSQL_ROW = null,
    length: c_ulong = 0,
};
pub const MYSQL_ROWS = struct_st_mysql_rows;
pub const MYSQL_ROW_OFFSET = [*c]MYSQL_ROWS;
pub const struct_st_mysql_data = extern struct {
    data: [*c]MYSQL_ROWS = null,
    embedded_info: ?*anyopaque = null,
    alloc: MA_MEM_ROOT = @import("std").mem.zeroes(MA_MEM_ROOT),
    rows: c_ulonglong = 0,
    fields: c_uint = 0,
    extension: ?*anyopaque = null,
};
pub const MYSQL_DATA = struct_st_mysql_data;
pub const MYSQL_OPT_CONNECT_TIMEOUT: c_int = 0;
pub const MYSQL_OPT_COMPRESS: c_int = 1;
pub const MYSQL_OPT_NAMED_PIPE: c_int = 2;
pub const MYSQL_INIT_COMMAND: c_int = 3;
pub const MYSQL_READ_DEFAULT_FILE: c_int = 4;
pub const MYSQL_READ_DEFAULT_GROUP: c_int = 5;
pub const MYSQL_SET_CHARSET_DIR: c_int = 6;
pub const MYSQL_SET_CHARSET_NAME: c_int = 7;
pub const MYSQL_OPT_LOCAL_INFILE: c_int = 8;
pub const MYSQL_OPT_PROTOCOL: c_int = 9;
pub const MYSQL_SHARED_MEMORY_BASE_NAME: c_int = 10;
pub const MYSQL_OPT_READ_TIMEOUT: c_int = 11;
pub const MYSQL_OPT_WRITE_TIMEOUT: c_int = 12;
pub const MYSQL_OPT_USE_RESULT: c_int = 13;
pub const MYSQL_OPT_USE_REMOTE_CONNECTION: c_int = 14;
pub const MYSQL_OPT_USE_EMBEDDED_CONNECTION: c_int = 15;
pub const MYSQL_OPT_GUESS_CONNECTION: c_int = 16;
pub const MYSQL_SET_CLIENT_IP: c_int = 17;
pub const MYSQL_SECURE_AUTH: c_int = 18;
pub const MYSQL_REPORT_DATA_TRUNCATION: c_int = 19;
pub const MYSQL_OPT_RECONNECT: c_int = 20;
pub const MYSQL_OPT_SSL_VERIFY_SERVER_CERT: c_int = 21;
pub const MYSQL_PLUGIN_DIR: c_int = 22;
pub const MYSQL_DEFAULT_AUTH: c_int = 23;
pub const MYSQL_OPT_BIND: c_int = 24;
pub const MYSQL_OPT_SSL_KEY: c_int = 25;
pub const MYSQL_OPT_SSL_CERT: c_int = 26;
pub const MYSQL_OPT_SSL_CA: c_int = 27;
pub const MYSQL_OPT_SSL_CAPATH: c_int = 28;
pub const MYSQL_OPT_SSL_CIPHER: c_int = 29;
pub const MYSQL_OPT_SSL_CRL: c_int = 30;
pub const MYSQL_OPT_SSL_CRLPATH: c_int = 31;
pub const MYSQL_OPT_CONNECT_ATTR_RESET: c_int = 32;
pub const MYSQL_OPT_CONNECT_ATTR_ADD: c_int = 33;
pub const MYSQL_OPT_CONNECT_ATTR_DELETE: c_int = 34;
pub const MYSQL_SERVER_PUBLIC_KEY: c_int = 35;
pub const MYSQL_ENABLE_CLEARTEXT_PLUGIN: c_int = 36;
pub const MYSQL_OPT_CAN_HANDLE_EXPIRED_PASSWORDS: c_int = 37;
pub const MYSQL_OPT_SSL_ENFORCE: c_int = 38;
pub const MYSQL_OPT_MAX_ALLOWED_PACKET: c_int = 39;
pub const MYSQL_OPT_NET_BUFFER_LENGTH: c_int = 40;
pub const MYSQL_OPT_TLS_VERSION: c_int = 41;
pub const MYSQL_OPT_ZSTD_COMPRESSION_LEVEL: c_int = 42;
pub const MYSQL_PROGRESS_CALLBACK: c_int = 5999;
pub const MYSQL_OPT_NONBLOCK: c_int = 6000;
pub const MYSQL_DATABASE_DRIVER: c_int = 7000;
pub const MARIADB_OPT_SSL_FP: c_int = 7001;
pub const MARIADB_OPT_SSL_FP_LIST: c_int = 7002;
pub const MARIADB_OPT_TLS_PASSPHRASE: c_int = 7003;
pub const MARIADB_OPT_TLS_CIPHER_STRENGTH: c_int = 7004;
pub const MARIADB_OPT_TLS_VERSION: c_int = 7005;
pub const MARIADB_OPT_TLS_PEER_FP: c_int = 7006;
pub const MARIADB_OPT_TLS_PEER_FP_LIST: c_int = 7007;
pub const MARIADB_OPT_CONNECTION_READ_ONLY: c_int = 7008;
pub const MYSQL_OPT_CONNECT_ATTRS: c_int = 7009;
pub const MARIADB_OPT_USERDATA: c_int = 7010;
pub const MARIADB_OPT_CONNECTION_HANDLER: c_int = 7011;
pub const MARIADB_OPT_PORT: c_int = 7012;
pub const MARIADB_OPT_UNIXSOCKET: c_int = 7013;
pub const MARIADB_OPT_PASSWORD: c_int = 7014;
pub const MARIADB_OPT_HOST: c_int = 7015;
pub const MARIADB_OPT_USER: c_int = 7016;
pub const MARIADB_OPT_SCHEMA: c_int = 7017;
pub const MARIADB_OPT_DEBUG: c_int = 7018;
pub const MARIADB_OPT_FOUND_ROWS: c_int = 7019;
pub const MARIADB_OPT_MULTI_RESULTS: c_int = 7020;
pub const MARIADB_OPT_MULTI_STATEMENTS: c_int = 7021;
pub const MARIADB_OPT_INTERACTIVE: c_int = 7022;
pub const MARIADB_OPT_PROXY_HEADER: c_int = 7023;
pub const MARIADB_OPT_IO_WAIT: c_int = 7024;
pub const MARIADB_OPT_SKIP_READ_RESPONSE: c_int = 7025;
pub const MARIADB_OPT_RESTRICTED_AUTH: c_int = 7026;
pub const MARIADB_OPT_RPL_REGISTER_REPLICA: c_int = 7027;
pub const MARIADB_OPT_STATUS_CALLBACK: c_int = 7028;
pub const MARIADB_OPT_SERVER_PLUGINS: c_int = 7029;
pub const MARIADB_OPT_BULK_UNIT_RESULTS: c_int = 7030;
pub const MARIADB_OPT_TLS_VERIFICATION_CALLBACK: c_int = 7031;
pub const enum_mysql_option = c_uint;
pub const MARIADB_CHARSET_ID: c_int = 0;
pub const MARIADB_CHARSET_NAME: c_int = 1;
pub const MARIADB_CLIENT_ERRORS: c_int = 2;
pub const MARIADB_CLIENT_VERSION: c_int = 3;
pub const MARIADB_CLIENT_VERSION_ID: c_int = 4;
pub const MARIADB_CONNECTION_ASYNC_TIMEOUT: c_int = 5;
pub const MARIADB_CONNECTION_ASYNC_TIMEOUT_MS: c_int = 6;
pub const MARIADB_CONNECTION_MARIADB_CHARSET_INFO: c_int = 7;
pub const MARIADB_CONNECTION_ERROR: c_int = 8;
pub const MARIADB_CONNECTION_ERROR_ID: c_int = 9;
pub const MARIADB_CONNECTION_HOST: c_int = 10;
pub const MARIADB_CONNECTION_INFO: c_int = 11;
pub const MARIADB_CONNECTION_PORT: c_int = 12;
pub const MARIADB_CONNECTION_PROTOCOL_VERSION_ID: c_int = 13;
pub const MARIADB_CONNECTION_PVIO_TYPE: c_int = 14;
pub const MARIADB_CONNECTION_SCHEMA: c_int = 15;
pub const MARIADB_CONNECTION_SERVER_TYPE: c_int = 16;
pub const MARIADB_CONNECTION_SERVER_VERSION: c_int = 17;
pub const MARIADB_CONNECTION_SERVER_VERSION_ID: c_int = 18;
pub const MARIADB_CONNECTION_SOCKET: c_int = 19;
pub const MARIADB_CONNECTION_SQLSTATE: c_int = 20;
pub const MARIADB_CONNECTION_SSL_CIPHER: c_int = 21;
pub const MARIADB_TLS_LIBRARY: c_int = 22;
pub const MARIADB_CONNECTION_TLS_VERSION: c_int = 23;
pub const MARIADB_CONNECTION_TLS_VERSION_ID: c_int = 24;
pub const MARIADB_CONNECTION_TYPE: c_int = 25;
pub const MARIADB_CONNECTION_UNIX_SOCKET: c_int = 26;
pub const MARIADB_CONNECTION_USER: c_int = 27;
pub const MARIADB_MAX_ALLOWED_PACKET: c_int = 28;
pub const MARIADB_NET_BUFFER_LENGTH: c_int = 29;
pub const MARIADB_CONNECTION_SERVER_STATUS: c_int = 30;
pub const MARIADB_CONNECTION_SERVER_CAPABILITIES: c_int = 31;
pub const MARIADB_CONNECTION_EXTENDED_SERVER_CAPABILITIES: c_int = 32;
pub const MARIADB_CONNECTION_CLIENT_CAPABILITIES: c_int = 33;
pub const MARIADB_CONNECTION_BYTES_READ: c_int = 34;
pub const MARIADB_CONNECTION_BYTES_SENT: c_int = 35;
pub const MARIADB_TLS_PEER_CERT_INFO: c_int = 36;
pub const MARIADB_TLS_VERIFY_STATUS: c_int = 37;
pub const enum_mariadb_value = c_uint;
pub const MYSQL_STATUS_READY: c_int = 0;
pub const MYSQL_STATUS_GET_RESULT: c_int = 1;
pub const MYSQL_STATUS_USE_RESULT: c_int = 2;
pub const MYSQL_STATUS_QUERY_SENT: c_int = 3;
pub const MYSQL_STATUS_SENDING_LOAD_DATA: c_int = 4;
pub const MYSQL_STATUS_FETCHING_DATA: c_int = 5;
pub const MYSQL_STATUS_NEXT_RESULT_PENDING: c_int = 6;
pub const MYSQL_STATUS_QUIT_SENT: c_int = 7;
pub const MYSQL_STATUS_STMT_RESULT: c_int = 8;
pub const enum_mysql_status = c_uint;
pub const MYSQL_PROTOCOL_DEFAULT: c_int = 0;
pub const MYSQL_PROTOCOL_TCP: c_int = 1;
pub const MYSQL_PROTOCOL_SOCKET: c_int = 2;
pub const MYSQL_PROTOCOL_PIPE: c_int = 3;
pub const MYSQL_PROTOCOL_MEMORY: c_int = 4;
pub const enum_mysql_protocol_type = c_uint;
pub const struct_st_dynamic_array_6 = opaque {};
pub const struct_st_mysql_options_extension_7 = opaque {};
pub const struct_st_mysql_options = extern struct {
    connect_timeout: c_uint = 0,
    read_timeout: c_uint = 0,
    write_timeout: c_uint = 0,
    port: c_uint = 0,
    protocol: c_uint = 0,
    client_flag: c_ulong = 0,
    host: [*c]u8 = null,
    user: [*c]u8 = null,
    password: [*c]u8 = null,
    unix_socket: [*c]u8 = null,
    db: [*c]u8 = null,
    init_command: ?*struct_st_dynamic_array_6 = null,
    my_cnf_file: [*c]u8 = null,
    my_cnf_group: [*c]u8 = null,
    charset_dir: [*c]u8 = null,
    charset_name: [*c]u8 = null,
    ssl_key: [*c]u8 = null,
    ssl_cert: [*c]u8 = null,
    ssl_ca: [*c]u8 = null,
    ssl_capath: [*c]u8 = null,
    ssl_cipher: [*c]u8 = null,
    shared_memory_base_name: [*c]u8 = null,
    max_allowed_packet: c_ulong = 0,
    use_ssl: my_bool = 0,
    compress: my_bool = 0,
    named_pipe: my_bool = 0,
    reconnect: my_bool = 0,
    unused_1: my_bool = 0,
    unused_2: my_bool = 0,
    unused_3: my_bool = 0,
    methods_to_use: enum_mysql_option = @import("std").mem.zeroes(enum_mysql_option),
    bind_address: [*c]u8 = null,
    secure_auth: my_bool = 0,
    report_data_truncation: my_bool = 0,
    local_infile_init: ?*const fn ([*c]?*anyopaque, [*c]const u8, ?*anyopaque) callconv(.c) c_int = null,
    local_infile_read: ?*const fn (?*anyopaque, [*c]u8, c_uint) callconv(.c) c_int = null,
    local_infile_end: ?*const fn (?*anyopaque) callconv(.c) void = null,
    local_infile_error: ?*const fn (?*anyopaque, [*c]u8, c_uint) callconv(.c) c_int = null,
    local_infile_userdata: ?*anyopaque = null,
    extension: ?*struct_st_mysql_options_extension_7 = null,
};
pub const MYSQL = struct_st_mysql;
pub const MYSQL_STMT_INITTED: c_int = 0;
pub const MYSQL_STMT_PREPARED: c_int = 1;
pub const MYSQL_STMT_EXECUTED: c_int = 2;
pub const MYSQL_STMT_WAITING_USE_OR_STORE: c_int = 3;
pub const MYSQL_STMT_USE_OR_STORE_CALLED: c_int = 4;
pub const MYSQL_STMT_USER_FETCHING: c_int = 5;
pub const MYSQL_STMT_FETCH_DONE: c_int = 6;
pub const enum_mysql_stmt_state = c_uint;
pub const enum_mysqlnd_stmt_state = enum_mysql_stmt_state;
const union_unnamed_8 = extern union {
    row_ptr: [*c]u8,
    indicator: [*c]u8,
};
pub const struct_st_mysql_bind = extern struct {
    length: [*c]c_ulong = null,
    is_null: [*c]my_bool = null,
    buffer: ?*anyopaque = null,
    @"error": [*c]my_bool = null,
    u: union_unnamed_8 = @import("std").mem.zeroes(union_unnamed_8),
    store_param_func: ?*const fn (net: [*c]NET, param: [*c]struct_st_mysql_bind) callconv(.c) void = null,
    fetch_result: ?*const fn ([*c]struct_st_mysql_bind, [*c]MYSQL_FIELD, row: [*c][*c]u8) callconv(.c) void = null,
    skip_result: ?*const fn ([*c]struct_st_mysql_bind, [*c]MYSQL_FIELD, row: [*c][*c]u8) callconv(.c) void = null,
    buffer_length: c_ulong = 0,
    offset: c_ulong = 0,
    length_value: c_ulong = 0,
    flags: c_uint = 0,
    pack_length: c_uint = 0,
    buffer_type: enum_enum_field_types = @import("std").mem.zeroes(enum_enum_field_types),
    error_value: my_bool = 0,
    is_unsigned: my_bool = 0,
    long_data_used: my_bool = 0,
    is_null_value: my_bool = 0,
    extension: ?*anyopaque = null,
};
pub const MYSQL_BIND = struct_st_mysql_bind;
pub const struct_st_mysqlnd_upsert_result = extern struct {
    warning_count: c_uint = 0,
    server_status: c_uint = 0,
    affected_rows: c_ulonglong = 0,
    last_insert_id: c_ulonglong = 0,
};
pub const mysql_upsert_status = struct_st_mysqlnd_upsert_result;
pub const mysql_stmt_fetch_row_func = ?*const fn (stmt: [*c]MYSQL_STMT, row: [*c][*c]u8) callconv(.c) c_int;
pub const struct_st_mysql_res = extern struct {
    row_count: c_ulonglong = 0,
    field_count: c_uint = 0,
    current_field: c_uint = 0,
    fields: [*c]MYSQL_FIELD = null,
    data: [*c]MYSQL_DATA = null,
    data_cursor: [*c]MYSQL_ROWS = null,
    field_alloc: MA_MEM_ROOT = @import("std").mem.zeroes(MA_MEM_ROOT),
    row: MYSQL_ROW = null,
    current_row: MYSQL_ROW = null,
    lengths: [*c]c_ulong = null,
    handle: [*c]MYSQL = null,
    eof: my_bool = 0,
    is_ps: my_bool = 0,
    pub const mysql_num_rows = __root.mysql_num_rows;
    pub const mysql_num_fields = __root.mysql_num_fields;
    pub const mysql_eof = __root.mysql_eof;
    pub const mysql_fetch_field_direct = __root.mysql_fetch_field_direct;
    pub const mysql_fetch_fields = __root.mysql_fetch_fields;
    pub const mysql_row_tell = __root.mysql_row_tell;
    pub const mysql_field_tell = __root.mysql_field_tell;
    pub const mysql_free_result = __root.mysql_free_result;
    pub const mysql_data_seek = __root.mysql_data_seek;
    pub const mysql_row_seek = __root.mysql_row_seek;
    pub const mysql_field_seek = __root.mysql_field_seek;
    pub const mysql_fetch_row = __root.mysql_fetch_row;
    pub const mysql_fetch_lengths = __root.mysql_fetch_lengths;
    pub const mysql_fetch_field = __root.mysql_fetch_field;
    pub const mysql_free_result_start = __root.mysql_free_result_start;
    pub const mysql_free_result_cont = __root.mysql_free_result_cont;
    pub const rows = __root.mysql_num_rows;
    pub const direct = __root.mysql_fetch_field_direct;
    pub const tell = __root.mysql_row_tell;
    pub const result = __root.mysql_free_result;
    pub const seek = __root.mysql_data_seek;
    pub const field = __root.mysql_fetch_field;
    pub const start = __root.mysql_free_result_start;
    pub const cont = __root.mysql_free_result_cont;
};
pub const MYSQL_RES = struct_st_mysql_res;
pub const mysql_stmt_use_or_store_func = ?*const fn ([*c]MYSQL_STMT) callconv(.c) [*c]MYSQL_RES;
pub const ps_result_callback = ?*const fn (data: ?*anyopaque, column: c_uint, row: [*c][*c]u8) callconv(.c) void;
pub const ps_param_callback = ?*const fn (data: ?*anyopaque, bind: [*c]MYSQL_BIND, row_nr: c_uint) callconv(.c) my_bool;
pub const struct_st_mysql_stmt = extern struct {
    mem_root: MA_MEM_ROOT = @import("std").mem.zeroes(MA_MEM_ROOT),
    mysql: [*c]MYSQL = null,
    stmt_id: c_ulong = 0,
    flags: c_ulong = 0,
    state: enum_mysqlnd_stmt_state = @import("std").mem.zeroes(enum_mysqlnd_stmt_state),
    fields: [*c]MYSQL_FIELD = null,
    field_count: c_uint = 0,
    param_count: c_uint = 0,
    send_types_to_server: u8 = 0,
    params: [*c]MYSQL_BIND = null,
    bind: [*c]MYSQL_BIND = null,
    result: MYSQL_DATA = @import("std").mem.zeroes(MYSQL_DATA),
    result_cursor: [*c]MYSQL_ROWS = null,
    bind_result_done: my_bool = 0,
    bind_param_done: my_bool = 0,
    upsert_status: mysql_upsert_status = @import("std").mem.zeroes(mysql_upsert_status),
    last_errno: c_uint = 0,
    last_error: [513]u8 = @import("std").mem.zeroes([513]u8),
    sqlstate: [6]u8 = @import("std").mem.zeroes([6]u8),
    update_max_length: my_bool = 0,
    prefetch_rows: c_ulong = 0,
    list: LIST = @import("std").mem.zeroes(LIST),
    cursor_exists: my_bool = 0,
    extension: ?*anyopaque = null,
    fetch_row_func: mysql_stmt_fetch_row_func = null,
    execute_count: c_uint = 0,
    default_rset_handler: mysql_stmt_use_or_store_func = null,
    request_buffer: [*c]u8 = null,
    array_size: c_uint = 0,
    row_size: usize = 0,
    prebind_params: c_uint = 0,
    user_data: ?*anyopaque = null,
    result_callback: ps_result_callback = null,
    param_callback: ps_param_callback = null,
    request_length: usize = 0,
    sql: MARIADB_CONST_STRING = @import("std").mem.zeroes(MARIADB_CONST_STRING),
    pub const stmt_set_error = __root.stmt_set_error;
    pub const mysql_stmt_prepare = __root.mysql_stmt_prepare;
    pub const mysql_stmt_execute = __root.mysql_stmt_execute;
    pub const mysql_stmt_fetch = __root.mysql_stmt_fetch;
    pub const mysql_stmt_fetch_column = __root.mysql_stmt_fetch_column;
    pub const mysql_stmt_store_result = __root.mysql_stmt_store_result;
    pub const mysql_stmt_param_count = __root.mysql_stmt_param_count;
    pub const mysql_stmt_attr_set = __root.mysql_stmt_attr_set;
    pub const mysql_stmt_attr_get = __root.mysql_stmt_attr_get;
    pub const mysql_stmt_bind_param = __root.mysql_stmt_bind_param;
    pub const mysql_stmt_bind_result = __root.mysql_stmt_bind_result;
    pub const mysql_stmt_close = __root.mysql_stmt_close;
    pub const mysql_stmt_reset = __root.mysql_stmt_reset;
    pub const mysql_stmt_free_result = __root.mysql_stmt_free_result;
    pub const mysql_stmt_send_long_data = __root.mysql_stmt_send_long_data;
    pub const mysql_stmt_result_metadata = __root.mysql_stmt_result_metadata;
    pub const mysql_stmt_param_metadata = __root.mysql_stmt_param_metadata;
    pub const mysql_stmt_errno = __root.mysql_stmt_errno;
    pub const mysql_stmt_error = __root.mysql_stmt_error;
    pub const mysql_stmt_sqlstate = __root.mysql_stmt_sqlstate;
    pub const mysql_stmt_row_seek = __root.mysql_stmt_row_seek;
    pub const mysql_stmt_row_tell = __root.mysql_stmt_row_tell;
    pub const mysql_stmt_data_seek = __root.mysql_stmt_data_seek;
    pub const mysql_stmt_num_rows = __root.mysql_stmt_num_rows;
    pub const mysql_stmt_affected_rows = __root.mysql_stmt_affected_rows;
    pub const mysql_stmt_insert_id = __root.mysql_stmt_insert_id;
    pub const mysql_stmt_field_count = __root.mysql_stmt_field_count;
    pub const mysql_stmt_next_result = __root.mysql_stmt_next_result;
    pub const mysql_stmt_more_results = __root.mysql_stmt_more_results;
    pub const mariadb_stmt_execute_direct = __root.mariadb_stmt_execute_direct;
    pub const mariadb_stmt_fetch_fields = __root.mariadb_stmt_fetch_fields;
    pub const mysql_stmt_warning_count = __root.mysql_stmt_warning_count;
    pub const @"error" = __root.stmt_set_error;
    pub const prepare = __root.mysql_stmt_prepare;
    pub const execute = __root.mysql_stmt_execute;
    pub const fetch = __root.mysql_stmt_fetch;
    pub const column = __root.mysql_stmt_fetch_column;
    pub const count = __root.mysql_stmt_param_count;
    pub const set = __root.mysql_stmt_attr_set;
    pub const get = __root.mysql_stmt_attr_get;
    pub const param = __root.mysql_stmt_bind_param;
    pub const close = __root.mysql_stmt_close;
    pub const reset = __root.mysql_stmt_reset;
    pub const data = __root.mysql_stmt_send_long_data;
    pub const metadata = __root.mysql_stmt_result_metadata;
    pub const errno = __root.mysql_stmt_errno;
    pub const seek = __root.mysql_stmt_row_seek;
    pub const tell = __root.mysql_stmt_row_tell;
    pub const rows = __root.mysql_stmt_num_rows;
    pub const id = __root.mysql_stmt_insert_id;
    pub const results = __root.mysql_stmt_more_results;
    pub const direct = __root.mariadb_stmt_execute_direct;
};
pub const MYSQL_STMT = struct_st_mysql_stmt;
pub const struct_character_set = extern struct {
    number: c_uint = 0,
    state: c_uint = 0,
    csname: [*c]const u8 = null,
    name: [*c]const u8 = null,
    comment: [*c]const u8 = null,
    dir: [*c]const u8 = null,
    mbminlen: c_uint = 0,
    mbmaxlen: c_uint = 0,
};
pub const MY_CHARSET_INFO = struct_character_set;
pub const STMT_ATTR_UPDATE_MAX_LENGTH: c_int = 0;
pub const STMT_ATTR_CURSOR_TYPE: c_int = 1;
pub const STMT_ATTR_PREFETCH_ROWS: c_int = 2;
pub const STMT_ATTR_PREBIND_PARAMS: c_int = 200;
pub const STMT_ATTR_ARRAY_SIZE: c_int = 201;
pub const STMT_ATTR_ROW_SIZE: c_int = 202;
pub const STMT_ATTR_STATE: c_int = 203;
pub const STMT_ATTR_CB_USER_DATA: c_int = 204;
pub const STMT_ATTR_CB_PARAM: c_int = 205;
pub const STMT_ATTR_CB_RESULT: c_int = 206;
pub const STMT_ATTR_SQL_STATEMENT: c_int = 207;
pub const enum_enum_stmt_attr_type = c_uint;
pub const struct_st_mariadb_api = extern struct {
    mysql_num_rows: ?*const fn (res: [*c]MYSQL_RES) callconv(.c) c_ulonglong = null,
    mysql_num_fields: ?*const fn (res: [*c]MYSQL_RES) callconv(.c) c_uint = null,
    mysql_eof: ?*const fn (res: [*c]MYSQL_RES) callconv(.c) my_bool = null,
    mysql_fetch_field_direct: ?*const fn (res: [*c]MYSQL_RES, fieldnr: c_uint) callconv(.c) [*c]MYSQL_FIELD = null,
    mysql_fetch_fields: ?*const fn (res: [*c]MYSQL_RES) callconv(.c) [*c]MYSQL_FIELD = null,
    mysql_row_tell: ?*const fn (res: [*c]MYSQL_RES) callconv(.c) [*c]MYSQL_ROWS = null,
    mysql_field_tell: ?*const fn (res: [*c]MYSQL_RES) callconv(.c) c_uint = null,
    mysql_field_count: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_uint = null,
    mysql_more_results: ?*const fn (mysql: [*c]MYSQL) callconv(.c) my_bool = null,
    mysql_next_result: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_int = null,
    mysql_affected_rows: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_ulonglong = null,
    mysql_autocommit: ?*const fn (mysql: [*c]MYSQL, mode: my_bool) callconv(.c) my_bool = null,
    mysql_commit: ?*const fn (mysql: [*c]MYSQL) callconv(.c) my_bool = null,
    mysql_rollback: ?*const fn (mysql: [*c]MYSQL) callconv(.c) my_bool = null,
    mysql_insert_id: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_ulonglong = null,
    mysql_errno: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_uint = null,
    mysql_error: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]const u8 = null,
    mysql_info: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]const u8 = null,
    mysql_thread_id: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_ulong = null,
    mysql_character_set_name: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]const u8 = null,
    mysql_get_character_set_info: ?*const fn (mysql: [*c]MYSQL, cs: [*c]MY_CHARSET_INFO) callconv(.c) void = null,
    mysql_set_character_set: ?*const fn (mysql: [*c]MYSQL, csname: [*c]const u8) callconv(.c) c_int = null,
    mariadb_get_infov: ?*const fn (mysql: [*c]MYSQL, value: enum_mariadb_value, arg: ?*anyopaque, ...) callconv(.c) my_bool = null,
    mariadb_get_info: ?*const fn (mysql: [*c]MYSQL, value: enum_mariadb_value, arg: ?*anyopaque) callconv(.c) my_bool = null,
    mysql_init: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]MYSQL = null,
    mysql_ssl_set: ?*const fn (mysql: [*c]MYSQL, key: [*c]const u8, cert: [*c]const u8, ca: [*c]const u8, capath: [*c]const u8, cipher: [*c]const u8) callconv(.c) c_int = null,
    mysql_get_ssl_cipher: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]const u8 = null,
    mysql_change_user: ?*const fn (mysql: [*c]MYSQL, user: [*c]const u8, passwd: [*c]const u8, db: [*c]const u8) callconv(.c) my_bool = null,
    mysql_real_connect: ?*const fn (mysql: [*c]MYSQL, host: [*c]const u8, user: [*c]const u8, passwd: [*c]const u8, db: [*c]const u8, port: c_uint, unix_socket: [*c]const u8, clientflag: c_ulong) callconv(.c) [*c]MYSQL = null,
    mysql_close: ?*const fn (sock: [*c]MYSQL) callconv(.c) void = null,
    mysql_select_db: ?*const fn (mysql: [*c]MYSQL, db: [*c]const u8) callconv(.c) c_int = null,
    mysql_query: ?*const fn (mysql: [*c]MYSQL, q: [*c]const u8) callconv(.c) c_int = null,
    mysql_send_query: ?*const fn (mysql: [*c]MYSQL, q: [*c]const u8, length: c_ulong) callconv(.c) c_int = null,
    mysql_read_query_result: ?*const fn (mysql: [*c]MYSQL) callconv(.c) my_bool = null,
    mysql_real_query: ?*const fn (mysql: [*c]MYSQL, q: [*c]const u8, length: c_ulong) callconv(.c) c_int = null,
    mysql_shutdown: ?*const fn (mysql: [*c]MYSQL, shutdown_level: enum_mysql_enum_shutdown_level) callconv(.c) c_int = null,
    mysql_dump_debug_info: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_int = null,
    mysql_refresh: ?*const fn (mysql: [*c]MYSQL, refresh_options: c_uint) callconv(.c) c_int = null,
    mysql_kill: ?*const fn (mysql: [*c]MYSQL, pid: c_ulong) callconv(.c) c_int = null,
    mysql_ping: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_int = null,
    mysql_stat: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]u8 = null,
    mysql_get_server_info: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]u8 = null,
    mysql_get_server_version: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_ulong = null,
    mysql_get_host_info: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]u8 = null,
    mysql_get_proto_info: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_uint = null,
    mysql_list_dbs: ?*const fn (mysql: [*c]MYSQL, wild: [*c]const u8) callconv(.c) [*c]MYSQL_RES = null,
    mysql_list_tables: ?*const fn (mysql: [*c]MYSQL, wild: [*c]const u8) callconv(.c) [*c]MYSQL_RES = null,
    mysql_list_fields: ?*const fn (mysql: [*c]MYSQL, table: [*c]const u8, wild: [*c]const u8) callconv(.c) [*c]MYSQL_RES = null,
    mysql_list_processes: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]MYSQL_RES = null,
    mysql_store_result: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]MYSQL_RES = null,
    mysql_use_result: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]MYSQL_RES = null,
    mysql_options: ?*const fn (mysql: [*c]MYSQL, option: enum_mysql_option, arg: ?*const anyopaque) callconv(.c) c_int = null,
    mysql_free_result: ?*const fn (result: [*c]MYSQL_RES) callconv(.c) void = null,
    mysql_data_seek: ?*const fn (result: [*c]MYSQL_RES, offset: c_ulonglong) callconv(.c) void = null,
    mysql_row_seek: ?*const fn (result: [*c]MYSQL_RES, MYSQL_ROW_OFFSET) callconv(.c) MYSQL_ROW_OFFSET = null,
    mysql_field_seek: ?*const fn (result: [*c]MYSQL_RES, offset: MYSQL_FIELD_OFFSET) callconv(.c) MYSQL_FIELD_OFFSET = null,
    mysql_fetch_row: ?*const fn (result: [*c]MYSQL_RES) callconv(.c) MYSQL_ROW = null,
    mysql_fetch_lengths: ?*const fn (result: [*c]MYSQL_RES) callconv(.c) [*c]c_ulong = null,
    mysql_fetch_field: ?*const fn (result: [*c]MYSQL_RES) callconv(.c) [*c]MYSQL_FIELD = null,
    mysql_escape_string: ?*const fn (to: [*c]u8, from: [*c]const u8, from_length: c_ulong) callconv(.c) c_ulong = null,
    mysql_real_escape_string: ?*const fn (mysql: [*c]MYSQL, to: [*c]u8, from: [*c]const u8, length: c_ulong) callconv(.c) c_ulong = null,
    mysql_thread_safe: ?*const fn () callconv(.c) c_uint = null,
    mysql_warning_count: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_uint = null,
    mysql_sqlstate: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]const u8 = null,
    mysql_server_init: ?*const fn (argc: c_int, argv: [*c][*c]u8, groups: [*c][*c]u8) callconv(.c) c_int = null,
    mysql_server_end: ?*const fn () callconv(.c) void = null,
    mysql_thread_end: ?*const fn () callconv(.c) void = null,
    mysql_thread_init: ?*const fn () callconv(.c) my_bool = null,
    mysql_set_server_option: ?*const fn (mysql: [*c]MYSQL, option: enum_enum_mysql_set_option) callconv(.c) c_int = null,
    mysql_get_client_info: ?*const fn () callconv(.c) [*c]const u8 = null,
    mysql_get_client_version: ?*const fn () callconv(.c) c_ulong = null,
    mariadb_connection: ?*const fn (mysql: [*c]MYSQL) callconv(.c) my_bool = null,
    mysql_get_server_name: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]const u8 = null,
    mariadb_get_charset_by_name: ?*const fn (csname: [*c]const u8) callconv(.c) [*c]MARIADB_CHARSET_INFO = null,
    mariadb_get_charset_by_nr: ?*const fn (csnr: c_uint) callconv(.c) [*c]MARIADB_CHARSET_INFO = null,
    mariadb_convert_string: ?*const fn (from: [*c]const u8, from_len: [*c]usize, from_cs: [*c]MARIADB_CHARSET_INFO, to: [*c]u8, to_len: [*c]usize, to_cs: [*c]MARIADB_CHARSET_INFO, errorcode: [*c]c_int) callconv(.c) usize = null,
    mysql_optionsv: ?*const fn (mysql: [*c]MYSQL, option: enum_mysql_option, ...) callconv(.c) c_int = null,
    mysql_get_optionv: ?*const fn (mysql: [*c]MYSQL, option: enum_mysql_option, arg: ?*anyopaque, ...) callconv(.c) c_int = null,
    mysql_get_option: ?*const fn (mysql: [*c]MYSQL, option: enum_mysql_option, arg: ?*anyopaque) callconv(.c) c_int = null,
    mysql_hex_string: ?*const fn (to: [*c]u8, from: [*c]const u8, len: c_ulong) callconv(.c) c_ulong = null,
    mysql_get_socket: ?*const fn (mysql: [*c]MYSQL) callconv(.c) my_socket = null,
    mysql_get_timeout_value: ?*const fn (mysql: [*c]const MYSQL) callconv(.c) c_uint = null,
    mysql_get_timeout_value_ms: ?*const fn (mysql: [*c]const MYSQL) callconv(.c) c_uint = null,
    mariadb_reconnect: ?*const fn (mysql: [*c]MYSQL) callconv(.c) my_bool = null,
    mysql_stmt_init: ?*const fn (mysql: [*c]MYSQL) callconv(.c) [*c]MYSQL_STMT = null,
    mysql_stmt_prepare: ?*const fn (stmt: [*c]MYSQL_STMT, query: [*c]const u8, length: c_ulong) callconv(.c) c_int = null,
    mysql_stmt_execute: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) c_int = null,
    mysql_stmt_fetch: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) c_int = null,
    mysql_stmt_fetch_column: ?*const fn (stmt: [*c]MYSQL_STMT, bind_arg: [*c]MYSQL_BIND, column: c_uint, offset: c_ulong) callconv(.c) c_int = null,
    mysql_stmt_store_result: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) c_int = null,
    mysql_stmt_param_count: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) c_ulong = null,
    mysql_stmt_attr_set: ?*const fn (stmt: [*c]MYSQL_STMT, attr_type: enum_enum_stmt_attr_type, attr: ?*const anyopaque) callconv(.c) my_bool = null,
    mysql_stmt_attr_get: ?*const fn (stmt: [*c]MYSQL_STMT, attr_type: enum_enum_stmt_attr_type, attr: ?*anyopaque) callconv(.c) my_bool = null,
    mysql_stmt_bind_param: ?*const fn (stmt: [*c]MYSQL_STMT, bnd: [*c]MYSQL_BIND) callconv(.c) my_bool = null,
    mysql_stmt_bind_result: ?*const fn (stmt: [*c]MYSQL_STMT, bnd: [*c]MYSQL_BIND) callconv(.c) my_bool = null,
    mysql_stmt_close: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) my_bool = null,
    mysql_stmt_reset: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) my_bool = null,
    mysql_stmt_free_result: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) my_bool = null,
    mysql_stmt_send_long_data: ?*const fn (stmt: [*c]MYSQL_STMT, param_number: c_uint, data: [*c]const u8, length: c_ulong) callconv(.c) my_bool = null,
    mysql_stmt_result_metadata: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) [*c]MYSQL_RES = null,
    mysql_stmt_param_metadata: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) [*c]MYSQL_RES = null,
    mysql_stmt_errno: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) c_uint = null,
    mysql_stmt_error: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) [*c]const u8 = null,
    mysql_stmt_sqlstate: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) [*c]const u8 = null,
    mysql_stmt_row_seek: ?*const fn (stmt: [*c]MYSQL_STMT, offset: MYSQL_ROW_OFFSET) callconv(.c) MYSQL_ROW_OFFSET = null,
    mysql_stmt_row_tell: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) MYSQL_ROW_OFFSET = null,
    mysql_stmt_data_seek: ?*const fn (stmt: [*c]MYSQL_STMT, offset: c_ulonglong) callconv(.c) void = null,
    mysql_stmt_num_rows: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) c_ulonglong = null,
    mysql_stmt_affected_rows: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) c_ulonglong = null,
    mysql_stmt_insert_id: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) c_ulonglong = null,
    mysql_stmt_field_count: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) c_uint = null,
    mysql_stmt_next_result: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) c_int = null,
    mysql_stmt_more_results: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) my_bool = null,
    mariadb_stmt_execute_direct: ?*const fn (stmt: [*c]MYSQL_STMT, stmtstr: [*c]const u8, length: usize) callconv(.c) c_int = null,
    mysql_reset_connection: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_int = null,
};
pub const struct_st_mariadb_methods = extern struct {
    db_connect: ?*const fn (mysql: [*c]MYSQL, host: [*c]const u8, user: [*c]const u8, passwd: [*c]const u8, db: [*c]const u8, port: c_uint, unix_socket: [*c]const u8, clientflag: c_ulong) callconv(.c) [*c]MYSQL = null,
    db_close: ?*const fn (mysql: [*c]MYSQL) callconv(.c) void = null,
    db_command: ?*const fn (mysql: [*c]MYSQL, command: enum_enum_server_command, arg: [*c]const u8, length: usize, skip_check: my_bool, opt_arg: ?*anyopaque) callconv(.c) c_int = null,
    db_skip_result: ?*const fn (mysql: [*c]MYSQL) callconv(.c) void = null,
    db_read_query_result: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_int = null,
    db_read_rows: ?*const fn (mysql: [*c]MYSQL, fields: [*c]MYSQL_FIELD, field_count: c_uint) callconv(.c) [*c]MYSQL_DATA = null,
    db_read_one_row: ?*const fn (mysql: [*c]MYSQL, fields: c_uint, row: MYSQL_ROW, lengths: [*c]c_ulong) callconv(.c) c_int = null,
    db_supported_buffer_type: ?*const fn (@"type": enum_enum_field_types) callconv(.c) my_bool = null,
    db_read_prepare_response: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) my_bool = null,
    db_read_stmt_result: ?*const fn (mysql: [*c]MYSQL) callconv(.c) c_int = null,
    db_stmt_get_result_metadata: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) my_bool = null,
    db_stmt_get_param_metadata: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) my_bool = null,
    db_stmt_read_all_rows: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) c_int = null,
    db_stmt_fetch: ?*const fn (stmt: [*c]MYSQL_STMT, row: [*c][*c]u8) callconv(.c) c_int = null,
    db_stmt_fetch_to_bind: ?*const fn (stmt: [*c]MYSQL_STMT, row: [*c]u8) callconv(.c) c_int = null,
    db_stmt_flush_unbuffered: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) void = null,
    set_error: ?*const fn (mysql: [*c]MYSQL, error_nr: c_uint, sqlstate: [*c]const u8, format: [*c]const u8, ...) callconv(.c) void = null,
    invalidate_stmts: ?*const fn (mysql: [*c]MYSQL, function_name: [*c]const u8) callconv(.c) void = null,
    api: [*c]struct_st_mariadb_api = null,
    db_read_execute_response: ?*const fn (stmt: [*c]MYSQL_STMT) callconv(.c) c_int = null,
    db_execute_generate_request: ?*const fn (stmt: [*c]MYSQL_STMT, request_len: [*c]usize, internal: my_bool) callconv(.c) [*c]u8 = null,
};
pub const struct_st_mariadb_extension_9 = opaque {};
pub const struct_st_mysql = extern struct {
    net: NET = @import("std").mem.zeroes(NET),
    unused_0: ?*anyopaque = null,
    host: [*c]u8 = null,
    user: [*c]u8 = null,
    passwd: [*c]u8 = null,
    unix_socket: [*c]u8 = null,
    server_version: [*c]u8 = null,
    host_info: [*c]u8 = null,
    info: [*c]u8 = null,
    db: [*c]u8 = null,
    charset: [*c]const struct_ma_charset_info_st = null,
    fields: [*c]MYSQL_FIELD = null,
    field_alloc: MA_MEM_ROOT = @import("std").mem.zeroes(MA_MEM_ROOT),
    affected_rows: c_ulonglong = 0,
    insert_id: c_ulonglong = 0,
    extra_info: c_ulonglong = 0,
    thread_id: c_ulong = 0,
    packet_length: c_ulong = 0,
    port: c_uint = 0,
    client_flag: c_ulong = 0,
    server_capabilities: c_ulong = 0,
    protocol_version: c_uint = 0,
    field_count: c_uint = 0,
    server_status: c_uint = 0,
    server_language: c_uint = 0,
    warning_count: c_uint = 0,
    options: struct_st_mysql_options = @import("std").mem.zeroes(struct_st_mysql_options),
    status: enum_mysql_status = @import("std").mem.zeroes(enum_mysql_status),
    free_me: my_bool = 0,
    unused_1: my_bool = 0,
    scramble_buff: [21]u8 = @import("std").mem.zeroes([21]u8),
    unused_2: my_bool = 0,
    unused_3: ?*anyopaque = null,
    unused_4: ?*anyopaque = null,
    unused_5: ?*anyopaque = null,
    unused_6: ?*anyopaque = null,
    stmts: [*c]LIST = null,
    methods: [*c]const struct_st_mariadb_methods = null,
    thd: ?*anyopaque = null,
    unbuffered_fetch_owner: [*c]my_bool = null,
    info_buffer: [*c]u8 = null,
    extension: ?*struct_st_mariadb_extension_9 = null,
    pub const ma_net_safe_read = __root.ma_net_safe_read;
    pub const ma_simple_command = __root.ma_simple_command;
    pub const mysql_stmt_init = __root.mysql_stmt_init;
    pub const mysql_load_plugin = __root.mysql_load_plugin;
    pub const mysql_load_plugin_v = __root.mysql_load_plugin_v;
    pub const mysql_client_find_plugin = __root.mysql_client_find_plugin;
    pub const mysql_client_register_plugin = __root.mysql_client_register_plugin;
    pub const mysql_set_local_infile_handler = __root.mysql_set_local_infile_handler;
    pub const mysql_set_local_infile_default = __root.mysql_set_local_infile_default;
    pub const my_set_error = __root.my_set_error;
    pub const mysql_field_count = __root.mysql_field_count;
    pub const mysql_more_results = __root.mysql_more_results;
    pub const mysql_next_result = __root.mysql_next_result;
    pub const mysql_affected_rows = __root.mysql_affected_rows;
    pub const mysql_autocommit = __root.mysql_autocommit;
    pub const mysql_commit = __root.mysql_commit;
    pub const mysql_rollback = __root.mysql_rollback;
    pub const mysql_insert_id = __root.mysql_insert_id;
    pub const mysql_errno = __root.mysql_errno;
    pub const mysql_error = __root.mysql_error;
    pub const mysql_info = __root.mysql_info;
    pub const mysql_thread_id = __root.mysql_thread_id;
    pub const mysql_character_set_name = __root.mysql_character_set_name;
    pub const mysql_get_character_set_info = __root.mysql_get_character_set_info;
    pub const mysql_set_character_set = __root.mysql_set_character_set;
    pub const mariadb_get_infov = __root.mariadb_get_infov;
    pub const mariadb_get_info = __root.mariadb_get_info;
    pub const mysql_init = __root.mysql_init;
    pub const mysql_ssl_set = __root.mysql_ssl_set;
    pub const mysql_get_ssl_cipher = __root.mysql_get_ssl_cipher;
    pub const mysql_change_user = __root.mysql_change_user;
    pub const mysql_real_connect = __root.mysql_real_connect;
    pub const mysql_close = __root.mysql_close;
    pub const mysql_select_db = __root.mysql_select_db;
    pub const mysql_query = __root.mysql_query;
    pub const mysql_send_query = __root.mysql_send_query;
    pub const mysql_read_query_result = __root.mysql_read_query_result;
    pub const mysql_real_query = __root.mysql_real_query;
    pub const mysql_shutdown = __root.mysql_shutdown;
    pub const mysql_dump_debug_info = __root.mysql_dump_debug_info;
    pub const mysql_refresh = __root.mysql_refresh;
    pub const mysql_kill = __root.mysql_kill;
    pub const mysql_ping = __root.mysql_ping;
    pub const mysql_stat = __root.mysql_stat;
    pub const mysql_get_server_info = __root.mysql_get_server_info;
    pub const mysql_get_server_version = __root.mysql_get_server_version;
    pub const mysql_get_host_info = __root.mysql_get_host_info;
    pub const mysql_get_proto_info = __root.mysql_get_proto_info;
    pub const mysql_list_dbs = __root.mysql_list_dbs;
    pub const mysql_list_tables = __root.mysql_list_tables;
    pub const mysql_list_fields = __root.mysql_list_fields;
    pub const mysql_list_processes = __root.mysql_list_processes;
    pub const mysql_store_result = __root.mysql_store_result;
    pub const mysql_use_result = __root.mysql_use_result;
    pub const mysql_options = __root.mysql_options;
    pub const mysql_options4 = __root.mysql_options4;
    pub const mysql_real_escape_string = __root.mysql_real_escape_string;
    pub const mysql_warning_count = __root.mysql_warning_count;
    pub const mysql_sqlstate = __root.mysql_sqlstate;
    pub const mysql_set_server_option = __root.mysql_set_server_option;
    pub const mariadb_connection = __root.mariadb_connection;
    pub const mysql_get_server_name = __root.mysql_get_server_name;
    pub const mysql_optionsv = __root.mysql_optionsv;
    pub const mysql_get_optionv = __root.mysql_get_optionv;
    pub const mysql_get_option = __root.mysql_get_option;
    pub const mysql_get_socket = __root.mysql_get_socket;
    pub const mysql_get_timeout_value = __root.mysql_get_timeout_value;
    pub const mysql_get_timeout_value_ms = __root.mysql_get_timeout_value_ms;
    pub const mariadb_reconnect = __root.mariadb_reconnect;
    pub const mariadb_cancel = __root.mariadb_cancel;
    pub const mysql_net_read_packet = __root.mysql_net_read_packet;
    pub const mysql_close_start = __root.mysql_close_start;
    pub const mysql_close_cont = __root.mysql_close_cont;
    pub const mysql_session_track_get_next = __root.mysql_session_track_get_next;
    pub const mysql_session_track_get_first = __root.mysql_session_track_get_first;
    pub const mysql_reset_connection = __root.mysql_reset_connection;
    pub const read = __root.ma_net_safe_read;
    pub const command = __root.ma_simple_command;
    pub const init = __root.mysql_stmt_init;
    pub const plugin = __root.mysql_load_plugin;
    pub const v = __root.mysql_load_plugin_v;
    pub const handler = __root.mysql_set_local_infile_handler;
    pub const default = __root.mysql_set_local_infile_default;
    pub const @"error" = __root.my_set_error;
    pub const count = __root.mysql_field_count;
    pub const results = __root.mysql_more_results;
    pub const result = __root.mysql_next_result;
    pub const rows = __root.mysql_affected_rows;
    pub const autocommit = __root.mysql_autocommit;
    pub const commit = __root.mysql_commit;
    pub const rollback = __root.mysql_rollback;
    pub const id = __root.mysql_insert_id;
    pub const errno = __root.mysql_errno;
    pub const name = __root.mysql_character_set_name;
    pub const set = __root.mysql_set_character_set;
    pub const infov = __root.mariadb_get_infov;
    pub const cipher = __root.mysql_get_ssl_cipher;
    pub const connect = __root.mysql_real_connect;
    pub const close = __root.mysql_close;
    pub const query = __root.mysql_query;
    pub const shutdown = __root.mysql_shutdown;
    pub const refresh = __root.mysql_refresh;
    pub const kill = __root.mysql_kill;
    pub const ping = __root.mysql_ping;
    pub const stat = __root.mysql_stat;
    pub const version = __root.mysql_get_server_version;
    pub const dbs = __root.mysql_list_dbs;
    pub const tables = __root.mysql_list_tables;
    pub const processes = __root.mysql_list_processes;
    pub const options4 = __root.mysql_options4;
    pub const string = __root.mysql_real_escape_string;
    pub const sqlstate = __root.mysql_sqlstate;
    pub const option = __root.mysql_set_server_option;
    pub const connection = __root.mariadb_connection;
    pub const optionsv = __root.mysql_optionsv;
    pub const optionv = __root.mysql_get_optionv;
    pub const socket = __root.mysql_get_socket;
    pub const value = __root.mysql_get_timeout_value;
    pub const ms = __root.mysql_get_timeout_value_ms;
    pub const reconnect = __root.mariadb_reconnect;
    pub const cancel = __root.mariadb_cancel;
    pub const packet = __root.mysql_net_read_packet;
    pub const start = __root.mysql_close_start;
    pub const cont = __root.mysql_close_cont;
    pub const next = __root.mysql_session_track_get_next;
    pub const first = __root.mysql_session_track_get_first;
};
pub const MYSQL_PARAMETERS = extern struct {
    p_max_allowed_packet: [*c]c_ulong = null,
    p_net_buffer_length: [*c]c_ulong = null,
    extension: ?*anyopaque = null,
};
pub const MARIADB_FIELD_ATTR_DATA_TYPE_NAME: c_int = 0;
pub const MARIADB_FIELD_ATTR_FORMAT_NAME: c_int = 1;
pub const enum_mariadb_field_attr_t = c_uint;
pub extern fn mariadb_field_attr(attr: [*c]MARIADB_CONST_STRING, field: [*c]const MYSQL_FIELD, @"type": enum_mariadb_field_attr_t) c_int;
pub const MYSQL_TIMESTAMP_NONE: c_int = -2;
pub const MYSQL_TIMESTAMP_ERROR: c_int = -1;
pub const MYSQL_TIMESTAMP_DATE: c_int = 0;
pub const MYSQL_TIMESTAMP_DATETIME: c_int = 1;
pub const MYSQL_TIMESTAMP_TIME: c_int = 2;
pub const enum_enum_mysql_timestamp_type = c_int;
pub const struct_st_mysql_time = extern struct {
    year: c_uint = 0,
    month: c_uint = 0,
    day: c_uint = 0,
    hour: c_uint = 0,
    minute: c_uint = 0,
    second: c_uint = 0,
    second_part: c_ulong = 0,
    neg: my_bool = 0,
    time_type: enum_enum_mysql_timestamp_type = @import("std").mem.zeroes(enum_enum_mysql_timestamp_type),
};
pub const MYSQL_TIME = struct_st_mysql_time;
pub const CURSOR_TYPE_NO_CURSOR: c_int = 0;
pub const CURSOR_TYPE_READ_ONLY: c_int = 1;
pub const CURSOR_TYPE_FOR_UPDATE: c_int = 2;
pub const CURSOR_TYPE_SCROLLABLE: c_int = 4;
pub const enum_enum_cursor_type = c_uint;
pub const STMT_INDICATOR_NTS: c_int = -1;
pub const STMT_INDICATOR_NONE: c_int = 0;
pub const STMT_INDICATOR_NULL: c_int = 1;
pub const STMT_INDICATOR_DEFAULT: c_int = 2;
pub const STMT_INDICATOR_IGNORE: c_int = 3;
pub const STMT_INDICATOR_IGNORE_ROW: c_int = 4;
pub const enum_enum_indicator_type = c_int;
pub const struct_st_mysql_cmd_buffer = extern struct {
    buffer: [*c]u8 = null,
    length: usize = 0,
};
pub const MYSQL_CMD_BUFFER = struct_st_mysql_cmd_buffer;
pub const struct_st_mysql_error_info = extern struct {
    error_no: c_uint = 0,
    @"error": [513]u8 = @import("std").mem.zeroes([513]u8),
    sqlstate: [6]u8 = @import("std").mem.zeroes([6]u8),
};
pub const mysql_error_info = struct_st_mysql_error_info;
pub const ps_field_fetch_func = ?*const fn (r_param: [*c]MYSQL_BIND, field: [*c]const MYSQL_FIELD, row: [*c][*c]u8) callconv(.c) void;
pub const struct_st_mysql_perm_bind = extern struct {
    func: ps_field_fetch_func = null,
    pack_len: c_int = 0,
    max_len: c_ulong = 0,
};
pub const MYSQL_PS_CONVERSION = struct_st_mysql_perm_bind;
pub extern var mysql_ps_fetch_functions: [256]MYSQL_PS_CONVERSION;
pub extern fn ma_net_safe_read(mysql: [*c]MYSQL) c_ulong;
pub extern fn mysql_init_ps_subsystem() void;
pub extern fn net_field_length(packet: [*c][*c]u8) c_ulong;
pub extern fn ma_simple_command(mysql: [*c]MYSQL, command: enum_enum_server_command, arg: [*c]const u8, length: usize, skipp_check: my_bool, opt_arg: ?*anyopaque) c_int;
pub extern fn stmt_set_error(stmt: [*c]MYSQL_STMT, error_nr: c_uint, sqlstate: [*c]const u8, format: [*c]const u8, ...) void;
pub extern fn mysql_stmt_init(mysql: [*c]MYSQL) [*c]MYSQL_STMT;
pub extern fn mysql_stmt_prepare(stmt: [*c]MYSQL_STMT, query: [*c]const u8, length: c_ulong) c_int;
pub extern fn mysql_stmt_execute(stmt: [*c]MYSQL_STMT) c_int;
pub extern fn mysql_stmt_fetch(stmt: [*c]MYSQL_STMT) c_int;
pub extern fn mysql_stmt_fetch_column(stmt: [*c]MYSQL_STMT, bind_arg: [*c]MYSQL_BIND, column: c_uint, offset: c_ulong) c_int;
pub extern fn mysql_stmt_store_result(stmt: [*c]MYSQL_STMT) c_int;
pub extern fn mysql_stmt_param_count(stmt: [*c]MYSQL_STMT) c_ulong;
pub extern fn mysql_stmt_attr_set(stmt: [*c]MYSQL_STMT, attr_type: enum_enum_stmt_attr_type, attr: ?*const anyopaque) my_bool;
pub extern fn mysql_stmt_attr_get(stmt: [*c]MYSQL_STMT, attr_type: enum_enum_stmt_attr_type, attr: ?*anyopaque) my_bool;
pub extern fn mysql_stmt_bind_param(stmt: [*c]MYSQL_STMT, bnd: [*c]MYSQL_BIND) my_bool;
pub extern fn mysql_stmt_bind_result(stmt: [*c]MYSQL_STMT, bnd: [*c]MYSQL_BIND) my_bool;
pub extern fn mysql_stmt_close(stmt: [*c]MYSQL_STMT) my_bool;
pub extern fn mysql_stmt_reset(stmt: [*c]MYSQL_STMT) my_bool;
pub extern fn mysql_stmt_free_result(stmt: [*c]MYSQL_STMT) my_bool;
pub extern fn mysql_stmt_send_long_data(stmt: [*c]MYSQL_STMT, param_number: c_uint, data: [*c]const u8, length: c_ulong) my_bool;
pub extern fn mysql_stmt_result_metadata(stmt: [*c]MYSQL_STMT) [*c]MYSQL_RES;
pub extern fn mysql_stmt_param_metadata(stmt: [*c]MYSQL_STMT) [*c]MYSQL_RES;
pub extern fn mysql_stmt_errno(stmt: [*c]MYSQL_STMT) c_uint;
pub extern fn mysql_stmt_error(stmt: [*c]MYSQL_STMT) [*c]const u8;
pub extern fn mysql_stmt_sqlstate(stmt: [*c]MYSQL_STMT) [*c]const u8;
pub extern fn mysql_stmt_row_seek(stmt: [*c]MYSQL_STMT, offset: MYSQL_ROW_OFFSET) MYSQL_ROW_OFFSET;
pub extern fn mysql_stmt_row_tell(stmt: [*c]MYSQL_STMT) MYSQL_ROW_OFFSET;
pub extern fn mysql_stmt_data_seek(stmt: [*c]MYSQL_STMT, offset: c_ulonglong) void;
pub extern fn mysql_stmt_num_rows(stmt: [*c]MYSQL_STMT) c_ulonglong;
pub extern fn mysql_stmt_affected_rows(stmt: [*c]MYSQL_STMT) c_ulonglong;
pub extern fn mysql_stmt_insert_id(stmt: [*c]MYSQL_STMT) c_ulonglong;
pub extern fn mysql_stmt_field_count(stmt: [*c]MYSQL_STMT) c_uint;
pub extern fn mysql_stmt_next_result(stmt: [*c]MYSQL_STMT) c_int;
pub extern fn mysql_stmt_more_results(stmt: [*c]MYSQL_STMT) my_bool;
pub extern fn mariadb_stmt_execute_direct(stmt: [*c]MYSQL_STMT, stmt_str: [*c]const u8, length: usize) c_int;
pub extern fn mariadb_stmt_fetch_fields(stmt: [*c]MYSQL_STMT) [*c]MYSQL_FIELD;
pub const struct_st_mysql_client_plugin = extern struct {
    type: c_int = 0,
    interface_version: c_uint = 0,
    name: [*c]const u8 = null,
    author: [*c]const u8 = null,
    desc: [*c]const u8 = null,
    version: [3]c_uint = @import("std").mem.zeroes([3]c_uint),
    license: [*c]const u8 = null,
    mysql_api: ?*anyopaque = null,
    init: ?*const fn ([*c]u8, usize, c_int, [*c]struct___va_list_tag_1) callconv(.c) c_int = null,
    deinit: ?*const fn () callconv(.c) c_int = null,
    options: ?*const fn (option: [*c]const u8, ?*const anyopaque) callconv(.c) c_int = null,
};
pub const MARIADB_VERIFY_NONE: c_int = 0;
pub const MARIADB_VERIFY_PIPE: c_int = 1;
pub const MARIADB_VERIFY_UNIXSOCKET: c_int = 2;
pub const MARIADB_VERIFY_LOCALHOST: c_int = 3;
pub const MARIADB_VERIFY_FINGERPRINT: c_int = 4;
pub const MARIADB_VERIFY_PEER_CERT: c_int = 5;
pub const enum_mariadb_tls_verification = c_uint;
pub const MARIADB_X509_INFO = extern struct {
    version: c_int = 0,
    issuer: [*c]u8 = null,
    subject: [*c]u8 = null,
    fingerprint: [129]u8 = @import("std").mem.zeroes([129]u8),
    not_before: struct_tm = @import("std").mem.zeroes(struct_tm),
    not_after: struct_tm = @import("std").mem.zeroes(struct_tm),
};
pub extern fn mysql_load_plugin(mysql: [*c]struct_st_mysql, name: [*c]const u8, @"type": c_int, argc: c_int, ...) [*c]struct_st_mysql_client_plugin;
pub extern fn mysql_load_plugin_v(mysql: [*c]struct_st_mysql, name: [*c]const u8, @"type": c_int, argc: c_int, args: [*c]struct___va_list_tag_1) [*c]struct_st_mysql_client_plugin;
pub extern fn mysql_client_find_plugin(mysql: [*c]struct_st_mysql, name: [*c]const u8, @"type": c_int) [*c]struct_st_mysql_client_plugin;
pub extern fn mysql_client_register_plugin(mysql: [*c]struct_st_mysql, plugin: [*c]struct_st_mysql_client_plugin) [*c]struct_st_mysql_client_plugin;
pub extern fn mysql_set_local_infile_handler(mysql: [*c]MYSQL, local_infile_init: ?*const fn ([*c]?*anyopaque, [*c]const u8, ?*anyopaque) callconv(.c) c_int, local_infile_read: ?*const fn (?*anyopaque, [*c]u8, c_uint) callconv(.c) c_int, local_infile_end: ?*const fn (?*anyopaque) callconv(.c) void, local_infile_error: ?*const fn (?*anyopaque, [*c]u8, c_uint) callconv(.c) c_int, ?*anyopaque) void;
pub extern fn mysql_set_local_infile_default(mysql: [*c]MYSQL) void;
pub extern fn my_set_error(mysql: [*c]MYSQL, error_nr: c_uint, sqlstate: [*c]const u8, format: [*c]const u8, ...) void;
pub extern fn mysql_num_rows(res: [*c]MYSQL_RES) my_ulonglong;
pub extern fn mysql_num_fields(res: [*c]MYSQL_RES) c_uint;
pub extern fn mysql_eof(res: [*c]MYSQL_RES) my_bool;
pub extern fn mysql_fetch_field_direct(res: [*c]MYSQL_RES, fieldnr: c_uint) [*c]MYSQL_FIELD;
pub extern fn mysql_fetch_fields(res: [*c]MYSQL_RES) [*c]MYSQL_FIELD;
pub extern fn mysql_row_tell(res: [*c]MYSQL_RES) [*c]MYSQL_ROWS;
pub extern fn mysql_field_tell(res: [*c]MYSQL_RES) c_uint;
pub extern fn mysql_field_count(mysql: [*c]MYSQL) c_uint;
pub extern fn mysql_more_results(mysql: [*c]MYSQL) my_bool;
pub extern fn mysql_next_result(mysql: [*c]MYSQL) c_int;
pub extern fn mysql_affected_rows(mysql: [*c]MYSQL) my_ulonglong;
pub extern fn mysql_autocommit(mysql: [*c]MYSQL, mode: my_bool) my_bool;
pub extern fn mysql_commit(mysql: [*c]MYSQL) my_bool;
pub extern fn mysql_rollback(mysql: [*c]MYSQL) my_bool;
pub extern fn mysql_insert_id(mysql: [*c]MYSQL) my_ulonglong;
pub extern fn mysql_errno(mysql: [*c]MYSQL) c_uint;
pub extern fn mysql_error(mysql: [*c]MYSQL) [*c]const u8;
pub extern fn mysql_info(mysql: [*c]MYSQL) [*c]const u8;
pub extern fn mysql_thread_id(mysql: [*c]MYSQL) c_ulong;
pub extern fn mysql_character_set_name(mysql: [*c]MYSQL) [*c]const u8;
pub extern fn mysql_get_character_set_info(mysql: [*c]MYSQL, cs: [*c]MY_CHARSET_INFO) void;
pub extern fn mysql_set_character_set(mysql: [*c]MYSQL, csname: [*c]const u8) c_int;
pub extern fn mariadb_get_infov(mysql: [*c]MYSQL, value: enum_mariadb_value, arg: ?*anyopaque, ...) my_bool;
pub extern fn mariadb_get_info(mysql: [*c]MYSQL, value: enum_mariadb_value, arg: ?*anyopaque) my_bool;
pub extern fn mysql_init(mysql: [*c]MYSQL) [*c]MYSQL;
pub extern fn mysql_ssl_set(mysql: [*c]MYSQL, key: [*c]const u8, cert: [*c]const u8, ca: [*c]const u8, capath: [*c]const u8, cipher: [*c]const u8) c_int;
pub extern fn mysql_get_ssl_cipher(mysql: [*c]MYSQL) [*c]const u8;
pub extern fn mysql_change_user(mysql: [*c]MYSQL, user: [*c]const u8, passwd: [*c]const u8, db: [*c]const u8) my_bool;
pub extern fn mysql_real_connect(mysql: [*c]MYSQL, host: [*c]const u8, user: [*c]const u8, passwd: [*c]const u8, db: [*c]const u8, port: c_uint, unix_socket: [*c]const u8, clientflag: c_ulong) [*c]MYSQL;
pub extern fn mysql_close(sock: [*c]MYSQL) void;
pub extern fn mysql_select_db(mysql: [*c]MYSQL, db: [*c]const u8) c_int;
pub extern fn mysql_query(mysql: [*c]MYSQL, q: [*c]const u8) c_int;
pub extern fn mysql_send_query(mysql: [*c]MYSQL, q: [*c]const u8, length: c_ulong) c_int;
pub extern fn mysql_read_query_result(mysql: [*c]MYSQL) my_bool;
pub extern fn mysql_real_query(mysql: [*c]MYSQL, q: [*c]const u8, length: c_ulong) c_int;
pub extern fn mysql_shutdown(mysql: [*c]MYSQL, shutdown_level: enum_mysql_enum_shutdown_level) c_int;
pub extern fn mysql_dump_debug_info(mysql: [*c]MYSQL) c_int;
pub extern fn mysql_refresh(mysql: [*c]MYSQL, refresh_options: c_uint) c_int;
pub extern fn mysql_kill(mysql: [*c]MYSQL, pid: c_ulong) c_int;
pub extern fn mysql_ping(mysql: [*c]MYSQL) c_int;
pub extern fn mysql_stat(mysql: [*c]MYSQL) [*c]u8;
pub extern fn mysql_get_server_info(mysql: [*c]MYSQL) [*c]u8;
pub extern fn mysql_get_server_version(mysql: [*c]MYSQL) c_ulong;
pub extern fn mysql_get_host_info(mysql: [*c]MYSQL) [*c]u8;
pub extern fn mysql_get_proto_info(mysql: [*c]MYSQL) c_uint;
pub extern fn mysql_list_dbs(mysql: [*c]MYSQL, wild: [*c]const u8) [*c]MYSQL_RES;
pub extern fn mysql_list_tables(mysql: [*c]MYSQL, wild: [*c]const u8) [*c]MYSQL_RES;
pub extern fn mysql_list_fields(mysql: [*c]MYSQL, table: [*c]const u8, wild: [*c]const u8) [*c]MYSQL_RES;
pub extern fn mysql_list_processes(mysql: [*c]MYSQL) [*c]MYSQL_RES;
pub extern fn mysql_store_result(mysql: [*c]MYSQL) [*c]MYSQL_RES;
pub extern fn mysql_use_result(mysql: [*c]MYSQL) [*c]MYSQL_RES;
pub extern fn mysql_options(mysql: [*c]MYSQL, option: enum_mysql_option, arg: ?*const anyopaque) c_int;
pub extern fn mysql_options4(mysql: [*c]MYSQL, option: enum_mysql_option, arg1: ?*const anyopaque, arg2: ?*const anyopaque) c_int;
pub extern fn mysql_free_result(result: [*c]MYSQL_RES) void;
pub extern fn mysql_data_seek(result: [*c]MYSQL_RES, offset: c_ulonglong) void;
pub extern fn mysql_row_seek(result: [*c]MYSQL_RES, MYSQL_ROW_OFFSET) MYSQL_ROW_OFFSET;
pub extern fn mysql_field_seek(result: [*c]MYSQL_RES, offset: MYSQL_FIELD_OFFSET) MYSQL_FIELD_OFFSET;
pub extern fn mysql_fetch_row(result: [*c]MYSQL_RES) MYSQL_ROW;
pub extern fn mysql_fetch_lengths(result: [*c]MYSQL_RES) [*c]c_ulong;
pub extern fn mysql_fetch_field(result: [*c]MYSQL_RES) [*c]MYSQL_FIELD;
pub extern fn mysql_escape_string(to: [*c]u8, from: [*c]const u8, from_length: c_ulong) c_ulong;
pub extern fn mysql_real_escape_string(mysql: [*c]MYSQL, to: [*c]u8, from: [*c]const u8, length: c_ulong) c_ulong;
pub extern fn mysql_thread_safe() c_uint;
pub extern fn mysql_warning_count(mysql: [*c]MYSQL) c_uint;
pub extern fn mysql_sqlstate(mysql: [*c]MYSQL) [*c]const u8;
pub extern fn mysql_server_init(argc: c_int, argv: [*c][*c]u8, groups: [*c][*c]u8) c_int;
pub extern fn mysql_server_end() void;
pub extern fn mysql_thread_end() void;
pub extern fn mysql_thread_init() my_bool;
pub extern fn mysql_set_server_option(mysql: [*c]MYSQL, option: enum_enum_mysql_set_option) c_int;
pub extern fn mysql_get_client_info() [*c]const u8;
pub extern fn mysql_get_client_version() c_ulong;
pub extern fn mariadb_connection(mysql: [*c]MYSQL) my_bool;
pub extern fn mysql_get_server_name(mysql: [*c]MYSQL) [*c]const u8;
pub extern fn mariadb_get_charset_by_name(csname: [*c]const u8) [*c]MARIADB_CHARSET_INFO;
pub extern fn mariadb_get_charset_by_nr(csnr: c_uint) [*c]MARIADB_CHARSET_INFO;
pub extern fn mariadb_convert_string(from: [*c]const u8, from_len: [*c]usize, from_cs: [*c]MARIADB_CHARSET_INFO, to: [*c]u8, to_len: [*c]usize, to_cs: [*c]MARIADB_CHARSET_INFO, errorcode: [*c]c_int) usize;
pub extern fn mysql_optionsv(mysql: [*c]MYSQL, option: enum_mysql_option, ...) c_int;
pub extern fn mysql_get_optionv(mysql: [*c]MYSQL, option: enum_mysql_option, arg: ?*anyopaque, ...) c_int;
pub extern fn mysql_get_option(mysql: [*c]MYSQL, option: enum_mysql_option, arg: ?*anyopaque) c_int;
pub extern fn mysql_hex_string(to: [*c]u8, from: [*c]const u8, len: c_ulong) c_ulong;
pub extern fn mysql_get_socket(mysql: [*c]MYSQL) my_socket;
pub extern fn mysql_get_timeout_value(mysql: [*c]const MYSQL) c_uint;
pub extern fn mysql_get_timeout_value_ms(mysql: [*c]const MYSQL) c_uint;
pub extern fn mariadb_reconnect(mysql: [*c]MYSQL) my_bool;
pub extern fn mariadb_cancel(mysql: [*c]MYSQL) c_int;
pub extern fn mysql_debug(debug: [*c]const u8) void;
pub extern fn mysql_net_read_packet(mysql: [*c]MYSQL) c_ulong;
pub extern fn mysql_net_field_length(packet: [*c][*c]u8) c_ulong;
pub extern fn mysql_embedded() my_bool;
pub extern fn mysql_get_parameters() [*c]MYSQL_PARAMETERS;
pub extern fn mysql_close_start(sock: [*c]MYSQL) c_int;
pub extern fn mysql_close_cont(sock: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_commit_start(ret: [*c]my_bool, mysql: [*c]MYSQL) c_int;
pub extern fn mysql_commit_cont(ret: [*c]my_bool, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_dump_debug_info_cont(ret: [*c]c_int, mysql: [*c]MYSQL, ready_status: c_int) c_int;
pub extern fn mysql_dump_debug_info_start(ret: [*c]c_int, mysql: [*c]MYSQL) c_int;
pub extern fn mysql_rollback_start(ret: [*c]my_bool, mysql: [*c]MYSQL) c_int;
pub extern fn mysql_rollback_cont(ret: [*c]my_bool, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_autocommit_start(ret: [*c]my_bool, mysql: [*c]MYSQL, auto_mode: my_bool) c_int;
pub extern fn mysql_list_fields_cont(ret: [*c][*c]MYSQL_RES, mysql: [*c]MYSQL, ready_status: c_int) c_int;
pub extern fn mysql_list_fields_start(ret: [*c][*c]MYSQL_RES, mysql: [*c]MYSQL, table: [*c]const u8, wild: [*c]const u8) c_int;
pub extern fn mysql_autocommit_cont(ret: [*c]my_bool, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_next_result_start(ret: [*c]c_int, mysql: [*c]MYSQL) c_int;
pub extern fn mysql_next_result_cont(ret: [*c]c_int, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_select_db_start(ret: [*c]c_int, mysql: [*c]MYSQL, db: [*c]const u8) c_int;
pub extern fn mysql_select_db_cont(ret: [*c]c_int, mysql: [*c]MYSQL, ready_status: c_int) c_int;
pub extern fn mysql_stmt_warning_count(stmt: [*c]MYSQL_STMT) c_int;
pub extern fn mysql_stmt_next_result_start(ret: [*c]c_int, stmt: [*c]MYSQL_STMT) c_int;
pub extern fn mysql_stmt_next_result_cont(ret: [*c]c_int, stmt: [*c]MYSQL_STMT, status: c_int) c_int;
pub extern fn mysql_set_character_set_start(ret: [*c]c_int, mysql: [*c]MYSQL, csname: [*c]const u8) c_int;
pub extern fn mysql_set_character_set_cont(ret: [*c]c_int, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_change_user_start(ret: [*c]my_bool, mysql: [*c]MYSQL, user: [*c]const u8, passwd: [*c]const u8, db: [*c]const u8) c_int;
pub extern fn mysql_change_user_cont(ret: [*c]my_bool, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_real_connect_start(ret: [*c][*c]MYSQL, mysql: [*c]MYSQL, host: [*c]const u8, user: [*c]const u8, passwd: [*c]const u8, db: [*c]const u8, port: c_uint, unix_socket: [*c]const u8, clientflag: c_ulong) c_int;
pub extern fn mysql_real_connect_cont(ret: [*c][*c]MYSQL, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_query_start(ret: [*c]c_int, mysql: [*c]MYSQL, q: [*c]const u8) c_int;
pub extern fn mysql_query_cont(ret: [*c]c_int, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_send_query_start(ret: [*c]c_int, mysql: [*c]MYSQL, q: [*c]const u8, length: c_ulong) c_int;
pub extern fn mysql_send_query_cont(ret: [*c]c_int, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_real_query_start(ret: [*c]c_int, mysql: [*c]MYSQL, q: [*c]const u8, length: c_ulong) c_int;
pub extern fn mysql_real_query_cont(ret: [*c]c_int, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_store_result_start(ret: [*c][*c]MYSQL_RES, mysql: [*c]MYSQL) c_int;
pub extern fn mysql_store_result_cont(ret: [*c][*c]MYSQL_RES, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_shutdown_start(ret: [*c]c_int, mysql: [*c]MYSQL, shutdown_level: enum_mysql_enum_shutdown_level) c_int;
pub extern fn mysql_shutdown_cont(ret: [*c]c_int, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_refresh_start(ret: [*c]c_int, mysql: [*c]MYSQL, refresh_options: c_uint) c_int;
pub extern fn mysql_refresh_cont(ret: [*c]c_int, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_kill_start(ret: [*c]c_int, mysql: [*c]MYSQL, pid: c_ulong) c_int;
pub extern fn mysql_kill_cont(ret: [*c]c_int, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_set_server_option_start(ret: [*c]c_int, mysql: [*c]MYSQL, option: enum_enum_mysql_set_option) c_int;
pub extern fn mysql_set_server_option_cont(ret: [*c]c_int, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_ping_start(ret: [*c]c_int, mysql: [*c]MYSQL) c_int;
pub extern fn mysql_ping_cont(ret: [*c]c_int, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_stat_start(ret: [*c][*c]const u8, mysql: [*c]MYSQL) c_int;
pub extern fn mysql_stat_cont(ret: [*c][*c]const u8, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_free_result_start(result: [*c]MYSQL_RES) c_int;
pub extern fn mysql_free_result_cont(result: [*c]MYSQL_RES, status: c_int) c_int;
pub extern fn mysql_fetch_row_start(ret: [*c]MYSQL_ROW, result: [*c]MYSQL_RES) c_int;
pub extern fn mysql_fetch_row_cont(ret: [*c]MYSQL_ROW, result: [*c]MYSQL_RES, status: c_int) c_int;
pub extern fn mysql_read_query_result_start(ret: [*c]my_bool, mysql: [*c]MYSQL) c_int;
pub extern fn mysql_read_query_result_cont(ret: [*c]my_bool, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_reset_connection_start(ret: [*c]c_int, mysql: [*c]MYSQL) c_int;
pub extern fn mysql_reset_connection_cont(ret: [*c]c_int, mysql: [*c]MYSQL, status: c_int) c_int;
pub extern fn mysql_session_track_get_next(mysql: [*c]MYSQL, @"type": enum_enum_session_state_type, data: [*c][*c]const u8, length: [*c]usize) c_int;
pub extern fn mysql_session_track_get_first(mysql: [*c]MYSQL, @"type": enum_enum_session_state_type, data: [*c][*c]const u8, length: [*c]usize) c_int;
pub extern fn mysql_stmt_prepare_start(ret: [*c]c_int, stmt: [*c]MYSQL_STMT, query: [*c]const u8, length: c_ulong) c_int;
pub extern fn mysql_stmt_prepare_cont(ret: [*c]c_int, stmt: [*c]MYSQL_STMT, status: c_int) c_int;
pub extern fn mysql_stmt_execute_start(ret: [*c]c_int, stmt: [*c]MYSQL_STMT) c_int;
pub extern fn mysql_stmt_execute_cont(ret: [*c]c_int, stmt: [*c]MYSQL_STMT, status: c_int) c_int;
pub extern fn mysql_stmt_fetch_start(ret: [*c]c_int, stmt: [*c]MYSQL_STMT) c_int;
pub extern fn mysql_stmt_fetch_cont(ret: [*c]c_int, stmt: [*c]MYSQL_STMT, status: c_int) c_int;
pub extern fn mysql_stmt_store_result_start(ret: [*c]c_int, stmt: [*c]MYSQL_STMT) c_int;
pub extern fn mysql_stmt_store_result_cont(ret: [*c]c_int, stmt: [*c]MYSQL_STMT, status: c_int) c_int;
pub extern fn mysql_stmt_close_start(ret: [*c]my_bool, stmt: [*c]MYSQL_STMT) c_int;
pub extern fn mysql_stmt_close_cont(ret: [*c]my_bool, stmt: [*c]MYSQL_STMT, status: c_int) c_int;
pub extern fn mysql_stmt_reset_start(ret: [*c]my_bool, stmt: [*c]MYSQL_STMT) c_int;
pub extern fn mysql_stmt_reset_cont(ret: [*c]my_bool, stmt: [*c]MYSQL_STMT, status: c_int) c_int;
pub extern fn mysql_stmt_free_result_start(ret: [*c]my_bool, stmt: [*c]MYSQL_STMT) c_int;
pub extern fn mysql_stmt_free_result_cont(ret: [*c]my_bool, stmt: [*c]MYSQL_STMT, status: c_int) c_int;
pub extern fn mysql_stmt_send_long_data_start(ret: [*c]my_bool, stmt: [*c]MYSQL_STMT, param_number: c_uint, data: [*c]const u8, len: c_ulong) c_int;
pub extern fn mysql_stmt_send_long_data_cont(ret: [*c]my_bool, stmt: [*c]MYSQL_STMT, status: c_int) c_int;
pub extern fn mysql_reset_connection(mysql: [*c]MYSQL) c_int;

pub const __VERSION__ = "Aro aro-zig";
pub const __Aro__ = "";
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const __STDC_EMBED_NOT_FOUND__ = @as(c_int, 0);
pub const __STDC_EMBED_FOUND__ = @as(c_int, 1);
pub const __STDC_EMBED_EMPTY__ = @as(c_int, 2);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __GNUC__ = @as(c_int, 7);
pub const __GNUC_MINOR__ = @as(c_int, 1);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 0);
pub const __ARO_EMULATE_NO__ = @as(c_int, 0);
pub const __ARO_EMULATE_CLANG__ = @as(c_int, 1);
pub const __ARO_EMULATE_GCC__ = @as(c_int, 2);
pub const __ARO_EMULATE_MSVC__ = @as(c_int, 3);
pub const __ARO_EMULATE__ = __ARO_EMULATE_GCC__;
pub inline fn __building_module(x: anytype) @TypeOf(@as(c_int, 0)) {
    _ = &x;
    return @as(c_int, 0);
}
pub const linux = @as(c_int, 1);
pub const __linux = @as(c_int, 1);
pub const __linux__ = @as(c_int, 1);
pub const unix = @as(c_int, 1);
pub const __unix = @as(c_int, 1);
pub const __unix__ = @as(c_int, 1);
pub const __code_model_small__ = @as(c_int, 1);
pub const __amd64__ = @as(c_int, 1);
pub const __amd64 = @as(c_int, 1);
pub const __x86_64__ = @as(c_int, 1);
pub const __x86_64 = @as(c_int, 1);
pub const __SEG_GS = @as(c_int, 1);
pub const __SEG_FS = @as(c_int, 1);
pub const __seg_gs = @compileError("unable to translate macro: undefined identifier `address_space`");
// <builtin>:33:9
pub const __seg_fs = @compileError("unable to translate macro: undefined identifier `address_space`");
// <builtin>:34:9
pub const __LAHF_SAHF__ = @as(c_int, 1);
pub const __AES__ = @as(c_int, 1);
pub const __VAES__ = @as(c_int, 1);
pub const __PCLMUL__ = @as(c_int, 1);
pub const __VPCLMULQDQ__ = @as(c_int, 1);
pub const __LZCNT__ = @as(c_int, 1);
pub const __RDRND__ = @as(c_int, 1);
pub const __FSGSBASE__ = @as(c_int, 1);
pub const __BMI__ = @as(c_int, 1);
pub const __BMI2__ = @as(c_int, 1);
pub const __POPCNT__ = @as(c_int, 1);
pub const __PRFCHW__ = @as(c_int, 1);
pub const __RDSEED__ = @as(c_int, 1);
pub const __ADX__ = @as(c_int, 1);
pub const __MOVBE__ = @as(c_int, 1);
pub const __FMA__ = @as(c_int, 1);
pub const __F16C__ = @as(c_int, 1);
pub const __GFNI__ = @as(c_int, 1);
pub const __SHA__ = @as(c_int, 1);
pub const __FXSR__ = @as(c_int, 1);
pub const __XSAVE__ = @as(c_int, 1);
pub const __XSAVEOPT__ = @as(c_int, 1);
pub const __XSAVEC__ = @as(c_int, 1);
pub const __XSAVES__ = @as(c_int, 1);
pub const __PKU__ = @as(c_int, 1);
pub const __CLFLUSHOPT__ = @as(c_int, 1);
pub const __CLWB__ = @as(c_int, 1);
pub const __SHSTK__ = @as(c_int, 1);
pub const __RDPID__ = @as(c_int, 1);
pub const __WAITPKG__ = @as(c_int, 1);
pub const __MOVDIRI__ = @as(c_int, 1);
pub const __MOVDIR64B__ = @as(c_int, 1);
pub const __PTWRITE__ = @as(c_int, 1);
pub const __INVPCID__ = @as(c_int, 1);
pub const __HRESET__ = @as(c_int, 1);
pub const __AVXVNNI__ = @as(c_int, 1);
pub const __SERIALIZE__ = @as(c_int, 1);
pub const __CRC32__ = @as(c_int, 1);
pub const __AVX2__ = @as(c_int, 1);
pub const __AVX__ = @as(c_int, 1);
pub const __SSE4_2__ = @as(c_int, 1);
pub const __SSE4_1__ = @as(c_int, 1);
pub const __SSSE3__ = @as(c_int, 1);
pub const __SSE3__ = @as(c_int, 1);
pub const __SSE2__ = @as(c_int, 1);
pub const __SSE__ = @as(c_int, 1);
pub const __SSE_MATH__ = @as(c_int, 1);
pub const __MMX__ = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __SIZEOF_FLOAT128__ = @as(c_int, 16);
pub const _LP64 = @as(c_int, 1);
pub const __LP64__ = @as(c_int, 1);
pub const __FLOAT128__ = @as(c_int, 1);
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const __ELF__ = @as(c_int, 1);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __ATOMIC_BOOL_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_WINT_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_SHORT_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_INT_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_LONG_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_LLONG_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_POINTER_LOCK_FREE = @as(c_int, 1);
pub const __WINT_UNSIGNED__ = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __BOOL_WIDTH__ = @as(c_int, 8);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SCHAR_WIDTH__ = @as(c_int, 8);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __SHRT_WIDTH__ = @as(c_int, 16);
pub const __INT_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_WIDTH__ = @as(c_int, 32);
pub const __LONG_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __LONG_WIDTH__ = @as(c_int, 64);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __LONG_LONG_WIDTH__ = @as(c_int, 64);
pub const __WCHAR_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WCHAR_WIDTH__ = @as(c_int, 32);
pub const __WINT_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __WINT_WIDTH__ = @as(c_int, 32);
pub const __INTMAX_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __SIZE_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __UINTMAX_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIG_ATOMIC_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __BITINT_MAXWIDTH__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 10);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 8);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 4);
pub const __SIZEOF_WINT_T__ = @as(c_int, 4);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTPTR_TYPE__ = c_long;
pub const __UINTPTR_TYPE__ = c_ulong;
pub const __INTMAX_TYPE__ = c_long;
pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`");
// <builtin>:160:9
pub const __INTMAX_C = __helpers.L_SUFFIX;
pub const __UINTMAX_TYPE__ = c_ulong;
pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`");
// <builtin>:163:9
pub const __UINTMAX_C = __helpers.UL_SUFFIX;
pub const __PTRDIFF_TYPE__ = c_long;
pub const __SIZE_TYPE__ = c_ulong;
pub const __WCHAR_TYPE__ = c_int;
pub const __WINT_TYPE__ = c_uint;
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT8_C_SUFFIX__ = "";
pub inline fn __INT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT16_C_SUFFIX__ = "";
pub inline fn __INT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT32_C_SUFFIX__ = "";
pub inline fn __INT32_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT64_TYPE__ = c_long;
pub const __INT64_FMTd__ = "ld";
pub const __INT64_FMTi__ = "li";
pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`");
// <builtin>:189:9
pub const __INT64_C = __helpers.L_SUFFIX;
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_C_SUFFIX__ = "";
pub inline fn __UINT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_C_SUFFIX__ = "";
pub inline fn __UINT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`");
// <builtin>:214:9
pub const __UINT32_C = __helpers.U_SUFFIX;
pub const __UINT32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulong;
pub const __UINT64_FMTo__ = "lo";
pub const __UINT64_FMTu__ = "lu";
pub const __UINT64_FMTx__ = "lx";
pub const __UINT64_FMTX__ = "lX";
pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`");
// <builtin>:223:9
pub const __UINT64_C = __helpers.UL_SUFFIX;
pub const __UINT64_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __INT64_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
pub const INT_LEAST8_FMTd__ = "hhd";
pub const INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const UINT_LEAST8_FMTo__ = "hho";
pub const UINT_LEAST8_FMTu__ = "hhu";
pub const UINT_LEAST8_FMTx__ = "hhx";
pub const UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
pub const INT_FAST8_FMTd__ = "hhd";
pub const INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const UINT_FAST8_FMTo__ = "hho";
pub const UINT_FAST8_FMTu__ = "hhu";
pub const UINT_FAST8_FMTx__ = "hhx";
pub const UINT_FAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
pub const INT_LEAST16_FMTd__ = "hd";
pub const INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_LEAST16_FMTo__ = "ho";
pub const UINT_LEAST16_FMTu__ = "hu";
pub const UINT_LEAST16_FMTx__ = "hx";
pub const UINT_LEAST16_FMTX__ = "hX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
pub const INT_FAST16_FMTd__ = "hd";
pub const INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_FAST16_FMTo__ = "ho";
pub const UINT_FAST16_FMTu__ = "hu";
pub const UINT_FAST16_FMTx__ = "hx";
pub const UINT_FAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
pub const INT_LEAST32_FMTd__ = "d";
pub const INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_LEAST32_FMTo__ = "o";
pub const UINT_LEAST32_FMTu__ = "u";
pub const UINT_LEAST32_FMTx__ = "x";
pub const UINT_LEAST32_FMTX__ = "X";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
pub const INT_FAST32_FMTd__ = "d";
pub const INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_FAST32_FMTo__ = "o";
pub const UINT_FAST32_FMTu__ = "u";
pub const UINT_FAST32_FMTx__ = "x";
pub const UINT_FAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_long;
pub const __INT_LEAST64_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
pub const INT_LEAST64_FMTd__ = "ld";
pub const INT_LEAST64_FMTi__ = "li";
pub const __UINT_LEAST64_TYPE__ = c_ulong;
pub const __UINT_LEAST64_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_LEAST64_FMTo__ = "lo";
pub const UINT_LEAST64_FMTu__ = "lu";
pub const UINT_LEAST64_FMTx__ = "lx";
pub const UINT_LEAST64_FMTX__ = "lX";
pub const __INT_FAST64_TYPE__ = c_long;
pub const __INT_FAST64_MAX__ = __helpers.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
pub const INT_FAST64_FMTd__ = "ld";
pub const INT_FAST64_FMTi__ = "li";
pub const __UINT_FAST64_TYPE__ = c_ulong;
pub const __UINT_FAST64_MAX__ = __helpers.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const UINT_FAST64_FMTo__ = "lo";
pub const UINT_FAST64_FMTu__ = "lu";
pub const UINT_FAST64_FMTx__ = "lx";
pub const UINT_FAST64_FMTX__ = "lX";
pub const __FLT16_DENORM_MIN__ = @as(f16, 5.9604644775390625e-8);
pub const __FLT16_HAS_DENORM__ = "";
pub const __FLT16_DIG__ = @as(c_int, 3);
pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
pub const __FLT16_EPSILON__ = @as(f16, 9.765625e-4);
pub const __FLT16_HAS_INFINITY__ = "";
pub const __FLT16_HAS_QUIET_NAN__ = "";
pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
pub const __FLT16_MAX__ = @as(f16, 6.5504e+4);
pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
pub const __FLT16_MIN__ = @as(f16, 6.103515625e-5);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_HAS_DENORM__ = "";
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = "";
pub const __FLT_HAS_QUIET_NAN__ = "";
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
pub const __DBL_HAS_DENORM__ = "";
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
pub const __DBL_HAS_INFINITY__ = "";
pub const __DBL_HAS_QUIET_NAN__ = "";
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __LDBL_HAS_DENORM__ = "";
pub const __LDBL_DIG__ = @as(c_int, 18);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __LDBL_HAS_INFINITY__ = "";
pub const __LDBL_HAS_QUIET_NAN__ = "";
pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __FLT_EVAL_METHOD__ = @as(c_int, 0);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __pic__ = @as(c_int, 2);
pub const __PIC__ = @as(c_int, 2);
pub const __GLIBC_MINOR__ = @as(c_int, 41);
pub const _mysql_h = "";
pub const LIBMARIADB = "";
pub const MYSQL_CLIENT = "";
pub const __STDC_VERSION_STDARG_H__ = @as(c_int, 0);
pub const va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`");
// /usr/local/zig/lib/compiler/aro/include/stdarg.h:12:9
pub const va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`");
// /usr/local/zig/lib/compiler/aro/include/stdarg.h:14:9
pub const va_arg = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg`");
// /usr/local/zig/lib/compiler/aro/include/stdarg.h:15:9
pub const __va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
// /usr/local/zig/lib/compiler/aro/include/stdarg.h:18:9
pub const va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
// /usr/local/zig/lib/compiler/aro/include/stdarg.h:22:9
pub const __GNUC_VA_LIST = @as(c_int, 1);
pub const _TIME_H = @as(c_int, 1);
pub const _FEATURES_H = @as(c_int, 1);
pub const __KERNEL_STRICT_NAMES = "";
pub inline fn __GNUC_PREREQ(maj: anytype, min: anytype) @TypeOf(((__GNUC__ << @as(c_int, 16)) + __GNUC_MINOR__) >= ((maj << @as(c_int, 16)) + min)) {
    _ = &maj;
    _ = &min;
    return ((__GNUC__ << @as(c_int, 16)) + __GNUC_MINOR__) >= ((maj << @as(c_int, 16)) + min);
}
pub inline fn __glibc_clang_prereq(maj: anytype, min: anytype) @TypeOf(@as(c_int, 0)) {
    _ = &maj;
    _ = &min;
    return @as(c_int, 0);
}
pub const __GLIBC_USE = @compileError("unable to translate macro: undefined identifier `__GLIBC_USE_`");
// /usr/include/features.h:191:9
pub const _DEFAULT_SOURCE = @as(c_int, 1);
pub const __GLIBC_USE_ISOC2Y = @as(c_int, 0);
pub const __GLIBC_USE_ISOC23 = @as(c_int, 0);
pub const __USE_ISOC11 = @as(c_int, 1);
pub const __USE_POSIX_IMPLICITLY = @as(c_int, 1);
pub const _POSIX_SOURCE = @as(c_int, 1);
pub const _POSIX_C_SOURCE = @as(c_long, 200809);
pub const __USE_POSIX = @as(c_int, 1);
pub const __USE_POSIX2 = @as(c_int, 1);
pub const __USE_POSIX199309 = @as(c_int, 1);
pub const __USE_POSIX199506 = @as(c_int, 1);
pub const __USE_XOPEN2K = @as(c_int, 1);
pub const __USE_ISOC95 = @as(c_int, 1);
pub const __USE_ISOC99 = @as(c_int, 1);
pub const __USE_XOPEN2K8 = @as(c_int, 1);
pub const _ATFILE_SOURCE = @as(c_int, 1);
pub const __WORDSIZE = @as(c_int, 64);
pub const __WORDSIZE_TIME64_COMPAT32 = @as(c_int, 1);
pub const __SYSCALL_WORDSIZE = @as(c_int, 64);
pub const __TIMESIZE = __WORDSIZE;
pub const __USE_TIME_BITS64 = @as(c_int, 1);
pub const __USE_MISC = @as(c_int, 1);
pub const __USE_ATFILE = @as(c_int, 1);
pub const __USE_FORTIFY_LEVEL = @as(c_int, 0);
pub const __GLIBC_USE_DEPRECATED_GETS = @as(c_int, 0);
pub const __GLIBC_USE_DEPRECATED_SCANF = @as(c_int, 0);
pub const __GLIBC_USE_C23_STRTOL = @as(c_int, 0);
pub const _STDC_PREDEF_H = @as(c_int, 1);
pub const __STDC_IEC_559__ = @as(c_int, 1);
pub const __STDC_IEC_60559_BFP__ = @as(c_long, 201404);
pub const __STDC_IEC_559_COMPLEX__ = @as(c_int, 1);
pub const __STDC_IEC_60559_COMPLEX__ = @as(c_long, 201404);
pub const __STDC_ISO_10646__ = @as(c_long, 201706);
pub const __GNU_LIBRARY__ = @as(c_int, 6);
pub const __GLIBC__ = @as(c_int, 2);
pub inline fn __GLIBC_PREREQ(maj: anytype, min: anytype) @TypeOf(((__GLIBC__ << @as(c_int, 16)) + __GLIBC_MINOR__) >= ((maj << @as(c_int, 16)) + min)) {
    _ = &maj;
    _ = &min;
    return ((__GLIBC__ << @as(c_int, 16)) + __GLIBC_MINOR__) >= ((maj << @as(c_int, 16)) + min);
}
pub const _SYS_CDEFS_H = @as(c_int, 1);
pub const __glibc_has_attribute = @compileError("unable to translate macro: undefined identifier `__has_attribute`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:45:10
pub inline fn __glibc_has_builtin(name: anytype) @TypeOf(__builtin.has_builtin(name)) {
    _ = &name;
    return __builtin.has_builtin(name);
}
pub const __glibc_has_extension = @compileError("unable to translate macro: undefined identifier `__has_extension`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:55:10
pub const __LEAF = @compileError("unable to translate macro: undefined identifier `__leaf__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:65:11
pub const __LEAF_ATTR = @compileError("unable to translate macro: undefined identifier `__leaf__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:66:11
pub const __THROW = @compileError("unable to translate macro: undefined identifier `__nothrow__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:79:11
pub const __THROWNL = @compileError("unable to translate macro: undefined identifier `__nothrow__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:80:11
pub const __NTH = @compileError("unable to translate macro: undefined identifier `__nothrow__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:81:11
pub const __NTHNL = @compileError("unable to translate macro: undefined identifier `__nothrow__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:82:11
pub const __COLD = @compileError("unable to translate macro: undefined identifier `__cold__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:102:11
pub inline fn __P(args: anytype) @TypeOf(args) {
    _ = &args;
    return args;
}
pub inline fn __PMT(args: anytype) @TypeOf(args) {
    _ = &args;
    return args;
}
pub const __CONCAT = @compileError("unable to translate C expr: unexpected token '##'");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:131:9
pub const __STRING = @compileError("unable to translate C expr: unexpected token ''");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:132:9
pub const __ptr_t = ?*anyopaque;
pub const __BEGIN_DECLS = "";
pub const __END_DECLS = "";
pub const __attribute_overloadable__ = "";
pub inline fn __bos(ptr: anytype) @TypeOf(__builtin.object_size(ptr, __USE_FORTIFY_LEVEL > @as(c_int, 1))) {
    _ = &ptr;
    return __builtin.object_size(ptr, __USE_FORTIFY_LEVEL > @as(c_int, 1));
}
pub inline fn __bos0(ptr: anytype) @TypeOf(__builtin.object_size(ptr, @as(c_int, 0))) {
    _ = &ptr;
    return __builtin.object_size(ptr, @as(c_int, 0));
}
pub inline fn __glibc_objsize0(__o: anytype) @TypeOf(__bos0(__o)) {
    _ = &__o;
    return __bos0(__o);
}
pub inline fn __glibc_objsize(__o: anytype) @TypeOf(__bos(__o)) {
    _ = &__o;
    return __bos(__o);
}
pub const __warnattr = @compileError("unable to translate macro: undefined identifier `__warning__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:366:10
pub const __errordecl = @compileError("unable to translate macro: undefined identifier `__error__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:367:10
pub const __flexarr = @compileError("unable to translate C expr: unexpected token '['");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:379:10
pub const __glibc_c99_flexarr_available = @as(c_int, 1);
pub const __REDIRECT = @compileError("unable to translate C expr: unexpected token '__asm__'");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:410:10
pub const __REDIRECT_NTH = @compileError("unable to translate C expr: unexpected token '__asm__'");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:417:11
pub const __REDIRECT_NTHNL = @compileError("unable to translate C expr: unexpected token '__asm__'");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:419:11
pub const __ASMNAME = @compileError("unable to translate macro: undefined identifier `__USER_LABEL_PREFIX__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:422:10
pub inline fn __ASMNAME2(prefix: anytype, cname: anytype) @TypeOf(__STRING(prefix) ++ cname) {
    _ = &prefix;
    _ = &cname;
    return __STRING(prefix) ++ cname;
}
pub const __REDIRECT_FORTIFY = __REDIRECT;
pub const __REDIRECT_FORTIFY_NTH = __REDIRECT_NTH;
pub const __attribute_malloc__ = @compileError("unable to translate macro: undefined identifier `__malloc__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:452:10
pub const __attribute_alloc_size__ = @compileError("unable to translate macro: undefined identifier `__alloc_size__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:460:10
pub const __attribute_alloc_align__ = @compileError("unable to translate macro: undefined identifier `__alloc_align__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:469:10
pub const __attribute_pure__ = @compileError("unable to translate macro: undefined identifier `__pure__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:479:10
pub const __attribute_const__ = @compileError("unable to translate C expr: unexpected token '__attribute__'");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:486:10
pub const __attribute_maybe_unused__ = @compileError("unable to translate macro: undefined identifier `__unused__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:492:10
pub const __attribute_used__ = @compileError("unable to translate macro: undefined identifier `__used__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:501:10
pub const __attribute_noinline__ = @compileError("unable to translate macro: undefined identifier `__noinline__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:502:10
pub const __attribute_deprecated__ = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:510:10
pub const __attribute_deprecated_msg__ = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:520:10
pub const __attribute_format_arg__ = @compileError("unable to translate macro: undefined identifier `__format_arg__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:533:10
pub const __attribute_format_strfmon__ = @compileError("unable to translate macro: undefined identifier `__format__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:543:10
pub const __attribute_nonnull__ = @compileError("unable to translate macro: undefined identifier `__nonnull__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:555:11
pub inline fn __nonnull(params: anytype) @TypeOf(__attribute_nonnull__(params)) {
    _ = &params;
    return __attribute_nonnull__(params);
}
pub const __returns_nonnull = @compileError("unable to translate macro: undefined identifier `__returns_nonnull__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:568:10
pub const __attribute_warn_unused_result__ = @compileError("unable to translate macro: undefined identifier `__warn_unused_result__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:577:10
pub const __wur = "";
pub const __always_inline = @compileError("unable to translate macro: undefined identifier `__always_inline__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:595:10
pub const __attribute_artificial__ = @compileError("unable to translate macro: undefined identifier `__artificial__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:604:10
pub const __extern_inline = @compileError("unable to translate C expr: unexpected token 'extern'");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:626:11
pub const __extern_always_inline = @compileError("unable to translate C expr: unexpected token 'extern'");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:627:11
pub const __fortify_function = __extern_always_inline ++ __attribute_artificial__;
pub const __va_arg_pack = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg_pack`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:638:10
pub const __va_arg_pack_len = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg_pack_len`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:639:10
pub const __restrict_arr = @compileError("unable to translate C expr: unexpected token '__restrict'");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:666:10
pub inline fn __glibc_unlikely(cond: anytype) @TypeOf(__builtin.expect(cond, @as(c_int, 0))) {
    _ = &cond;
    return __builtin.expect(cond, @as(c_int, 0));
}
pub inline fn __glibc_likely(cond: anytype) @TypeOf(__builtin.expect(cond, @as(c_int, 1))) {
    _ = &cond;
    return __builtin.expect(cond, @as(c_int, 1));
}
pub const __attribute_nonstring__ = "";
pub inline fn __attribute_copy__(arg: anytype) void {
    _ = &arg;
    return;
}
pub const __LDOUBLE_REDIRECTS_TO_FLOAT128_ABI = @as(c_int, 0);
pub inline fn __LDBL_REDIR1(name: anytype, proto: anytype, alias: anytype) @TypeOf(name ++ proto) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return name ++ proto;
}
pub inline fn __LDBL_REDIR(name: anytype, proto: anytype) @TypeOf(name ++ proto) {
    _ = &name;
    _ = &proto;
    return name ++ proto;
}
pub inline fn __LDBL_REDIR1_NTH(name: anytype, proto: anytype, alias: anytype) @TypeOf(name ++ proto ++ __THROW) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return name ++ proto ++ __THROW;
}
pub inline fn __LDBL_REDIR_NTH(name: anytype, proto: anytype) @TypeOf(name ++ proto ++ __THROW) {
    _ = &name;
    _ = &proto;
    return name ++ proto ++ __THROW;
}
pub inline fn __LDBL_REDIR2_DECL(name: anytype) void {
    _ = &name;
    return;
}
pub inline fn __LDBL_REDIR_DECL(name: anytype) void {
    _ = &name;
    return;
}
pub inline fn __REDIRECT_LDBL(name: anytype, proto: anytype, alias: anytype) @TypeOf(__REDIRECT(name, proto, alias)) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return __REDIRECT(name, proto, alias);
}
pub inline fn __REDIRECT_NTH_LDBL(name: anytype, proto: anytype, alias: anytype) @TypeOf(__REDIRECT_NTH(name, proto, alias)) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return __REDIRECT_NTH(name, proto, alias);
}
pub const __glibc_macro_warning1 = @compileError("unable to translate macro: undefined identifier `_Pragma`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:807:10
pub const __glibc_macro_warning = @compileError("unable to translate macro: undefined identifier `GCC`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:808:10
pub const __HAVE_GENERIC_SELECTION = @as(c_int, 1);
pub inline fn __fortified_attr_access(a: anytype, o: anytype, s: anytype) void {
    _ = &a;
    _ = &o;
    _ = &s;
    return;
}
pub inline fn __attr_access(x: anytype) void {
    _ = &x;
    return;
}
pub inline fn __attr_access_none(argno: anytype) void {
    _ = &argno;
    return;
}
pub inline fn __attr_dealloc(dealloc: anytype, argno: anytype) void {
    _ = &dealloc;
    _ = &argno;
    return;
}
pub const __attr_dealloc_free = "";
pub const __attribute_returns_twice__ = @compileError("unable to translate macro: undefined identifier `__returns_twice__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:872:10
pub const __attribute_struct_may_alias__ = @compileError("unable to translate macro: undefined identifier `__may_alias__`");
// /usr/include/x86_64-linux-gnu/sys/cdefs.h:881:10
pub const __stub___compat_bdflush = "";
pub const __stub_chflags = "";
pub const __stub_fchflags = "";
pub const __stub_gtty = "";
pub const __stub_revoke = "";
pub const __stub_setlogin = "";
pub const __stub_sigreturn = "";
pub const __stub_stty = "";
pub const __need_size_t = "";
pub const __need_NULL = "";
pub const __STDC_VERSION_STDDEF_H__ = @as(c_long, 202311);
pub const NULL = __helpers.cast(?*anyopaque, @as(c_int, 0));
pub const offsetof = @compileError("unable to translate macro: undefined identifier `__builtin_offsetof`");
// /usr/local/zig/lib/compiler/aro/include/stddef.h:18:9
pub const _BITS_TIME_H = @as(c_int, 1);
pub const _BITS_TYPES_H = @as(c_int, 1);
pub const __S16_TYPE = c_short;
pub const __U16_TYPE = c_ushort;
pub const __S32_TYPE = c_int;
pub const __U32_TYPE = c_uint;
pub const __SLONGWORD_TYPE = c_long;
pub const __ULONGWORD_TYPE = c_ulong;
pub const __SQUAD_TYPE = c_long;
pub const __UQUAD_TYPE = c_ulong;
pub const __SWORD_TYPE = c_long;
pub const __UWORD_TYPE = c_ulong;
pub const __SLONG32_TYPE = c_int;
pub const __ULONG32_TYPE = c_uint;
pub const __S64_TYPE = c_long;
pub const __U64_TYPE = c_ulong;
pub const _BITS_TYPESIZES_H = @as(c_int, 1);
pub const __SYSCALL_SLONG_TYPE = __SLONGWORD_TYPE;
pub const __SYSCALL_ULONG_TYPE = __ULONGWORD_TYPE;
pub const __DEV_T_TYPE = __UQUAD_TYPE;
pub const __UID_T_TYPE = __U32_TYPE;
pub const __GID_T_TYPE = __U32_TYPE;
pub const __INO_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __INO64_T_TYPE = __UQUAD_TYPE;
pub const __MODE_T_TYPE = __U32_TYPE;
pub const __NLINK_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSWORD_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __OFF_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __OFF64_T_TYPE = __SQUAD_TYPE;
pub const __PID_T_TYPE = __S32_TYPE;
pub const __RLIM_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __RLIM64_T_TYPE = __UQUAD_TYPE;
pub const __BLKCNT_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __BLKCNT64_T_TYPE = __SQUAD_TYPE;
pub const __FSBLKCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSBLKCNT64_T_TYPE = __UQUAD_TYPE;
pub const __FSFILCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSFILCNT64_T_TYPE = __UQUAD_TYPE;
pub const __ID_T_TYPE = __U32_TYPE;
pub const __CLOCK_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __TIME_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __USECONDS_T_TYPE = __U32_TYPE;
pub const __SUSECONDS_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __SUSECONDS64_T_TYPE = __SQUAD_TYPE;
pub const __DADDR_T_TYPE = __S32_TYPE;
pub const __KEY_T_TYPE = __S32_TYPE;
pub const __CLOCKID_T_TYPE = __S32_TYPE;
pub const __TIMER_T_TYPE = ?*anyopaque;
pub const __BLKSIZE_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __FSID_T_TYPE = @compileError("unable to translate macro: undefined identifier `__val`");
// /usr/include/x86_64-linux-gnu/bits/typesizes.h:73:9
pub const __SSIZE_T_TYPE = __SWORD_TYPE;
pub const __CPU_MASK_TYPE = __SYSCALL_ULONG_TYPE;
pub const __OFF_T_MATCHES_OFF64_T = @as(c_int, 1);
pub const __INO_T_MATCHES_INO64_T = @as(c_int, 1);
pub const __RLIM_T_MATCHES_RLIM64_T = @as(c_int, 1);
pub const __STATFS_MATCHES_STATFS64 = @as(c_int, 1);
pub const __KERNEL_OLD_TIMEVAL_MATCHES_TIMEVAL64 = @as(c_int, 1);
pub const __FD_SETSIZE = @as(c_int, 1024);
pub const _BITS_TIME64_H = @as(c_int, 1);
pub const __TIME64_T_TYPE = __TIME_T_TYPE;
pub const CLOCKS_PER_SEC = __helpers.cast(__clock_t, __helpers.promoteIntLiteral(c_int, 1000000, .decimal));
pub const CLOCK_REALTIME = @as(c_int, 0);
pub const CLOCK_MONOTONIC = @as(c_int, 1);
pub const CLOCK_PROCESS_CPUTIME_ID = @as(c_int, 2);
pub const CLOCK_THREAD_CPUTIME_ID = @as(c_int, 3);
pub const CLOCK_MONOTONIC_RAW = @as(c_int, 4);
pub const CLOCK_REALTIME_COARSE = @as(c_int, 5);
pub const CLOCK_MONOTONIC_COARSE = @as(c_int, 6);
pub const CLOCK_BOOTTIME = @as(c_int, 7);
pub const CLOCK_REALTIME_ALARM = @as(c_int, 8);
pub const CLOCK_BOOTTIME_ALARM = @as(c_int, 9);
pub const CLOCK_TAI = @as(c_int, 11);
pub const TIMER_ABSTIME = @as(c_int, 1);
pub const __clock_t_defined = @as(c_int, 1);
pub const __time_t_defined = @as(c_int, 1);
pub const __struct_tm_defined = @as(c_int, 1);
pub const _STRUCT_TIMESPEC = @as(c_int, 1);
pub const _BITS_ENDIAN_H = @as(c_int, 1);
pub const __LITTLE_ENDIAN = @as(c_int, 1234);
pub const __BIG_ENDIAN = @as(c_int, 4321);
pub const __PDP_ENDIAN = @as(c_int, 3412);
pub const _BITS_ENDIANNESS_H = @as(c_int, 1);
pub const __BYTE_ORDER = __LITTLE_ENDIAN;
pub const __FLOAT_WORD_ORDER = __BYTE_ORDER;
pub inline fn __LONG_LONG_PAIR(HI: anytype, LO: anytype) @TypeOf(HI) {
    _ = &HI;
    _ = &LO;
    return blk: {
        _ = &LO;
        break :blk HI;
    };
}
pub const __clockid_t_defined = @as(c_int, 1);
pub const __timer_t_defined = @as(c_int, 1);
pub const __itimerspec_defined = @as(c_int, 1);
pub const __pid_t_defined = "";
pub const _BITS_TYPES_LOCALE_T_H = @as(c_int, 1);
pub const _BITS_TYPES___LOCALE_T_H = @as(c_int, 1);
pub const TIME_UTC = @as(c_int, 1);
pub inline fn __isleap(year: anytype) @TypeOf((__helpers.rem(year, @as(c_int, 4)) == @as(c_int, 0)) and ((__helpers.rem(year, @as(c_int, 100)) != @as(c_int, 0)) or (__helpers.rem(year, @as(c_int, 400)) == @as(c_int, 0)))) {
    _ = &year;
    return (__helpers.rem(year, @as(c_int, 4)) == @as(c_int, 0)) and ((__helpers.rem(year, @as(c_int, 100)) != @as(c_int, 0)) or (__helpers.rem(year, @as(c_int, 400)) == @as(c_int, 0)));
}
pub const _SYS_TYPES_H = @as(c_int, 1);
pub const __u_char_defined = "";
pub const __ino_t_defined = "";
pub const __dev_t_defined = "";
pub const __gid_t_defined = "";
pub const __mode_t_defined = "";
pub const __nlink_t_defined = "";
pub const __uid_t_defined = "";
pub const __off_t_defined = "";
pub const __id_t_defined = "";
pub const __ssize_t_defined = "";
pub const __daddr_t_defined = "";
pub const __key_t_defined = "";
pub const _BITS_STDINT_INTN_H = @as(c_int, 1);
pub const __BIT_TYPES_DEFINED__ = @as(c_int, 1);
pub const _ENDIAN_H = @as(c_int, 1);
pub const LITTLE_ENDIAN = __LITTLE_ENDIAN;
pub const BIG_ENDIAN = __BIG_ENDIAN;
pub const PDP_ENDIAN = __PDP_ENDIAN;
pub const BYTE_ORDER = __BYTE_ORDER;
pub const _BITS_BYTESWAP_H = @as(c_int, 1);
pub inline fn __bswap_constant_16(x: anytype) __uint16_t {
    _ = &x;
    return __helpers.cast(__uint16_t, ((x >> @as(c_int, 8)) & @as(c_int, 0xff)) | ((x & @as(c_int, 0xff)) << @as(c_int, 8)));
}
pub inline fn __bswap_constant_32(x: anytype) @TypeOf(((((x & __helpers.promoteIntLiteral(c_uint, 0xff000000, .hex)) >> @as(c_int, 24)) | ((x & __helpers.promoteIntLiteral(c_uint, 0x00ff0000, .hex)) >> @as(c_int, 8))) | ((x & @as(c_uint, 0x0000ff00)) << @as(c_int, 8))) | ((x & @as(c_uint, 0x000000ff)) << @as(c_int, 24))) {
    _ = &x;
    return ((((x & __helpers.promoteIntLiteral(c_uint, 0xff000000, .hex)) >> @as(c_int, 24)) | ((x & __helpers.promoteIntLiteral(c_uint, 0x00ff0000, .hex)) >> @as(c_int, 8))) | ((x & @as(c_uint, 0x0000ff00)) << @as(c_int, 8))) | ((x & @as(c_uint, 0x000000ff)) << @as(c_int, 24));
}
pub inline fn __bswap_constant_64(x: anytype) @TypeOf(((((((((x & @as(c_ulonglong, 0xff00000000000000)) >> @as(c_int, 56)) | ((x & @as(c_ulonglong, 0x00ff000000000000)) >> @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x0000ff0000000000)) >> @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000ff00000000)) >> @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x00000000ff000000)) << @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x0000000000ff0000)) << @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000000000ff00)) << @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x00000000000000ff)) << @as(c_int, 56))) {
    _ = &x;
    return ((((((((x & @as(c_ulonglong, 0xff00000000000000)) >> @as(c_int, 56)) | ((x & @as(c_ulonglong, 0x00ff000000000000)) >> @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x0000ff0000000000)) >> @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000ff00000000)) >> @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x00000000ff000000)) << @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x0000000000ff0000)) << @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000000000ff00)) << @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x00000000000000ff)) << @as(c_int, 56));
}
pub const _BITS_UINTN_IDENTITY_H = @as(c_int, 1);
pub inline fn htobe16(x: anytype) @TypeOf(__bswap_16(x)) {
    _ = &x;
    return __bswap_16(x);
}
pub inline fn htole16(x: anytype) @TypeOf(__uint16_identity(x)) {
    _ = &x;
    return __uint16_identity(x);
}
pub inline fn be16toh(x: anytype) @TypeOf(__bswap_16(x)) {
    _ = &x;
    return __bswap_16(x);
}
pub inline fn le16toh(x: anytype) @TypeOf(__uint16_identity(x)) {
    _ = &x;
    return __uint16_identity(x);
}
pub inline fn htobe32(x: anytype) @TypeOf(__bswap_32(x)) {
    _ = &x;
    return __bswap_32(x);
}
pub inline fn htole32(x: anytype) @TypeOf(__uint32_identity(x)) {
    _ = &x;
    return __uint32_identity(x);
}
pub inline fn be32toh(x: anytype) @TypeOf(__bswap_32(x)) {
    _ = &x;
    return __bswap_32(x);
}
pub inline fn le32toh(x: anytype) @TypeOf(__uint32_identity(x)) {
    _ = &x;
    return __uint32_identity(x);
}
pub inline fn htobe64(x: anytype) @TypeOf(__bswap_64(x)) {
    _ = &x;
    return __bswap_64(x);
}
pub inline fn htole64(x: anytype) @TypeOf(__uint64_identity(x)) {
    _ = &x;
    return __uint64_identity(x);
}
pub inline fn be64toh(x: anytype) @TypeOf(__bswap_64(x)) {
    _ = &x;
    return __bswap_64(x);
}
pub inline fn le64toh(x: anytype) @TypeOf(__uint64_identity(x)) {
    _ = &x;
    return __uint64_identity(x);
}
pub const _SYS_SELECT_H = @as(c_int, 1);
pub const __FD_ZERO = @compileError("unable to translate macro: undefined identifier `__i`");
// /usr/include/x86_64-linux-gnu/bits/select.h:25:9
pub const __FD_SET = @compileError("unable to translate C expr: expected ')' instead got '|='");
// /usr/include/x86_64-linux-gnu/bits/select.h:32:9
pub const __FD_CLR = @compileError("unable to translate C expr: expected ')' instead got '&='");
// /usr/include/x86_64-linux-gnu/bits/select.h:34:9
pub inline fn __FD_ISSET(d: anytype, s: anytype) @TypeOf((__FDS_BITS(s)[@as(usize, @intCast(__FD_ELT(d)))] & __FD_MASK(d)) != @as(c_int, 0)) {
    _ = &d;
    _ = &s;
    return (__FDS_BITS(s)[@as(usize, @intCast(__FD_ELT(d)))] & __FD_MASK(d)) != @as(c_int, 0);
}
pub const __sigset_t_defined = @as(c_int, 1);
pub const ____sigset_t_defined = "";
pub const _SIGSET_NWORDS = __helpers.div(@as(c_int, 1024), @as(c_int, 8) * __helpers.sizeof(c_ulong));
pub const __timeval_defined = @as(c_int, 1);
pub const __suseconds_t_defined = "";
pub const __NFDBITS = @as(c_int, 8) * __helpers.cast(c_int, __helpers.sizeof(__fd_mask));
pub inline fn __FD_ELT(d: anytype) @TypeOf(__helpers.div(d, __NFDBITS)) {
    _ = &d;
    return __helpers.div(d, __NFDBITS);
}
pub inline fn __FD_MASK(d: anytype) __fd_mask {
    _ = &d;
    return __helpers.cast(__fd_mask, @as(c_ulong, 1) << __helpers.rem(d, __NFDBITS));
}
pub inline fn __FDS_BITS(set: anytype) @TypeOf(set.*.__fds_bits) {
    _ = &set;
    return set.*.__fds_bits;
}
pub const FD_SETSIZE = __FD_SETSIZE;
pub const NFDBITS = __NFDBITS;
pub inline fn FD_SET(fd: anytype, fdsetp: anytype) @TypeOf(__FD_SET(fd, fdsetp)) {
    _ = &fd;
    _ = &fdsetp;
    return __FD_SET(fd, fdsetp);
}
pub inline fn FD_CLR(fd: anytype, fdsetp: anytype) @TypeOf(__FD_CLR(fd, fdsetp)) {
    _ = &fd;
    _ = &fdsetp;
    return __FD_CLR(fd, fdsetp);
}
pub inline fn FD_ISSET(fd: anytype, fdsetp: anytype) @TypeOf(__FD_ISSET(fd, fdsetp)) {
    _ = &fd;
    _ = &fdsetp;
    return __FD_ISSET(fd, fdsetp);
}
pub inline fn FD_ZERO(fdsetp: anytype) @TypeOf(__FD_ZERO(fdsetp)) {
    _ = &fdsetp;
    return __FD_ZERO(fdsetp);
}
pub const __blksize_t_defined = "";
pub const __blkcnt_t_defined = "";
pub const __fsblkcnt_t_defined = "";
pub const __fsfilcnt_t_defined = "";
pub const _BITS_PTHREADTYPES_COMMON_H = @as(c_int, 1);
pub const _THREAD_SHARED_TYPES_H = @as(c_int, 1);
pub const _BITS_PTHREADTYPES_ARCH_H = @as(c_int, 1);
pub const __SIZEOF_PTHREAD_MUTEX_T = @as(c_int, 40);
pub const __SIZEOF_PTHREAD_ATTR_T = @as(c_int, 56);
pub const __SIZEOF_PTHREAD_RWLOCK_T = @as(c_int, 56);
pub const __SIZEOF_PTHREAD_BARRIER_T = @as(c_int, 32);
pub const __SIZEOF_PTHREAD_MUTEXATTR_T = @as(c_int, 4);
pub const __SIZEOF_PTHREAD_COND_T = @as(c_int, 48);
pub const __SIZEOF_PTHREAD_CONDATTR_T = @as(c_int, 4);
pub const __SIZEOF_PTHREAD_RWLOCKATTR_T = @as(c_int, 8);
pub const __SIZEOF_PTHREAD_BARRIERATTR_T = @as(c_int, 4);
pub const __LOCK_ALIGNMENT = "";
pub const __ONCE_ALIGNMENT = "";
pub const _BITS_ATOMIC_WIDE_COUNTER_H = "";
pub const _THREAD_MUTEX_INTERNAL_H = @as(c_int, 1);
pub const __PTHREAD_MUTEX_HAVE_PREV = @as(c_int, 1);
pub const __PTHREAD_MUTEX_INITIALIZER = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/x86_64-linux-gnu/bits/struct_mutex.h:56:10
pub const _RWLOCK_INTERNAL_H = "";
pub const __PTHREAD_RWLOCK_ELISION_EXTRA = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/x86_64-linux-gnu/bits/struct_rwlock.h:40:11
pub inline fn __PTHREAD_RWLOCK_INITIALIZER(__flags: anytype) @TypeOf(__flags) {
    _ = &__flags;
    return blk: {
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = &__PTHREAD_RWLOCK_ELISION_EXTRA;
        _ = @as(c_int, 0);
        break :blk __flags;
    };
}
pub const __ONCE_FLAG_INIT = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/x86_64-linux-gnu/bits/thread-shared-types.h:114:9
pub const __have_pthread_attr_t = @as(c_int, 1);
pub const STDCALL = "";
pub const my_socket_defined = "";
pub const _mysql_com_h = "";
pub const NAME_CHAR_LEN = @as(c_int, 64);
pub const NAME_LEN = @as(c_int, 256);
pub const HOSTNAME_LENGTH = @as(c_int, 255);
pub const SYSTEM_MB_MAX_CHAR_LENGTH = @as(c_int, 4);
pub const USERNAME_CHAR_LENGTH = @as(c_int, 128);
pub const USERNAME_LENGTH = USERNAME_CHAR_LENGTH * SYSTEM_MB_MAX_CHAR_LENGTH;
pub const SERVER_VERSION_LENGTH = @as(c_int, 60);
pub const SQLSTATE_LENGTH = @as(c_int, 5);
pub const SCRAMBLE_LENGTH = @as(c_int, 20);
pub const SCRAMBLE_LENGTH_323 = @as(c_int, 8);
pub const LOCAL_HOST = "localhost";
pub const LOCAL_HOST_NAMEDPIPE = ".";
pub const MYSQL_AUTODETECT_CHARSET_NAME = "auto";
pub const BINCMP_FLAG = __helpers.promoteIntLiteral(c_int, 131072, .decimal);
pub const NOT_NULL_FLAG = @as(c_int, 1);
pub const PRI_KEY_FLAG = @as(c_int, 2);
pub const UNIQUE_KEY_FLAG = @as(c_int, 4);
pub const MULTIPLE_KEY_FLAG = @as(c_int, 8);
pub const BLOB_FLAG = @as(c_int, 16);
pub const UNSIGNED_FLAG = @as(c_int, 32);
pub const ZEROFILL_FLAG = @as(c_int, 64);
pub const BINARY_FLAG = @as(c_int, 128);
pub const ENUM_FLAG = @as(c_int, 256);
pub const AUTO_INCREMENT_FLAG = @as(c_int, 512);
pub const TIMESTAMP_FLAG = @as(c_int, 1024);
pub const SET_FLAG = @as(c_int, 2048);
pub const NO_DEFAULT_VALUE_FLAG = @as(c_int, 4096);
pub const ON_UPDATE_NOW_FLAG = @as(c_int, 8192);
pub const NUM_FLAG = __helpers.promoteIntLiteral(c_int, 32768, .decimal);
pub const PART_KEY_FLAG = @as(c_int, 16384);
pub const GROUP_FLAG = __helpers.promoteIntLiteral(c_int, 32768, .decimal);
pub const UNIQUE_FLAG = __helpers.promoteIntLiteral(c_int, 65536, .decimal);
pub const REFRESH_GRANT = @as(c_int, 1);
pub const REFRESH_LOG = @as(c_int, 2);
pub const REFRESH_TABLES = @as(c_int, 4);
pub const REFRESH_HOSTS = @as(c_int, 8);
pub const REFRESH_STATUS = @as(c_int, 16);
pub const REFRESH_THREADS = @as(c_int, 32);
pub const REFRESH_SLAVE = @as(c_int, 64);
pub const REFRESH_MASTER = @as(c_int, 128);
pub const REFRESH_READ_LOCK = @as(c_int, 16384);
pub const REFRESH_FAST = __helpers.promoteIntLiteral(c_int, 32768, .decimal);
pub const CLIENT_MYSQL = @as(c_int, 1);
pub const CLIENT_FOUND_ROWS = @as(c_int, 2);
pub const CLIENT_LONG_FLAG = @as(c_int, 4);
pub const CLIENT_CONNECT_WITH_DB = @as(c_int, 8);
pub const CLIENT_NO_SCHEMA = @as(c_int, 16);
pub const CLIENT_COMPRESS = @as(c_int, 32);
pub const CLIENT_ODBC = @as(c_int, 64);
pub const CLIENT_LOCAL_FILES = @as(c_int, 128);
pub const CLIENT_IGNORE_SPACE = @as(c_int, 256);
pub const CLIENT_INTERACTIVE = @as(c_int, 1024);
pub const CLIENT_SSL = @as(c_int, 2048);
pub const CLIENT_IGNORE_SIGPIPE = @as(c_int, 4096);
pub const CLIENT_TRANSACTIONS = @as(c_int, 8192);
pub const CLIENT_PROTOCOL_41 = @as(c_int, 512);
pub const CLIENT_RESERVED = @as(c_int, 16384);
pub const CLIENT_SECURE_CONNECTION = __helpers.promoteIntLiteral(c_int, 32768, .decimal);
pub const CLIENT_MULTI_STATEMENTS = @as(c_ulong, 1) << @as(c_int, 16);
pub const CLIENT_MULTI_RESULTS = @as(c_ulong, 1) << @as(c_int, 17);
pub const CLIENT_PS_MULTI_RESULTS = @as(c_ulong, 1) << @as(c_int, 18);
pub const CLIENT_PLUGIN_AUTH = @as(c_ulong, 1) << @as(c_int, 19);
pub const CLIENT_CONNECT_ATTRS = @as(c_ulong, 1) << @as(c_int, 20);
pub const CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA = @as(c_ulong, 1) << @as(c_int, 21);
pub const CLIENT_CAN_HANDLE_EXPIRED_PASSWORDS = @as(c_ulong, 1) << @as(c_int, 22);
pub const CLIENT_SESSION_TRACKING = @as(c_ulong, 1) << @as(c_int, 23);
pub const CLIENT_ZSTD_COMPRESSION = @as(c_ulong, 1) << @as(c_int, 26);
pub const CLIENT_PROGRESS = @as(c_ulong, 1) << @as(c_int, 29);
pub const CLIENT_PROGRESS_OBSOLETE = CLIENT_PROGRESS;
pub const CLIENT_SSL_VERIFY_SERVER_CERT = @as(c_ulong, 1) << @as(c_int, 30);
pub const CLIENT_SSL_VERIFY_SERVER_CERT_OBSOLETE = CLIENT_SSL_VERIFY_SERVER_CERT;
pub const CLIENT_REMEMBER_OPTIONS = @as(c_ulong, 1) << @as(c_int, 31);
pub const MARIADB_CLIENT_FLAGS = @as(c_ulonglong, 0xFFFFFFFF00000000);
pub const MARIADB_CLIENT_PROGRESS = @as(c_ulonglong, 1) << @as(c_int, 32);
pub const MARIADB_CLIENT_RESERVED_1 = @as(c_ulonglong, 1) << @as(c_int, 33);
pub const MARIADB_CLIENT_STMT_BULK_OPERATIONS = @as(c_ulonglong, 1) << @as(c_int, 34);
pub const MARIADB_CLIENT_EXTENDED_METADATA = @as(c_ulonglong, 1) << @as(c_int, 35);
pub const MARIADB_CLIENT_CACHE_METADATA = @as(c_ulonglong, 1) << @as(c_int, 36);
pub const MARIADB_CLIENT_BULK_UNIT_RESULTS = @as(c_ulonglong, 1) << @as(c_int, 37);
pub inline fn IS_MARIADB_EXTENDED_SERVER(mysql: anytype) @TypeOf(!((mysql.*.server_capabilities & CLIENT_MYSQL) != 0)) {
    _ = &mysql;
    return !((mysql.*.server_capabilities & CLIENT_MYSQL) != 0);
}
pub const MARIADB_CLIENT_SUPPORTED_FLAGS = (((MARIADB_CLIENT_PROGRESS | MARIADB_CLIENT_STMT_BULK_OPERATIONS) | MARIADB_CLIENT_EXTENDED_METADATA) | MARIADB_CLIENT_CACHE_METADATA) | MARIADB_CLIENT_BULK_UNIT_RESULTS;
pub const CLIENT_SUPPORTED_FLAGS = ((((((((((((((((((((((CLIENT_MYSQL | CLIENT_FOUND_ROWS) | CLIENT_LONG_FLAG) | CLIENT_CONNECT_WITH_DB) | CLIENT_NO_SCHEMA) | CLIENT_COMPRESS) | CLIENT_ODBC) | CLIENT_LOCAL_FILES) | CLIENT_IGNORE_SPACE) | CLIENT_INTERACTIVE) | CLIENT_SSL) | CLIENT_IGNORE_SIGPIPE) | CLIENT_TRANSACTIONS) | CLIENT_PROTOCOL_41) | CLIENT_RESERVED) | CLIENT_SECURE_CONNECTION) | CLIENT_MULTI_STATEMENTS) | CLIENT_MULTI_RESULTS) | CLIENT_PROGRESS) | CLIENT_SSL_VERIFY_SERVER_CERT) | CLIENT_REMEMBER_OPTIONS) | CLIENT_PLUGIN_AUTH) | CLIENT_SESSION_TRACKING) | CLIENT_CONNECT_ATTRS;
pub const CLIENT_ALLOWED_FLAGS = ((((CLIENT_SUPPORTED_FLAGS | CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA) | CLIENT_CAN_HANDLE_EXPIRED_PASSWORDS) | CLIENT_ZSTD_COMPRESSION) | CLIENT_PS_MULTI_RESULTS) | CLIENT_REMEMBER_OPTIONS;
pub const CLIENT_CAPABILITIES = (((((((((CLIENT_MYSQL | CLIENT_LONG_FLAG) | CLIENT_TRANSACTIONS) | CLIENT_SECURE_CONNECTION) | CLIENT_MULTI_RESULTS) | CLIENT_PS_MULTI_RESULTS) | CLIENT_PROTOCOL_41) | CLIENT_PLUGIN_AUTH) | CLIENT_PLUGIN_AUTH_LENENC_CLIENT_DATA) | CLIENT_SESSION_TRACKING) | CLIENT_CONNECT_ATTRS;
pub const CLIENT_DEFAULT_FLAGS = (CLIENT_SUPPORTED_FLAGS & ~CLIENT_COMPRESS) & ~CLIENT_SSL;
pub const CLIENT_DEFAULT_EXTENDED_FLAGS = MARIADB_CLIENT_SUPPORTED_FLAGS & ~MARIADB_CLIENT_BULK_UNIT_RESULTS;
pub const SERVER_STATUS_IN_TRANS = @as(c_int, 1);
pub const SERVER_STATUS_AUTOCOMMIT = @as(c_int, 2);
pub const SERVER_MORE_RESULTS_EXIST = @as(c_int, 8);
pub const SERVER_QUERY_NO_GOOD_INDEX_USED = @as(c_int, 16);
pub const SERVER_QUERY_NO_INDEX_USED = @as(c_int, 32);
pub const SERVER_STATUS_CURSOR_EXISTS = @as(c_int, 64);
pub const SERVER_STATUS_LAST_ROW_SENT = @as(c_int, 128);
pub const SERVER_STATUS_DB_DROPPED = @as(c_int, 256);
pub const SERVER_STATUS_NO_BACKSLASH_ESCAPES = @as(c_int, 512);
pub const SERVER_STATUS_METADATA_CHANGED = @as(c_int, 1024);
pub const SERVER_QUERY_WAS_SLOW = @as(c_int, 2048);
pub const SERVER_PS_OUT_PARAMS = @as(c_int, 4096);
pub const SERVER_STATUS_IN_TRANS_READONLY = @as(c_int, 8192);
pub const SERVER_SESSION_STATE_CHANGED = @as(c_int, 16384);
pub const SERVER_STATUS_ANSI_QUOTES = __helpers.promoteIntLiteral(c_int, 32768, .decimal);
pub const MYSQL_ERRMSG_SIZE = @as(c_int, 512);
pub const NET_READ_TIMEOUT = @as(c_int, 30);
pub const NET_WRITE_TIMEOUT = @as(c_int, 60);
pub const NET_WAIT_TIMEOUT = (@as(c_int, 8) * @as(c_int, 60)) * @as(c_int, 60);
pub const LIST_PROCESS_HOST_LEN = @as(c_int, 64);
pub const MYSQL50_TABLE_NAME_PREFIX = "#mysql50#";
pub const MYSQL50_TABLE_NAME_PREFIX_LENGTH = __helpers.sizeof(MYSQL50_TABLE_NAME_PREFIX) - @as(c_int, 1);
pub const SAFE_NAME_LEN = NAME_LEN + MYSQL50_TABLE_NAME_PREFIX_LENGTH;
pub const MAX_CHAR_WIDTH = @as(c_int, 255);
pub const MAX_BLOB_WIDTH = @as(c_int, 8192);
pub const MAX_TINYINT_WIDTH = @as(c_int, 3);
pub const MAX_SMALLINT_WIDTH = @as(c_int, 5);
pub const MAX_MEDIUMINT_WIDTH = @as(c_int, 8);
pub const MAX_INT_WIDTH = @as(c_int, 10);
pub const MAX_BIGINT_WIDTH = @as(c_int, 20);
pub const packet_error = __helpers.cast(c_uint, -@as(c_int, 1));
pub const SESSION_TRACK_BEGIN = @as(c_int, 0);
pub const SESSION_TRACK_END = SESSION_TRACK_TRANSACTION_STATE;
pub const SESSION_TRACK_TYPES = SESSION_TRACK_END + @as(c_int, 1);
pub const SESSION_TRACK_TRANSACTION_TYPE = SESSION_TRACK_TRANSACTION_STATE;
pub const FIELD_TYPE_CHAR = FIELD_TYPE_TINY;
pub const FIELD_TYPE_INTERVAL = FIELD_TYPE_ENUM;
pub const FIELD_TYPE_DECIMAL = MYSQL_TYPE_DECIMAL;
pub const FIELD_TYPE_NEWDECIMAL = MYSQL_TYPE_NEWDECIMAL;
pub const FIELD_TYPE_TINY = MYSQL_TYPE_TINY;
pub const FIELD_TYPE_SHORT = MYSQL_TYPE_SHORT;
pub const FIELD_TYPE_LONG = MYSQL_TYPE_LONG;
pub const FIELD_TYPE_FLOAT = MYSQL_TYPE_FLOAT;
pub const FIELD_TYPE_DOUBLE = MYSQL_TYPE_DOUBLE;
pub const FIELD_TYPE_NULL = MYSQL_TYPE_NULL;
pub const FIELD_TYPE_TIMESTAMP = MYSQL_TYPE_TIMESTAMP;
pub const FIELD_TYPE_LONGLONG = MYSQL_TYPE_LONGLONG;
pub const FIELD_TYPE_INT24 = MYSQL_TYPE_INT24;
pub const FIELD_TYPE_DATE = MYSQL_TYPE_DATE;
pub const FIELD_TYPE_TIME = MYSQL_TYPE_TIME;
pub const FIELD_TYPE_DATETIME = MYSQL_TYPE_DATETIME;
pub const FIELD_TYPE_YEAR = MYSQL_TYPE_YEAR;
pub const FIELD_TYPE_NEWDATE = MYSQL_TYPE_NEWDATE;
pub const FIELD_TYPE_ENUM = MYSQL_TYPE_ENUM;
pub const FIELD_TYPE_SET = MYSQL_TYPE_SET;
pub const FIELD_TYPE_TINY_BLOB = MYSQL_TYPE_TINY_BLOB;
pub const FIELD_TYPE_MEDIUM_BLOB = MYSQL_TYPE_MEDIUM_BLOB;
pub const FIELD_TYPE_LONG_BLOB = MYSQL_TYPE_LONG_BLOB;
pub const FIELD_TYPE_BLOB = MYSQL_TYPE_BLOB;
pub const FIELD_TYPE_VAR_STRING = MYSQL_TYPE_VAR_STRING;
pub const FIELD_TYPE_STRING = MYSQL_TYPE_STRING;
pub const FIELD_TYPE_GEOMETRY = MYSQL_TYPE_GEOMETRY;
pub const FIELD_TYPE_BIT = MYSQL_TYPE_BIT;
pub const net_new_transaction = @compileError("unable to translate C expr: expected ')' instead got '='");
// /usr/include/mysql/mariadb_com.h:415:9
pub const MARIADB_CONNECTION_UNIXSOCKET = @as(c_int, 0);
pub const MARIADB_CONNECTION_TCP = @as(c_int, 1);
pub const MARIADB_CONNECTION_NAMEDPIPE = @as(c_int, 2);
pub const MARIADB_CONNECTION_SHAREDMEM = @as(c_int, 3);
pub const NET_HEADER_SIZE = @as(c_int, 4);
pub const COMP_HEADER_SIZE = @as(c_int, 3);
pub const native_password_plugin_name = "mysql_native_password";
pub const old_password_plugin_name = "mysql_old_password";
pub const NULL_LENGTH = __helpers.cast(c_ulong, ~@as(c_int, 0));
pub const _mariadb_version_h_ = "";
pub const PROTOCOL_VERSION = @as(c_int, 10);
pub const MARIADB_CLIENT_VERSION_STR = "11.8.6";
pub const MARIADB_BASE_VERSION = "mariadb-11.8";
pub const MARIADB_VERSION_ID = __helpers.promoteIntLiteral(c_int, 110806, .decimal);
pub const MARIADB_PORT = @as(c_int, 3306);
pub const MARIADB_UNIX_ADDR = "/run/mysqld/mysqld.sock";
pub const MYSQL_UNIX_ADDR = MARIADB_UNIX_ADDR;
pub const MYSQL_PORT = MARIADB_PORT;
pub const MYSQL_CONFIG_NAME = "my";
pub const MYSQL_VERSION_ID = __helpers.promoteIntLiteral(c_int, 110806, .decimal);
pub const MYSQL_SERVER_VERSION = "11.8.6-MariaDB";
pub const MARIADB_PACKAGE_VERSION = "3.4.9";
pub const MARIADB_PACKAGE_VERSION_ID = @as(c_int, 30409);
pub const MARIADB_SYSTEM_TYPE = "Linux";
pub const MARIADB_MACHINE_TYPE = "x86_64";
pub const MARIADB_PLUGINDIR = "/usr/lib/x86_64-linux-gnu/libmariadb3/plugin";
pub const MYSQL_CHARSET = "";
pub const CC_SOURCE_REVISION = "";
pub const _list_h_ = "";
pub inline fn list_rest(a: anytype) @TypeOf(a.*.next) {
    _ = &a;
    return a.*.next;
}
pub const list_push = @compileError("unable to translate C expr: unexpected token '='");
// /usr/include/mysql/ma_list.h:41:9
pub const list_pop = @compileError("unable to translate macro: undefined identifier `old`");
// /usr/include/mysql/ma_list.h:42:9
pub const _mariadb_ctype_h = "";
pub const _CTYPE_H = @as(c_int, 1);
pub inline fn _ISbit(bit: anytype) @TypeOf(if (__helpers.cast(bool, bit < @as(c_int, 8))) (@as(c_int, 1) << bit) << @as(c_int, 8) else (@as(c_int, 1) << bit) >> @as(c_int, 8)) {
    _ = &bit;
    return if (__helpers.cast(bool, bit < @as(c_int, 8))) (@as(c_int, 1) << bit) << @as(c_int, 8) else (@as(c_int, 1) << bit) >> @as(c_int, 8);
}
pub inline fn __isctype(c: anytype, @"type": anytype) @TypeOf(__ctype_b_loc().*[@as(usize, @intCast(__helpers.cast(c_int, c)))] & __helpers.cast(c_ushort, @"type")) {
    _ = &c;
    _ = &@"type";
    return __ctype_b_loc().*[@as(usize, @intCast(__helpers.cast(c_int, c)))] & __helpers.cast(c_ushort, @"type");
}
pub inline fn __isascii(c: anytype) @TypeOf((c & ~@as(c_int, 0x7f)) == @as(c_int, 0)) {
    _ = &c;
    return (c & ~@as(c_int, 0x7f)) == @as(c_int, 0);
}
pub inline fn __toascii(c: anytype) @TypeOf(c & @as(c_int, 0x7f)) {
    _ = &c;
    return c & @as(c_int, 0x7f);
}
pub const __exctype = @compileError("unable to translate C expr: unexpected token 'extern'");
// /usr/include/ctype.h:102:9
pub const __tobody = @compileError("unable to translate macro: undefined identifier `__res`");
// /usr/include/ctype.h:155:9
pub inline fn __isctype_l(c: anytype, @"type": anytype, locale: anytype) @TypeOf(locale.*.__ctype_b[@as(usize, @intCast(__helpers.cast(c_int, c)))] & __helpers.cast(c_ushort, @"type")) {
    _ = &c;
    _ = &@"type";
    _ = &locale;
    return locale.*.__ctype_b[@as(usize, @intCast(__helpers.cast(c_int, c)))] & __helpers.cast(c_ushort, @"type");
}
pub const __exctype_l = @compileError("unable to translate C expr: unexpected token 'extern'");
// /usr/include/ctype.h:244:10
pub inline fn __isalnum_l(c: anytype, l: anytype) @TypeOf(__isctype_l(c, _ISalnum, l)) {
    _ = &c;
    _ = &l;
    return __isctype_l(c, _ISalnum, l);
}
pub inline fn __isalpha_l(c: anytype, l: anytype) @TypeOf(__isctype_l(c, _ISalpha, l)) {
    _ = &c;
    _ = &l;
    return __isctype_l(c, _ISalpha, l);
}
pub inline fn __iscntrl_l(c: anytype, l: anytype) @TypeOf(__isctype_l(c, _IScntrl, l)) {
    _ = &c;
    _ = &l;
    return __isctype_l(c, _IScntrl, l);
}
pub inline fn __isdigit_l(c: anytype, l: anytype) @TypeOf(__isctype_l(c, _ISdigit, l)) {
    _ = &c;
    _ = &l;
    return __isctype_l(c, _ISdigit, l);
}
pub inline fn __islower_l(c: anytype, l: anytype) @TypeOf(__isctype_l(c, _ISlower, l)) {
    _ = &c;
    _ = &l;
    return __isctype_l(c, _ISlower, l);
}
pub inline fn __isgraph_l(c: anytype, l: anytype) @TypeOf(__isctype_l(c, _ISgraph, l)) {
    _ = &c;
    _ = &l;
    return __isctype_l(c, _ISgraph, l);
}
pub inline fn __isprint_l(c: anytype, l: anytype) @TypeOf(__isctype_l(c, _ISprint, l)) {
    _ = &c;
    _ = &l;
    return __isctype_l(c, _ISprint, l);
}
pub inline fn __ispunct_l(c: anytype, l: anytype) @TypeOf(__isctype_l(c, _ISpunct, l)) {
    _ = &c;
    _ = &l;
    return __isctype_l(c, _ISpunct, l);
}
pub inline fn __isspace_l(c: anytype, l: anytype) @TypeOf(__isctype_l(c, _ISspace, l)) {
    _ = &c;
    _ = &l;
    return __isctype_l(c, _ISspace, l);
}
pub inline fn __isupper_l(c: anytype, l: anytype) @TypeOf(__isctype_l(c, _ISupper, l)) {
    _ = &c;
    _ = &l;
    return __isctype_l(c, _ISupper, l);
}
pub inline fn __isxdigit_l(c: anytype, l: anytype) @TypeOf(__isctype_l(c, _ISxdigit, l)) {
    _ = &c;
    _ = &l;
    return __isctype_l(c, _ISxdigit, l);
}
pub inline fn __isblank_l(c: anytype, l: anytype) @TypeOf(__isctype_l(c, _ISblank, l)) {
    _ = &c;
    _ = &l;
    return __isctype_l(c, _ISblank, l);
}
pub inline fn __isascii_l(c: anytype, l: anytype) @TypeOf(__isascii(c)) {
    _ = &c;
    _ = &l;
    return blk_1: {
        _ = &l;
        break :blk_1 __isascii(c);
    };
}
pub inline fn __toascii_l(c: anytype, l: anytype) @TypeOf(__toascii(c)) {
    _ = &c;
    _ = &l;
    return blk_1: {
        _ = &l;
        break :blk_1 __toascii(c);
    };
}
pub inline fn isascii_l(c: anytype, l: anytype) @TypeOf(__isascii_l(c, l)) {
    _ = &c;
    _ = &l;
    return __isascii_l(c, l);
}
pub inline fn toascii_l(c: anytype, l: anytype) @TypeOf(__toascii_l(c, l)) {
    _ = &c;
    _ = &l;
    return __toascii_l(c, l);
}
pub const CHARSET_DIR = "charsets/";
pub const MY_CS_NAME_SIZE = @as(c_int, 32);
pub const MADB_DEFAULT_CHARSET_NAME = "latin1";
pub const MADB_DEFAULT_COLLATION_NAME = "latin1_swedish_ci";
pub const MADB_AUTODETECT_CHARSET_NAME = "auto";
pub const ST_MA_USED_MEM_DEFINED = "";
pub inline fn IS_PRI_KEY(n: anytype) @TypeOf(n & PRI_KEY_FLAG) {
    _ = &n;
    return n & PRI_KEY_FLAG;
}
pub inline fn IS_NOT_NULL(n: anytype) @TypeOf(n & NOT_NULL_FLAG) {
    _ = &n;
    return n & NOT_NULL_FLAG;
}
pub inline fn IS_BLOB(n: anytype) @TypeOf(n & BLOB_FLAG) {
    _ = &n;
    return n & BLOB_FLAG;
}
pub inline fn IS_NUM(t: anytype) @TypeOf((((t <= MYSQL_TYPE_INT24) and (t != MYSQL_TYPE_TIMESTAMP)) or (t == MYSQL_TYPE_YEAR)) or (t == MYSQL_TYPE_NEWDECIMAL)) {
    _ = &t;
    return (((t <= MYSQL_TYPE_INT24) and (t != MYSQL_TYPE_TIMESTAMP)) or (t == MYSQL_TYPE_YEAR)) or (t == MYSQL_TYPE_NEWDECIMAL);
}
pub inline fn IS_NUM_FIELD(f: anytype) @TypeOf(f.*.flags & NUM_FLAG) {
    _ = &f;
    return f.*.flags & NUM_FLAG;
}
pub inline fn INTERNAL_NUM_FIELD(f: anytype) @TypeOf(((((f.*.type <= MYSQL_TYPE_INT24) and (((f.*.type != MYSQL_TYPE_TIMESTAMP) or (f.*.length == @as(c_int, 14))) or (f.*.length == @as(c_int, 8)))) or (f.*.type == MYSQL_TYPE_YEAR)) or (f.*.type == MYSQL_TYPE_NEWDECIMAL)) or (f.*.type == MYSQL_TYPE_DECIMAL)) {
    _ = &f;
    return ((((f.*.type <= MYSQL_TYPE_INT24) and (((f.*.type != MYSQL_TYPE_TIMESTAMP) or (f.*.length == @as(c_int, 14))) or (f.*.length == @as(c_int, 8)))) or (f.*.type == MYSQL_TYPE_YEAR)) or (f.*.type == MYSQL_TYPE_NEWDECIMAL)) or (f.*.type == MYSQL_TYPE_DECIMAL);
}
pub const SET_CLIENT_ERROR = @compileError("unable to translate macro: undefined identifier `strncpy`");
// /usr/include/mysql/mysql.h:139:9
pub inline fn set_mariadb_error(A: anytype, B: anytype, C: anytype) @TypeOf(SET_CLIENT_ERROR(A, B, C, @as(c_int, 0))) {
    _ = &A;
    _ = &B;
    _ = &C;
    return SET_CLIENT_ERROR(A, B, C, @as(c_int, 0));
}

// /usr/include/mysql/mysql.h:151:9: warning: macro 'unknown_sqlstate' contains a runtime value, translated to function
pub inline fn unknown_sqlstate() @TypeOf(SQLSTATE_UNKNOWN) {
    return SQLSTATE_UNKNOWN;
}
pub const CLEAR_CLIENT_ERROR = @compileError("unable to translate macro: undefined identifier `strcpy`");
// /usr/include/mysql/mysql.h:153:9
pub const MYSQL_COUNT_ERROR = ~__helpers.cast(c_ulonglong, @as(c_int, 0));
pub const MARIADB_FIELD_ATTR_LAST = MARIADB_FIELD_ATTR_FORMAT_NAME;
pub const AUTO_SEC_PART_DIGITS = @as(c_int, 39);
pub const SEC_PART_DIGITS = @as(c_int, 6);
pub const MARIADB_INVALID_SOCKET = -@as(c_int, 1);
pub const MYSQL_WAIT_READ = @as(c_int, 1);
pub const MYSQL_WAIT_WRITE = @as(c_int, 2);
pub const MYSQL_WAIT_EXCEPT = @as(c_int, 4);
pub const MYSQL_WAIT_TIMEOUT = @as(c_int, 8);
pub const MARIADB_TLS_VERIFY_OK = @as(c_int, 0);
pub const MARIADB_TLS_VERIFY_TRUST = @as(c_int, 1);
pub const MARIADB_TLS_VERIFY_HOST = @as(c_int, 2);
pub const MARIADB_TLS_VERIFY_FINGERPRINT = @as(c_int, 4);
pub const MARIADB_TLS_VERIFY_PERIOD = @as(c_int, 8);
pub const MARIADB_TLS_VERIFY_REVOKED = @as(c_int, 16);
pub const MARIADB_TLS_VERIFY_UNKNOWN = @as(c_int, 32);
pub const MARIADB_TLS_VERIFY_ERROR = @as(c_int, 128);
pub const LOCAL_INFILE_ERROR_LEN = @as(c_int, 512);
pub const MYSQL_NO_DATA = @as(c_int, 100);
pub const MYSQL_DATA_TRUNCATED = @as(c_int, 101);
pub const MYSQL_DEFAULT_PREFETCH_ROWS = __helpers.cast(c_ulong, @as(c_int, 1));
pub const MADB_BIND_DUMMY = @as(c_int, 1);
pub inline fn MARIADB_STMT_BULK_SUPPORTED(stmt: anytype) @TypeOf((stmt.*.mysql != 0) and (!((stmt.*.mysql.*.server_capabilities & CLIENT_MYSQL) != 0) and ((stmt.*.mysql.*.extension.*.mariadb_server_capabilities & (MARIADB_CLIENT_STMT_BULK_OPERATIONS >> @as(c_int, 32))) != 0))) {
    _ = &stmt;
    return (stmt.*.mysql != 0) and (!((stmt.*.mysql.*.server_capabilities & CLIENT_MYSQL) != 0) and ((stmt.*.mysql.*.extension.*.mariadb_server_capabilities & (MARIADB_CLIENT_STMT_BULK_OPERATIONS >> @as(c_int, 32))) != 0));
}
pub inline fn MARIADB_STMT_BULK_UNIT_RESULTS_SUPPORTED(stmt: anytype) @TypeOf((stmt.*.mysql != 0) and (!((stmt.*.mysql.*.server_capabilities & CLIENT_MYSQL) != 0) and ((stmt.*.mysql.*.extension.*.mariadb_client_flag & (MARIADB_CLIENT_BULK_UNIT_RESULTS >> @as(c_int, 32))) != 0))) {
    _ = &stmt;
    return (stmt.*.mysql != 0) and (!((stmt.*.mysql.*.server_capabilities & CLIENT_MYSQL) != 0) and ((stmt.*.mysql.*.extension.*.mariadb_client_flag & (MARIADB_CLIENT_BULK_UNIT_RESULTS >> @as(c_int, 32))) != 0));
}
pub const CLEAR_CLIENT_STMT_ERROR = @compileError("unable to translate macro: undefined identifier `strcpy`");
// /usr/include/mysql/mariadb_stmt.h:43:9
pub const MYSQL_PS_SKIP_RESULT_W_LEN = -@as(c_int, 1);
pub const MYSQL_PS_SKIP_RESULT_STR = -@as(c_int, 2);
pub const STMT_ID_LENGTH = @as(c_int, 4);
pub const STMT_BULK_FLAG_CLIENT_SEND_TYPES = @as(c_int, 128);
pub const STMT_BULK_FLAG_SEND_UNIT_RESULTS = @as(c_int, 64);
pub const MYSQL_CLIENT_PLUGIN_HEADER = @compileError("unable to translate macro: undefined identifier `type`");
// /usr/include/mysql/mysql.h:482:9
pub inline fn mysql_reload(mysql: anytype) @TypeOf(mysql_refresh(mysql, REFRESH_GRANT)) {
    _ = &mysql;
    return mysql_refresh(mysql, REFRESH_GRANT);
}
pub const mysql_library_init = mysql_server_init;
pub const mysql_library_end = mysql_server_end;
pub inline fn mariadb_connect(hdl: anytype, conn_str: anytype) @TypeOf(mysql_real_connect(hdl, conn_str, NULL, NULL, NULL, @as(c_int, 0), NULL, @as(c_int, 0))) {
    _ = &hdl;
    _ = &conn_str;
    return mysql_real_connect(hdl, conn_str, NULL, NULL, NULL, @as(c_int, 0), NULL, @as(c_int, 0));
}
pub const HAVE_MYSQL_REAL_CONNECT = "";
pub const tm = struct_tm;
pub const timespec = struct_timespec;
pub const itimerspec = struct_itimerspec;
pub const sigevent = struct_sigevent;
pub const __locale_struct = struct___locale_struct;
pub const timeval = struct_timeval;
pub const __pthread_internal_list = struct___pthread_internal_list;
pub const __pthread_internal_slist = struct___pthread_internal_slist;
pub const __pthread_mutex_s = struct___pthread_mutex_s;
pub const __pthread_rwlock_arch_t = struct___pthread_rwlock_arch_t;
pub const __pthread_cond_s = struct___pthread_cond_s;
pub const Item_result = enum_Item_result;
pub const mysql_enum_shutdown_level = enum_mysql_enum_shutdown_level;
pub const enum_server_command = enum_enum_server_command;
pub const st_ma_pvio = struct_st_ma_pvio;
pub const st_ma_connection_plugin = struct_st_ma_connection_plugin;
pub const st_net = struct_st_net;
pub const enum_mysql_set_option = enum_enum_mysql_set_option;
pub const enum_mariadb_status_info = enum_enum_mariadb_status_info;
pub const enum_session_state_type = enum_enum_session_state_type;
pub const enum_field_types = enum_enum_field_types;
pub const rand_struct = struct_rand_struct;
pub const st_udf_args = struct_st_udf_args;
pub const st_udf_init = struct_st_udf_init;
pub const st_list = struct_st_list;
pub const ma_charset_info_st = struct_ma_charset_info_st;
pub const st_ma_const_string = struct_st_ma_const_string;
pub const st_ma_const_data = struct_st_ma_const_data;
pub const st_ma_used_mem = struct_st_ma_used_mem;
pub const st_ma_mem_root = struct_st_ma_mem_root;
pub const st_mysql_field = struct_st_mysql_field;
pub const st_mysql_rows = struct_st_mysql_rows;
pub const st_mysql_data = struct_st_mysql_data;
pub const mysql_option = enum_mysql_option;
pub const mariadb_value = enum_mariadb_value;
pub const mysql_status = enum_mysql_status;
pub const mysql_protocol_type = enum_mysql_protocol_type;
pub const st_mysql_options = struct_st_mysql_options;
pub const mysql_stmt_state = enum_mysql_stmt_state;
pub const st_mysql_bind = struct_st_mysql_bind;
pub const st_mysqlnd_upsert_result = struct_st_mysqlnd_upsert_result;
pub const st_mysql_res = struct_st_mysql_res;
pub const st_mysql_stmt = struct_st_mysql_stmt;
pub const character_set = struct_character_set;
pub const enum_stmt_attr_type = enum_enum_stmt_attr_type;
pub const st_mariadb_api = struct_st_mariadb_api;
pub const st_mariadb_methods = struct_st_mariadb_methods;
pub const st_mysql = struct_st_mysql;
pub const mariadb_field_attr_t = enum_mariadb_field_attr_t;
pub const enum_mysql_timestamp_type = enum_enum_mysql_timestamp_type;
pub const st_mysql_time = struct_st_mysql_time;
pub const enum_cursor_type = enum_enum_cursor_type;
pub const enum_indicator_type = enum_enum_indicator_type;
pub const st_mysql_cmd_buffer = struct_st_mysql_cmd_buffer;
pub const st_mysql_error_info = struct_st_mysql_error_info;
pub const st_mysql_perm_bind = struct_st_mysql_perm_bind;
pub const st_mysql_client_plugin = struct_st_mysql_client_plugin;
pub const mariadb_tls_verification = enum_mariadb_tls_verification;
