defmodule Brain.Markov.Digram do
  def new do
    HashDict.new
  end

  def parse(dictionary, source) when is_binary(source) do
    parse(dictionary, String.split(source))
  end

  def parse(dictionary, [word1, word2, word3|rest]) do
    dictionary
    |> insert_unigram(word1, word2)
    |> insert_digram([word1, word2], word3)
    |> parse([word2, word3|rest])
  end

  def parse(dictionary, [word1, word2]) do
    dictionary
    |> insert_unigram(word1, word2)
    |> insert_digram([word1, word2], :stop)
    |> parse([word2])
  end

  def parse(dictionary, [single]) do
    dictionary
    |> insert_unigram(single, :stop)
  end

  def insert_unigram(dictionary, first_word, next_word) when is_binary(first_word) do
    value = Dict.get(dictionary, first_word, [])
    Dict.put(dictionary, first_word, [next_word|value])
  end

  def insert_digram(dictionary, digram, next_word) do
    combination = digram |> Enum.join(" ")
    value = Dict.get(dictionary, combination, [])
    Dict.put(dictionary, combination, [next_word|value])
  end

  def next(dictionary, [word1, word2]) do
    combination = [word1, word2] |> Enum.join(" ")
    next(dictionary, combination)
  end

  def next(dictionary, word) when is_binary(word) do
    Dict.get(dictionary, word)
  end

  def get_word(dictionary, start_word) do
    case next(dictionary, start_word) do
      nil -> nil
      list -> list |> Enum.shuffle |> hd
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
      [word1, word2] -> generate_words(dictionary, num_words - 2, [word2, word1])
      [single]       -> generate_words(dictionary, num_words - 1, [single])
      _              -> generate_words(dictionary, 0, [:stop])
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

  def generate_words(dictionary, num_words, generated_words = [word2, word1|_rest]) do
    new_word = get_word(dictionary, [word1, word2])
    generate_words(dictionary, num_words - 1, [new_word|generated_words])
  end

end
