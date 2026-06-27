defmodule Snippetwiki.UserAuth do
  alias Snippetwiki.Snippets.Scope

  def process_auth_headers(headers) do
    result = Enum.reduce(headers, %{}, fn header, acc ->
      {key, value} = header
      case key do
        "x-authenticated-user" ->
          Map.put(acc, :email, value)

        "x-authenticated-group" ->
          bags =
            value
            |> String.split(",")
            |> Enum.map(&String.trim/1)
            |> Enum.reject(&(&1 == ""))

          acc
          |> Map.put(:bags, bags)
          |> Map.put(:bag, List.first(bags))

        _ ->
          acc
      end
    end)

    # We need the headers to provide both email (username) and bag (group) information.
    # `:bag` is the write target (first bag in the recipe) and `:bags` is the full
    # read list. `bag` is nil when the group header was present but empty.
    if Enum.empty?(result) or not Map.has_key?(result, :email) or
         not Map.has_key?(result, :bags) or is_nil(result[:bag]) do
      nil
    else
      %Scope{user: result}
    end
  end
end
