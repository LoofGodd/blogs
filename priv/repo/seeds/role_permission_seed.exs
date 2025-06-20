defmodule Loofgodd.Seeds.RolesPermissions do
  alias Loofgodd.Repo
  alias Loofgodd.Accounts.{Role, Permission, RolePermission}

  def seed do
    Repo.transaction(fn ->
      # 1) Define all roles
      roles = [
        %{name: "super_admin", description: "Unrestricted access"},
        %{name: "admin", description: "Most features, no system-critical settings"},
        %{name: "editor", description: "Manages content: posts & comments"},
        %{name: "author", description: "Creates & edits own posts"},
        %{name: "contributor", description: "Submits drafts for review"},
        %{name: "moderator", description: "Moderates comments & interactions"},
        %{name: "subscriber", description: "Registered: view & comment"},
        %{name: "guest", description: "Unauthenticated: view only"},
        # New roles:
        %{name: "seo_manager", description: "Optimizes content for search engines"},
        %{name: "support_agent", description: "Handles user support tickets"},
        %{name: "developer", description: "Manages integrations & deployments"},
        %{name: "analyst", description: "Runs reports and A/B tests"}
      ]

      # 2) Define all permissions
      permissions = [
        # Core blog permissions
        %{name: "view_posts", description: "View published posts"},
        %{name: "view_drafts", description: "View draft posts"},
        %{name: "create_post", description: "Create new posts"},
        %{name: "edit_own_posts", description: "Edit own posts"},
        %{name: "edit_all_posts", description: "Edit any post"},
        %{name: "publish_posts", description: "Publish posts"},
        %{name: "delete_own_posts", description: "Delete own posts"},
        %{name: "delete_all_posts", description: "Delete any post"},
        %{name: "create_revision", description: "Create post revisions"},
        %{name: "view_revisions", description: "View revision history"},
        %{name: "revert_revision", description: "Revert to prior revision"},
        %{name: "manage_tags", description: "CRUD tags"},
        %{name: "manage_categories", description: "CRUD categories"},
        %{name: "view_comments", description: "View comments"},
        %{name: "create_comment", description: "Post comments"},
        %{name: "moderate_comments", description: "Approve/edit/delete comments"},
        %{name: "manage_users", description: "CRUD user accounts"},
        %{name: "assign_roles", description: "Assign roles to users"},
        %{name: "view_analytics", description: "View analytics & reports"},
        %{name: "manage_settings", description: "Edit site settings"},
        # New permissions:
        %{name: "manage_seo", description: "Edit SEO settings (meta, sitemaps)"},
        %{name: "run_ab_tests", description: "Create & monitor A/B tests"},
        %{name: "export_reports", description: "Download analytics data"},
        %{name: "manage_api_tokens", description: "CRUD API tokens"},
        %{name: "view_error_logs", description: "Access application logs"},
        %{name: "manage_webhooks", description: "Configure webhooks"},
        %{name: "flag_abusive_users", description: "Flag abusive content"},
        %{name: "view_support_tickets", description: "See support tickets"},
        %{name: "respond_support_tickets", description: "Reply to support tickets"},
        %{name: "upload_media", description: "Upload to media library"},
        %{name: "delete_media", description: "Delete from media library"},
        %{name: "manage_widgets", description: "Configure UI widgets"},
        %{name: "schedule_posts", description: "Schedule future publications"}
      ]

      # 3) Upsert roles and build a name→struct map
      role_map =
        roles
        |> Enum.map(fn attrs ->
          {:ok, role} =
            %Role{}
            |> Role.changeset(attrs)
            |> Repo.insert(
              on_conflict: {:replace, [:description]},
              conflict_target: :name
            )

          {role.name, role}
        end)
        |> Map.new()

      # 4) Upsert permissions and build a name→struct map
      perm_map =
        permissions
        |> Enum.map(fn attrs ->
          {:ok, perm} =
            %Permission{}
            |> Permission.changeset(attrs)
            |> Repo.insert(
              on_conflict: :nothing,
              conflict_target: :name
            )

          {perm.name, perm}
        end)
        |> Map.new()

      # 5) Define which permissions each role should have
      role_permissions = %{
        "super_admin" => Map.keys(perm_map),
        "admin" => Map.keys(perm_map) -- ["manage_settings"],
        "editor" => [
          "view_posts",
          "view_drafts",
          "create_post",
          "edit_own_posts",
          "edit_all_posts",
          "publish_posts",
          "create_revision",
          "view_revisions",
          "revert_revision",
          "manage_tags",
          "manage_categories",
          "view_comments",
          "create_comment",
          "moderate_comments"
        ],
        "author" => [
          "view_posts",
          "create_post",
          "edit_own_posts",
          "delete_own_posts",
          "create_revision",
          "view_revisions",
          "create_comment"
        ],
        "contributor" => [
          "view_posts",
          "create_post",
          "edit_own_posts",
          "create_revision",
          "view_revisions",
          "create_comment"
        ],
        "moderator" => ["view_posts", "view_comments", "create_comment", "moderate_comments"],
        "subscriber" => ["view_posts", "view_comments", "create_comment"],
        "guest" => ["view_posts"],

        # New role mappings:
        "seo_manager" => ["manage_seo", "view_analytics", "export_reports", "run_ab_tests"],
        "support_agent" => [
          "view_support_tickets",
          "respond_support_tickets",
          "flag_abusive_users"
        ],
        "developer" => ["manage_api_tokens", "view_error_logs", "manage_webhooks"],
        "analyst" => ["view_analytics", "export_reports", "run_ab_tests"]
      }

      # 6) Build join rows and bulk-insert, ignoring duplicates
      now =
        DateTime.utc_now()
        |> DateTime.truncate(:second)

      rp_rows =
        for {role_name, perm_names} <- role_permissions,
            perm_name <- perm_names,
            role = role_map[role_name],
            perm = perm_map[perm_name] do
          %{
            role_id: role.id,
            permission_id: perm.id,
            inserted_at: now,
            updated_at: now
          }
        end

      Repo.insert_all(
        RolePermission,
        rp_rows,
        on_conflict: :nothing,
        conflict_target: [:role_id, :permission_id]
      )
    end)

    IO.puts("✅ Roles & Permissions seeding complete.")
  end
end
