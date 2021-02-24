defmodule CxsStarter.AccountsFactory do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CxsStarter.Accounts` context.
  """

  alias CxsStarter.Repo

  def unique_user_name, do: Faker.Person.name()
  def unique_user_email, do: Faker.Internet.email()
  def valid_user_password, do: "hello world!"

  def user_factory(attrs \\ %{}) do
    confirmed_at = Map.get(attrs, :confirmed_at, nil)

    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: unique_user_name(),
        email: unique_user_email(),
        password: valid_user_password()
      })
      |> CxsStarter.Accounts.register_user()

    user =
      if confirmed_at do
        user = Ecto.Changeset.change(user, confirmed_at: confirmed_at)

        {:ok, user} = Repo.update(user)

        user
      else
        user
      end

    user
  end

  def extract_user_token(fun) when is_function(fun) do
    captured = fun.(&"[TOKEN]#{&1}[TOKEN]")

    [_, token, _] = String.split(captured.html_body, "[TOKEN]")
    token
  end

  def extract_user_token(body) do
    [_, token, _] = String.split(body, "[TOKEN]")
    token
  end
end
