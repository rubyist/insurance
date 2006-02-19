#include <ruby.h>
#include <node.h>
#include <env.h>

static int tracing    = 0;
static int am_tracing = 0;

static char *
get_event_name(rb_event_t event)
{
  switch (event) {
  case RUBY_EVENT_LINE:
	  return "line";
  case RUBY_EVENT_CLASS:
	  return "class";
  case RUBY_EVENT_END:
	  return "end";
  case RUBY_EVENT_CALL:
	  return "call";
  case RUBY_EVENT_RETURN:
	  return "return";
  case RUBY_EVENT_C_CALL:
	  return "c-call";
  case RUBY_EVENT_C_RETURN:
	  return "c-return";
  case RUBY_EVENT_RAISE:
	  return "raise";
  default:
	  return "unknown";
  }
}

static VALUE cov_tracer = 0;

static void
insurance_trace_func(event, node, self, id, klass)
    rb_event_t event;
    NODE *node;
    VALUE self;
    ID id;
    VALUE klass;
{
  int state, raised;
  NODE *node_save;
  VALUE srcfile;
  struct FRAME *prev;
  static int counting = 0;

  if (tracing) return;
  if (id == ID_ALLOCATOR) return;
  tracing = 1;
  if (node) {
    ruby_current_node = node;
    ruby_frame->node = node;
    ruby_sourcefile = node->nd_file;
    ruby_sourceline = nd_line(node);
  }

  srcfile = rb_str_new2(ruby_sourcefile?ruby_sourcefile:"(ruby)");
  rb_funcall(cov_tracer, rb_intern("call"), 3, rb_str_new2(get_event_name(event)), srcfile, INT2FIX(ruby_sourceline));
  tracing = 0;
}

static VALUE
is_tracing()
{
  if (am_tracing == 0) {
    return Qfalse;
  }
  return Qtrue;
}

static VALUE
set_insurance_trace_func(obj, trace)
    VALUE obj, trace;
{
  if (NIL_P(trace)) {
	  cov_tracer = 0;
	  am_tracing = 0;
	  rb_remove_event_hook(insurance_trace_func);
	  return Qnil;
  }

  cov_tracer = trace;
  am_tracing = 1;
  rb_add_event_hook(insurance_trace_func, RUBY_EVENT_LINE);
  return trace;
}


void
Init_insurance_tracer()
{
    VALUE mProf;

    mProf = rb_define_module("Insurance");
    rb_define_module_function(mProf, "set_trace_func", set_insurance_trace_func, 1);
    rb_define_module_function(mProf, "is_tracing?", is_tracing, 0);
}
