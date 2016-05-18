defmodule NodeExec do
  require Logger

  def say_intro do
    :os.cmd('osascript -e "set volume 6"')
    :os.cmd('say Wow, `whoami`. You should not be so trusting.')
  end

  def send_message(recipient) do
    pid = :literary_bot |> :global.whereis_name
    if is_pid(pid) do
      Kernel.send pid, {:received, "not a real literary message", self, recipient}
      :timer.sleep(4_750)

      send_message(recipient)
    else
      Logger.warn "Could not find literary_bot process. Found #{inspect pid}"
    end
  end

  def join_log_message do
    Logger.info "[" <> node_name <> "] Botnet joined."
  end

  def node_name do
    Node.self |> to_string
  end

  def whois_spammer do
    my_pid = self
    case :global.whereis_name(:spammer) do
      :undefined -> 
        Logger.debug "[" <> node_name <> "] No one is spamming."
        :me
      ^my_pid -> 
        Logger.debug "[" <> node_name <> "] I'm already elected as spammer."
        :me
      pid -> 
        Logger.debug "[" <> node_name <> "] Someone at #{inspect pid} is already spamming."
        :someone_else
    end
  end

  def volunteer(recipient) do
    if :me == whois_spammer do
        :global.re_register_name(:spammer, self)
        Logger.info "[" <> node_name <> "] No other spammer. I will do it."
        send_message(recipient)
    else
        Logger.info "[" <> node_name <> "] Someone else is currently spamming."
    end
  end 

end
