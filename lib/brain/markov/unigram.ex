defmodule Brain.Markov.Unigram do
  def new do
    HashDict.new
  end

  def parse(dictionary, source) when is_binary(source) do
    parse(dictionary, String.split(source))
  end

  def parse(dictionary, [word1, word2|rest]) do
    value = Dict.get(dictionary, word1, [])
    dictionary = Dict.put(dictionary, word1, [word2|value])
    parse(dictionary, [word2|rest])
  end

  def parse(dictionary, [single]) do
    value = Dict.get(dictionary, single, [])
    Dict.put(dictionary, single, [:stop|value])
  end

  def next(dictionary, word) do
    Dict.get(dictionary, word)
  end

  def get_word(dictionary, start_word) do
    case next(dictionary, start_word) do
      nil -> nil
      list -> list |> Enum.shuffle |> hd
    end
  end

  def generate_words(dictionary, start_word, _num_words, [:stop|generated_words]) do
    generate_words(dictionary, start_word, 0, generated_words)
  end

  def generate_words(_dictionary, _start_word, 0, generated_words) do
    generated_words
    |> Enum.reverse
    |> Enum.join(" ")
  end

  def generate_words(dictionary, start_word, num_words, generated_words) do
    new_word = get_word(dictionary, start_word)
    generate_words(dictionary, new_word, num_words - 1, [new_word|generated_words])
  end
end
