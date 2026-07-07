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

  pipeline :require_principal do
    plug ModelCanaanWeb.Plugs.RequireRole, "principal"
  end

  pipeline :require_teacher do
    plug ModelCanaanWeb.Plugs.RequireRole, "teacher"
  end

  scope "/teacher", ModelCanaanWeb do
    pipe_through [:browser, :require_teacher]

    get "/dashboard", TeacherController, :dashboard
    get "/students/:id", TeacherController, :show_student
    post "/students/:id/attendance", TeacherController, :mark_attendance
    get "/classes/:id/report/new", TeacherController, :new_report
    post "/classes/:id/report", TeacherController, :create_report
  end

  scope "/principal", ModelCanaanWeb do
    pipe_through [:browser, :require_principal]

    get "/dashboard", PrincipalController, :dashboard

    get "/students/new", PrincipalController, :new_student
    post "/students", PrincipalController, :create_student
    get "/students/:id/finance", PrincipalController, :student_finance

    get "/assignments/new", PrincipalController, :new_assignment
    post "/assignments", PrincipalController, :create_assignment

    get "/reports", PrincipalController, :reports
    post "/reports/:id/review", PrincipalController, :review_report
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
