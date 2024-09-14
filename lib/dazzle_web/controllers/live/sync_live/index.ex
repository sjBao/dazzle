defmodule DazzleWeb.SyncLive.Index do
  use DazzleWeb, :live_view

  def mount(%{"user" => user, "count" => count}, _session, socket) do
    # Don't use string to atom for user input in production code!
    # atoms are finite and can be exhausted by an attacker.
    user = String.to_atom(user)
    count = to_string(count)

    # Not production code! For educational purposes only
    # Pubsub is the correct tool for this application
    Process.register(self(), user)

    {:ok, assign(socket, user: user, count: count)}
  end
end
