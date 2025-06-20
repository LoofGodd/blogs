# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Loofgodd.Repo.insert!(%Loofgodd.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#

# Load every .exs under priv/repo/seeds/ so the modules get defined
Path.wildcard(Path.join(__DIR__, "seeds/*.exs"))
|> Enum.each(&Code.require_file(&1))

#  Now alias & run
alias Loofgodd.Seeds.{RolesPermissions, Users}

RolesPermissions.seed()
Users.seed()
