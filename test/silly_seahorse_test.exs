defmodule SillySeahorseTest do
  use ExUnit.Case
  doctest SillySeahorse

  @max_name_length 20

  describe "adjective" do
    test "is not longer than 12 characters" do
      for adj <- SillySeahorse.Adjective.adjectives() |> Tuple.to_list() do
        assert String.length(adj) <= 12
      end
    end

    test "consists of lowercase letters, spaces and dashes" do
      for adj <- SillySeahorse.Adjective.adjectives() |> Tuple.to_list() do
        assert String.match?(adj, ~r/^[a-z \-]+$/)
      end
    end
  end

  describe "noun" do
    test "is not longer than 8 characters" do
      for noun <- SillySeahorse.Noun.nouns() |> Tuple.to_list() do
        assert String.length(noun) <= 8
      end
    end

    test "consists of lowercase letters, spaces and dashes" do
      for noun <- SillySeahorse.Noun.nouns() |> Tuple.to_list() do
        assert String.match?(noun, ~r/^[a-z \-]+$/)
      end
    end
  end

  describe "adverb" do
    test "consists of lowercase letters, spaces and dashes" do
      for adv <- SillySeahorse.Adverb.adverbs() |> Tuple.to_list() do
        assert String.match?(adv, ~r/^[a-z \-]+$/)
      end
    end
  end

  describe "generate_random/0" do
    test "returns usernames with max length of 20" do
      for _ <- 1..400 do
        assert String.length(SillySeahorse.generate_random()) <= @max_name_length
      end
    end

    test "returns snake case" do
      for _ <- 1..400 do
        assert String.match?(SillySeahorse.generate_random(), ~r/^[a-z]+(_[a-z]+)*$/)
      end
    end
  end

  describe "generate_random/1" do
    test "optionally returns usernames longer than 20 characters" do
      assert Enum.any?(1..400, fn _ ->
               SillySeahorse.generate_random(max_length: 30)
               |> String.length()
               |> Kernel.>(20)
             end)
    end

    test "optionally returns usernames with a delimiter other than _" do
      assert SillySeahorse.generate_random(delimiter: "-")
             |> String.match?(~r/^[a-z]+(-[a-z]+)*$/)

      assert SillySeahorse.generate_random(delimiter: ".")
             |> String.match?(~r/^[a-z]+(\.[a-z]+)*$/)

      assert SillySeahorse.generate_random(delimiter: "") |> String.match?(~r/^[a-z]+[a-z]+$/)
    end
  end
end
