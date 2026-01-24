#include <ruby.h>
#include <stdint.h>

#ifdef __APPLE__
#include <dlfcn.h>
#elif defined(_WIN32)
#include <windows.h>
#else
#include <dlfcn.h>
#endif

/* GLFW type definitions */
typedef void* GLFWwindow;
typedef void* GLFWmonitor;

typedef struct {
    int width;
    int height;
    int redBits;
    int greenBits;
    int blueBits;
    int refreshRate;
} GLFWvidmode;

/* Callback type definitions */
typedef void (*GLFWkeyfun)(GLFWwindow*, int, int, int, int);
typedef void (*GLFWcursorposfun)(GLFWwindow*, double, double);
typedef void (*GLFWmousebuttonfun)(GLFWwindow*, int, int, int);

/* Function pointer types */
typedef int (*PFN_glfwInit)(void);
typedef void (*PFN_glfwTerminate)(void);
typedef GLFWwindow* (*PFN_glfwCreateWindow)(int, int, const char*, GLFWmonitor*, GLFWwindow*);
typedef void (*PFN_glfwDestroyWindow)(GLFWwindow*);
typedef void (*PFN_glfwWindowHint)(int, int);
typedef void (*PFN_glfwSetWindowAttrib)(GLFWwindow*, int, int);
typedef void (*PFN_glfwSetWindowTitle)(GLFWwindow*, const char*);
typedef void (*PFN_glfwSetWindowMonitor)(GLFWwindow*, GLFWmonitor*, int, int, int, int, int);
typedef int (*PFN_glfwWindowShouldClose)(GLFWwindow*);
typedef void (*PFN_glfwSetWindowShouldClose)(GLFWwindow*, int);
typedef void (*PFN_glfwFocusWindow)(GLFWwindow*);
typedef void (*PFN_glfwMakeContextCurrent)(GLFWwindow*);
typedef void (*PFN_glfwGetFramebufferSize)(GLFWwindow*, int*, int*);
typedef void (*PFN_glfwPollEvents)(void);
typedef void (*PFN_glfwSwapBuffers)(GLFWwindow*);
typedef void (*PFN_glfwSwapInterval)(int);
typedef GLFWkeyfun (*PFN_glfwSetKeyCallback)(GLFWwindow*, GLFWkeyfun);
typedef GLFWcursorposfun (*PFN_glfwSetCursorPosCallback)(GLFWwindow*, GLFWcursorposfun);
typedef GLFWmousebuttonfun (*PFN_glfwSetMouseButtonCallback)(GLFWwindow*, GLFWmousebuttonfun);
typedef GLFWmonitor* (*PFN_glfwGetPrimaryMonitor)(void);
typedef const GLFWvidmode* (*PFN_glfwGetVideoMode)(GLFWmonitor*);
typedef const GLFWvidmode* (*PFN_glfwGetVideoModes)(GLFWmonitor*, int*);
typedef void (*PFN_glfwSetInputMode)(GLFWwindow*, int, int);
typedef int (*PFN_glfwGetInputMode)(GLFWwindow*, int);

