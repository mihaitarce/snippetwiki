defmodule Snippetwiki.Repo do
  use Ecto.Repo,
    otp_app: :snippetwiki,
    adapter: Ecto.Adapters.Postgres
end
