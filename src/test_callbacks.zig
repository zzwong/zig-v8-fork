const c = @import("v8.zig").c;

// binding.o requires the embedder's inspector callbacks even when no inspector
// is created. These exports belong only to this package's standalone test build.
pub export fn v8_inspector__Channel__IMPL__sendResponse(_: *c.InspectorChannelImpl, _: ?*anyopaque, _: c_int, _: [*c]u8, _: usize) callconv(.c) void {
    @panic("unexpected inspector callback in binding test");
}
pub export fn v8_inspector__Channel__IMPL__sendNotification(_: *c.InspectorChannelImpl, _: ?*anyopaque, _: [*c]u8, _: usize) callconv(.c) void {
    @panic("unexpected inspector callback in binding test");
}
pub export fn v8_inspector__Channel__IMPL__flushProtocolNotifications(_: *c.InspectorChannelImpl, _: ?*anyopaque) callconv(.c) void {
    @panic("unexpected inspector callback in binding test");
}
pub export fn v8_inspector__Client__IMPL__generateUniqueId(_: *c.InspectorClientImpl) callconv(.c) i64 {
    @panic("unexpected inspector callback in binding test");
}
pub export fn v8_inspector__Client__IMPL__runMessageLoopOnPause(_: *c.InspectorClientImpl, _: c_int) callconv(.c) void {
    @panic("unexpected inspector callback in binding test");
}
pub export fn v8_inspector__Client__IMPL__quitMessageLoopOnPause(_: *c.InspectorClientImpl) callconv(.c) void {
    @panic("unexpected inspector callback in binding test");
}
pub export fn v8_inspector__Client__IMPL__runIfWaitingForDebugger(_: *c.InspectorClientImpl, _: c_int) callconv(.c) void {
    @panic("unexpected inspector callback in binding test");
}
pub export fn v8_inspector__Client__IMPL__consoleAPIMessage(_: *c.InspectorClientImpl, _: c_int, _: c.MessageErrorLevel, _: *c.StringView, _: *c.StringView, _: c_uint, _: c_uint, _: *c.StackTrace) callconv(.c) void {
    @panic("unexpected inspector callback in binding test");
}
pub export fn v8_inspector__Client__IMPL__ensureDefaultContextInGroup(_: *c.InspectorClientImpl, _: ?*anyopaque, _: c_int) callconv(.c) ?*const c.Context {
    @panic("unexpected inspector callback in binding test");
}