/* Function pointers storage */
static PFN_glfwInit pfn_glfwInit = NULL;
static PFN_glfwTerminate pfn_glfwTerminate = NULL;
static PFN_glfwCreateWindow pfn_glfwCreateWindow = NULL;
static PFN_glfwDestroyWindow pfn_glfwDestroyWindow = NULL;
static PFN_glfwWindowHint pfn_glfwWindowHint = NULL;
static PFN_glfwSetWindowAttrib pfn_glfwSetWindowAttrib = NULL;
static PFN_glfwSetWindowTitle pfn_glfwSetWindowTitle = NULL;
static PFN_glfwSetWindowMonitor pfn_glfwSetWindowMonitor = NULL;
static PFN_glfwWindowShouldClose pfn_glfwWindowShouldClose = NULL;
static PFN_glfwSetWindowShouldClose pfn_glfwSetWindowShouldClose = NULL;
static PFN_glfwFocusWindow pfn_glfwFocusWindow = NULL;
static PFN_glfwMakeContextCurrent pfn_glfwMakeContextCurrent = NULL;
static PFN_glfwGetFramebufferSize pfn_glfwGetFramebufferSize = NULL;
static PFN_glfwPollEvents pfn_glfwPollEvents = NULL;
static PFN_glfwSwapBuffers pfn_glfwSwapBuffers = NULL;
static PFN_glfwSwapInterval pfn_glfwSwapInterval = NULL;
static PFN_glfwSetKeyCallback pfn_glfwSetKeyCallback = NULL;
static PFN_glfwSetCursorPosCallback pfn_glfwSetCursorPosCallback = NULL;
static PFN_glfwSetMouseButtonCallback pfn_glfwSetMouseButtonCallback = NULL;
static PFN_glfwGetPrimaryMonitor pfn_glfwGetPrimaryMonitor = NULL;
static PFN_glfwGetVideoMode pfn_glfwGetVideoMode = NULL;
static PFN_glfwGetVideoModes pfn_glfwGetVideoModes = NULL;
static PFN_glfwSetInputMode pfn_glfwSetInputMode = NULL;
static PFN_glfwGetInputMode pfn_glfwGetInputMode = NULL;

/* Library handle */
static void* glfw_lib = NULL;

/* Module reference */
static VALUE mGLFWNative;

/* Callback storage - we store Ruby procs */
static VALUE rb_key_callback = Qnil;
static VALUE rb_cursor_pos_callback = Qnil;
static VALUE rb_mouse_button_callback = Qnil;

/* Helper to load a function pointer */
static void* load_func(const char* name) {
    if (!glfw_lib) {
        rb_raise(rb_eRuntimeError, "GLFW library not loaded. Call load_lib first.");
    }
#ifdef _WIN32
    return GetProcAddress((HMODULE)glfw_lib, name);
#else
    return dlsym(glfw_lib, name);
#endif
}

/* load_lib(path) - Load the GLFW shared library */
static VALUE rb_glfw_load_lib(VALUE self, VALUE path) {
    const char* lib_path = StringValueCStr(path);

#ifdef _WIN32
    glfw_lib = LoadLibrary(lib_path);
#else
    glfw_lib = dlopen(lib_path, RTLD_LAZY | RTLD_GLOBAL);
#endif

    if (!glfw_lib) {
#ifdef _WIN32
        rb_raise(rb_eRuntimeError, "Failed to load GLFW library: %s", lib_path);
#else
        rb_raise(rb_eRuntimeError, "Failed to load GLFW library: %s - %s", lib_path, dlerror());
#endif
    }

    /* Load all function pointers */
    pfn_glfwInit = (PFN_glfwInit)load_func("glfwInit");
    pfn_glfwTerminate = (PFN_glfwTerminate)load_func("glfwTerminate");
    pfn_glfwCreateWindow = (PFN_glfwCreateWindow)load_func("glfwCreateWindow");
    pfn_glfwDestroyWindow = (PFN_glfwDestroyWindow)load_func("glfwDestroyWindow");
    pfn_glfwWindowHint = (PFN_glfwWindowHint)load_func("glfwWindowHint");
    pfn_glfwSetWindowAttrib = (PFN_glfwSetWindowAttrib)load_func("glfwSetWindowAttrib");
    pfn_glfwSetWindowTitle = (PFN_glfwSetWindowTitle)load_func("glfwSetWindowTitle");
    pfn_glfwSetWindowMonitor = (PFN_glfwSetWindowMonitor)load_func("glfwSetWindowMonitor");
    pfn_glfwWindowShouldClose = (PFN_glfwWindowShouldClose)load_func("glfwWindowShouldClose");
    pfn_glfwSetWindowShouldClose = (PFN_glfwSetWindowShouldClose)load_func("glfwSetWindowShouldClose");
    pfn_glfwFocusWindow = (PFN_glfwFocusWindow)load_func("glfwFocusWindow");
    pfn_glfwMakeContextCurrent = (PFN_glfwMakeContextCurrent)load_func("glfwMakeContextCurrent");
    pfn_glfwGetFramebufferSize = (PFN_glfwGetFramebufferSize)load_func("glfwGetFramebufferSize");
    pfn_glfwPollEvents = (PFN_glfwPollEvents)load_func("glfwPollEvents");
    pfn_glfwSwapBuffers = (PFN_glfwSwapBuffers)load_func("glfwSwapBuffers");
    pfn_glfwSwapInterval = (PFN_glfwSwapInterval)load_func("glfwSwapInterval");
    pfn_glfwSetKeyCallback = (PFN_glfwSetKeyCallback)load_func("glfwSetKeyCallback");
    pfn_glfwSetCursorPosCallback = (PFN_glfwSetCursorPosCallback)load_func("glfwSetCursorPosCallback");
    pfn_glfwSetMouseButtonCallback = (PFN_glfwSetMouseButtonCallback)load_func("glfwSetMouseButtonCallback");
    pfn_glfwGetPrimaryMonitor = (PFN_glfwGetPrimaryMonitor)load_func("glfwGetPrimaryMonitor");
    pfn_glfwGetVideoMode = (PFN_glfwGetVideoMode)load_func("glfwGetVideoMode");
    pfn_glfwGetVideoModes = (PFN_glfwGetVideoModes)load_func("glfwGetVideoModes");
    pfn_glfwSetInputMode = (PFN_glfwSetInputMode)load_func("glfwSetInputMode");
    pfn_glfwGetInputMode = (PFN_glfwGetInputMode)load_func("glfwGetInputMode");

    return Qtrue;
}

