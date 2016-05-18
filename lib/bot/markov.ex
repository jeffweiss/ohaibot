defmodule Bot.Markov do
  @moduledoc """
  This is an example event handler that greets users when they join a channel
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client], name: __MODULE__)
  end

  def init([client]) do
    :random.seed(:os.timestamp)
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def markov(string, channel) do
    send(__MODULE__, {:received, "markov " <> string, self, channel})
  end

  def handle_info({:received, <<"markov "::utf8, start_word::bitstring>>, _from, channel}, client) do
    debug("markov bot producing phrase that starts with " <> start_word)
    phrase = Brain.Markov.generate_phrase(start_word, 12 + :random.uniform(10))
    ExIrc.Client.msg client, :privmsg, channel, phrase
    {:noreply, client}
  end

  def handle_info({:received, message, _from, _channel}, client) do
    debug("markbov bot parsing " <> message)
    Brain.Markov.parse(message)
    {:noreply, client}
  end

  def handle_info({:mentioned, _message, _from, channel}, client) do
    starting_phrase = ["I think", "I am", "I know", "I read", "you don't", "you should" ] |> Enum.shuffle |> hd
    ExIrc.Client.msg client, :privmsg, channel, Brain.Markov.generate_phrase(starting_phrase, 15 + :random.uniform(10))
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
