defmodule Brain.Markov do
  alias Brain.Markov.Ngram
  use GenServer

  def start_link(initial_state \\ []) do
    GenServer.start_link __MODULE__, [initial_state], name: __MODULE__
  end

  def init(seed_directories) do
    :random.seed(:os.timestamp)
    dictionary = Ngram.new
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
    |> Enum.reduce(dictionary, fn(line, d) -> Ngram.parse(d, line) end)
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

  def generate_phrase(word_count \\ 20) when is_number(word_count) do
    GenServer.call __MODULE__, {:generate_phrase, word_count}
  end

  def generate_phrase(start_word, word_count) when is_binary(start_word) do
    GenServer.call __MODULE__, {:generate_phrase, start_word, word_count}
  end

  def handle_cast({:parse, string}, dictionary) do
    {:noreply, Ngram.parse(dictionary, string)}
  end

  def handle_call({:generate_phrase, word_count}, _from, dictionary) do
    phrase = Ngram.generate_words(dictionary, word_count)
    {:reply, phrase, dictionary}
  end

  def handle_call({:generate_phrase, start_word, word_count}, _from, dictionary) do
    phrase = Ngram.generate_words(dictionary, word_count, String.split(start_word) |> Enum.reverse)
    {:reply, phrase, dictionary}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end

end
