# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ModelCanaan.Repo.insert!(%ModelCanaan.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
{:ok, admin} = ModelCanaan.Accounts.Role.create(%{"name" => "Admin", "slug" => "admin"})
{:ok, teacher} = ModelCanaan.Accounts.Role.create(%{"name" => "Teacher", "slug" => "teacher"})
{:ok, parent} = ModelCanaan.Accounts.Role.create(%{"name" => "Parent", "slug" => "parent"})
ModelCanaan.Accounts.Permission.permission_seeds()