/* Init() */
static VALUE rb_glfw_init(VALUE self) {
    if (!pfn_glfwInit) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    int result = pfn_glfwInit();
    return INT2NUM(result);
}

/* Terminate() */
static VALUE rb_glfw_terminate(VALUE self) {
    if (!pfn_glfwTerminate) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    pfn_glfwTerminate();
    return Qnil;
}

/* CreateWindow(width, height, title, monitor, share) */
static VALUE rb_glfw_create_window(VALUE self, VALUE width, VALUE height, VALUE title, VALUE monitor, VALUE share) {
    if (!pfn_glfwCreateWindow) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    const char* title_str = StringValueCStr(title);
    GLFWmonitor* mon = NIL_P(monitor) ? NULL : (GLFWmonitor*)(uintptr_t)NUM2ULL(monitor);
    GLFWwindow* shr = NIL_P(share) ? NULL : (GLFWwindow*)(uintptr_t)NUM2ULL(share);
    GLFWwindow* window = pfn_glfwCreateWindow(NUM2INT(width), NUM2INT(height), title_str, mon, shr);
    if (!window) return Qnil;
    return ULL2NUM((uintptr_t)window);
}

/* DestroyWindow(window) */
static VALUE rb_glfw_destroy_window(VALUE self, VALUE window) {
    if (!pfn_glfwDestroyWindow) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);
    pfn_glfwDestroyWindow(win);
    return Qnil;
}

/* WindowHint(hint, value) */
static VALUE rb_glfw_window_hint(VALUE self, VALUE hint, VALUE value) {
    if (!pfn_glfwWindowHint) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    pfn_glfwWindowHint(NUM2INT(hint), NUM2INT(value));
    return Qnil;
}

/* SetWindowAttrib(window, attrib, value) */
static VALUE rb_glfw_set_window_attrib(VALUE self, VALUE window, VALUE attrib, VALUE value) {
    if (!pfn_glfwSetWindowAttrib) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);
    pfn_glfwSetWindowAttrib(win, NUM2INT(attrib), NUM2INT(value));
    return Qnil;
}

