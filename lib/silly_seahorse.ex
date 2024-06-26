defmodule SillySeahorse do
  @moduledoc """
  This library will generate random usernames like "silly_seahorse" or "anxious-turtle".

  Usernames consist of an adjective and a name of an animal. Optionally, usernames can be prefixed with an adverb: e.g., "very_silly_seahorse".

  By default, there is a 50 percent chance that an adverb will be prepended to the username. This option can be disabled by passing `allow_adverb: false` to `generate_random/1`. It is currently not possible to customize the probability of an adverb being prepended.

  The words that form the username are joined by the delimiter `-`, and the maximum length of the generated usernames is 20 characters. Both can be changed by passing `:delimiter` or `:max_length` option to `generate_random/1`.

  ## Notes
  - The smallest possible value for `:max_length` is 20. If you pass a smaller value, it will be ignored.
  - Custom delimiters must be a single character grapheme. Data types other than `string` are not allowed. For example, `generate_random(delimiter: "ö")` will work, but `generate_random(delimiter: 9)` will not.
  """

  @type opts :: [
          {:delimiter, String.t()},
          {:allow_adverb, boolean()},
          {:max_length, non_neg_integer()}
        ]

  @max_length 20
  @default_delimiter "-"
  @adjectives SillySeahorse.Adjective.adjectives()
  @adjective_count tuple_size(@adjectives)
  @nouns SillySeahorse.Noun.nouns()
  @noun_count tuple_size(@nouns)
  @adverbs SillySeahorse.Adverb.adverbs()

  @doc """
  Generates a random username.

  ## Examples

      SillySeahorse.generate_random()
      => "silly-seahorse"

  ## Options

    * :delimiter - The character to use between word. Must be consisting of one grapheme. Defaults to "-".
    * :allow_adverb - If true, it will prepend an adjective to the name. If it can't because of the max name length, it returns the originally generated username. Also, even if there are enough characters left, there is a 50 percent chance that an adverb will not be prepended. Defaults to `true`.
    * :max_length - The max length of the generated name. Values lower than 20 are ignored. Defaults to `20`.

  ### Examples

      SillySeahorse.generate_random(delimiter: "_")
      => "very_anxious_turtle"

      SillySeahorse.generate_random(allow_adverb: false)
      => "anxious-turtle"

      SillySeahorse.generate_random(max_length: 30)
      => "extremely-worried-hippopotamus"

  """
  @doc since: "0.1.0"
  @spec generate_random(opts) :: String.t()
  def generate_random(opts \\ [])

  def generate_random(opts) do
    [random_adjective(), random_noun()]
    |> maybe_prepend_adverb(opts)
    |> join_with_delimiter(opts)
  end

  # Note: random_adjective/1 and random_noun/1
  # Using elem/2 over Enum.random/1 for performance reasons
  # https://elixirforum.com/t/why-is-my-random-number-lookup-slow-using-lists/27970/10
  defp random_adjective() do
    elem(@adjectives, :rand.uniform(@adjective_count) - 1)
  end

  defp random_noun() do
    elem(@nouns, :rand.uniform(@noun_count) - 1)
  end

  defp maybe_prepend_adverb(username_as_list, opts) do
    if allow_adverb?(opts) and Enum.random([true, false]) do
      try_prepend_adverb(
        username_as_list,
        calc_n_remaining_chars(username_as_list, opts)
      )
    else
      username_as_list
    end
  end

  defp allow_adverb?(opts) do
    Keyword.get(opts, :allow_adverb, true)
  end

  defp calc_n_remaining_chars(username_as_list, opts) do
    # Substract 1 to account for delimiter between adjective and noun
    get_max_length(opts) - string_length_of(username_as_list) - 1
  end

  defp get_max_length(opts) do
    opts
    |> Keyword.get(:max_length, @max_length)
    |> max(@max_length)
  end

  defp string_length_of(list) do
    list
    |> Enum.join()
    |> String.length()
  end

  defp try_prepend_adverb(username_as_list, n_char_remaining) do
    # Substract 1 to account for delimiter between adverb and adjective
    case filter_adverbs_by_max_length(n_char_remaining - 1) do
      [] ->
        username_as_list

      adverbs ->
        [Enum.random(adverbs) | username_as_list]
    end
  end

  defp filter_adverbs_by_max_length(max_length) do
    @adverbs
    |> Tuple.to_list()
    |> Enum.filter(&(String.length(&1) <= max_length))
  end

  defp join_with_delimiter(username_as_list, opts) do
    delimiter = get_valid_delimiter(opts)

    username_as_list
    |> Enum.join(delimiter)
    # Nouns, adjectives and adverbs might contain empty spaces or the symbol `-`
    |> String.replace(" ", delimiter)
    |> String.replace("-", delimiter)
  end

  defp get_valid_delimiter(opts) do
    delimiter_raw = Keyword.get(opts, :delimiter)

    cond do
      valid_delimiter?(delimiter_raw) -> delimiter_raw
      true -> @default_delimiter
    end
  end

  defp valid_delimiter?(delimiter) do
    is_binary(delimiter) and String.length(delimiter) == 1
  end
end
