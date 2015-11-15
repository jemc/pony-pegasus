
use "ponytest"
use ".."
use "../interpreter"

class InterpreterTest is UnitTest
  new iso create() => None
  fun name(): String => "pegasus/interpreter.Interpreter"
  
  fun apply(h: TestHelper): TestResult =>
    test_match(h, P.any(), [
      (true, "x", 0, 1),
      (true, "y", 0, 1),
      (true, "xy", 0, 1),
      (false, "", 0, 0)
    ])
    
    test_match(h, P("xyz"), [
      (true, "xyz", 0, 3),
      (true, "xyzxyz", 0, 3),
      (false, "zyx", 0, 0),
      (false, "abc", 0, 0)
    ])
    
    test_match(h, P.set("xyz") >= 1, [
      (true, "xyz", 0, 3),
      (true, "zyx", 0, 3),
      (false, "abc", 0, 0),
      (true, "xxxzzy", 0, 6),
      (true, "xxxazy", 0, 3),
      (false, "axxx", 0, 0)
    ])
    
    test_match(h, (P("xyz") / P("abc")) >= 2, [
      (false, "", 0, 0),
      (false, "abc", 0, 3),
      (false, "abcd", 0, 3),
      (true, "abcxyz", 0, 6),
      (true, "abcxyz?!", 0, 6),
      (true, "xyzabcxyz", 0, 9),
      (true, "xyzabcxyz?!", 0, 9)
    ])
    
    test_match(h, ((P("x") + P("y") + P("z")) <= 2) + P("!"), [
      (false, "", 0, 0),
      (true, "!", 0, 1),
      (false, "xy!", 0, 2),
      (true, "xyz!", 0, 4),
      (false, "xyz", 0, 3),
      (false, "zyx!", 0, 0),
      (false, "xyzx", 0, 4),
      (true, "xyzxyz!", 0, 7),
      (false, "xyzxyzxyz!", 0, 6)
    ])
    
    true
  
  fun test_match(h: TestHelper, g: Pattern, a: Array[(Bool, String, U64, U64)]) =>
    let parse = Interpreter
    for data in a.values() do
      (let success, let subject, let start, let final) = data
      let desc = g.string()+" ~ '"+subject+"' "
      
      parse(g, subject)
      
      h.expect_eq[String](parse.subject, subject, desc+"subject")
      h.expect_eq[U64](parse.start_index, start, desc+"start_index")
      
      try
        if success then
          h.expect_true(parse.error_index is None, desc+"error_index")
          h.expect_eq[U64](parse.end_index as U64, final, desc+"end_index")
        else
          h.expect_true(parse.end_index is None, desc+"end_index")
          h.expect_eq[U64](parse.error_index as U64, final, desc+"error_index")
        end
      else
        h.expect_true(false, if success then
          desc+"expected end_index to be a U64"
        else
          desc+"expected error_index to be a U64"
        end)
      end
    end
