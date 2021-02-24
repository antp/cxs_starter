defmodule CxsStarterWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  def get_input_colour(form, field) do
    has_error = Keyword.get(form.errors, field)

    has_value = Map.get(form.params, Atom.to_string(field))

    cond do
      has_error != nil -> "red-700"
      has_error == nil and has_value not in [nil, ""] -> "green-700"
      true -> "gray-300"
    end
  end

  def get_input_icon(form, field) do
    has_error = Keyword.get(form.errors, field)

    has_value = Map.get(form.params, Atom.to_string(field))

    cond do
      has_error != nil ->
        """
        <svg class="w-5 h-5 text-red-600  xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
        </svg>
        """

      has_error == nil and has_value not in [nil, ""] ->
        """
        <svg class="w-5 h-5 text-green-700  xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
        </svg>
        """

      true ->
        ""
    end
  end

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      f1 =
        Atom.to_string(field)
        |> String.replace("_", " ")
        |> String.replace("-", " ")

      {error_text, other} = error

      error_text =
        "#{f1} #{error_text}"
        |> String.capitalize()

      error = {error_text, other}

      content_tag(:span, translate_error(error),
        class: "text-red-500",
        phx_feedback_for: input_id(form, field)
      )
    end)
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(CxsStarterWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(CxsStarterWeb.Gettext, "errors", msg, opts)
    end
  end
end
