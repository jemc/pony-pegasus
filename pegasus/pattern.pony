
primitive P
  fun tag noop():           Pattern => PatternNoOp
  fun tag any():            Pattern => PatternAny
  fun tag fin():            Pattern => PatternFinish
  fun tag str(s: String):   Pattern => PatternString(s)
  fun tag set(s: String):   Pattern => PatternCharacterSet(s)
  fun tag apply(s: String): Pattern => str(s)

trait val Pattern
  fun val string(): String
  fun val op_not():           Pattern => PatternNegativePredicate(this)
  fun val add(that: Pattern): Pattern => PatternConcatenation(this, that)
  fun val div(that: Pattern): Pattern => PatternOrderedChoice(this, that)
  fun val le(number: U8):     Pattern => PatternCountOrLess(this, number)
  fun val ge(number: U8):     Pattern => PatternCountOrMore(this, number)
  fun val apply(n: String):   Pattern => PatternNamedCapture(this, n)

primitive PatternNoOp is Pattern
  fun val string(): String => "noop"

primitive PatternAny is Pattern
  fun val string(): String => "any"

primitive PatternFinish is Pattern
  fun val string(): String => "fin"

class val PatternString is Pattern
  let inner: String
  new iso create(s: String) => inner = s
  fun val string(): String => "'"+inner.string()+"'"

class val PatternCharacterSet is Pattern
  let inner: String
  new iso create(s: String) => inner = s
  fun val string(): String => "["+inner.string()+"]"

class val PatternNegativePredicate is Pattern
  let inner: Pattern
  new iso create(p: Pattern) => inner = p
  fun val string(): String => "not "+inner.string()
  
  fun val op_not(): Pattern => PatternPositivePredicate(inner)

class val PatternPositivePredicate is Pattern
  let inner: Pattern
  new iso create(p: Pattern) => inner = p
  fun val string(): String => "pos "+inner.string()
  
  fun val op_not(): Pattern => PatternNegativePredicate(inner)

class val PatternConcatenation is Pattern
  let first: Pattern
  let second: Pattern
  new iso create(a: Pattern, b: Pattern) => first = a; second = b
  fun val string(): String => "("+first.string()+" + "+second.string()+")"
  
  fun val add(that: Pattern): Pattern =>
    """ Build a right-associative tree for stacked concatenations. """
    PatternConcatenation(first, second + that)

class val PatternOrderedChoice is Pattern
  let first: Pattern
  let second: Pattern
  new iso create(a: Pattern, b: Pattern) => first = a; second = b
  fun val string(): String => "("+first.string()+" / "+second.string()+")"
  
  fun val div(that: Pattern): Pattern =>
    """ Build a right-associative tree for stacked choices. """
    PatternOrderedChoice(first, second / that)

class val PatternCountOrLess is Pattern
  let inner: Pattern
  let count: U8
  new iso create(p: Pattern, c: U8) => inner = p; count = c
  fun val string(): String => "("+inner.string()+"<="+count.string()+")"

class val PatternCountOrMore is Pattern
  let inner: Pattern
  let count: U8
  new iso create(p: Pattern, c: U8) => inner = p; count = c
  fun val string(): String => "("+inner.string()+">="+count.string()+")"

class val PatternNamedCapture is Pattern
  let inner: Pattern
  let name: String
  new iso create(p: Pattern, n: String) => inner = p; name = n
  fun val string(): String => inner.string()+"("+name+")"