/* SetWindowTitle(window, title) */
static VALUE rb_glfw_set_window_title(VALUE self, VALUE window, VALUE title) {
    if (!pfn_glfwSetWindowTitle) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);
    const char* title_str = StringValueCStr(title);
    pfn_glfwSetWindowTitle(win, title_str);
    return Qnil;
}

/* SetWindowMonitor(window, monitor, xpos, ypos, width, height, refreshRate) */
static VALUE rb_glfw_set_window_monitor(VALUE self, VALUE window, VALUE monitor, VALUE xpos, VALUE ypos, VALUE width, VALUE height, VALUE refresh_rate) {
    if (!pfn_glfwSetWindowMonitor) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);
    GLFWmonitor* mon = NIL_P(monitor) ? NULL : (GLFWmonitor*)(uintptr_t)NUM2ULL(monitor);
    pfn_glfwSetWindowMonitor(win, mon, NUM2INT(xpos), NUM2INT(ypos), NUM2INT(width), NUM2INT(height), NUM2INT(refresh_rate));
    return Qnil;
}

/* WindowShouldClose(window) */
static VALUE rb_glfw_window_should_close(VALUE self, VALUE window) {
    if (!pfn_glfwWindowShouldClose) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);
    int result = pfn_glfwWindowShouldClose(win);
    return INT2NUM(result);
}

/* SetWindowShouldClose(window, value) */
static VALUE rb_glfw_set_window_should_close(VALUE self, VALUE window, VALUE value) {
    if (!pfn_glfwSetWindowShouldClose) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);
    pfn_glfwSetWindowShouldClose(win, NUM2INT(value));
    return Qnil;
}

/* FocusWindow(window) */
static VALUE rb_glfw_focus_window(VALUE self, VALUE window) {
    if (!pfn_glfwFocusWindow) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);
    pfn_glfwFocusWindow(win);
    return Qnil;
}

/* MakeContextCurrent(window) */
static VALUE rb_glfw_make_context_current(VALUE self, VALUE window) {
    if (!pfn_glfwMakeContextCurrent) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);
    pfn_glfwMakeContextCurrent(win);
    return Qnil;
}

/* GetFramebufferSize(window, width_buf, height_buf) - writes to buffers */
static VALUE rb_glfw_get_framebuffer_size(VALUE self, VALUE window, VALUE width_buf, VALUE height_buf) {
    if (!pfn_glfwGetFramebufferSize) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);
    Check_Type(width_buf, T_STRING);
    Check_Type(height_buf, T_STRING);
    int* w_ptr = (int*)RSTRING_PTR(width_buf);
    int* h_ptr = (int*)RSTRING_PTR(height_buf);
    pfn_glfwGetFramebufferSize(win, w_ptr, h_ptr);
    return Qnil;
}

/* PollEvents() */
static VALUE rb_glfw_poll_events(VALUE self) {
    if (!pfn_glfwPollEvents) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    pfn_glfwPollEvents();
    return Qnil;
}

/* SwapBuffers(window) */
static VALUE rb_glfw_swap_buffers(VALUE self, VALUE window) {
    if (!pfn_glfwSwapBuffers) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);
    pfn_glfwSwapBuffers(win);
    return Qnil;
}

/* SwapInterval(interval) */
static VALUE rb_glfw_swap_interval(VALUE self, VALUE interval) {
    if (!pfn_glfwSwapInterval) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    pfn_glfwSwapInterval(NUM2INT(interval));
    return Qnil;
}

/* GetPrimaryMonitor() */
static VALUE rb_glfw_get_primary_monitor(VALUE self) {
    if (!pfn_glfwGetPrimaryMonitor) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWmonitor* monitor = pfn_glfwGetPrimaryMonitor();
    if (!monitor) return Qnil;
    return ULL2NUM((uintptr_t)monitor);
}

/* GetVideoMode(monitor) - returns pointer as integer */
static VALUE rb_glfw_get_video_mode(VALUE self, VALUE monitor) {
    if (!pfn_glfwGetVideoMode) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWmonitor* mon = (GLFWmonitor*)(uintptr_t)NUM2ULL(monitor);
    const GLFWvidmode* mode = pfn_glfwGetVideoMode(mon);
    if (!mode) return Qnil;
    return ULL2NUM((uintptr_t)mode);
}

