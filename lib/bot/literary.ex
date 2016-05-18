defmodule Bot.Literary do
  require Logger

  @vsn "0"
  def code_change("0", {client, lines}, _extra) do
    upcased_lines = Enum.map(lines, &String.upcase/1)
    {:ok, {client, upcased_lines}}
  end
  def code_change("1", {client, lines}, _extra) do
    downcased_lines = Enum.map(lines, &String.downcase/1)
    {:ok, {client, downcased_lines}}
  end
  def code_change("2", {client, lines}, _extra) do
    titlecased_lines = lines
                        |> Enum.map( fn (line) -> line 
                                                  |> String.split 
                                                  |> Enum.map(&String.capitalize/1) 
                                                  |> Enum.join(" ") 
                                     end)

    {:ok, {client, titlecased_lines}}
  end

  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    :global.re_register_name(:literary_bot, self)
    ExIrc.Client.add_handler client, self
    Logger.debug "Starting literary bot"
    send(self, {:read_files, 'data/literary'})
    {:ok, {client, []}}
  end

  def handle_info({:received, msg, _from, channel}, {client, lines = [next_line|rest]}) do
    Logger.debug msg
    ########
    cond do
      Regex.match?(~r/^crash$/iu, msg) ->
        raise "Ermegerd"
      true -> :ok
    end
    #######
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
      #|> Enum.map(&String.upcase/1)
    end
    {:noreply, {client, new_lines |> List.flatten}}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    Logger.debug "#{inspect _msg}"
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end

  def suspend do
    :literary_bot
    |> :global.whereis_name
    |> :sys.suspend
  end

  def resume do
    :literary_bot
    |> :global.whereis_name
    |> :sys.resume
  end

  def upgrade_from(version) do
    :literary_bot
    |> :global.whereis_name
    |> :sys.change_code(__MODULE__, version, [])
  end

  def downcase do
    suspend
    upgrade_from("1")
    Logger.debug "pretending this migration takes a little while..."
    :timer.sleep(10000)
    resume
  end

  def upcase do
    suspend
    upgrade_from("0")
    Logger.debug "pretending this migration takes a little while..."
    :timer.sleep(10000)
    resume
  end

  def titlecase do
    suspend
    upgrade_from("2")
    Logger.debug "pretending this migration takes a little while..."
    :timer.sleep(10000)
    resume
  end
end
