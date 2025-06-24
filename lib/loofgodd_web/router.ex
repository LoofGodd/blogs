defmodule LoofgoddWeb.Router do
  use LoofgoddWeb, :router

  import LoofgoddWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LoofgoddWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LoofgoddWeb do
    pipe_through :browser

    live_session :defual,
      on_mount: [
        {LoofgoddWeb.Util, :save_request_uri},
        {LoofgoddWeb.UserAuth, :mount_current_user}
      ] do
      live "/", HomeLive.Index, :index
      live "/about", HomeLive.Index, :index
      live "/blog", HomeLive.Index, :index
      live "/projects", HomeLive.Index, :index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", LoofgoddWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:loofgodd, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard("/dashboard", metrics: LoofgoddWeb.Telemetry)

      forward "/mailbox", Pljug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes
  scope "/", LoofgoddWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [
        {LoofgoddWeb.UserAuth, :redirect_if_user_is_authenticated},
        {LoofgoddWeb.Util, :save_request_uri}
      ] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LoofgoddWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{LoofgoddWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", LoofgoddWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{LoofgoddWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
