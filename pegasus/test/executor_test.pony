
use "ponytest"
use ".."
use "../executor"

class ExecutorTest is UnitTest
  new iso create() => None
  fun name(): String => "pegasus/executor.Executor"
  
  fun apply(h: TestHelper) =>
    let no_crumbs = Array[(USize, String, String)]
    
    test_match(h, P.any(), [
      (true, "x", 0, 1, no_crumbs),
      (true, "y", 0, 1, no_crumbs),
      (true, "xy", 0, 1, no_crumbs),
      (false, "", 0, 0, no_crumbs)
    ])
    
    test_match(h, P.noop() + P.any(), [
      (true, "x", 0, 1, no_crumbs),
      (true, "y", 0, 1, no_crumbs),
      (true, "xy", 0, 1, no_crumbs),
      (false, "", 0, 0, no_crumbs)
    ])
    
    test_match(h, P.fail() + P.any(), [
      (false, "x", 0, 0, no_crumbs),
      (false, "y", 0, 0, no_crumbs),
      (false, "xy", 0, 0, no_crumbs),
      (false, "", 0, 0, no_crumbs)
    ])
    
    test_match(h, P("xyz"), [
      (true, "xyz", 0, 3, no_crumbs),
      (true, "xyzxyz", 0, 3, no_crumbs),
      (false, "zyx", 0, 0, no_crumbs),
      (false, "abc", 0, 0, no_crumbs)
    ])
    
    test_match(h, P("xyz") + P.fin(), [
      (true, "xyz", 0, 3, no_crumbs),
      (false, "xyzx", 0, 3, no_crumbs)
    ])
    
    test_match(h, P.set("xyz") >= 1, [
      (true, "xyz", 0, 3, no_crumbs),
      (true, "zyx", 0, 3, no_crumbs),
      (false, "abc", 0, 0, no_crumbs),
      (true, "xxxzzy", 0, 6, no_crumbs),
      (true, "xxxazy", 0, 3, no_crumbs),
      (false, "axxx", 0, 0, no_crumbs)
    ])
    
    test_match(h, (P("xyz") / P("abc")) >= 2, [
      (false, "", 0, 0, no_crumbs),
      (false, "abc", 0, 3, no_crumbs),
      (false, "abcd", 0, 3, no_crumbs),
      (true, "abcxyz", 0, 6, no_crumbs),
      (true, "abcxyz?!", 0, 6, no_crumbs),
      (true, "xyzabcxyz", 0, 9, no_crumbs),
      (true, "xyzabcxyz?!", 0, 9, no_crumbs)
    ])
    
    test_match(h, ((P("x") + P("y") + P("z")) <= 2) + P("!"), [
      (false, "", 0, 0, no_crumbs),
      (true, "!", 0, 1, no_crumbs),
      (false, "xy!", 0, 2, no_crumbs),
      (true, "xyz!", 0, 4, no_crumbs),
      (false, "xyz", 0, 3, no_crumbs),
      (false, "zyx!", 0, 0, no_crumbs),
      (false, "xyzx", 0, 4, no_crumbs),
      (true, "xyzxyz!", 0, 7, no_crumbs),
      (false, "xyzxyzxyz!", 0, 6, no_crumbs)
    ])
    
    test_match(h, ((not P("!") + P.any()) >= 1) + P.fin(), [
      (false, "", 0, 0, no_crumbs),
      (true, "x", 0, 1, no_crumbs),
      (true, "xyz", 0, 3, no_crumbs),
      (false, "x!z", 0, 1, no_crumbs)
    ])
    
    test_match(h, ((not not P.set("xyz") + P.any()) >= 1) + P.fin(), [
      (false, "", 0, 0, no_crumbs),
      (true, "x", 0, 1, no_crumbs),
      (true, "xyz", 0, 3, no_crumbs),
      (false, "x!z", 0, 1, no_crumbs)
    ])
    
    test_match(h, (P.any() + P("xyz")("NAME") + P.any()), [
      (true, "~xyz~", 0, 5, [
        (1, "c_start", "NAME"),
        (4, "c_end",   "NAME")
      ])
    ])
    
    true
  
  fun test_match(h: TestHelper, g: Pattern,
    a: Array[(Bool, String, USize, USize, Array[(USize, String, String)])]
  ) =>
    let parse = Executor
    for data in a.values() do
      (let success, let subject, let start, let final, let crumbs) = data
      let desc = g.string()+" ~ '"+subject+"' "
      
      parse(g, subject)
      
      h.assert_eq[String](parse.subject, subject, desc+"subject")
      h.assert_eq[USize](parse.start_index, start, desc+"start_index")
      
      try
        if success then
          h.assert_true(parse.error_index is None, desc+"error_index")
          h.assert_eq[USize](parse.end_index as USize, final, desc+"end_index")
        else
          h.assert_true(parse.end_index is None, desc+"end_index")
          h.assert_eq[USize](parse.error_index as USize, final, desc+"error_index")
        end
      else
        h.assert_true(false, if success then
          desc+"expected no end_index, but error_index was "
              +try (parse.error_index as USize).string() else "?" end
        else
          desc+"expected no error_index, but end_index was "
              +try (parse.end_index as USize).string() else "?" end
        end)
      end
      
      if success then
        for expected_crumb in crumbs.values() do
          None
          for actual_crumb in parse.crumbs.rarray().values() do
            h.assert_eq[USize](actual_crumb.index, expected_crumb._1)
            h.assert_eq[String](actual_crumb.categ, expected_crumb._2)
            h.assert_eq[String](actual_crumb.name, expected_crumb._3)
          end
        end
      end
    end
