<!--
© 2024 Carl Åstholm
SPDX-License-Identifier: MIT
-->

# SDL ported to the Zig build system

This is a port of SDL 3.0 to the Zig build system, packaged for the Zig package manager.

## Usage

```sh
zig fetch --save git+https://github.com/castholm/SDL
```

```zig
const sdl_dep = b.dependency("sdl", .{
    .target = target,
    .optimize = optimize,
    //.link_mode = .dynamic,
});
const sdl_lib = sdl_dep.artifact("SDL3");
const sdl_test_lib = sdl_dep.artifact("SDL3_test");
```

## License

This repository is [REUSE-compliant](https://reuse.software/). The effective SPDX license expression for the repository as a whole is:

```
(BSD-3-Clause OR GPL-3.0 OR HIDAPI) AND Apache-2.0 AND BSD-3-Clause AND CC0-1.0 AND HIDAPI AND HPND-sell-variant AND MIT AND SunPro AND Zlib
```

Copyright notices and license texts have been reproduced in [`LICENSE.txt`](LICENSE.txt), for your convenience.
