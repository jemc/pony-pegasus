
use ".."

class val ExecutorCrumb
  var index: USize = 0
  var categ: String = ""
  var name: String = ""
  new val create(i: USize, c: String, n: String) =>
    index = i; categ = c; name = n

type ExecutorCrumbs is Stack[ExecutorCrumb] val

class Executor
  var index:       USize          = 0
  var start_index: USize          = 0
  var end_index:   (USize | None) = 0
  var error_index: (USize | None) = 0
  var subject:     String         = ""
  var crumbs:      ExecutorCrumbs = ExecutorCrumbs
  
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
  
  fun _save(): (USize, ExecutorCrumbs) =>
    (index, crumbs)
  
  fun ref _restore(saved: (USize, ExecutorCrumbs), lookahead: Bool = false) =>
    try if not lookahead and (index > (error_index as USize)) then
      error_index = index
    end end
    index  = saved._1
    crumbs = saved._2
  
  fun ref _leave_crumb(s: String, n: String) =>
    crumbs = crumbs + ExecutorCrumb(index, s, n)
  
  fun ref _execute(p: PatternAny)? =>
    if subject.size() > index then
      index = index + 1
    else
      error
    end
  
  fun ref _execute(p: PatternFinish)? =>
    if subject.size() > index then
      error
    end
  
  fun ref _execute(p: PatternString)? =>
    if subject.compare_sub(p.inner, p.inner.size(), index.isize()) is Equal then
      index = index + p.inner.size()
    else
      error
    end
  
  fun ref _execute(p: PatternCharacterSet)? =>
    try p.inner.find(subject.substring(index.isize(), index.isize() + 1))
      index = index + 1
    else
      error
    end
  
  fun ref _execute(p: PatternNegativePredicate)? =>
    let saved = _save()
    if try _execute(p.inner); true else false end then
      _restore(saved, true)
      error
    else
      _restore(saved, true)
    end
  
  fun ref _execute(p: PatternPositivePredicate)? =>
    let saved = _save()
    if try _execute(p.inner); true else false end then
      _restore(saved, true)
    else
      _restore(saved, true)
      error
    end
  
  fun ref _execute(p: PatternConcatenation)? =>
    let saved = _save()
    try
      _execute(p.first)
      _execute(p.second)
    else
      _restore(saved)
      error
    end
  
  fun ref _execute(p: PatternOrderedChoice)? =>
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
  
  fun ref _execute(p: PatternCountOrLess) =>
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
  
  fun ref _execute(p: PatternCountOrMore)? =>
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
  
  fun ref _execute(p: PatternNamedCapture)? =>
    let saved = _save()
    _leave_crumb("c_start", p.name)
    try _execute(p.inner)
      _leave_crumb("c_end", p.name)
    else
      _restore(saved)
      error
    end
    
  fun ref _execute(p: Pattern)? => error
