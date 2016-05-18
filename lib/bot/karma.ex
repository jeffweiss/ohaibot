defmodule Bot.Karma do
  @moduledoc """
  This is an example event handler that greets users when they join a channel
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:received, message, _from, channel}, client) do
    ~r/(@(\S+[^:\s])\s|(\S+[^+:\s])|\(([^\(\)]+\W[^\(\)]+)\))(\+\+|--)(\s|$)/u
    |> Regex.scan(message)
    |> process_karma_list(channel, client)
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp process_karma_list([], _channel, _client) do
  end
  defp process_karma_list([[_expression, _match, name, word, phrase, operator, _] | rest], channel, client) do
    subject = [name, word, phrase]
      |> Enum.filter(fn(x) -> String.length(x) > 1 end)
      |> List.first
      |> String.downcase
    function = if operator == "++", do: &Brain.Karma.increment/1, else: &Brain.Karma.decrement/1
    ExIrc.Client.msg client, :notice, channel, "points for #{subject}: #{function.(subject)}"
    process_karma_list(rest, channel, client)
  end
end
