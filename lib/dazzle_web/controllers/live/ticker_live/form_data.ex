defmodule DazzleWeb.Live.TickerLive.FormData do
  defstruct message: "Don't worry, be happy", count: 0
  @types %{ message: :string, count: :integer}

  @spec new(binary(), number()) :: %{count: binary(), message: number()}
  def new(message, count), do: %{message: message, count: count}

  @spec change(
          map(),
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  def change(form, params) do
    { form, @types }
    |> Ecto.Changeset.cast(params, Map.keys(@types))
    |> Ecto.Changeset.validate_length(:message, min: 4, max: 12)
    |> Ecto.Changeset.validate_number(:count, greater_than: 0, less_than: 361)
    |> Map.put(:action, :validate)
  end
end
