defmodule ConnectionHandler do
  defmodule State do
    defstruct host: "chat.freenode.net",
              port: 6667,
              pass: "ohaipassword",
              nick: "ohaibot",
              user: "ohaibot",
              name: "ohaibot welcomes you",
              client: nil
  end

  def start_link(client, state \\ %State{}) do
    GenServer.start_link(__MODULE__, [%{state | client: client}])
  end

  def init([state]) do
    ExIrc.Client.add_handler state.client, self
    ExIrc.Client.connect! state.client, state.host, state.port
    {:ok, state}
  end

  def handle_info({:connected, server, port}, state) do
    debug "Connected to #{server}:#{port}"
    ExIrc.Client.logon state.client, state.pass, state.nick, state.user, state.name
    {:noreply, state}
  end

  def handle_info(:disconnected, state) do
    ExIrc.Client.connect! state.client, state.host, state.port
  end

  # Catch-all for messages you don't care about
  def handle_info(msg, state) do
    #debug "Received unknown message:"
    #IO.inspect msg
    {:noreply, state}
  end

  defp client_pid(%{client: client}) when is_pid(client), do: client
  defp client_pid(%{client: client}), do: Process.whereis(client)

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
