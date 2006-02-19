# Taken from Ruby 1.8.3's test_settracefunc.rb
require 'test/unit'
require 'insurance'

class TestSetTraceFunc < Test::Unit::TestCase
  def foo; end;

  def bar
    events = []
    Insurance.set_trace_func(Proc.new { |event, file, lineno|
      events << [event, lineno]
    })
    return events
  end

  def test_event
    events = []
    Insurance.set_trace_func(Proc.new { |event, file, lineno|
      events << [event, lineno]
    })
    a = 1
    foo
    a
    b = 1 + 2
    if b == 3
      case b
      when 2
        c = "b == 2"
      when 3
        c = "b == 3"
      end
    end
    begin
      raise "error"
    rescue
    end
    eval("class Foo; end")
    Insurance.set_trace_func nil

    assert_equal(["line", 21],
                 events.shift)     # a = 1
    assert_equal(["line", 22],
                 events.shift)     # foo
    assert_equal(["call", 6],
                 events.shift)     # foo
    assert_equal(["return", 6],
                 events.shift)     # foo
    assert_equal(["line", 23],
                 events.shift)     # a
    assert_equal(["line", 24],
                 events.shift)     # b = 1 + 2
    assert_equal(["c-call", 24],
                 events.shift)     # 1 + 2
    assert_equal(["c-return", 24],
                 events.shift)     # 1 + 2
    assert_equal(["line", 25],
                 events.shift)     # if b == 3
    assert_equal(["line", 25],
                 events.shift)     # if b == 3
    assert_equal(["c-call", 25],
                 events.shift)     # b == 3
    assert_equal(["c-return", 25],
                 events.shift)     # b == 3
    assert_equal(["line", 26],
                 events.shift)     # case b
    assert_equal(["line", 27],
                 events.shift)     # when 2
    assert_equal(["c-call", 27],
                 events.shift)     # when 2
    assert_equal(["c-call", 27],
                 events.shift)     # when 2
    assert_equal(["c-return", 27],
                 events.shift)     # when 2
    assert_equal(["c-return", 27],
                 events.shift)     # when 2
    assert_equal(["line", 29],
                 events.shift)     # when 3
    assert_equal(["c-call", 29],
                 events.shift)     # when 3
    assert_equal(["c-return", 29],
                 events.shift)     # when 3
    assert_equal(["line", 30],
                 events.shift)     # c = "b == 3"
    assert_equal(["line", 33],
                 events.shift)     # begin
    assert_equal(["line", 34],
                 events.shift)     # raise "error"
    assert_equal(["c-call", 34],
                 events.shift)     # raise "error"
    assert_equal(["c-call", 34],
                 events.shift)     # raise "error"
    assert_equal(["c-call", 34],
                 events.shift)     # raise "error"
    assert_equal(["c-return", 34],
                 events.shift)     # raise "error"
    assert_equal(["c-return", 34],
                 events.shift)     # raise "error"
    assert_equal(["c-call", 34],
                 events.shift)     # raise "error"
    assert_equal(["c-return", 34],
                 events.shift)     # raise "error"
    assert_equal(["c-call", 34],
                 events.shift)     # raise "error"
    assert_equal(["c-return", 34],
                 events.shift)     # raise "error"
    assert_equal(["raise", 34],
                 events.shift)     # raise "error"
    assert_equal(["c-return", 34],
                 events.shift)     # raise "error"
    assert_equal(["line", 37],
                 events.shift)     # eval(<<EOF)
    assert_equal(["c-call", 37],
                 events.shift)     # eval(<<EOF)
    assert_equal(["line", 1],
                 events.shift)     # class Foo
    assert_equal(["c-call", 1],
                 events.shift)     # class Foo
    assert_equal(["c-return", 1],
                 events.shift)     # class Foo
    assert_equal(["class", 1],
                 events.shift)     # class Foo
    assert_equal(["end", 1],
                 events.shift)     # class Foo
    assert_equal(["c-return", 37],
                 events.shift)     # eval(<<EOF)
    assert_equal(["line", 38],
                 events.shift)     # set_trace_func nil
    assert_equal(["c-call", 38],
                 events.shift)     # set_trace_func nil
   assert_equal([], events)

    events = bar
    Insurance.set_trace_func(nil)
    assert_equal(["line", 13], events.shift)
    assert_equal(["return", 9], events.shift)
    assert_equal(["line", 133], events.shift)
    assert_equal(["c-call", 133], events.shift)
    assert_equal([], events)
  end
end
