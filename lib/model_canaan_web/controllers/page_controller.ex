defmodule ModelCanaanWeb.HomeController do
  use ModelCanaanWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
