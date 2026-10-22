const std = @import("std");

pub const c = @import("binding");

/// Enables C to allocate using the given Zig allocator.
pub export fn zigAlloc(self: *anyopaque, bytes: usize) callconv(.c) ?[*]u8 {
    const allocator: *std.mem.Allocator = @ptrCast(@alignCast(self));
    const allocated_bytes = allocator.alloc(u8, bytes) catch return null;
    return allocated_bytes.ptr;
}

comptime {
    if (@import("default_exports").standalone_tests) {
        _ = @import("test_callbacks.zig");
    }
    if (@import("default_exports").inspector_subtype) {
        _ = @import("inspector_subtypes.zig");
    }
}

test "timezone UTF16 sizing, canonicalization and invalid no-mutation" {
    if (comptime !@import("default_exports").timezone_bindings) return error.SkipZigTest;
    try std.testing.expect(c.v8__V8__InitializeICU());
    const original = try defaultTimeZone();
    defer std.testing.allocator.free(original);
    defer std.debug.assert(c.v8__V8__SetDefaultTimeZone(original.ptr, @intCast(original.len)) == c.TimeZoneOk);

    var required: i32 = -1;
    try expectTimeZoneStatus(c.TimeZoneBufferTooSmall, c.v8__V8__GetDefaultTimeZone(null, 0, &required));
    try std.testing.expectEqual(original.len, @as(usize, @intCast(required)));
    const exact = try std.testing.allocator.alloc(u16, original.len);
    defer std.testing.allocator.free(exact);
    @memset(exact, 0xffff);
    try expectTimeZoneStatus(c.TimeZoneBufferTooSmall, c.v8__V8__GetDefaultTimeZone(exact.ptr, @intCast(exact.len - 1), &required));
    for (exact) |unit| try std.testing.expectEqual(@as(u16, 0xffff), unit);
    try expectTimeZoneStatus(c.TimeZoneOk, c.v8__V8__GetDefaultTimeZone(exact.ptr, @intCast(exact.len), &required));
    try std.testing.expectEqualSlices(u16, original, exact);
    const oversized = try std.testing.allocator.alloc(u16, original.len + 3);
    defer std.testing.allocator.free(oversized);
    @memset(oversized, 0xffff);
    try expectTimeZoneStatus(c.TimeZoneOk, c.v8__V8__GetDefaultTimeZone(oversized.ptr, @intCast(oversized.len), &required));
    try std.testing.expectEqualSlices(u16, original, oversized[0..original.len]);
    for (oversized[original.len..]) |unit| try std.testing.expectEqual(@as(u16, 0xffff), unit);

    const alias = std.unicode.utf8ToUtf16LeStringLiteral("US/Eastern");
    const canonical = std.unicode.utf8ToUtf16LeStringLiteral("America/New_York");
    var buffer: [canonical.len]u16 = @splat(0xffff);
    try expectTimeZoneStatus(c.TimeZoneBufferTooSmall, c.v8__V8__CanonicalTimeZoneID(alias, alias.len, null, 0, &required));
    try std.testing.expectEqual(@as(i32, canonical.len), required);
    try expectTimeZoneStatus(c.TimeZoneBufferTooSmall, c.v8__V8__CanonicalTimeZoneID(alias, alias.len, &buffer, buffer.len - 1, &required));
    for (buffer) |unit| try std.testing.expectEqual(@as(u16, 0xffff), unit);
    try expectTimeZoneStatus(c.TimeZoneOk, c.v8__V8__CanonicalTimeZoneID(alias, alias.len, &buffer, buffer.len, &required));
    try std.testing.expectEqualSlices(u16, canonical, &buffer);
    var oversized_canonical: [canonical.len + 3]u16 = @splat(0xffff);
    try expectTimeZoneStatus(c.TimeZoneOk, c.v8__V8__CanonicalTimeZoneID(alias, alias.len, &oversized_canonical, oversized_canonical.len, &required));
    try std.testing.expectEqualSlices(u16, canonical, oversized_canonical[0..canonical.len]);
    for (oversized_canonical[canonical.len..]) |unit| try std.testing.expectEqual(@as(u16, 0xffff), unit);
    try expectTimeZoneStatus(c.TimeZoneOk, c.v8__V8__SetDefaultTimeZone(alias, alias.len));
    const active = try defaultTimeZone();
    defer std.testing.allocator.free(active);

    const invalid = std.unicode.utf8ToUtf16LeStringLiteral("Invalid/Timezone");
    @memset(&buffer, 0xffff);
    try expectTimeZoneStatus(c.TimeZoneInvalidId, c.v8__V8__CanonicalTimeZoneID(invalid, invalid.len, &buffer, buffer.len, &required));
    try std.testing.expectEqual(@as(i32, 0), required);
    for (buffer) |unit| try std.testing.expectEqual(@as(u16, 0xffff), unit);
    try expectTimeZoneStatus(c.TimeZoneInvalidId, c.v8__V8__SetDefaultTimeZone(invalid, invalid.len));
    const unchanged = try defaultTimeZone();
    defer std.testing.allocator.free(unchanged);
    try std.testing.expectEqualSlices(u16, active, unchanged);

    try expectTimeZoneStatus(c.TimeZoneInvalidArgument, c.v8__V8__GetDefaultTimeZone(null, 1, &required));
    try std.testing.expectEqual(@as(i32, 0), required);
    try expectTimeZoneStatus(c.TimeZoneInvalidArgument, c.v8__V8__GetDefaultTimeZone(&buffer, -1, &required));
    try expectTimeZoneStatus(c.TimeZoneInvalidArgument, c.v8__V8__GetDefaultTimeZone(&buffer, buffer.len, null));
    try expectTimeZoneStatus(c.TimeZoneInvalidArgument, c.v8__V8__SetDefaultTimeZone(null, 0));
    const embedded_null = [_]u16{ 'U', 'T', 'C', 0, 'X' };
    try expectTimeZoneStatus(c.TimeZoneInvalidArgument, c.v8__V8__SetDefaultTimeZone(&embedded_null, embedded_null.len));
    try expectTimeZoneStatus(c.TimeZoneOk, c.v8__V8__SetDefaultTimeZone(original.ptr, @intCast(original.len)));
    const restored = try defaultTimeZone();
    defer std.testing.allocator.free(restored);
    try std.testing.expectEqualSlices(u16, original, restored);
}

fn defaultTimeZone() ![]u16 {
    var required: i32 = 0;
    try expectTimeZoneStatus(c.TimeZoneBufferTooSmall, c.v8__V8__GetDefaultTimeZone(null, 0, &required));
    const zone = try std.testing.allocator.alloc(u16, @intCast(required));
    errdefer std.testing.allocator.free(zone);
    try expectTimeZoneStatus(c.TimeZoneOk, c.v8__V8__GetDefaultTimeZone(zone.ptr, @intCast(zone.len), &required));
    return zone;
}

fn expectTimeZoneStatus(expected: c.TimeZoneStatus, actual: c.TimeZoneStatus) !void {
    try std.testing.expectEqual(expected, actual);
}
