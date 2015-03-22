defmodule Supervisor.Bot do
  use Supervisor

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state)
  end

  def init(client_name) do
    children = [
      worker(Bot.Ohai, [client_name]),
      worker(Bot.Karma, [client_name]),
      worker(Bot.Sing, [client_name]),
      worker(Bot.Markov, [client_name]),
      worker(Bot.Nope, [client_name]),
      worker(Bot.Soon, [client_name]),
      worker(Bot.Literary, [client_name]),
      worker(Bot.Wrong, [client_name])
      ]
    supervise(children, strategy: :one_for_one)
  end
end
