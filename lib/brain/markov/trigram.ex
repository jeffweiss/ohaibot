defmodule Brain.Markov.Trigram do
  def new do
    HashDict.new
  end

  def parse(dictionary, source) when is_binary(source) do
    parse(dictionary, String.split(source))
  end

  def parse(dictionary, [word1, word2, word3, word4|rest]) do
    dictionary
    #|> insert_ngram([word1], word2)
    |> insert_ngram([word1, word2], word3)
    |> insert_ngram([word1, word2, word3], word4)
    |> parse([word2, word3, word4|rest])
  end

  def parse(dictionary, [word1, word2, word3]) do
    dictionary
    #|> insert_ngram([word1], word2)
    |> insert_ngram([word1, word2], word3)
    |> insert_ngram([word1, word2, word3], :stop)
    |> parse([word2, word3])
  end

  def parse(dictionary, [word1, word2]) do
    dictionary
    #|> insert_ngram([word1], word2)
    |> insert_ngram([word1, word2], :stop)
    |> parse([word2])
  end

  def parse(dictionary, [single]) do
    dictionary
    #|> insert_ngram([single], :stop)
  end

  def insert_ngram(dictionary, ngram, next_word) do
    combination = ngram |> Enum.join(" ")
    value = Dict.get(dictionary, combination, [])
    Dict.put(dictionary, combination, [next_word|value])
  end

  def next(dictionary, word) when is_binary(word) do
    Dict.get(dictionary, word)
  end

  def next(dictionary, ngram) do
    combination = ngram |> Enum.join(" ")
    next(dictionary, combination)
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
