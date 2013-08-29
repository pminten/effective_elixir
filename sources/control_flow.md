# Control Flow

As Elixir is a functional programming language it doesn't have all the control
structures you see in a language like C or Ruby. In particular there is no
while or for loop. Instead higher order functions such as `Enum.reduce/2` or
recursive functions are used.

Language features that direct control flow can roughly be divided into two
categories: choice and repetition. In languages like C and Ruby choice
corresponds to things like `if` and repetition to `for`. In Elixir the principle
mechanism for choice is pattern matching and the one for repetition is recursive
functions.

To make things easier for the programmer Elixir has additional control flow
features (often implemented as macro's). At the end of the day however those
boil down to pattern matching and recursive functions.

## Pattern Matching

Pattern matching can be seen as a very powerful form of equality checking.
Instead of checking if value A is equal to value B pattern matching allows
looking into value A to see if it matches some specification. An example is
probably helpful here. Say you have a tuple and you want to know if the first
element is `:ok`:

    def is_ok({ :ok, _ }), do: true
    def is_ok(_),          do: false

If the argument of `is_ok` is a tuple with two values (commonly called a pair)
for which the first element is `:ok` the body of the first `is_ok` definition is
executed (causing `true` to be returned). If not, the body of the second `is_ok`
definition is executed (causing `false` to be returned). The `_` pattern is used
to indicate that any value will match.

Now say you want to know the value of the second element if the first is `:ok`
and that if the first value is not `:ok` you want things (in particular the
current process) to crash. This is actually very common as we shall see in the
section on error handling.

    { :ok, contents } = File.read(...)
    IO.puts(contents)

This will print the contents of the file if those could be read. The contents
variable is set to, or more exactly unified with, the second element of the
tuple returned by `File.read/2`.

Pattern matching in Elixir is a bit more powerful than we've seen so far. You
can for example use the same pattern matching variable in multiple spots.

    def eq_first({a, _}, {a, _}), do: true
    def eq_first(_, _),           do: false

    def eq_first_to(a, b) do
        case b do
            {^a, _} -> true
            _       -> false
        end
    end

Here in `eq_first` `true` is only returned if the first element of both pairs
matches. In `eq_first_to` `true` is only returned if the first element of `b`
matches `a`. Note the caret (`^`) before `a`, that tells Elixir that it should
unify (match) with the value of `a` instead of binding `a` to whatever is in
that spot. In `eq_first` it's not needed because the value isn't obtained from a
variable.

    def divmod(a, b), do: do_divmod(a, b, 0)

    defp do_divmod(a, b, acc) when a < b, do: { acc, a }
    defp do_divmod(a, b, acc),            do: do_divmod(a - b, b, acc + 1)

This example shows off guards (`when ...`). Guards are very useful in some
situations and can be applied in most circumstances where pattern matching is
used (you can't use it in a `=` expression). While useful guards are
unfortunately limited, you can only use some functions and some expressions.
This is a restriction from the underlying Erlang system and sometimes quite
annoying.

Very roughly the following are allowed in guards:

* Type tests: `is_atom/1`, `is_tuple/1`.
* Basic properties of values: `hd/1`, `size/1`.
* Some basic numerical operations: `abs/1`, `trunc/1`.
* A few functions related to this process: `node/1`, `self/1`.
* Most operators.

To make the guard restrictions slightly more bearable but somewhat harder to
reason about it is not uncommon in Elixir to use macros, for example to define a
list and to check if a value is a member of that list. You can't do that in
Erlang but in Elixir you can because the `in` operator works like a macro that
expands to a series of equality tests (`1 in [1,2,3]` --> 
`1 == 1 || 1 == 2 || 1 == 3`, `1 in 1..3` --> `1 >= 1 and 1 <= 3`).

The last nice feature of pattern matching is the ability to have what you could
call aliases for parts of a value. This is easier explained in code:

    def tup_and_first({ a, _ } = t), do: { t, a }

If you call `tup_and_first({ 1, 2 })` you will get `{{1, 2}, 1}` returned. You
can do this even in deeper patterns (`{{a, b} = t1, {c, d} = t2}`). It can come
in quite handy sometimes.

## Case

The most basic form of path choice (do this if, do that if) in Elixir is pattern
matching. Pattern matching can be done in several ways, such as in the head of a
function (that terminology comes from Prolog through Erlang and pretty much
means the bit with the argument list). It's also possible inside a function
though the case construct. This works just like pattern matching in the function
head.

Take for example traversing an AST in preorder, here's a head matching version:

    def traverse_ast({l, r}, f) do
      f.(l)
      traverse_ast(l, f)
      f.(r)
      traverse_ast(l, r)
    end

    def traverse_ast({_, _, cs} = t, f) do
      f.(t)
      traverse_ast(cs, f)
    end

    def traverse_ast(l, f) when is_list(l) do
      f.(l)
      Enum.each(l, &traverse_ast(&1, f))
    end

    def traverse_ast(x, f) do
      f.(x)
    end

And this version uses case:

    def traverse_ast(ast, f) do
      case ast do
        {l, r} ->
          f.(l)
          traverse_ast(l, f)
          f.(r)
          traverse_ast(l, r)
        {_, _, cs} = t ->
          f.(t)
          traverse_ast(cs, f)
        l when is_list(l) ->
          f.(l)
          Enum.each(l, &traverse_ast(&1, f))
        x ->
          f.(x)
      end
    end

There is no clear rule on where to use head matching and where to use case. Just
do whatever works best.

Do try to avoid this however:

    fn t -> 
      case t do
        {x, y} -> x + y
        nil    -> 0
      end
    end

The fn construct supports multiple heads, so you could say it has a case
construct built in:

    fn
        {x, y} -> x + y
        nil    -> 0
    end

Whenever you want to choose between different actions or values based on some
value case (or another form of pattern matching) should be the first thing on
your mind. There are other options however and if they provide clearer code
don't be afraid to use them.

In particular don't write:

    case c of
      true  -> ...
      _     -> ...
    end

Use an if expression, which more clearly conveys your intention, unless you
absolutely need absolute control over which values are considered true (if's
rule is that anything not false or nil is considered true).

## If

Elixir's version of the if-statement, the if macro, works like this:

    if some_condition do
      then_expression
    else
      else_expression
    end

The then expression is evaluated when some_condition is trueish, not `false` or
`nil`. Note that 0 is considered true, not false. To avoid any confusion always
use tests that return a proper boolean or in where all true values are obviously
true. For example if you have a value that's either a record or `nil` it's
idiomatic to say `if val do ... end` because obviously all records are true.

If the else clause isn't given `nil` is returned if the condition isn't
trueish. Don't write code that depends on this, it's confusing for your readers.
If you use the value of an if-expression always include the else clause.

The usual macro translation rules apply so the above is equivalent to:

  if some_condition, do: then_expression, else: else_expression

Written this way the if-macro can be used where you would use a ternary operator
(`?:`) in C.

Although the 'do-end' and 'do:' form of an if expression are semantically
identical only use the 'do:' form for relatively simple expressions without
side effects and always include the 'else:' option/clause.

## Cond

The cond macro is a replacement for nested if-statements of the form `if ... do
... else if ... do ... end end`:

    cond do
      condition1 -> expression1
      condition2 -> expression2
      condition3 -> expression3
      true       -> default_expression
    end

The expression belonging to the first condition that is true is returned. The
conditions are evaluated in order.

If no condition matches an exception is raised. To prevent that put a default
(or catch-all) clause at the end (`true -> default_expression`).

Although cond is powerful it's best saved for when case just don't cut
it (remember that you can use guards in the clauses of case). Case often offers
advantages because of the pattern matching and in any case is more idiomatic
than cond. Along the same lines a cond with only one non-catch-all condition
should be replaced by an if as that conveys the intention of the code much
better.

## Pipelines (|>)

The `|>` pipeline operator isn't a control structure in the proper sense but
more of a convenience. It makes writing some expressions easier. Compare:

    Enum.max(Stream.take(Stream.drop(Stream.iterate(1, &(&1 * 2)), 5), 5))

With:

    Stream.iterate(1, &(&1 * 2)) |> Stream.drop(5) |> Stream.take(5) |> Enum.max

The main thing to remember with pipelines is that they are very limited. All the
`|>` operator does is turn the left argument into the first argument of the
function call that's its right argument (`x |> f(y, z)` --> `f(x, y, z)`).

While pipelines work great for Elixir functions which are designed to be used
with them (the first argument is the collection or whatever is the "subject" of
the function) they often don't work with Erlang functions as many of those put
the "subject" last. While you could work around this with some rather ugly
looking code (left as exercise for the reader) you should just assign to normal
variables. Pipelines are great conveniences, but you shouldn't try to shoehorn
stuff into them.


