primitive _StackBottom
  fun size(): U64 => 0

class box Stack[A: Any val] is ReadSeq[A]
  """
  A FILO stack implemented as a read-only persistent singly linked list.
  """
  let _inner: (_StackBottom | Stack[A])
  let _value: (_StackBottom | A)
  
  new val create() =>
    _inner = _StackBottom
    _value = _StackBottom
  
  new box _create_on(inner: Stack[A], value: A) =>
    _inner = consume inner
    _value = consume value
  
  fun size(): U64 => 1 + _inner.size()
  
  fun apply(i: U64 = 0): A^ ? =>
    match i
    | 0 => _value as A^
    else
      (_inner as this->Stack[A])(i - 1)
    end
  
  fun is_empty(): Bool =>
    _inner isnt _StackBottom
  
  fun add(value: A): this->Stack[A]^ =>
    _create_on(this, consume value)
  
  fun top(): A^? =>
    _value as A^
  
  fun without_top(): this->Stack[A]^? =>
    _inner as this->Stack[A]
  
  fun values(): Iterator[A^]^ =>
    """
    Return an iterator on the values in the stack, starting from the top.
    """
    _StackValues[A](this)
  
  fun reversed(): Stack[A]^ =>
    var r = recover box Stack[A] end
    for v in values() do
      r = r + consume v
    end
    consume r
  
  fun array(): Array[A] val^ =>
    let s = size()
    let a = recover trn Array[A](s) end
    for v in values() do
      a.push(consume v)
    end
    consume a
  
  fun rarray(): Array[A] val^ =>
    var i: U64 = size()
    let a = recover trn Array[A](i) end
    for v in values() do i = i - 1
      try a.update(i, consume v) end
    end
    consume a

class _StackValues[A: Any val] is Iterator[A^]
  """
  Iterate over the values in a stack, starting from the top.
  """
  var _stack: Stack[A]
  
  new create(stack: Stack[A]) =>
    """
    Keep the stack to be examined.
    """
    _stack = stack
  
  fun has_next(): Bool =>
    """
    Return true if the held stack is not empty.
    """
    not _stack.is_empty()
  
  fun ref next(): A^? =>
    """
    Get the value at the top of the stack, then move to the inner stack.
    """
    (_stack = _stack.without_top()).top()
