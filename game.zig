const std = @import("std");
const glfw = @import("mach-glfw");
pub const gl = @import("gl");

// Table pointing to OpenGL functions, we get it at runtime since it is very large for the stack.
var gl_procs: gl.ProcTable = undefined;

pub fn run(
    comptime oneShot: fn () void,
    comptime draw: fn (delta: f32) void,
    comptime cleanup: fn () void,
) void {
    glfw.setErrorCallback(logGlfwError);
    if (!glfw.init(.{})) {
        std.log.err("Failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    }
    defer glfw.terminate();

    // Create our window
    var window = glfw.Window.create(640, 480, "Title", null, null, .{}) orelse {
        std.log.err("Failed to create GLFW window: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    window.setSizeLimits(.{ .width = 320, .height = 200 }, .{ .width = null, .height = null });
    defer window.destroy();

    // Make the window current.
    glfw.makeContextCurrent(window);
    defer glfw.makeContextCurrent(null);

    // Initialize OpenGL procedures with the window procedure address.
    if (!gl_procs.init(glfw.getProcAddress)) {
        std.log.err("Failed to initialize OpenGL procedures", .{});
        std.process.exit(1);
    }

    // Make the procedure table current.
    gl.makeProcTableCurrent(&gl_procs);
    defer gl.makeProcTableCurrent(null);

    // One shot stuff that gets passed to us.
    oneShot();

    // The game loop.
    var last_time = std.time.microTimestamp();
    while (!window.shouldClose()) {
        // Get delta time
        const micro_time_diff = std.time.microTimestamp() - last_time;
        last_time = std.time.microTimestamp();
        const delta = @as(f32, @floatFromInt(micro_time_diff)) * 0.000001;

        // Read input.

        // Draw stuff.
        draw(delta);

        // Call events and swap the buffers.
        window.swapBuffers();
        glfw.pollEvents();
    }

    // Cleanup steps passed to us.
    cleanup();
}

/// GLFW error callback function.
fn logGlfwError(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}
