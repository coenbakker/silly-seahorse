defmodule SillySeahorse do
  @moduledoc """
    This library will generate random names like "silly_seahorse" or "anxious-turtle".
    A generated name is made up of an adjectives and a name of an animal.

    By default, there is a 50 percent chance that an adverb will be prepended to the
    name as well. This option can be disabled by passing `allow_adverb: false` to
    `generate_random/1`.

    Additionally, words are joined by the delimiter `_` and the max length of the
    generated name is 20 characters. Both of these options can be changed by passing
    `:delimiter` or `:max_length` to `generate_random/1`.

    Note that the smallest value for `:max_length` is 20. If you pass a smaller value,
    it will be ignored.

    **Options**
    :delimiter - The character to use between the words. Default is "_".
    :allow_adverb - If true, it will try to prepend an adjective to the name.
    If it can't because of the max name length, it returns the originally
    generated name. Also, even if there are enough characters left, there is
    a 50 percent chance that an adverb will not be prepended. Default is true.
    :max_length - The max length of the generated name. Default is 20.
  """
  @max_name_length 20

  @adjectives SillySeahorse.Adjective.adjectives()
  @adjective_count @adjectives |> tuple_size()
  @doc false
  def adjectives(), do: @adjectives
  @doc false
  def adjective_count(), do: @adjective_count

  @nouns SillySeahorse.Noun.nouns()
  @noun_count @nouns |> tuple_size
  @doc false
  def nouns(), do: @nouns
  @doc false
  def noun_count(), do: @noun_count

  @adverbs SillySeahorse.Adverb.adverbs()
  @doc false
  def adverbs(), do: @adverbs
  @doc false
  def adverb_count(), do: @adverbs |> tuple_size()

  @doc """
    Generates a random username.

    ## Examples

        SillySeahorse.generate_random()
        => "silly_seahorse"
        SillySeahorse.generate_random(delimiter: "-")
        => "anxious-turtle"

  """
  @spec generate_random(list | []) :: String.t()

  def generate_random(opts \\ [])

  def generate_random(opts) do
    adj = elem(@adjectives, :rand.uniform(@adjective_count) - 1)
    noun = elem(@nouns, :rand.uniform(@noun_count) - 1)
    name_as_list = [adj, noun]

    name_as_list
    |> maybe_prepend_adverb(opts)
    |> apply_delimiter(opts)
  end

  defp string_length_of(list) do
    list
    |> Enum.join()
    |> String.length()
  end

  defp maybe_prepend_adverb(name_as_list, opts) do
    allow_adverb = Keyword.get(opts, :allow_adverb, true)
    max_name_length = Keyword.get(opts, :max_length, @max_name_length) |> max(@max_name_length)

    if allow_adverb && Enum.random([true, false]) do
      n_char_remaining = max_name_length - string_length_of(name_as_list) - 1

      adverbs =
        @adverbs
        |> Tuple.to_list()
        |> Enum.filter(&(String.length(&1) <= n_char_remaining - 1))

      case adverbs do
        [] ->
          name_as_list

        _ ->
          [Enum.random(adverbs) | name_as_list]
      end
    else
      name_as_list
    end
  end

  defp apply_delimiter(name_as_list, opts) do
    delimiter = Keyword.get(opts, :delimiter, "_")

    name_as_list
    |> Enum.join(delimiter)
    |> String.replace(" ", delimiter)
    |> String.replace("-", delimiter)
  end
end
