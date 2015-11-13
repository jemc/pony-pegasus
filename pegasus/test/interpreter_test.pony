
use "ponytest"
use ".."
use "../interpreter"

class InterpreterTest is UnitTest
  new iso create() => None
  fun name(): String => "pegasus/interpreter.Interpreter"
  
  fun apply(h: TestHelper): TestResult =>
    Interpreter
    
    true
