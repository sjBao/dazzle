defmodule Dazzle.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dazzle.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Dazzle.Accounts.create_user()

    user
  end
end
