
use "ponytest"
use ".."

class PatternTest is UnitTest
  new iso create() => None
  fun name(): String => "pegasus.Pattern"
  
  fun apply(h: TestHelper) =>
    h.assert_eq[String](
      ((P("xyz") + P.set("abc")) / (P.any() + P.fin())).string(),
      "(('xyz' + [abc]) / (any + fin))",
      "Basic patterns and relations."
    )
    
    h.assert_eq[String](
      (P("x") + P("y") + P("z") + P("!")).string(),
      "('x' + ('y' + ('z' + '!')))",
      "Right-associative tree for concatenations."
    )
    
    h.assert_eq[String](
      (P("x") / P("y") / P("z") / P("!")).string(),
      "('x' / ('y' / ('z' / '!')))",
      "Right-associative tree for ordered choices."
    )
    
    h.assert_eq[String](
      ((P("x")<=1) + (P("y")>=0)).string(),
      "(('x'<=1) + ('y'>=0))",
      "Count-or-less and count-or-more patterns."
    )
    
    h.assert_eq[String](
      (not P("x") + not not P("y") + not not not P("z") + P.any()).string(),
      "(not 'x' + (pos 'y' + (not 'z' + any)))",
      "Negative and positive preicates (lookahead)."
    )
    
    h.assert_eq[String](
      P("xyz")("NAME").string(),
      "'xyz'(NAME)",
      "Named captures."
    )
    
    true
