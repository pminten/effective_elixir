effective_elixir
================

A work-in-progress document about how to use the Elixir language effectively

Building
--------

The build script requires access to the beam files from ex_doc. If your ex_doc
checkout is in ../ex_doc this will build effective_elixir.html:

    elixir -pa ../ex_doc/ebin/ ./build.exs