/* GetVideoModes(monitor, count_buf) - returns pointer as integer, writes count to buffer */
static VALUE rb_glfw_get_video_modes(VALUE self, VALUE monitor, VALUE count_buf) {
    if (!pfn_glfwGetVideoModes) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWmonitor* mon = (GLFWmonitor*)(uintptr_t)NUM2ULL(monitor);
    Check_Type(count_buf, T_STRING);
    int* count_ptr = (int*)RSTRING_PTR(count_buf);
    const GLFWvidmode* modes = pfn_glfwGetVideoModes(mon, count_ptr);
    if (!modes) return Qnil;
    return ULL2NUM((uintptr_t)modes);
}

/* SetInputMode(window, mode, value) */
static VALUE rb_glfw_set_input_mode(VALUE self, VALUE window, VALUE mode, VALUE value) {
    if (!pfn_glfwSetInputMode) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);
    pfn_glfwSetInputMode(win, NUM2INT(mode), NUM2INT(value));
    return Qnil;
}

/* GetInputMode(window, mode) */
static VALUE rb_glfw_get_input_mode(VALUE self, VALUE window, VALUE mode) {
    if (!pfn_glfwGetInputMode) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);
    int result = pfn_glfwGetInputMode(win, NUM2INT(mode));
    return INT2NUM(result);
}

/* Callback trampolines - these are called by GLFW and invoke Ruby procs */
static void key_callback_trampoline(GLFWwindow* window, int key, int scancode, int action, int mods) {
    if (rb_key_callback != Qnil) {
        VALUE args[5];
        args[0] = ULL2NUM((uintptr_t)window);
        args[1] = INT2NUM(key);
        args[2] = INT2NUM(scancode);
        args[3] = INT2NUM(action);
        args[4] = INT2NUM(mods);
        rb_funcall2(rb_key_callback, rb_intern("call"), 5, args);
    }
}

static void cursor_pos_callback_trampoline(GLFWwindow* window, double xpos, double ypos) {
    if (rb_cursor_pos_callback != Qnil) {
        VALUE args[3];
        args[0] = ULL2NUM((uintptr_t)window);
        args[1] = DBL2NUM(xpos);
        args[2] = DBL2NUM(ypos);
        rb_funcall2(rb_cursor_pos_callback, rb_intern("call"), 3, args);
    }
}

static void mouse_button_callback_trampoline(GLFWwindow* window, int button, int action, int mods) {
    if (rb_mouse_button_callback != Qnil) {
        VALUE args[4];
        args[0] = ULL2NUM((uintptr_t)window);
        args[1] = INT2NUM(button);
        args[2] = INT2NUM(action);
        args[3] = INT2NUM(mods);
        rb_funcall2(rb_mouse_button_callback, rb_intern("call"), 4, args);
    }
}

/* SetKeyCallback(window, callback) - callback is a Ruby proc/block */
static VALUE rb_glfw_set_key_callback(VALUE self, VALUE window, VALUE callback) {
    if (!pfn_glfwSetKeyCallback) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);

    rb_key_callback = callback;
    if (NIL_P(callback)) {
        pfn_glfwSetKeyCallback(win, NULL);
    } else {
        pfn_glfwSetKeyCallback(win, key_callback_trampoline);
    }
    return Qnil;
}

/* SetCursorPosCallback(window, callback) */
static VALUE rb_glfw_set_cursor_pos_callback(VALUE self, VALUE window, VALUE callback) {
    if (!pfn_glfwSetCursorPosCallback) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);

    rb_cursor_pos_callback = callback;
    if (NIL_P(callback)) {
        pfn_glfwSetCursorPosCallback(win, NULL);
    } else {
        pfn_glfwSetCursorPosCallback(win, cursor_pos_callback_trampoline);
    }
    return Qnil;
}

