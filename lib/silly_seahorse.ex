defmodule SillySeahorse do
  @moduledoc """
  This library will generate random usernames like "silly_seahorse" or "anxious-turtle".

  Usernames consist of an adjective and a name of an animal. Optionally,
  usernames can be prefixed with an adverb: e.g., "very_silly_seahorse".

  By default, there is a 50 percent chance that an adverb will be prepended to the
  username. This option can be disabled by passing `allow_adverb: false` to
  `generate_random/1`.

  Additionally, words are joined by the delimiter `_` and the max length of the
  generated usernames is 20 characters. Both of these options can be changed by passing
  `:delimiter` or `:max_length` to `generate_random/1`.

  Note that the smallest value for `:max_length` is 20. If you pass a smaller value,
  it will be ignored.
  """

  @type opts :: [
          {:delimiter, String.t()},
          {:allow_adverb, boolean()},
          {:max_length, non_neg_integer()}
        ]

  @max_length 20
  @adjectives SillySeahorse.Adjective.adjectives()
  @adjective_count tuple_size(@adjectives)
  @nouns SillySeahorse.Noun.nouns()
  @noun_count tuple_size(@nouns)
  @adverbs SillySeahorse.Adverb.adverbs()

  @doc """
  Generates a random username.

  ## Examples

      SillySeahorse.generate_random()
      => "silly_seahorse"

  ## Options

    * :delimiter - The character to use between word. Must be consisting of one
      grapheme. Default is "_".
    * :allow_adverb - If true, it will prepend an adjective to the name.
      If it can't because of the max name length, it returns the originally
      generated username. Also, even if there are enough characters left, there is
      a 50 percent chance that an adverb will not be prepended. Default is true.
    * :max_length - The max length of the generated name. Values lower than 20 are
      ignored. Default is 20.

  ### Examples

      SillySeahorse.generate_random(delimiter: "-")
      => "very-anxious-turtle"

      SillySeahorse.generate_random(allow_adverb: false)
      => "anxious-turtle"

      SillySeahorse.generate_random(max_length: 30)
      => "extremely_worried_hippopotamus"

  """
  @doc since: "0.1.0"
  @spec generate_random(opts) :: String.t()
  def generate_random(opts \\ [])

  def generate_random(opts) do
    adj = elem(@adjectives, :rand.uniform(@adjective_count) - 1)
    noun = elem(@nouns, :rand.uniform(@noun_count) - 1)

    [adj, noun]
    |> maybe_prepend_adverb(opts)
    |> apply_delimiter(opts)
  end

  defp maybe_prepend_adverb(name_as_list, opts) do
    is_allow_adverb = Keyword.get(opts, :allow_adverb, true)
    max_length = Keyword.get(opts, :max_length, @max_length) |> max(@max_length)

    if is_allow_adverb and Enum.random([true, false]) do
      # Minus 1 for delimiter between adjective and noun
      n_char_remaining = max_length - string_length_of(name_as_list) - 1
      prepend_adverb_that_fits(name_as_list, n_char_remaining)
    else
      name_as_list
    end
  end

  defp string_length_of(list) do
    list
    |> Enum.join()
    |> String.length()
  end

  defp prepend_adverb_that_fits(name_as_list, n_char_remaining) do
    # Minus 1 for delimiter between adverb and adjective
    case filter_adverbs_by_max_length(n_char_remaining - 1) do
      [] ->
        name_as_list

      adverbs ->
        [Enum.random(adverbs) | name_as_list]
    end
  end

  defp filter_adverbs_by_max_length(max_length) do
    @adverbs
    |> Tuple.to_list()
    |> Enum.filter(&(String.length(&1) <= max_length))
  end

  defp apply_delimiter(name_as_list, opts) do
    delimiter = get_delimiter(opts)

    name_as_list
    |> Enum.join(delimiter)
    |> String.replace(" ", delimiter)
    # Nouns/adjectives/adverbs might contain `"-"`
    |> String.replace("-", delimiter)
  end

  defp get_delimiter(opts) do
    delimiter_raw = Keyword.get(opts, :delimiter)

    cond do
      is_binary(delimiter_raw) and String.length(delimiter_raw) == 1 -> delimiter_raw
      true -> "_"
    end
  end
end
