defmodule Bot.Soon do
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

  def handle_info({:received, msg, _from, channel}, client) do
    if String.match?(msg, ~r/\bso[o]+n\b/i) do
      ExIrc.Client.msg client, :privmsg, channel, random_soon
    end
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def random_soon do
    [
      "http://i.imgur.com/TVxNL84.png",
      "http://i.imgur.com/bFb5qZt.jpg",
      "http://i.imgur.com/qX5jkRi.jpg",
      "http://i.imgur.com/Rqe94Xw.jpg",
      "http://i.imgur.com/i2leGDn.jpg",
      "http://i.imgur.com/QdnGKdY.jpg",
      "http://i.imgur.com/bkox94P.jpg",
      "http://i.imgur.com/hdG9IOk.jpg",
      "http://i.imgur.com/ne6T0UP.png",
      "http://i.imgur.com/41vZ1zP.png",
      "http://i.imgur.com/yweXMrA.jpg",
      "http://i.imgur.com/GcnzEjU.jpg",
      "http://i.imgur.com/J0PLa1k.jpg",
      "http://i.imgur.com/GHHLFqK.jpg",
      "http://i.imgur.com/o25zB5O.jpg",
      "http://i.imgur.com/6yyeCBR.jpg",
      "http://i.imgur.com/GKSdoAm.png",
      "http://i.imgur.com/3L0UQ8A.jpg",
      "http://i.imgur.com/GWSQBxx.jpg",
      "http://i.imgur.com/eCvTcTQ.jpg",
      "http://i.imgur.com/0ypfizN.jpg",
      "http://i.imgur.com/xUgmD93.jpg",
      "http://i.imgur.com/ftGheRE.jpg",
      "http://i.imgur.com/pDXRVjp.jpg",
    ]
    |> Enum.shuffle
    |> hd
  end



  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
