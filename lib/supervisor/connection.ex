defmodule Supervisor.Connection do
  use Supervisor

  def start_link(state \\ []) do
    Supervisor.start_link(__MODULE__, state)
  end

  def init(_state) do
    client = OhaiBot.ExIrc.Client

    children = [
      worker(ExIrc.Client, [[debug: true], [name: client]]),
      worker(ConnectionHandler, [client]),
      worker(LoginHandler, [client, ["#ohaibot-testing"]]),
      worker(Supervisor.Bot, [client])
      ]
    supervise(children, strategy: :one_for_all)
  end
end
