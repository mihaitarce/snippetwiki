defmodule Snippetwiki.UserAuth do
  alias Snippetwiki.Snippets.Scope

  def process_auth_headers(headers) do
    result = Enum.reduce(headers, %{}, fn header, acc ->
      {key, value} = header
      case key do
        "x-authenticated-user" -> Map.put(acc, :email, value)
        "x-authenticated-group" -> Map.put(acc, :bag, value)
        _ -> acc
      end
    end)

    if Enum.empty?(result) do
      nil
    else
      %Scope{user: result}
    end
  end
end
