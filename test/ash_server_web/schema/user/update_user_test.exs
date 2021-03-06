defmodule AshServerWeb.Schema.UpdateUserTest do
  use AshServerWeb.ConnCase
  import AshServer.Factory

  @query """
    mutation UpdateUser($id: ID!, $user: UpdateUserParams!) {
      updateUser(id: $id, user: $user) {
        id
        email
      }
    }
  """

  @tag :authenticated
  test "users can update themselves", %{conn: conn, current_user: current_user} do
    response = post_gql(conn, %{
      query: @query,
      variables: %{
        id: current_user.id,
        user: %{
          password: "password",
          confirmPassword: "password",
          currentPassword: "test_password"
        }
      }
    })

    assert response == %{
      "data" => %{
        "updateUser" => %{
          "id" => to_string(current_user.id),
          "email" => current_user.email
        }
      }
    }
  end

  @tag :authenticated
  test "users can't update someone else", %{conn: conn} do
    user = insert(:user)
    response = post_gql(conn, %{
      query: @query,
      variables: %{
        id: user.id,
        user: %{
          password: "password",
          confirmPassword: "password",
          currentPassword: "test_password"
        }
      }
    })

    assert response == %{
      "data" => %{"updateUser" => nil},
      "errors" => [
        %{
          "locations" => [%{"column" => 0, "line" => 2}],
          "message" => "unauthorized",
          "path" => ["updateUser"]
        }
      ]
    }
  end
end
