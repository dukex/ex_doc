defmodule ExDoc.Markdown do
  @markdown_processors [
    ExDoc.Markdown.Hoedown,
    ExDoc.Markdown.Earmark,
    ExDoc.Markdown.Pandoc
  ]

  @markdown_processor_key :markdown_processor

  @doc """
  Converts the given markdown document to HTML.
  """
  def to_html(text) when is_binary(text) do
    get_markdown_processor().to_html(text) |> pretty_codeblocks
  end

  @doc """
  Helper to handle plain code blocks (```...```) with and without
  language specification and indentation code blocks
  """
  def pretty_codeblocks(bin) do
    bin = Regex.replace(~r/<pre><code(\s+class=\"\")?>\s*iex&gt;/,
                        # Add "elixir" class for now, until we have support for
                        # "iex" in highlight.js
                        bin, "<pre><code class=\"iex elixir\">iex&gt;")
    bin = Regex.replace(~r/<pre><code(\s+class=\"\")?>/,
                        bin, "<pre><code class=\"elixir\">")

    bin
  end

  defp get_markdown_processor() do
    case Application.fetch_env(:ex_doc, @markdown_processor_key) do
      {:ok, processor} -> processor
      :error ->
        processor = find_markdown_processor || raise_no_markdown_processor
        Application.put_env(:ex_doc, @markdown_processor_key, processor)
        processor
    end
  end

  defp find_markdown_processor() do
    Enum.find @markdown_processors, fn module ->
      Code.ensure_loaded?(module) && module.available?
    end
  end

  defp raise_no_markdown_processor() do
    raise """
    Could not find a markdown processor to be used by ex_doc.
    You can either:

    * Add {:earmark, ">= 0.0.0"} to your mix.exs deps
      to use an Elixir-based markdown processor

    * Add {:markdown, github: "devinus/markdown"} to your mix.exs deps
      to use a C-based markdown processor

    * Ensure pandoc (http://johnmacfarlane.net/pandoc) is available in your system
      to use it as an external tool
    """
  end
end
