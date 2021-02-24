defmodule CxsStarterWeb.Router do
  use CxsStarterWeb, :router

  import CxsStarterWeb.UserAuth
  import CxsStarterWeb.Redirect

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {CxsStarterWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", CxsStarterWeb do
    pipe_through(:browser)

    live("/", PageLive, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", CxsStarterWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: CxsStarterWeb.Telemetry)
    end
  end

  redirect("/users/settings", "/users/settings/profile", :permanent)

  ## Authentication routes

  scope "/", CxsStarterWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/users/register", UserRegistrationController, :new)
    post("/users/register", UserRegistrationController, :create)
    get("/users/sign_in", UserSessionController, :new)
    post("/users/sign_in", UserSessionController, :create)
    get("/users/reset_password", UserResetPasswordController, :new)
    post("/users/reset_password", UserResetPasswordController, :create)
    get("/users/reset_password/:token", UserResetPasswordController, :edit)
    put("/users/reset_password/:token", UserResetPasswordController, :update)
  end

  scope "/", CxsStarterWeb do
    pipe_through([:browser, :require_authenticated_user])

    live("/users/settings/profile", UserSettings.UserProfileLive, :profile)
    live("/users/settings/profile/name/edit", UserSettings.UserProfileLive, :name_edit)
    live("/users/settings/profile/email/edit", UserSettings.UserProfileLive, :email_edit)
    live("/users/settings/profile/password/edit", UserSettings.UserProfileLive, :password_edit)

    live(
      "/users/settings/profile/confirm_email/:token",
      UserSettings.UserProfileLive,
      :confirm_email
    )

    live("/users/settings/profile/delete", UserSettings.UserProfileLive, :delete)
  end

  scope "/", CxsStarterWeb do
    pipe_through([:browser])

    delete("/users/sign_out", UserSessionController, :delete)
    get("/users/confirm", UserConfirmationController, :new)
    post("/users/confirm", UserConfirmationController, :create)
    get("/users/confirm/:token", UserConfirmationController, :confirm)
  end

  if Mix.env() == :dev do
    forward "/sent-emails", Bamboo.SentEmailViewerPlug
  end
end
