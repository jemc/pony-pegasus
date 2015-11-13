
use "ponytest"
use ".."

class PatternTest is UnitTest
  new iso create() => None
  fun name(): String => "pegasus.Pattern"
  
  fun apply(h: TestHelper): TestResult =>
    let pattern = (P("x") + P("y")) / (P("z") + P.any())
    
    h.expect_eq[String](
      ((P("x") + P("y")) / (P("z") + P.any())).string(),
      "(('x' + 'y') / ('z' + any))"
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
    
    true
