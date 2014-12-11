defmodule Brain.Markov do
  use GenServer

  def start_link(initial_state \\ []) do
    GenServer.start_link __MODULE__, [initial_state], name: __MODULE__
  end

  def init(seed_directories) do
    :random.seed(:erlang.now)
    dictionary = HashDict.new
                 |> populate_with_files_in_directories(seed_directories)
    {:ok, dictionary}
  end

  defp populate_with_files_in_directories(dictionary, []) do
    dictionary
  end
  defp populate_with_files_in_directories(dictionary, [dir|rest]) do
    dictionary
    |> populate_with_files_in_single_directory(dir)
    |> populate_with_files_in_directories(rest)
  end

  defp populate_with_files_in_single_directory(dictionary, dir) do
    {:ok, files} = File.ls(dir)
    files = Enum.map(files, fn(f) -> Path.join(dir, f) end)
    populate_with_files(dictionary, files)
  end

  defp populate_with_files(dictionary, []) do
    dictionary
  end
  defp populate_with_files(dictionary, [file|rest]) do
    populate_with_file_contents(dictionary, file)
    |> populate_with_files(rest)
  end

  defp populate_with_file_contents(dictionary, file) do
    debug("attempting to read " <> file)
    file
    |> File.stream!
    |> Stream.map(&String.strip/1)
    |> Enum.to_list
    |> consolidate_paragraphs([])
    |> IO.inspect
    |> Enum.reduce(dictionary, fn(line, d) -> _parse(d, line) end)
  end

  defp consolidate_paragraphs([], accumulator) do
    accumulator |> Enum.reverse
  end
  defp consolidate_paragraphs([line1], accumulator) do
    consolidate_paragraphs([], [line1|accumulator])
  end
  defp consolidate_paragraphs([""|rest], accumulator) do
    consolidate_paragraphs(rest, accumulator)
  end
  defp consolidate_paragraphs([line1, ""|rest], accumulator) do
    consolidate_paragraphs(rest, [line1|accumulator])
  end
  defp consolidate_paragraphs([line1, line2|rest], accumulator) do
    consolidate_paragraphs([line1 <> " " <> line2|rest], accumulator)
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

  defp _parse(dictionary, [single]) do
    value = Dict.get(dictionary, single, [])
    Dict.put(dictionary, single, [:stop|value])
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

  defp generate_words(dictionary, start_word, _num_words, [:stop|generated_words]) do
    generate_words(dictionary, start_word, 0, generated_words)
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

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end

end
