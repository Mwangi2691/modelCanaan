defmodule ModelCanaanWeb.Router do
  use ModelCanaanWeb, :router

  import ModelCanaanWeb.Plugs.Auth,
    only: [
      require_authenticated_user: 2,
      require_role: 2
    ]


  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ModelCanaanWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug ModelCanaanWeb.Plugs.Auth
    plug ModelCanaanWeb.Plugs.FetchCurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug :require_authenticated_user
  end

  pipeline :admin_only do
    plug :require_authenticated_user
    plug :require_role, "admin"
  end

  pipeline :teacher_only do
    plug :require_authenticated_user
    plug :require_role, "teacher"
  end

  pipeline :parent_only do
    plug :require_authenticated_user
    plug :require_role, "parent"
  end


  scope "/", ModelCanaanWeb do
    pipe_through :browser

    get "/", HomeController, :home

    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create

    get "/login", SessionController, :new
    post "/login", SessionController, :create

    delete "/logout", SessionController, :delete
  end

  scope "/admin", ModelCanaanWeb do
    pipe_through [:browser, :admin_only]

    get "/dashboard", AdminController, :dashboard

    resources "/roles", RoleController, except: [:show]
    get "/users", UserController, :index
    get "/users/:id", UserController, :show


    post "/users/:id/roles", RoleController, :assign_role
    delete "/users/:user_id/roles/:role_id", RoleController, :revoke_role
  end



  scope "/teacher", ModelCanaanWeb do
    pipe_through [:browser, :teacher_only]

    get "/dashboard", TeacherController, :dashboard
  end


  scope "/parent", ModelCanaanWeb do
    pipe_through [:browser, :parent_only]

    get "/dashboard", ParentController, :dashboard
  end


  if Application.compile_env(:model_canaan, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard",
        metrics: ModelCanaanWeb.Telemetry

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
