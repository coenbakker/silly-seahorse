defmodule SillySeahorse do
  @moduledoc """
    This library will generate random names like "cheery-dog" or "litte-spicy-cat".
    The names are made up of one or two adjectives and a name of an animal.

    If you need more variation, you can generate names likes "litte-spicy-cat-2047".

    It can also create consistent names if you pass in integers

    Example. This will always return `"interesting-emu"`

        user = %User{id: 341, timestamp: 1530244444}
        generate_consistent(user.id, user.timestamp)
        => "interesting-emu"
        generate_consistent(user.id, user.timestamp)
        => "interesting-emu"

    Options:
    :delimiter - The character to use between the words. Default is "_".
    :extra_adjective - If true, it will try to prepend an adjective to the name.
    If it can't because of the max name length, it returns the originally
    generated name. Default is true.
    :snake_case - If true, it will convert the name to snake case. Default is true.
    :max_name_length - The max length of the generated name. Default is 20.
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

  @default_num_possibilities @adjective_count * @noun_count

  def num_possible_names(), do: @default_num_possibilities

  @doc """
    This will create a new unique name on each call.
    By default, the number of possibilities are:
    number of adjectives(#{@adjective_count}) multiplied by the number of nouns(#{@noun_count}) = #{@adjective_count * @noun_count}

    Passing a param will add a number if more possibilities are needed.

        generate_random()
        => "cheery-pond"
        generate_random(1_000_000)
        => "spicy-snowflake-5"

  """
  @spec generate_random(integer | nil, list | []) :: String.t()

  def generate_random(num_possibilities \\ nil, opts \\ [])

  def generate_random(nil, opts) do
    adj = elem(@adjectives, :rand.uniform(@adjective_count) - 1)
    noun = elem(@nouns, :rand.uniform(@noun_count) - 1)
    delimiter = Keyword.get(opts, :delimiter, "_")
    name = adj <> delimiter <> noun

    if Keyword.get(opts, :extra_adjective, true), do: maybe_prepend_adjective(name, opts)
    if Keyword.get(opts, :snake_case, true), do: snake_case(name)
  end

  def generate_random(num_possibilities, _opts) when is_integer(num_possibilities) do
    nums = get_random_numbers_for(num_possibilities)

    case nums do
      nil -> generate_random()
      numbers -> generate_random() <> "-" <> numbers
    end
  end

  defp maybe_prepend_adjective(name, opts) do
    max_name_length = Keyword.get(opts, :max_name_length, @max_name_length)
    n_char_remaining = max_name_length - String.length(name)

    list =
      @adjectives
      |> Tuple.to_list()
      |> Enum.filter(&(String.length(&1) <= n_char_remaining - 1))

    case list do
      [] -> name
      _ -> Enum.random(list) <> "-" <> name
    end
  end

  defp snake_case(name) do
    name
    |> String.downcase()
    |> String.replace("-", "_")
    |> String.replace(" ", "_")
  end

  @doc """
    This will always return the same result if the same params are passed.\n
    This can be used for always giving the same name to a user.
    For example `generate_consistent(user.id, user.inserted_at_unix_timestamp))`

        generate_consistent(1, 2)
        => "damaged-quill"
        generate_consistent(1, 2)
        => "damaged-quill"
        generate_consistent(10, 11, 2_000_000)
        => "hidden-ghost-18"
        generate_consistent(10, 11, 2_000_000)
        => "hidden-ghost-18"
  """
  @spec generate_consistent(integer, integer, integer | nil) :: String.t()
  def generate_consistent(a, b, num_possibilities \\ nil)

  def generate_consistent(a, b, nil) when is_integer(a) and is_integer(b) do
    adj = elem(@adjectives, :erlang.phash2(a, @adjective_count))
    noun = elem(@nouns, :erlang.phash2(b, @noun_count))
    adj <> "-" <> noun
  end

  def generate_consistent(a, b, num) when is_integer(a) and is_integer(b) do
    prefix = generate_consistent(a, b, nil)
    suffix = get_consistent_numbers_for(a, b, num)
    prefix <> "-" <> suffix
  end

  @spec get_random_numbers_for(integer) :: String.t() | nil
  defp get_random_numbers_for(num_possibilities) do
    needed = numbers_needed_to_get_possibilities(num_possibilities)

    if needed > 0 do
      1..numbers_needed_to_get_possibilities(num_possibilities)
      |> Enum.map(fn _ -> :rand.uniform(10) - 1 end)
      |> Enum.join("")
    end
  end

  @spec numbers_needed_to_get_possibilities(integer) :: integer
  defp numbers_needed_to_get_possibilities(num) when num <= @default_num_possibilities, do: 0

  defp numbers_needed_to_get_possibilities(num) do
    :math.log10(num / @default_num_possibilities)
    |> Float.ceil()
    |> trunc
  end

  @spec get_consistent_numbers_for(integer, integer, integer) :: String.t()
  defp get_consistent_numbers_for(a, b, num_possibilities) do
    nums_needed = numbers_needed_to_get_possibilities(num_possibilities)
    a_binary = Integer.to_string(a, 2) |> String.pad_leading(8, "0")
    b_binary = Integer.to_string(b, 2) |> String.pad_leading(8, "0")
    binary = get_binary_string_to_create_n_numbers(a_binary <> b_binary, nums_needed)
    create_n_numbers_from_binary(binary, nums_needed)
  end

  @spec get_binary_string_to_create_n_numbers(String.t(), integer) :: String.t()
  defp get_binary_string_to_create_n_numbers(binary, num) do
    str_len = num * 5
    bin_len = binary |> String.length()
    dup_times = (str_len / bin_len) |> Float.ceil() |> trunc

    binary
    |> String.duplicate(dup_times)
  end

  @spec create_n_numbers_from_binary(String.t(), integer) :: String.t()
  defp create_n_numbers_from_binary(binary, num) do
    binary
    |> String.codepoints()
    |> Enum.chunk_every(5)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&String.to_integer(&1, 2))
    |> Enum.map(&rem(&1, 10))
    |> Enum.take(num)
    |> Enum.join()
  end
end
