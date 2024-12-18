const std = @import("std");
const game = @import("game.zig");
const renderer = @import("renderer.zig");
const gl = @import("gl");

var shader_program: u32 = undefined;
var vao: u32 = undefined;
var vbo: u32 = undefined;
var ebo: u32 = undefined;

pub fn main() void {
    game.run(entry, draw, cleanup);
}

fn entry() void {
    // Vertex shader.
    const vert_shader = renderer.loadShader("basic.vert.glsl", .vertex);

    // Fragment shader.
    const frag_shader = renderer.loadShader("basic.frag.glsl", .fragment);

    // Link shaders.
    shader_program = gl.CreateProgram();
    gl.AttachShader(shader_program, vert_shader);
    gl.AttachShader(shader_program, frag_shader);
    gl.LinkProgram(shader_program);
    gl.DeleteShader(vert_shader);
    gl.DeleteShader(frag_shader);

    // Simple tri vertices.
    const vertices = [_]f32{
        // first tri
        0.5, 0.5, 0, // top right
        0.5, -0.5, 0, // bottom right
        -0.5, -0.5, 0, // bottom left
        -0.5, 0.5, 0, // top left
    };

    // Groups making up tris.
    const indices = [_]i32{
        0, 1, 3, // upper tri
        1, 2, 3, // lower tri
    };

    // Vertex buffer object.
    gl.GenBuffers(1, @ptrCast(&vbo)); // Generate buffers and assign ids.
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo); // Bind so we can write to it.
    gl.BufferData(gl.ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices, gl.STATIC_DRAW);

    // Vertex array object.
    gl.GenVertexArrays(1, @ptrCast(&vao)); // Generate arrays and assign ids.
    gl.BindVertexArray(vao); // Bind so we can write to it.

    // Element buffer object.
    gl.GenBuffers(1, @ptrCast(&ebo));
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, @sizeOf(@TypeOf(indices)), &indices, gl.STATIC_DRAW);

    // Tell OpenGL how to use the vertex data.
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), 0);
    gl.EnableVertexAttribArray(0);
    //gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE);
}

fn draw(delta: f64) void {
    gl.ClearColor(0, 0, 0, 1);
    gl.Clear(gl.COLOR_BUFFER_BIT);
    gl.UseProgram(shader_program);

    const wave_color: f32 = @floatCast((@sin(game.getTime()) + 1) / 2);
    const wave_color_loc: i32 = gl.GetUniformLocation(shader_program, "waveColor");
    gl.Uniform4f(wave_color_loc, wave_color, wave_color, wave_color, 1);

    gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, 0);
    std.debug.print("time: {d}\ndelta: {d}\nfps: {d}\n", .{ game.getTime(), delta, 1 / delta });
}

fn cleanup() void {
    gl.DeleteVertexArrays(1, @ptrCast(&vao));
    gl.DeleteBuffers(1, @ptrCast(&vbo));
    gl.DeleteBuffers(1, @ptrCast(&ebo));
    gl.DeleteShader(shader_program);
}
