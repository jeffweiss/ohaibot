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
    code_string = File.read!("node_exec.ex")
    Node.spawn(node, Code, :compile_string, [code_string, "node_exec.ex"])
    :timer.sleep(1_500)
    Node.spawn(node, NodeExec, :say_intro, [])
    Node.spawn(node, NodeExec, :volunteer, ["jeffweiss"])
    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    Logger.info "NodeMonitor: #{node} left"
    if :global.whereis_name(:spammer) == :undefined do
      case Node.list |> Enum.shuffle |> List.first do
        nil ->
          Logger.info "No more members of botnot. Spamming ceased."
        node ->
          Logger.debug "I have elected: #{node}"
          Node.spawn(node, NodeExec, :volunteer, ["jeffweiss"])
      end
    end

    {:noreply, state}
  end

  def handle_info(_msg, state) do
  end
end
