defmodule Bot.Wrong do
  @moduledoc """
  This is an example event handler that greets users when they join a channel
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    :random.seed(:os.timestamp)
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:received, msg, "brittbot", channel}, client) do
    captures = Regex.named_captures(~r/(?<person>.*): (Incorrect answer|Wrong)./, msg)
    case captures do
      nil -> nil
      _ -> if :random.uniform(10) == 1, do: send_wrong(client, channel, captures["person"])
    end
    {:noreply, client}
  end

  def handle_info({:received, <<"wrong"::utf8, _::bitstring>>, _from, channel}, client) do
    send_wrong(client, channel)
    {:noreply, client}
  end

  def handle_info({:received, <<"wrong"::utf8, _::bitstring>>, from}, client) do
    send_wrong(client, from)
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp send_wrong(client, channel, person \\ nil) do
    message_prefix = case person do
      nil -> ""
      _ -> "#{person}: "
    end
    message = message_prefix <> "https://pbs.twimg.com/media/B6sl-PDCUAAMFy5.jpg"

    ExIrc.Client.msg client, :privmsg, channel, message
  end


  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
