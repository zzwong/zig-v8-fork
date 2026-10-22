# zig-v8

Builds V8 from official source and provides C bindings and a Zig API. This would be used for embedding the V8 runtime into your Zig or C ABI compatible projects.

V8 is the JS/WASM runtime that powers Google Chrome and Microsoft Edge.

## System Requirements
- Zig compiler (0.17.0). Clone and build https://github.com/ziglang/zig.
- Python 3 (2.7 seems to work as well)
- unzip (`apt install unzip`)
- rsync (`apt install rsync`)
- For native macOS builds:
  - XCode (You won't need this when using zig's c++ toolchain!)<br/>
if you come across this error:<br />
`xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance`<br />
  run `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`

## Build
Compiling v8 will take 20+ minutes.

```sh
zig build prepare-v8
zig build build-v8
```

Once complete, you can find v8 in: `v8/out/LINUX_OR_MAC/debug/obj/zig/libc_v8.a`

If you build with `zig build -Doptimize=fast build-v8`, v8 will be in `v8/out/LINUX_OR_MAC/release/obj/zig/libc_v8.a`.

## Native ICU time zone bindings

Source builds include the UTF-16 ICU GetDefaultTimeZone, CanonicalTimeZoneID and SetDefaultTimeZone APIs declared through `src/binding.h`. These APIs change process-wide ICU state. Callers own serialization, restoration and dependent runtime cache notification; the binding does not implement browser-context isolation.

An older **matching V8 15.5.35.13 static archive** can use `-Dtimezone_overlay=true -Dprebuilt_v8_path=/absolute/path/libc_v8.a`. This compiles only `src/timezone.cpp` against the immutable ICU revision pinned by V8's DEPS. It does not build V8 or use system ICU. Run `zig build test` with those same options to exercise canonicalization, invalid-input no-mutation, default restoration and exact/short/zero/oversized UTF-16 buffers.

The overlay is opt-in and rejects shared libraries: existing `libc_v8.so` assets hide the native symbols it needs. Shared users need a new wrapper-containing asset built from source. Prebuilt consumers without the overlay retain their existing path and must not call the new APIs unless their asset already contains them. The tests skip unavailable time zone APIs on that path.
