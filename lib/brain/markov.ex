defmodule Brain.Markov do
  use GenServer

  def start_link(initial_state \\ []) do
    GenServer.start_link __MODULE__, [initial_state], name: __MODULE__
  end

  def init([_state]) do
    :random.seed(:erlang.now)
    {:ok, HashDict.new}
  end

  def parse(string) do
    GenServer.cast __MODULE__, {:parse, string}
  end

  def generate_phrase(start_word, word_count \\ 10) do
    GenServer.call __MODULE__, {:generate_phrase, start_word, word_count}
  end

  def handle_cast({:parse, string}, dictionary) do
    {:noreply, _parse(dictionary, string)}
  end

  def handle_call({:generate_phrase, start_word, word_count}, _from, dictionary) do
    phrase = generate_words(dictionary, start_word, word_count, [start_word])
    {:reply, phrase, dictionary}
  end

  defp _parse(dictionary, source) when is_binary(source) do
    _parse(dictionary, String.split(source))
  end

  defp _parse(dictionary, [word1, word2|rest]) do
    value = Dict.get(dictionary, word1, [])
    dictionary = Dict.put(dictionary, word1, [word2|value])
    _parse(dictionary, [word2|rest])
  end

  defp _parse(dictionary, [_single]) do
    dictionary
  end

  defp next(dictionary, word) do
    Dict.get(dictionary, word)
  end

  defp get_word(dictionary, start_word) do
    case next(dictionary, start_word) do
      nil -> nil
      list -> list |> Enum.shuffle |> hd
    end
  end

  defp generate_words(_dictionary, _start_word, 0, generated_words) do
    generated_words
    |> Enum.reverse
    |> Enum.join(" ")
  end

  defp generate_words(dictionary, start_word, num_words, generated_words) do
    new_word = get_word(dictionary, start_word)
    generate_words(dictionary, new_word, num_words - 1, [new_word|generated_words])
  end

end
