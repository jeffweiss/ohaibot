defmodule Bot.Nope do
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

  def handle_info({:received, <<"nope.avi"::utf8>>, _from, channel}, client) do
    ExIrc.Client.msg client, :privmsg, channel, "https://www.youtube.com/watch?v=gvdf5n-zI14"
    {:noreply, client}
  end

  def handle_info({:received, <<"nope.jpg"::utf8>>, _from, channel}, client) do
    ExIrc.Client.msg client, :privmsg, channel, random_nope
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def random_nope do
    [
      "https://pbs.twimg.com/media/B-JwCV6CAAAJ1Rl.png",
      "http://i.imgur.com/F02COpJ.jpg",
      "https://pbs.twimg.com/media/B-Jx1cmCIAAkPrV.png"
    ]
    |> Enum.shuffle
    |> hd
  end



  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
