defmodule Supervisor.Brain do
  use Supervisor

  def start_link(state \\ []) do
    {:ok, pid} = Supervisor.start_link(__MODULE__, state)
  end

  def init(_state) do
    children = [
      worker(Brain.Karma, []),
      worker(Brain.Markov, ["data/markov"])
    ]
    supervise children, strategy: :one_for_one
  end

end
