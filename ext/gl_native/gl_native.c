#include <ruby.h>

#ifdef __APPLE__
#include <OpenGL/gl3.h>
#else
#include <GL/gl.h>
#endif

/* Module reference */
static VALUE mGLNative;

/* BindFramebuffer(target, framebuffer) */
static VALUE rb_gl_bind_framebuffer(VALUE self, VALUE target, VALUE framebuffer) {
    glBindFramebuffer((GLenum)NUM2INT(target), (GLuint)NUM2UINT(framebuffer));
    return Qnil;
}

/* BindVertexArray(array) */
static VALUE rb_gl_bind_vertex_array(VALUE self, VALUE array) {
    glBindVertexArray((GLuint)NUM2UINT(array));
    return Qnil;
}

/* BindBuffer(target, buffer) */
static VALUE rb_gl_bind_buffer(VALUE self, VALUE target, VALUE buffer) {
    glBindBuffer((GLenum)NUM2INT(target), (GLuint)NUM2UINT(buffer));
    return Qnil;
}

/* BindTexture(target, texture) */
static VALUE rb_gl_bind_texture(VALUE self, VALUE target, VALUE texture) {
    glBindTexture((GLenum)NUM2INT(target), (GLuint)NUM2UINT(texture));
    return Qnil;
}

/* ActiveTexture(texture) */
static VALUE rb_gl_active_texture(VALUE self, VALUE texture) {
    glActiveTexture((GLenum)NUM2INT(texture));
    return Qnil;
}

/* UseProgram(program) */
static VALUE rb_gl_use_program(VALUE self, VALUE program) {
    glUseProgram((GLuint)NUM2UINT(program));
    return Qnil;
}

/* Enable(cap) */
static VALUE rb_gl_enable(VALUE self, VALUE cap) {
    glEnable((GLenum)NUM2INT(cap));
    return Qnil;
}

/* Disable(cap) */
static VALUE rb_gl_disable(VALUE self, VALUE cap) {
    glDisable((GLenum)NUM2INT(cap));
    return Qnil;
}

/* DrawArrays(mode, first, count) */
static VALUE rb_gl_draw_arrays(VALUE self, VALUE mode, VALUE first, VALUE count) {
    glDrawArrays((GLenum)NUM2INT(mode), (GLint)NUM2INT(first), (GLsizei)NUM2INT(count));
    return Qnil;
}

/* DrawElements(mode, count, type, indices) */
static VALUE rb_gl_draw_elements(VALUE self, VALUE mode, VALUE count, VALUE type, VALUE indices) {
    glDrawElements((GLenum)NUM2INT(mode), (GLsizei)NUM2INT(count), (GLenum)NUM2INT(type), (const void*)(uintptr_t)NUM2ULL(indices));
    return Qnil;
}

/* DrawElementsInstanced(mode, count, type, indices, instance_count) */
static VALUE rb_gl_draw_elements_instanced(VALUE self, VALUE mode, VALUE count, VALUE type, VALUE indices, VALUE instance_count) {
    glDrawElementsInstanced((GLenum)NUM2INT(mode), (GLsizei)NUM2INT(count), (GLenum)NUM2INT(type), (const void*)(uintptr_t)NUM2ULL(indices), (GLsizei)NUM2INT(instance_count));
    return Qnil;
}

/* Clear(mask) */
static VALUE rb_gl_clear(VALUE self, VALUE mask) {
    glClear((GLbitfield)NUM2UINT(mask));
    return Qnil;
}

/* Viewport(x, y, width, height) */
static VALUE rb_gl_viewport(VALUE self, VALUE x, VALUE y, VALUE width, VALUE height) {
    glViewport((GLint)NUM2INT(x), (GLint)NUM2INT(y), (GLsizei)NUM2INT(width), (GLsizei)NUM2INT(height));
    return Qnil;
}

/* Uniform1f(location, v0) */
static VALUE rb_gl_uniform1f(VALUE self, VALUE location, VALUE v0) {
    glUniform1f((GLint)NUM2INT(location), (GLfloat)NUM2DBL(v0));
    return Qnil;
}

/* Uniform2f(location, v0, v1) */
static VALUE rb_gl_uniform2f(VALUE self, VALUE location, VALUE v0, VALUE v1) {
    glUniform2f((GLint)NUM2INT(location), (GLfloat)NUM2DBL(v0), (GLfloat)NUM2DBL(v1));
    return Qnil;
}

/* Uniform3f(location, v0, v1, v2) */
static VALUE rb_gl_uniform3f(VALUE self, VALUE location, VALUE v0, VALUE v1, VALUE v2) {
    glUniform3f((GLint)NUM2INT(location), (GLfloat)NUM2DBL(v0), (GLfloat)NUM2DBL(v1), (GLfloat)NUM2DBL(v2));
    return Qnil;
}

/* Uniform4f(location, v0, v1, v2, v3) */
static VALUE rb_gl_uniform4f(VALUE self, VALUE location, VALUE v0, VALUE v1, VALUE v2, VALUE v3) {
    glUniform4f((GLint)NUM2INT(location), (GLfloat)NUM2DBL(v0), (GLfloat)NUM2DBL(v1), (GLfloat)NUM2DBL(v2), (GLfloat)NUM2DBL(v3));
    return Qnil;
}

