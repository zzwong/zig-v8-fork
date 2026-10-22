#include <memory>
#include <new>
#include "unicode/ucal.h"

#include "timezone.h"

namespace {
TimeZoneStatus status(UErrorCode error) {
  if (error == U_ILLEGAL_ARGUMENT_ERROR) return TimeZoneInvalidId;
  if (error == U_MEMORY_ALLOCATION_ERROR) return TimeZoneAllocationFailure;
  return U_FAILURE(error) ? TimeZoneIcuFailure : TimeZoneOk;
}

bool valid_id(const uint16_t* id, int32_t length) {
  if (!id || length <= 0) return false;
  for (int32_t i = 0; i < length; ++i) {
    if (id[i] == 0) return false;
  }
  return true;
}

bool valid_output(uint16_t* out, int32_t capacity, int32_t* required) {
  if (!required) return false;
  *required = 0;
  return capacity >= 0 && (out || capacity == 0);
}
}  // namespace

extern "C" TimeZoneStatus v8__V8__GetDefaultTimeZone(
    uint16_t* out, int32_t capacity, int32_t* required) {
  if (!valid_output(out, capacity, required)) return TimeZoneInvalidArgument;
  UErrorCode error = U_ZERO_ERROR;
  const int32_t size = ucal_getDefaultTimeZone(nullptr, 0, &error);
  if (error != U_BUFFER_OVERFLOW_ERROR && U_FAILURE(error)) return status(error);
  *required = size;
  if (capacity < size) return TimeZoneBufferTooSmall;
  error = U_ZERO_ERROR;
  ucal_getDefaultTimeZone(reinterpret_cast<UChar*>(out), size, &error);
  if (U_FAILURE(error)) *required = 0;
  return status(error);
}

extern "C" TimeZoneStatus v8__V8__CanonicalTimeZoneID(
    const uint16_t* id, int32_t length, uint16_t* out, int32_t capacity,
    int32_t* required) {
  if (!valid_output(out, capacity, required) || !valid_id(id, length))
    return TimeZoneInvalidArgument;
  UErrorCode error = U_ZERO_ERROR;
  const auto* input = reinterpret_cast<const UChar*>(id);
  UChar scratch;
  const int32_t size = ucal_getCanonicalTimeZoneID(
      input, length, &scratch, 1, nullptr, &error);
  if (error != U_BUFFER_OVERFLOW_ERROR && U_FAILURE(error)) return status(error);
  *required = size;
  if (capacity < size) return TimeZoneBufferTooSmall;
  error = U_ZERO_ERROR;
  ucal_getCanonicalTimeZoneID(input, length, reinterpret_cast<UChar*>(out),
                             size, nullptr, &error);
  if (U_FAILURE(error)) *required = 0;
  return status(error);
}

extern "C" TimeZoneStatus v8__V8__SetDefaultTimeZone(
    const uint16_t* id, int32_t length) {
  int32_t required;
  const auto checked = v8__V8__CanonicalTimeZoneID(
      id, length, nullptr, 0, &required);
  if (checked != TimeZoneBufferTooSmall && checked != TimeZoneOk) return checked;
  auto terminated = std::unique_ptr<UChar[]>(
      new (std::nothrow) UChar[static_cast<size_t>(length) + 1]);
  if (!terminated) return TimeZoneAllocationFailure;
  for (int32_t i = 0; i < length; ++i) terminated[i] = id[i];
  terminated[length] = 0;
  UErrorCode error = U_ZERO_ERROR;
  ucal_setDefaultTimeZone(terminated.get(), &error);
  return status(error);
}