/* SetMouseButtonCallback(window, callback) */
static VALUE rb_glfw_set_mouse_button_callback(VALUE self, VALUE window, VALUE callback) {
    if (!pfn_glfwSetMouseButtonCallback) rb_raise(rb_eRuntimeError, "GLFW not loaded");
    GLFWwindow* win = (GLFWwindow*)(uintptr_t)NUM2ULL(window);

    rb_mouse_button_callback = callback;
    if (NIL_P(callback)) {
        pfn_glfwSetMouseButtonCallback(win, NULL);
    } else {
        pfn_glfwSetMouseButtonCallback(win, mouse_button_callback_trampoline);
    }
    return Qnil;
}

/* Extension init */
void Init_glfw_native(void) {
    mGLFWNative = rb_define_module("GLFWNative");

    /* Register callbacks for GC marking */
    rb_gc_register_address(&rb_key_callback);
    rb_gc_register_address(&rb_cursor_pos_callback);
    rb_gc_register_address(&rb_mouse_button_callback);

    /* Library loading */
    rb_define_module_function(mGLFWNative, "load_lib", rb_glfw_load_lib, 1);

    /* Initialization */
    rb_define_module_function(mGLFWNative, "init", rb_glfw_init, 0);
    rb_define_module_function(mGLFWNative, "terminate", rb_glfw_terminate, 0);

    /* Window */
    rb_define_module_function(mGLFWNative, "create_window", rb_glfw_create_window, 5);
    rb_define_module_function(mGLFWNative, "destroy_window", rb_glfw_destroy_window, 1);
    rb_define_module_function(mGLFWNative, "window_hint", rb_glfw_window_hint, 2);
    rb_define_module_function(mGLFWNative, "set_window_attrib", rb_glfw_set_window_attrib, 3);
    rb_define_module_function(mGLFWNative, "set_window_title", rb_glfw_set_window_title, 2);
    rb_define_module_function(mGLFWNative, "set_window_monitor", rb_glfw_set_window_monitor, 7);
    rb_define_module_function(mGLFWNative, "window_should_close", rb_glfw_window_should_close, 1);
    rb_define_module_function(mGLFWNative, "set_window_should_close", rb_glfw_set_window_should_close, 2);
    rb_define_module_function(mGLFWNative, "focus_window", rb_glfw_focus_window, 1);
    rb_define_module_function(mGLFWNative, "make_context_current", rb_glfw_make_context_current, 1);
    rb_define_module_function(mGLFWNative, "get_framebuffer_size", rb_glfw_get_framebuffer_size, 3);

    /* Events */
    rb_define_module_function(mGLFWNative, "poll_events", rb_glfw_poll_events, 0);
    rb_define_module_function(mGLFWNative, "swap_buffers", rb_glfw_swap_buffers, 1);
    rb_define_module_function(mGLFWNative, "swap_interval", rb_glfw_swap_interval, 1);

    /* Callbacks */
    rb_define_module_function(mGLFWNative, "set_key_callback", rb_glfw_set_key_callback, 2);
    rb_define_module_function(mGLFWNative, "set_cursor_pos_callback", rb_glfw_set_cursor_pos_callback, 2);
    rb_define_module_function(mGLFWNative, "set_mouse_button_callback", rb_glfw_set_mouse_button_callback, 2);

    /* Monitor */
    rb_define_module_function(mGLFWNative, "get_primary_monitor", rb_glfw_get_primary_monitor, 0);
    rb_define_module_function(mGLFWNative, "get_video_mode", rb_glfw_get_video_mode, 1);
    rb_define_module_function(mGLFWNative, "get_video_modes", rb_glfw_get_video_modes, 2);

    /* Input */
    rb_define_module_function(mGLFWNative, "set_input_mode", rb_glfw_set_input_mode, 3);
    rb_define_module_function(mGLFWNative, "get_input_mode", rb_glfw_get_input_mode, 2);
}
