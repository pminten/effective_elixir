# Control Structures

As Elixir is a functional programming language it doesn't have all the control
structures you see in a language like C or Ruby. In particular there is no
while or for loop. Instead higher order functions such as `Enum.reduce/2` are
used.

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
