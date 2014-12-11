defmodule Bot.Markov do
  @moduledoc """
  This is an example event handler that greets users when they join a channel
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    :random.seed(:erlang.now)
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:received, <<"markov "::utf8, start_word::bitstring>>, _from, channel}, client) do
    debug("markov bot producing phrase that starts with " <> start_word)
    phrase = Brain.Markov.generate_phrase(start_word, 10 + :random.uniform(10))
    ExIrc.Client.msg client, :privmsg, channel, phrase
    {:noreply, client}
  end

  def handle_info({:received, message, _from, _channel}, client) do
    debug("markbov bot parsing " <> message)
    Brain.Markov.parse(message)
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