/* Uniform1i(location, v0) */
static VALUE rb_gl_uniform1i(VALUE self, VALUE location, VALUE v0) {
    glUniform1i((GLint)NUM2INT(location), (GLint)NUM2INT(v0));
    return Qnil;
}

/* UniformMatrix4fv(location, count, transpose, value) */
static VALUE rb_gl_uniform_matrix4fv(VALUE self, VALUE location, VALUE count, VALUE transpose, VALUE value) {
    /* value should be a String containing packed floats */
    Check_Type(value, T_STRING);
    const GLfloat *data = (const GLfloat *)RSTRING_PTR(value);
    glUniformMatrix4fv((GLint)NUM2INT(location), (GLsizei)NUM2INT(count), (GLboolean)NUM2INT(transpose), data);
    return Qnil;
}

/* BlitFramebuffer(...) */
static VALUE rb_gl_blit_framebuffer(VALUE self, VALUE src_x0, VALUE src_y0, VALUE src_x1, VALUE src_y1,
                                     VALUE dst_x0, VALUE dst_y0, VALUE dst_x1, VALUE dst_y1,
                                     VALUE mask, VALUE filter) {
    glBlitFramebuffer(
        (GLint)NUM2INT(src_x0), (GLint)NUM2INT(src_y0), (GLint)NUM2INT(src_x1), (GLint)NUM2INT(src_y1),
        (GLint)NUM2INT(dst_x0), (GLint)NUM2INT(dst_y0), (GLint)NUM2INT(dst_x1), (GLint)NUM2INT(dst_y1),
        (GLbitfield)NUM2UINT(mask), (GLenum)NUM2INT(filter)
    );
    return Qnil;
}

/* AttachShader(program, shader) */
static VALUE rb_gl_attach_shader(VALUE self, VALUE program, VALUE shader) {
    glAttachShader((GLuint)NUM2UINT(program), (GLuint)NUM2UINT(shader));
    return Qnil;
}

/* BeginQuery(target, id) */
static VALUE rb_gl_begin_query(VALUE self, VALUE target, VALUE id) {
    glBeginQuery((GLenum)NUM2INT(target), (GLuint)NUM2UINT(id));
    return Qnil;
}

/* BlendFunc(sfactor, dfactor) */
static VALUE rb_gl_blend_func(VALUE self, VALUE sfactor, VALUE dfactor) {
    glBlendFunc((GLenum)NUM2INT(sfactor), (GLenum)NUM2INT(dfactor));
    return Qnil;
}

/* BufferData(target, size, data, usage) */
static VALUE rb_gl_buffer_data(VALUE self, VALUE target, VALUE size, VALUE data, VALUE usage) {
    const void *ptr = NIL_P(data) ? NULL : (const void *)RSTRING_PTR(data);
    glBufferData((GLenum)NUM2INT(target), (GLsizeiptr)NUM2LONG(size), ptr, (GLenum)NUM2INT(usage));
    return Qnil;
}

/* Extension init */
void Init_gl_native(void) {
    mGLNative = rb_define_module("GLNative");

    rb_define_module_function(mGLNative, "bind_framebuffer", rb_gl_bind_framebuffer, 2);
    rb_define_module_function(mGLNative, "bind_vertex_array", rb_gl_bind_vertex_array, 1);
    rb_define_module_function(mGLNative, "bind_buffer", rb_gl_bind_buffer, 2);
    rb_define_module_function(mGLNative, "bind_texture", rb_gl_bind_texture, 2);
    rb_define_module_function(mGLNative, "active_texture", rb_gl_active_texture, 1);
    rb_define_module_function(mGLNative, "use_program", rb_gl_use_program, 1);
    rb_define_module_function(mGLNative, "enable", rb_gl_enable, 1);
    rb_define_module_function(mGLNative, "disable", rb_gl_disable, 1);
    rb_define_module_function(mGLNative, "draw_arrays", rb_gl_draw_arrays, 3);
    rb_define_module_function(mGLNative, "draw_elements", rb_gl_draw_elements, 4);
    rb_define_module_function(mGLNative, "draw_elements_instanced", rb_gl_draw_elements_instanced, 5);
    rb_define_module_function(mGLNative, "clear", rb_gl_clear, 1);
    rb_define_module_function(mGLNative, "viewport", rb_gl_viewport, 4);
    rb_define_module_function(mGLNative, "uniform1f", rb_gl_uniform1f, 2);
    rb_define_module_function(mGLNative, "uniform2f", rb_gl_uniform2f, 3);
    rb_define_module_function(mGLNative, "uniform3f", rb_gl_uniform3f, 4);
    rb_define_module_function(mGLNative, "uniform4f", rb_gl_uniform4f, 5);
    rb_define_module_function(mGLNative, "uniform1i", rb_gl_uniform1i, 2);
    rb_define_module_function(mGLNative, "uniform_matrix4fv", rb_gl_uniform_matrix4fv, 4);
    rb_define_module_function(mGLNative, "blit_framebuffer", rb_gl_blit_framebuffer, 10);
    rb_define_module_function(mGLNative, "attach_shader", rb_gl_attach_shader, 2);
    rb_define_module_function(mGLNative, "begin_query", rb_gl_begin_query, 2);
    rb_define_module_function(mGLNative, "blend_func", rb_gl_blend_func, 2);
    rb_define_module_function(mGLNative, "buffer_data", rb_gl_buffer_data, 4);
}
