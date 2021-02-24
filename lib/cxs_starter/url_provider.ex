defmodule CxsStarter.UrlProvider do
  @type token :: String.t()
  @type url :: String.t()

  @callback base_url() :: url
  @callback build_email_token(token) :: url
  @callback reset_password_url(token) :: url
  @callback update_email_url(token) :: url
end
