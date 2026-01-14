defmodule SnippetwikWeb.UserLiveAuth do
  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    # socket =
    #   assign_new(socket, :current_user, fn ->
    #     Accounts.get_user_by_session_token(user_token)
    #   end)

    IO.inspect(get_connect_info(socket, :x_headers))

    socket = assign(socket, :current_user, "anonymous")

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/login")}
    end
  end

  defp process_auth_headers(socket) do
    # [{"x-authenticated-user", "username"}, {"x-authenticated-group", "group"}]

    headers = get_connect_info(socket, :x_headers)

    if is_nil(headers) do
      socket
    else
      headers
      |> Enum.reduce(socket, fn header, socket -> process_header(header, socket) end)
    end
  end

  defp process_header({"x-authenticated-user", username}, socket) do
    assign(socket, username: username)
  end

  defp process_header({"x-authenticated-group", group}, socket) do
    assign(socket, group: group)
  end

  defp process_header(_, socket) do
    socket
  end
end
