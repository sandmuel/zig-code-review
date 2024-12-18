const std = @import("std");
const gl = @import("gl");

/// The opengl bindings use plain uints, we wrap those in an enum for safety.
const ShaderType = enum {
    geometry,
    vertex,
    fragment,
};

/// Takes in a path to the shader source, and the type of shader.
/// Returns OpenGL's provided ID for referencing the shader.
pub fn loadShader(comptime path: []const u8, shader_type: ShaderType) u32 {
    const shader_source = @embedFile(path);
    const gl_shader_type: u32 = switch (shader_type) {
        .geometry => gl.GEOMETRY_SHADER,
        .vertex => gl.VERTEX_SHADER,
        .fragment => gl.FRAGMENT_SHADER,
    };
    const shader: u32 = gl.CreateShader(gl_shader_type);
    gl.ShaderSource(shader, 1, @ptrCast(&shader_source), null);
    gl.CompileShader(shader);

    // Print any shader compilation errors.
    var success: i32 = undefined;
    gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success);
    if (success == 0) {
        var infoLog: [512]u8 = undefined;
        gl.GetShaderInfoLog(shader, 512, null, @ptrCast(&infoLog));
        std.log.err("{s}", .{infoLog});
    }

    return shader;
}
