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
    <div class="grid grid-cols-1 mb-10">
    <.simple_form
      :let={f}
      for={@changeset}
      id="count-form"
      phx-change="validate"
      as={:form}
     >
      <.input
        class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"
        max="360"
        min="0"
        type="range"
        field={f[:count]}
        phx-change="change"
        phx-debounce="300"
      />
    </.simple_form>
    </div>
    <div class="grid grid-cols-2 gap-4">
      <.rotate count={@count} message={@message} />
      <.scroll count={@count} message={@message} />
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
      <.input field={f[:message]} phx-blur="message_blur" type="text" label="Message" />
      <.input field={f[:count]} type="number" label="Count" min={0} />
      <.button type="submit">Save</.button>
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

    {:ok, assign(socket, count: count, changeset: changeset, message: message)}
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
  def handle_event("change", %{"form" => form_params}, socket) do
    {:noreply, apply_slider(socket, form_params)}
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
  def handle_event("validate", %{"form" => unsigned_params}, socket) do
    validate(socket, unsigned_params)

    {:noreply, validate(socket, unsigned_params)}
  end

  @impl true
  def handle_event("save", %{"form" => params}, socket) do
    {:noreply, save(socket, params)}
  end

  @impl true
  def handle_event("message_blur", %{"value" => value}, socket) do
    {:noreply, save(socket, %{"message" => value})}
  end

  defp save(socket, params) do
    changeset =
      FormData.new(socket.assigns.message, socket.assigns.count)
      |> FormData.change(params)

    apply_changes(socket, changeset)
  end

  defp apply_changes(socket, %{changes: changes, valid?: true}) do
    assign(socket, Map.to_list(changes))
  end

  defp apply_changes(socket, %{valid?: false}) do
    socket
  end

  defp validate(socket, params) do
    changeset =
      FormData.new(socket.assigns.message, max(socket.assigns.count, 0))
      |> FormData.change(params)

    assign(socket, changeset: changeset)
  end

  defp inc(socket) do
    new_count = wrap(socket.assigns.count + 1)

    assign(socket, count: new_count)
    |> validate(%{"count" => new_count})
  end

  defp dec(socket) do
    new_count = wrap(socket.assigns.count - 1)

    assign(socket, count: new_count)
    |> validate(%{"count" => new_count})
  end

  defp wrap(count), do: 0 |> max(count) |> rem(361)

  defp apply_slider(socket, form_params) do
    new_count = form_params["count"] |> String.to_integer() |> wrap()

    socket
    |> assign(count: wrap(new_count))
    |> validate(%{"count" => wrap(new_count)})
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
