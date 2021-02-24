defmodule CxsStarter.Mailer do
  use Bamboo.Mailer, otp_app: :cxs_starter

  def get_opts() do
    [
      path: Path.join(:code.priv_dir(:cxs_starter), "mailer")
    ]
  end
end
