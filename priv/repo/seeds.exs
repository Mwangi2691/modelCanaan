# priv/repo/seeds.exs
#
# Run with: mix run priv/repo/seeds.exs
# Safe to run more than once — everything here is upsert-style.

alias ModelCanaan.Accounts.Role
alias ModelCanaan.Accounts.Permission
alias ModelCanaan.Repo

IO.puts("Seeding permissions...")
Permission.permission_seeds()

IO.puts("Seeding roles...")

roles = [
  %{
    "name" => "Admin",
    "slug" => "admin",
    "type" => "admin",
    "description" => "Full access to the school system"
  },
  %{
    "name" => "Principal",
    "slug" => "principal",
    "type" => "principal",
    "description" => "Assigns teachers to classes, admits students, reviews reports and finances"
  },
  %{
    "name" => "Teacher",
    "slug" => "teacher",
    "type" => "teacher",
    "description" => "Manages classes, grades, and attendance"
  },
  %{
    "name" => "Parent",
    "slug" => "parent",
    "type" => "parent",
    "description" => "Views their child's progress and fees"
  },
  %{
    "name" => "Student",
    "slug" => "student",
    "type" => "student",
    "description" => "Views their own grades, attendance, and assignments"
  },
  %{
    "name" => "Guest",
    "slug" => "guest",
    "type" => "guest",
    "description" => "Limited read-only access, e.g. prospective parents"
  }
]

created_roles =
  for attrs <- roles do
    case Repo.get_by(Role, slug: attrs["slug"]) do
      nil ->
        {:ok, role} = Role.create(attrs)
        IO.puts("✓ Created role: #{role.name}")
        role

      role ->
        IO.puts("→ Role already exists: #{role.name}")
        role
    end
  end

# Give admin every permission that exists
admin_role = Enum.find(created_roles, &(&1.slug == "admin"))
all_permission_ids = Repo.all(Permission) |> Enum.map(&to_string(&1.id))

if admin_role do
  {:ok, _} = Role.update(admin_role, %{"permission_ids" => all_permission_ids})
  IO.puts(" Granted admin all permissions")
end

# Give teacher read/write on students, grades, attendance
teacher_role = Enum.find(created_roles, &(&1.slug == "teacher"))

teacher_permission_ids =
  Permission
  |> Repo.all()
  |> Enum.filter(&(&1.resource in ["students", "grades", "attendance"]))
  |> Enum.map(&to_string(&1.id))

if teacher_role do
  {:ok, _} = Role.update(teacher_role, %{"permission_ids" => teacher_permission_ids})
  IO.puts("✓ Granted teacher permissions on students/grades/attendance")
end

# Give parent read-only on grades, attendance, fees
parent_role = Enum.find(created_roles, &(&1.slug == "parent"))

parent_permission_ids =
  Permission
  |> Repo.all()
  |> Enum.filter(&(&1.action == "read" and &1.resource in ["grades", "attendance", "fees"]))
  |> Enum.map(&to_string(&1.id))

if parent_role do
  {:ok, _} = Role.update(parent_role, %{"permission_ids" => parent_permission_ids})
  IO.puts("✓ Granted parent read-only permissions on grades/attendance/fees")
end

# Give student read-only on their own grades/attendance
student_role = Enum.find(created_roles, &(&1.slug == "student"))

student_permission_ids =
  Permission
  |> Repo.all()
  |> Enum.filter(&(&1.action == "read" and &1.resource in ["grades", "attendance"]))
  |> Enum.map(&to_string(&1.id))

if student_role do
  {:ok, _} = Role.update(student_role, %{"permission_ids" => student_permission_ids})
  IO.puts("✓ Granted student read-only permissions on grades/attendance")
end

# Guest gets no permissions by default — read-only public pages are handled
# by simply not requiring a role, not by granting this role permissions.
guest_role = Enum.find(created_roles, &(&1.slug == "guest"))

if guest_role do
  IO.puts("✓ Guest role created with no permissions (intentional)")
end

IO.puts("Done.")
