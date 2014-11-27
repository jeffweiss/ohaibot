defmodule Brain.Karma do
  use GenServer

  def start_link(initial_state \\ []) do
    GenServer.start_link __MODULE__, [initial_state], name: __MODULE__
  end

  def init([state]) do
    {:ok, state}
  end

  def increment(subject, amount \\ 1) do
    GenServer.call __MODULE__, {:change, subject, amount}
  end

  def decrement(subject, amount \\ -1) do
    GenServer.call __MODULE__, {:change, subject, amount}
  end

  def handle_call({:change, subject, amount}, _from, state) do
    {^subject, current_karma} = List.keyfind(state, subject, 0, {subject, 0})
    new_karma = current_karma + amount
    new_state = List.keystore(state, subject, 0, {subject, new_karma})
    {:reply, new_karma, new_state}
  end
end
