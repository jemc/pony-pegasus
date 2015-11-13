
primitive P
  fun tag any():            Pattern => PatternAny
  fun tag str(s: String):   Pattern => PatternString(s)
  fun tag apply(s: String): Pattern => str(s)

trait val Pattern
  fun val string(): String
  fun val add(that: Pattern): Pattern => PatternConcatenation(this, that)
  fun val div(that: Pattern): Pattern => PatternOrderedChoice(this, that)

class val PatternAny is Pattern
  fun val string(): String => "any"

class val PatternString is Pattern
  let inner: String
  new iso create(s: String) => inner = s
  fun val string(): String => "'"+inner.string()+"'"

class val PatternConcatenation is Pattern
  let first: Pattern
  let second: Pattern
  new iso create(a: Pattern, b: Pattern) => first = a; second = b
  fun val string(): String => "("+first.string()+" + "+second.string()+")"

class val PatternOrderedChoice is Pattern
  let first: Pattern
  let second: Pattern
  new iso create(a: Pattern, b: Pattern) => first = a; second = b
  fun val string(): String => "("+first.string()+" / "+second.string()+")"
