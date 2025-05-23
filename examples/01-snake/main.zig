const std = @import("std");
const sdl = @import("sdl");
const BitArray = @import("bitarray.zig").BitArray;

const sdl_log = std.log.scoped(.sdl);
const app_log = std.log.scoped(.app);

const STEP_RATE_MS = 125;
const BLOCK_SIZE = 24;

const GAME_WIDTH = 24;
const GAME_HEIGHT = 18;

const WINDOW_WIDTH: comptime_int = BLOCK_SIZE * GAME_WIDTH;
const WINDOW_HEIGHT: comptime_int = BLOCK_SIZE * GAME_HEIGHT;

const MATRIX_SIZE: comptime_int = GAME_WIDTH * GAME_HEIGHT;
const CELL_MAX_BITS: comptime_int = 3;

const CellArray = BitArray(MATRIX_SIZE, u3);

const THREE_BITS: u8 = 0x7;

fn SHIFT(x: i16, y: i16) u16 {
    return @intCast(x + (y * GAME_WIDTH));
}

const Cell = enum(u3) {
    Empty,
    Right,
    Up,
    Left,
    Down,
    Food,

    fn to_int(c: Cell) u3 {
        return @intFromEnum(c);
    }

    fn from_dir(d: Direction) Cell {
        return @enumFromInt(@intFromEnum(d) + 1);
    }
};

const Direction = enum(u8) { Right, Up, Left, Down, _ };

const Vec2 = struct {
    x: i8,
    y: i8,

    pub fn new(x: anytype, y: anytype) Vec2 {
        return .{
            .x = @intCast(x),
            .y = @intCast(y),
        };
    }
};

fn frect(x: i16, y: i16) sdl.FRect {
    return .{
        .x = @floatFromInt(x * BLOCK_SIZE),
        .y = @floatFromInt(y * BLOCK_SIZE),
        .w = BLOCK_SIZE,
        .h = BLOCK_SIZE,
    };
}

const Context = struct {
    cells: CellArray = CellArray{},
    head: Vec2,
    tail: Vec2,
    next_dir: Direction,
    inhibit_tail_step: u8,
    occupied_cells: u32,

    fn init() Context {
        const x = GAME_WIDTH / 2;
        const y = GAME_HEIGHT / 2;
        var ctx = Context{
            .head = .{ .x = x, .y = y },
            .tail = .{ .x = x, .y = y },
            .next_dir = .Right,
            .inhibit_tail_step = 4,
            .occupied_cells = 3,
        };

        ctx.occupied_cells -= 1;
        put_cell_at(&ctx, ctx.tail, .Right);
        for (0..4) |_| {
            put_rand_food(&ctx);
            ctx.occupied_cells += 1;
        }

        return ctx;
    }
};

fn snake_redir(ctx: *Context, dir: Direction) void {
    const ct = cell_at(ctx, .{ .x = ctx.head.x, .y = ctx.head.y });
    if ((dir == .Right and ct != .Left) or
        (dir == .Up and ct != .Down) or
        (dir == .Left and ct != .Right) or
        (dir == .Down and ct != .Up))
    {
        ctx.next_dir = dir;
    }
}

fn wrap_around(val: anytype, max: @TypeOf(val)) i8 {
    if (val < 0) {
        return @intCast(max - 1);
    } else if (val > max - 1) {
        return 0;
    } else {
        return @intCast(val);
    }
}

const SnakeAppState = struct {
    ctx: Context,
    last_step: u64,
    window: *sdl.Window,
    renderer: *sdl.Renderer,
    joystick: ?*sdl.joystick.Joystick = null,
};

fn cell_at(ctx: *Context, pos: Vec2) Cell {
    const shift = SHIFT(pos.x, pos.y);
    return @enumFromInt(ctx.cells.get(shift));
}

fn put_cell_at(ctx: *Context, pos: Vec2, ct: Cell) void {
    const shift = SHIFT(pos.x, pos.y);
    ctx.cells.set(shift, @intFromEnum(ct));
}

fn are_cells_full(ctx: *Context) bool {
    return ctx.occupied_cells == (GAME_HEIGHT * GAME_WIDTH);
}

