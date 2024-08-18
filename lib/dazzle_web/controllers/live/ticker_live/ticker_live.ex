defmodule DazzleWeb.TickerLive do
  alias DazzleWeb.Live.TickerLive.FormData
  use DazzleWeb, :live_view
  @rotation_factor 10

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-3 mb-10" phx-window-keydown="keydown">
      <.arrow_link direction="decrement" />
      <span class="text-center">
        Dazzle Count: <%= @count %>
      </span>
      <.arrow_link direction="increment" />
    </div>
    <div class="grid grid-cols-2 gap-4">
      <.rotate count={@count} message="Hello there" />
      <.scroll count={@count} message="Hello there" />
    </div>
    <div class="grid" />
    <.simple_form
      :let={f}
      for={@changeset}
      id="user-form"
      phx-change="validate"
      phx-submit="save"
      as={:form}
    >
      <.input field={f[:message]} type="text" label="Message" />
      <.input field={f[:count]} type="number" label="Count" />
    </.simple_form>
    """
  end

  @impl true
  def mount(_, _, socket) do
    count = 0
    message = "Dazzle"
    changeset =
      FormData.new(message, count)
      |> FormData.change(%{})

    {:ok, assign(socket, count: count, changeset: changeset)}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, inc(socket)}
  end

  @impl true
  def handle_event("change", %{"direction" => "increment"}, socket) do
    {:noreply, inc(socket)}
  end

  @impl true
  def handle_event("change", %{"direction" => "decrement"}, socket) do
    {:noreply, dec(socket)}
  end

  @impl true
  def handle_event("keydown", %{"key" => "ArrowRight"}, socket) do
    {:noreply, inc(socket)}
  end

  @impl true
  def handle_event("keydown", %{"key" => "ArrowUp"}, socket) do
    {:noreply, inc(socket)}
  end

  @impl true
  def handle_event("keydown", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, dec(socket)}
  end

  @impl true
  def handle_event("keydown", %{"key" => "ArrowDown"}, socket) do
    {:noreply, dec(socket)}
  end

  @impl true
  def handle_event("keydown", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("validate", unsigned_params, socket) do
    DazzleWeb.Live.TickerLive.FormData.change(socket.assigns.changeset, unsigned_params)
  end

  defp inc(socket) do
    assign(socket, count: wrap(socket.assigns.count + 1))
  end

  defp dec(socket) do
    assign(socket, count: wrap(socket.assigns.count - 1))
  end

  defp wrap(count), do: rem(count, 360)

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
      class="cursor-pointer hover:border-gray-500 border rounded-md flex items-center justify-center z-50 bg-white"
      phx-click="change"
      phx-value-direction={@direction}
    >
      &#<%= unicode(@direction) %>;
    </span>
    """
  end

  defp unicode("increment"), do: 9658
  defp unicode("decrement"), do: 9664

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
      n when n <= 10 -> 1 - n / 10
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
