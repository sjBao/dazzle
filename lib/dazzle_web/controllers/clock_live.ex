defmodule DazzleWeb.ClockLive do
  use DazzleWeb, :live_view

  @impl true
  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="flex justify-center">
      <.clock current_time={@current_time} />
    </div>
    """
  end

  @impl true
  def mount(_, _, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok, assign(socket, current_time: :calendar.universal_time())}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, assign(socket, current_time: :calendar.universal_time())}
  end

  defp clock(assigns) do
    assigns = assign(assigns, hour: get_hour(assigns))

    ~H"""
    <div class="border-8 border-zinc-600 border-double rounded-full relative w-96 h-96">
      <.hour_hand hour={@hour} />
      <.minute_hand minute={get_minute(assigns)} />
      <.second_hand second={get_second(assigns)} />
      <.reference_marks />
    </div>
    """
  end

  defp get_hour(assigns) do
    {_date, time} = assigns.current_time
    {hour, _minute, _second} = time
    hour
  end

  defp get_minute(assigns) do
    {_date, time} = assigns.current_time
    {_hour, minute, _second} = time
    minute
  end

  defp get_second(assigns) do
    {_date, time} = assigns.current_time
    {_hour, _minute, second} = time
    second
  end

  defp hour_hand(assigns) do
    ~H"""
    <div
      class="absolute w-full h-full flex justify-center items-center"
      style={hour_hand_style(@hour)}
    >
      <div class="w-1/2 h-1/2 flex justify-center items-start">
        <div class="border-2 border-double border-zinc-900 h-1/2" />
      </div>
    </div>
    """
  end

  defp minute_hand(assigns) do
    ~H"""
    <div
      class="absolute w-full h-full flex justify-center items-center"
      style={minute_hand_style(@minute)}
    >
      <div class="w-3/4 h-3/4 flex justify-center items-start">
        <div class="border-2 border-double border-zinc-900 h-1/2" />
      </div>
    </div>
    """
  end

  defp second_hand(assigns) do
    ~H"""
    <div
      class="absolute w-full h-full flex justify-center items-center"
      style={second_hand_style(@second)}
    >
      <div class="w-5/6 h-5/6 flex justify-center items-start">
        <div class="border-2 border-double border-zinc-900 h-1/2" />
      </div>
    </div>
    """
  end

  defp hour_hand_style(hour) do
    """
    transform: rotate(#{hour * 30}deg);
    """
  end

  defp minute_hand_style(minute) do
    """
    transform: rotate(#{minute * 6}deg);
    """
  end

  defp second_hand_style(second) do
    """
    transform: rotate(#{second * 6}deg);
    """
  end

  defp reference_marks(assigns) do
    ~H"""
    <div class="absolute w-full h-full flex justify-center items-center">
      <div class="absolute px-2 py-1 text-xl top-0">12</div>
      <div class="absolute px-2 py-1 text-xl right-0">3</div>
      <div class="absolute px-2 py-1 text-xl bottom-0">6</div>
      <div class="absolute px-2 py-1 text-xl left-0">9</div>
    </div>
    """
  end
end
