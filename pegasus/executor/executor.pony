
use ".."

class Executor
  var index:       U64          = 0
  var start_index: U64          = 0
  var end_index:   (U64 | None) = 0
  var error_index: (U64 | None) = 0
  var subject:     String       = ""
  
  fun ref apply(grammar: Pattern, subject': String): Executor =>
    start_index = 0
    end_index   = None
    error_index = 0
    index       = start_index
    subject     = subject'
    
    try _execute(grammar)
      error_index = None
      end_index = index
    end
    
    this
  
  fun ref _execute(p': Pattern)? =>
    match p'
    | let p: PatternAny               => _execute_any()
    | let p: PatternFinish            => _execute_finish()
    | let p: PatternString            => _execute_string(p)
    | let p: PatternCharacterSet      => _execute_character_set(p)
    | let p: PatternNegativePredicate => _execute_negative_predicate(p)
    | let p: PatternPositivePredicate => _execute_positive_predicate(p)
    | let p: PatternConcatenation     => _execute_concatenation(p)
    | let p: PatternOrderedChoice     => _execute_ordered_choice(p)
    | let p: PatternCountOrLess       => _execute_count_or_less(p)
    | let p: PatternCountOrMore       => _execute_count_or_more(p)
    end
  
  fun _save(): U64 =>
    index
  
  fun ref _restore(saved: U64, lookahead: Bool = false) =>
    try if not lookahead and (index > (error_index as U64)) then
      error_index = index
    end end
    index = saved
  
  fun ref _execute_any()? =>
    if subject.size() > index then
      index = index + 1
    else
      error
    end
  
  fun ref _execute_finish()? =>
    if subject.size() > index then
      error
    end
  
  fun ref _execute_string(p: PatternString)? =>
    if subject.compare_sub(p.inner, p.inner.size(), index.i64()) is Equal then
      index = index + p.inner.size()
    else
      error
    end
  
  fun ref _execute_character_set(p: PatternCharacterSet)? =>
    try p.inner.find(subject.substring(index.i64(), index.i64()))
      index = index + 1
    else
      error
    end
  
  fun ref _execute_negative_predicate(p: PatternNegativePredicate)? =>
    let saved = _save()
    if try _execute(p.inner); true else false end then
      _restore(saved, true)
      error
    else
      _restore(saved, true)
    end
  
  fun ref _execute_positive_predicate(p: PatternPositivePredicate)? =>
    let saved = _save()
    if try _execute(p.inner); true else false end then
      _restore(saved, true)
    else
      _restore(saved, true)
      error
    end
  
  fun ref _execute_concatenation(p: PatternConcatenation)? =>
    let saved = _save()
    try
      _execute(p.first)
      _execute(p.second)
    else
      _restore(saved)
      error
    end
  
  fun ref _execute_ordered_choice(p: PatternOrderedChoice)? =>
    let saved = _save()
    try
      _execute(p.first)
    else
      try
        _execute(p.second)
      else
        _restore(saved)
        error
      end
    end
  
  fun ref _execute_count_or_less(p: PatternCountOrLess) =>
    try
      var i: U8 = 0
      while i < p.count do
        let saved = _save()
        try _execute(p.inner) else
          _restore(saved)
          error
        end
      i = i + 1 end
    end
  
  fun ref _execute_count_or_more(p: PatternCountOrMore)? =>
    let saved = _save()
    try
      var i: U8 = 0
      while i < p.count do
        _execute(p.inner)
      i = i + 1 end
    else
      _restore(saved)
      error
    end
    try
      while true do
        let saved' = _save()
        try _execute(p.inner) else
          _restore(saved')
          error
        end
      end
    end