fn put_rand_food(ctx: *Context) void {
    while (true) {
        const rand = std.crypto.random;
        const x = rand.intRangeAtMost(u8, 0, GAME_WIDTH - 1);
        const y = rand.intRangeAtMost(u8, 0, GAME_HEIGHT - 1);
        if (cell_at(ctx, Vec2.new(x, y)) == .Empty) {
            put_cell_at(ctx, Vec2.new(x, y), .Food);
            return;
        }
    }
}

const App = struct {
    pub const AppState = SnakeAppState;
    const KVProp = struct {
        key: [*:0]const u8,
        val: [*:0]const u8,
    };

    fn kv(key: [*:0]const u8, val: [*:0]const u8) KVProp {
        return .{ .key = key, .val = val };
    }
    const extended_metadata = [_]KVProp{
        kv(sdl.app_metadata.URL_STRING, "https://examples.libsdl.org/SDL3/demo/01-snake/"),
        kv(sdl.app_metadata.CREATOR_STRING, "SDL team"),
        kv(sdl.app_metadata.COPYRIGHT_STRING, "Placed in the public domain"),
        kv(sdl.app_metadata.TYPE_STRING, "game"),
    };

    pub fn on_init(appstate: *?[*]SnakeAppState, args: []const [*:0]u8) sdl.AppResult {
        _ = args;

        if (!sdl.app_metadata.set("Example Snake game", "1.0", "com.example.Snake")) {
            return .Failure;
        }

        for (App.extended_metadata) |md| {
            if (!sdl.app_metadata.set_property(md.key, md.val)) {
                return .Failure;
            }
        }

        if (!sdl.init(.{ .video = true, .joystick = true })) {
            sdl_log.err("Couldn't initialize SDL: {s}", .{sdl.err.get()});
            return .Failure;
        }

        const as: ?[]SnakeAppState = std.heap.page_allocator.alloc(SnakeAppState, 1) catch null;
        if (as) |_| {} else {
            return .Failure;
        }
        appstate.* = @ptrCast(as.?.ptr);

        if (sdl.create_window_and_renderer("examples/demo/snake", WINDOW_WIDTH, WINDOW_HEIGHT, .{})) |r| {
            as.?[0] = .{
                .ctx = Context.init(),
                .last_step = sdl.get_ticks(),
                .window = r.window,
                .renderer = r.renderer,
            };
        } else {
            return .Failure;
        }

        return .Continue;
    }

    pub fn iter(appstates: ?[*]SnakeAppState) sdl.AppResult {
        if (appstates != null) {
            var appstate = &appstates.?[0];
            const ctx = &appstate.ctx;
            const now = sdl.get_ticks();

            // run game logic if we're at or past the time to run it. if we're
            // _really_ behind the time to run it, run it several times
            while ((now - appstate.last_step) >= STEP_RATE_MS) {
                snake_step(ctx);
                appstate.last_step += STEP_RATE_MS;
            }

            _ = sdl.render.draw_color(appstate.renderer, 0, 0, 0, sdl.ALPHA_OPAQUE);
            _ = sdl.render.clear(appstate.renderer);
            for (0..GAME_HEIGHT) |j| {
                for (0..GAME_WIDTH) |i| {
                    const ct = cell_at(ctx, Vec2.new(i, j));
                    if (ct == .Empty) {
                        continue;
                    }

                    if (ct == .Food) {
                        _ = sdl.render.draw_color(appstate.renderer, 80, 80, 255, sdl.ALPHA_OPAQUE);
                    } else {
                        // Body
                        _ = sdl.render.draw_color(appstate.renderer, 0, 128, 0, sdl.ALPHA_OPAQUE);
                    }
                    const rect = frect(@intCast(i), @intCast(j));
                    _ = sdl.render.fill_rect(appstate.renderer, &rect);
                }
            }

            // Head
            _ = sdl.render.draw_color(appstate.renderer, 255, 255, 0, sdl.ALPHA_OPAQUE);
            const rect = frect(@intCast(ctx.head.x), @intCast(ctx.head.y));
            _ = sdl.render.fill_rect(appstate.renderer, &rect);
            _ = sdl.render.present(appstate.renderer);
        }
        return .Continue;
    }

    pub fn on_event(appstates: ?[*]SnakeAppState, event: *sdl.Event) sdl.AppResult {
        if (appstates != null) {
            var as = &appstates.?[0];
            const ctx: *Context = &as.ctx;
            switch (event.type) {
                .Quit => {
                    return .Success;
                },
                .JoystickAdded => {
                    if (as.joystick == null) {
                        as.joystick = sdl.joystick.open(event.jdevice.which);
                        if (as.joystick == null) {
                            sdl_log.warn("Failed to open joystick Id {d}: {s}", .{ event.jdevice.which, sdl.err.get() });
                        }
                    }
                },
                .JoystickRemoved => {
                    if (as.joystick) |joystick| {
                        if (sdl.joystick.get_id(joystick) == event.jdevice.which) {
                            sdl.joystick.close(joystick);
                            as.joystick = null;
                        }
                    }
                },
                .JoystickHatMotion => {
                    return handle_hat_event(ctx, event.jhat.value);
                },
                .KeyDown => {
                    return handle_key_event(ctx, event.key.scancode);
                },
                else => {},
            }
        }
        return .Continue;
    }

    pub fn on_quit(appstate: ?[*]SnakeAppState, result: sdl.AppResult) void {
        _ = result;
        if (appstate) |*as| {
            if (as.*[0].joystick) |js| {
                sdl.joystick.close(js);
            }
            sdl.render.destroy(as.*[0].renderer);
            sdl.video.destroy_window(as.*[0].window);
            std.heap.page_allocator.free(as.*[0..1]);
        }
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    if (sdl.run_app(args, App) != 0) sdl_log.err("Failed to start application. Internal Error: {s}", .{sdl.err.get()});
}

fn snake_step(ctx: *Context) void {
    const dir_as_cell = Cell.from_dir(ctx.next_dir);
    var ct: Cell = undefined;

    // Move tail forward
    ctx.inhibit_tail_step -= 1;
    if (ctx.inhibit_tail_step == 0) {
        ctx.inhibit_tail_step += 1;
        ct = cell_at(ctx, ctx.tail);
        put_cell_at(ctx, ctx.tail, .Empty);
        switch (ct) {
            .Right => ctx.tail.x += 1,
            .Up => ctx.tail.y -= 1,
            .Left => ctx.tail.x -= 1,
            .Down => ctx.tail.y += 1,
            else => {},
        }
        ctx.tail.x = wrap_around(ctx.tail.x, GAME_WIDTH);
        ctx.tail.y = wrap_around(ctx.tail.y, GAME_HEIGHT);
    }

    // Move Head forward
    const prev = ctx.head;
    switch (ctx.next_dir) {
        .Right => ctx.head.x += 1,
        .Up => ctx.head.y -= 1,
        .Left => ctx.head.x -= 1,
        .Down => ctx.head.y += 1,
        else => {},
    }

    ctx.head.x = wrap_around(ctx.head.x, GAME_WIDTH);
    ctx.head.y = wrap_around(ctx.head.y, GAME_HEIGHT);

    // Collisions
    ct = cell_at(ctx, ctx.head);
    if (ct != .Empty and ct != .Food) {
        ctx.* = Context.init();
        return;
    }

    put_cell_at(ctx, prev, dir_as_cell);
    put_cell_at(ctx, ctx.head, dir_as_cell);
    if (ct == .Food) {
        if (are_cells_full(ctx)) {
            ctx.* = Context.init();
            return;
        }
        put_rand_food(ctx);
        ctx.inhibit_tail_step += 1;
        ctx.occupied_cells += 1;
    }
}

fn handle_key_event(ctx: *Context, key: sdl.Scanecode) sdl.AppResult {
    switch (key) {
        .ESCAPE, .Q => {
            return .Success;
        },
        .R => {
            ctx.* = Context.init();
        },
        .Right => {
            snake_redir(ctx, .Right);
        },
        .Up => {
            snake_redir(ctx, .Up);
        },
        .Left => {
            snake_redir(ctx, .Left);
        },
        .Down => {
            snake_redir(ctx, .Down);
        },
        else => {},
    }
    return .Continue;
}

fn handle_hat_event(ctx: *Context, hat: sdl.joystick.Hat) sdl.AppResult {
    if (hat.contains(.Right)) {
        snake_redir(ctx, .Right);
    } else if (hat.contains(.Up)) {
        snake_redir(ctx, .Up);
    } else if (hat.contains(.Left)) {
        snake_redir(ctx, .Left);
    } else if (hat.contains(.Right)) {
        snake_redir(ctx, .Right);
    }
    return .Continue;
}
