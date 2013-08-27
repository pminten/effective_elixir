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
`nil`. If the else clause isn't given `nil` is returned if the condition isn't
trueish.

The usual macro translation rules apply so the above is equivalent to:

  if some_condition, do: then_expression, else: else_expression

Written this way the if-macro can be used where you would use a ternary operator
(`?:`) in C.

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




