defmodule Bot.Ohai do
  @moduledoc """
  This is an example event handler that greets users when they join a channel
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    :random.seed(:os.timestamp)
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:joined, channel}, client) do
    debug "Joined #{channel}"
    {:noreply, client}
  end

  def handle_info({:joined, channel, user}, client) do
    # ExIrc currently has a bug that doesn't remove the \r\n from the end
    # of the channel name with it sends along this kind of message
    # so we ensure any trailing or leading whitespace is explicitly removed
    channel = String.strip(channel)
    debug "#{user} joined #{channel}"
    ExIrc.Client.msg(client, :privmsg, channel, random_greeting(user))
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end

  defp available_greetings do
    [ &("ohai #{&1}"),
      &("hey there, #{&1}"),
      &("welcome to the party, #{&1}"),
      &("hey, everyone, it's #{&1}!"),
      &("whew... I'm glad you're back, #{&1}. I was lost without you."),
      &("salutations, #{&1}"),
      &("greetings, #{&1}"),
      &("#{&1}, where have you been all my uptime?"),
      &("#{&1}: hiya"),
      &("hey #{&1}"),
      &("g'day #{&1}"),
      &("#{&1}: I have been trained in the act of communication in which human beings intentionally make their presence known to each other, to show attention to, and to suggest a type of relationship or social status. My algorithm has determined the most appropriate salutation is: What up, yo?"),
      &("#{&1}, this is your automated welcome message, lovingly crafted from locally-sourced, fair-trade electrons")
    ]
  end

  defp random_greeting(user) do
    greet = available_greetings
    |> Enum.shuffle
    |> hd
    greet.(user)
  end
end
