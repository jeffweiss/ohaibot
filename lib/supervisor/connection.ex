defmodule Supervisor.Connection do
  use Supervisor

  def start_link(state \\ []) do
    Supervisor.start_link(__MODULE__, state)
  end

  def init(_state) do
    client = OhaiBot.ExIrc.Client

    children = [
      worker(ExIrc.Client, [[debug: true], [name: client]]),
      worker(ConnectionHandler, [client, read_connection_config]),
      worker(LoginHandler, [client, read_channel_list]),
      worker(Supervisor.Bot, [client])
      ]
    supervise(children, strategy: :one_for_all)
  end

  defp read_connection_config(filename \\ "ohaibot.conf") do
    if File.exists?(filename) do
      {:ok, config} = :file.consult(filename)
      as_map = for conf_item <- config, into: Map.new, do: conf_item
      Map.merge(%ConnectionHandler.State{}, as_map)
    else
      %ConnectionHandler.State{}
    end
  end

  defp read_channel_list(filename \\ "channels.conf") do
    if File.exists?(filename) do
      {:ok, channels} = :file.consult(filename)
      channels
    else
      []
    end
  end

end
