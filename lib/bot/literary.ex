defmodule Bot.Literary do
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    :global.re_register_name(:literary_bot, self)
    ExIrc.Client.add_handler client, self
    send(self, {:read_files, 'data/literary'})
    {:ok, {client, []}}
  end

  def handle_info({:received, msg, _from, channel}, {client, lines = [next_line|rest]}) do
    if String.match?(msg, ~r/\bliterary\b/i) do
      ExIrc.Client.msg client, :privmsg, channel, next_line
      {:noreply, {client, rest ++ [next_line]}}
    else
      {:noreply, {client, lines}}
    end
  end

  def handle_info({:read_files, dir}, {client, lines}) do
    new_lines = for f <- File.ls!(dir), into: [] do
      dir
      |> Path.join(f)
      |> File.stream!
      |> Enum.map(&String.strip/1)
    end
    {:noreply, {client, new_lines |> List.flatten}}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
