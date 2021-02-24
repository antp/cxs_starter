defmodule CxsStarterWeb.UrlProvider do
  @behaviour CxsStarter.UrlProvider

  alias CxsStarterWeb.Endpoint
  alias CxsStarterWeb.Router.Helpers, as: Routes

  @impl true
  def base_url() do
    CxsStarterWeb.Endpoint.url()
  end

  @impl true
  def build_email_token(token) do
    Routes.user_confirmation_url(Endpoint, :confirm, token)
  end

  @impl true
  def reset_password_url(token) do
    Routes.user_reset_password_url(Endpoint, :edit, token)
  end

  @impl true
  def update_email_url(token) do
    Routes.user_profile_url(Endpoint, :confirm_email, token)
  end
end
