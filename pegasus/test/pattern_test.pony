
use "ponytest"
use ".."

class PatternTest is UnitTest
  new iso create() => None
  fun name(): String => "pegasus.Pattern"
  
  fun apply(h: TestHelper): TestResult =>
    (P("x") + P("y")) / P("z")
    
    true
