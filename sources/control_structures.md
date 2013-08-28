# Control Structures

As Elixir is a functional programming language it doesn't have all the control
structures you see in a language like C or Ruby. In particular there is no
while or for loop. Instead higher order functions such as `Enum.reduce/2` are
used.

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


