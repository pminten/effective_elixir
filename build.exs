#!/usr/bin/env elixir
defmodule Build do
  @doc """
  Create the document.
  """
  # Chapter names (files without .md) in the order in which they should appear
  # in the docs.
  @chapters [
    "control_structures"
  ]

  def run() do
    # Needs ex_doc ebin dir in the path.
    File.write!("effective_elixir.html", Markdown.to_html(read_sources!()))
  end

  defp read_sources!() do
    Enum.map_join(@chapters, "\n", &File.read!(Path.join("sources", &1 <> ".md")))
  end
end

Build.run
