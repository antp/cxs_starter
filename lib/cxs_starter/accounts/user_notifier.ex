defmodule CxsStarter.Accounts.UserNotifier do
  # For simplicity, this module simply logs messages to the terminal.
  # You should replace it by a proper email or notification tool, such as:
  #
  #   * Swoosh - https://hexdocs.pm/swoosh
  #   * Bamboo - https://hexdocs.pm/bamboo
  #

  use Bamboo.EEx

  @support_email "support@cxs_starter"

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url, base_url) do
    new_email()
    |> to(user.email)
    |> from(@support_email)
    |> subject("Confirm your email on Cxs Starter")
    |> render_to_html(
      "confirmation.html.eex",
      %{
        assigns: [
          name: user.name,
          confirm_url: url,
          support_email: @support_email,
          base_url: base_url
        ]
      },
      CxsStarter.Mailer.get_opts()
    )
    |> render_to_text(
      "confirmation.text.eex",
      %{
        assigns: [
          name: user.name,
          confirm_url: url,
          support_email: @support_email,
          base_url: base_url
        ]
      },
      CxsStarter.Mailer.get_opts()
    )
    |> CxsStarter.Mailer.deliver_now!()
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url, base_url) do
    new_email()
    |> to(user.email)
    |> from(@support_email)
    |> subject("Password reset on Cxs Starter")
    |> render_to_html(
      "password-recovery.html.eex",
      %{
        assigns: [
          name: user.name,
          confirm_url: url,
          support_email: @support_email,
          base_url: base_url
        ]
      },
      CxsStarter.Mailer.get_opts()
    )
    |> render_to_text(
      "password-recovery.text.eex",
      %{
        assigns: [
          name: user.name,
          confirm_url: url,
          support_email: @support_email,
          base_url: base_url
        ]
      },
      CxsStarter.Mailer.get_opts()
    )
    |> CxsStarter.Mailer.deliver_now!()
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url, base_url) do
    new_email()
    |> to(user.email)
    |> from(@support_email)
    |> subject("Change email on Cxs Starter")
    |> render_to_html(
      "email-change.html.eex",
      %{
        assigns: [
          name: user.name,
          confirm_url: url,
          support_email: @support_email,
          base_url: base_url
        ]
      },
      CxsStarter.Mailer.get_opts()
    )
    |> render_to_text(
      "email-change.text.eex",
      %{
        assigns: [
          name: user.name,
          confirm_url: url,
          support_email: @support_email,
          base_url: base_url
        ]
      },
      CxsStarter.Mailer.get_opts()
    )
    |> CxsStarter.Mailer.deliver_now!()
  end
end
