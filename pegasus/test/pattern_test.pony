
use "ponytest"
use ".."

class PatternTest is UnitTest
  new iso create() => None
  fun name(): String => "pegasus.Pattern"
  
  fun apply(h: TestHelper): TestResult =>
    h.expect_eq[String](
      ((P("x") + P("yz")) / (P.set("abc") + P.any())).string(),
      "(('x' + 'yz') / ([abc] + any))",
      "Basic patterns and relations."
    )
    
    h.expect_eq[String](
      (P("x") + P("y") + P("z") + P("!")).string(),
      "('x' + ('y' + ('z' + '!')))",
      "Right-associative tree for concatenations."
    )
    
    h.expect_eq[String](
      (P("x") / P("y") / P("z") / P("!")).string(),
      "('x' / ('y' / ('z' / '!')))",
      "Right-associative tree for ordered choices."
    )
    
    h.expect_eq[String](
      ((P("x")<=1) + (P("y")>=0)).string(),
      "(('x'<=1) + ('y'>=0))",
      "Count-or-less and count-or-more patterns."
    )
    
    true
