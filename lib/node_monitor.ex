defmodule OhaiBot.NodeMonitor do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    :global_group.monitor_nodes true
    {:ok, state}
  end

  def handle_info({:nodeup, node}, state) do
    Logger.info "NodeMonitor: #{node} joined"
    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    Logger.info "NodeMonitor: #{node} left"
    {:noreply, state}
  end

  def handle_info(_msg, state) do
  end
end
