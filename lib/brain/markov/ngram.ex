defmodule Brain.Markov.Ngram do
  def new do
    HashDict.new
  end

  def parse(dictionary, source) when is_binary(source) do
    parse(dictionary, String.split(source))
  end

  def parse(dictionary, [word1, word2, word3, word4|rest]) do
    dictionary
    |> insert_ngram([word1], word2)
    |> insert_ngram([word1, word2], word3)
    |> insert_ngram([word1, word2, word3], word4)
    |> parse([word2, word3, word4|rest])
  end

  def parse(dictionary, [word1, word2, word3]) do
    dictionary
    |> insert_ngram([word1], word2)
    |> insert_ngram([word1, word2], word3)
    |> insert_ngram([word1, word2, word3], :stop)
    |> parse([word2, word3])
  end

  def parse(dictionary, [word1, word2]) do
    dictionary
    |> insert_ngram([word1], word2)
    |> insert_ngram([word1, word2], :stop)
    |> parse([word2])
  end

  def parse(dictionary, [single]) do
    dictionary
    |> insert_ngram([single], :stop)
  end

  def insert_ngram(dictionary, ngram, next_word) do
    combination = ngram |> Enum.join(" ")
    weighted_next_words = Dict.get(dictionary, combination, HashDict.new)
    weight_of_target = Dict.get(weighted_next_words, next_word, 0)
    weighted_next_words = Dict.put(weighted_next_words, next_word, weight_of_target + 1)
    Dict.put(dictionary, combination, weighted_next_words)
  end

  def next(dictionary, word) when is_binary(word) do
    Dict.get(dictionary, word)
  end

  def next(dictionary, ngram) do
    combination = ngram |> Enum.join(" ")
    next(dictionary, combination)
  end

  def expand_weighted_targets(weighted_targets) do
    weighted_targets
    |> Enum.to_list
    |> expand([])
  end

  def expand([], accumulator) do
    accumulator
  end
  def expand([{word, 0}|rest], accumulator) do
    expand(rest, accumulator)
  end
  def expand([{word, count}|rest], accumulator) do
    expand([{word, count-1}|rest], [word|accumulator])
  end

  def get_word(dictionary, start_word) do
    case next(dictionary, start_word) do
      nil -> nil
      list -> list |> expand_weighted_targets |> Enum.shuffle |> hd
    end
  end

  defp random_starting_phrase(dictionary) do
    dictionary
    |> Dict.keys
    |> Enum.shuffle
    |> hd
    |> String.split
  end

  def generate_words(dictionary, num_words) when is_integer(num_words) do
    case random_starting_phrase(dictionary) do
      [word1, word2, word3] -> generate_words(dictionary, num_words - 3, [word3, word2, word1])
      [word1, word2]        -> generate_words(dictionary, num_words - 2, [word2, word1])
      [single]              -> generate_words(dictionary, num_words - 1, [single])
      _                     -> generate_words(dictionary, 0, [:stop])
    end
  end

  def generate_words(dictionary, _num_words, [:stop|rest]) do
    generate_words(dictionary, 0, rest)
  end

  def generate_words(dictionary, 0, generated_words) do
    generated_words
    |> Enum.reverse
    |> Enum.join(" ")
  end

  def generate_words(dictionary, num_words, [single]) do
    new_word = get_word(dictionary, single)
    generate_words(dictionary, num_words - 1, [new_word, single])
  end

  def generate_words(dictionary, num_words, generated_words = [word2, word1]) do
    new_word = get_word(dictionary, [word1, word2])
    generate_words(dictionary, num_words - 1, [new_word|generated_words])
  end

  def generate_words(dictionary, num_words, generated_words = [word3, word2, word1|_rest]) do
    new_word = get_word(dictionary, [word1, word2, word3])
    generate_words(dictionary, num_words - 1, [new_word|generated_words])
  end

end
