<!--
© 2024 Carl Åstholm
SPDX-License-Identifier: MIT
-->

# SDL ported to the Zig build system

This is a port of [SDL](https://libsdl.org/) to the Zig build system, packaged for the Zig package manager.

## Usage

Requires Zig `0.12.1`, `0.13.0` or `0.14.0-dev` (master).

```sh
zig fetch --save git+https://github.com/castholm/SDL.git
```

```zig
const sdl_dep = b.dependency("sdl", .{
    .target = target,
    .optimize = optimize,
    //.preferred_link_mode = .static, // or .dynamic
});
const sdl_lib = sdl_dep.artifact("SDL3");
const sdl_test_lib = sdl_dep.artifact("SDL3_test");
```

Example projects using this SDL package:

- [castholm/zig-examples/breakout](https://github.com/castholm/zig-examples/tree/master/breakout)
- [castholm/zig-examples/snake](https://github.com/castholm/zig-examples/tree/master/snake)

## Supported targets

Target \ Host|Windows|Linux|macOS
-|:-:|:-:|:-:
`x86_64-windows-gnu`|✅|✅|✅
`aarch64-windows-gnu`|🧪|🧪|🧪
`x86_64-linux-gnu`|✅|✅|✅
`aarch64-linux-gnu`|🧪|🧪|🧪
`x86_64-macos-none`|❌|❌|🉑
`aarch64-macos-none`|❌|❌|🉑

Legend:

- ✅ Supported
- 🉑 Supported, but requires external SDKs
- 🧪 Experimental
- ❌ Not supported

### Windows

Building for x86-64 Windows from any host system works out of the box. AArch64 Windows support is experimental and not yet actively tested.

### Linux

Building for x86-64 Linux from any host system works out of the box. AArch64 Linux support is experimental and not yet actively tested.

The [castholm/SDL_linux_deps](https://github.com/castholm/SDL_linux_deps) package provides supplementary headers and source files required for compiling for Linux.

### macOS

Building for x86-64 or AArch64 macOS requires Xcode 14.1 or later to be installed on the host system.

When building for non-native targets (for example for x86-64 from an AArch64 Mac), you must provide a path to the macOS SDK via `--sysroot`. This path can be obtained by running `xcrun --sdk macosx --show-sdk-path`:

```sh
macos_sdk_path=$(xcrun --sdk macosx --show-sdk-path)
zig build -Dtarget=x86_64-macos-none --sysroot "$macos_sdk_path"
```

Cross-compiling for macOS from Windows or Linux host systems is not supported because [the Xcode and Apple SDKs Agreement](https://www.apple.com/legal/sla/docs/xcode.pdf) explicitly prohibits using macOS SDK files from non-Apple-branded computers or devices.

## License

This repository is [REUSE-compliant](https://reuse.software/). The effective SPDX license expression for the repository as a whole is:

```
(BSD-3-Clause OR GPL-3.0 OR HIDAPI) AND Apache-2.0 AND BSD-3-Clause AND CC0-1.0 AND HIDAPI AND HPND-sell-variant AND MIT AND SunPro AND Zlib
```

(This is identical to the upstream SDL repository, just expressed in more explicit terms.)

Copyright notices and license texts have been reproduced in [`LICENSE.txt`](LICENSE.txt), for your convenience.
