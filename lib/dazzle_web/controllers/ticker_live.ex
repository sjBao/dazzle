defmodule DazzleWeb.TickerLive do
  use DazzleWeb, :live_view
  @rotation_factor 10

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-3 mb-10">
      <.arrow_link direction="increment" />
      <span class="text-center">
        Dazzle Count: <%= @count %>
      </span>
      <.arrow_link direction="decrement" />
    </div>
    <div class="grid grid-cols-2 gap-4">
      <.rotate count={@count} message="Hello there" />
      <.scroll count={@count} message="Hello there" />
    </div>
    """
  end

  @impl true
  def mount(_, _, socket) do
    {:ok, assign(socket, count: 0)}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, inc(socket)}
  end

  defp inc(socket) do
    assign(socket, count: socket.assigns.count + 1)
  end

  attr :count, :integer
  attr :message, :string

  def scroll(assigns) do
    ~H"""
    <div class="border">
      <pre>
        <h2 style="text-align: center;"><%= scrolled(@message, @count) %></h2>
      </pre>
    </div>
    """
  end

  attr :count, :integer
  attr :message, :string

  def rotate(assigns) do
    ~H"""
    <div class="border" style={style(@count)}>
      <pre>
        <h2 style="text-align: center;"><%= @message %></h2>
      </pre>
    </div>
    """
  end

  defp arrow_link(assigns) do
    ~H"""
    <span
      class="cursor-pointer hover:border-gray-500 border rounded-md flex items-center justify-center"
      phx-click="change"
      phx-value-direction={@direction}
    >
      <%= unicode(@direction) %>
    </span>
    """
  end

  defp unicode("increment"), do: "🔼"
  defp unicode("decrement"), do: "🔽"

  defp scrolled(string, count) do
    len = String.length(string)
    count = rem(count, len * 2)
    spaces = String.duplicate(" ", len)
    message = spaces <> string <> spaces

    String.slice(message, count, len)
  end

  defp opacity(count) do
    case rem(count, 20) do
      0 -> 1.0
      n when n <= 10 -> 1 - n /10
      n -> (n - 10) / 10
    end
  end

  defp text_color(count) do
    count
    |> opacity()
    |> Kernel.*(255)
    |> round()
  end

  defp text_color_string(count) do
    "rgba(#{text_color(count)}, #{text_color(count)}, #{text_color(count)}, 1.0)"
  end

  defp style(count) do
    """
    background-color: rgba(0, 0, 0, #{opacity(count)});
    color: #{text_color_string(count)};
    transform: rotate(#{count * @rotation_factor}deg);
    transition-duration: 250ms;
    transition-timing-function: linear;
    """
  end
end
