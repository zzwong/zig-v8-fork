#ifndef ZIG_V8_TIMEZONE_H
#define ZIG_V8_TIMEZONE_H
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum TimeZoneStatus {
    TimeZoneOk = 0,
    TimeZoneInvalidId,
    TimeZoneBufferTooSmall,
    TimeZoneInvalidArgument,
    TimeZoneAllocationFailure,
    TimeZoneIcuFailure,
} TimeZoneStatus;
// UTF-16 lengths and capacities are code units, excluding any terminator. No
// terminator is required or written. required is mandatory and receives the
// complete size on success or BufferTooSmall, otherwise zero. A null output is
// valid only at capacity zero. Short buffers are left untouched.
// Initialize ICU first. Callers must serialize process-wide default changes
// with all dependent ICU/V8 work; these functions do not provide isolation.
TimeZoneStatus v8__V8__GetDefaultTimeZone(uint16_t* out, int32_t capacity, int32_t* required);
TimeZoneStatus v8__V8__CanonicalTimeZoneID(const uint16_t* id, int32_t length, uint16_t* out, int32_t capacity, int32_t* required);
// IDs must be nonempty and contain no null code units. Invalid IDs leave the
// process default unchanged. Dependent runtime caches need separate notification.
TimeZoneStatus v8__V8__SetDefaultTimeZone(const uint16_t* id, int32_t length);

#ifdef __cplusplus
}
#endif
#endif
