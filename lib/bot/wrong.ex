defmodule Bot.Wrong do
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
    debug(_msg)
    {:noreply, state}
  end

  defp send_wrong(client, person_or_channel) do
    ExIrc.Client.msg client, :privmsg, person_or_channel, "https://pbs.twimg.com/media/B6sl-PDCUAAMFy5.jpg"
  end


  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
