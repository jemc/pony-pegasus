
primitive P
  fun tag apply(s: String): Pattern =>
    PatternString(s)

trait val Pattern
  fun val add(that: Pattern): Pattern => PatternConcatenation(this, that)
  fun val div(that: Pattern): Pattern => PatternChoice(this, that)

class val PatternString is Pattern
  let inner: String
  new iso create(s: String) => inner = s

class val PatternConcatenation is Pattern
  let left: Pattern
  let right: Pattern
  new iso create(a: Pattern, b: Pattern) => left = a; right = b

class val PatternChoice is Pattern
  let left: Pattern
  let right: Pattern
  new iso create(a: Pattern, b: Pattern) => left = a; right = b
