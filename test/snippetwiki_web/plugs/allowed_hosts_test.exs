defmodule SnippetwikiWeb.Plugs.AllowedHostsTest do
  use SnippetwikiWeb.ConnCase, async: false

  import Plug.Test

  alias SnippetwikiWeb.Plugs.AllowedHosts

  @login_path "/users/log-in"

  setup do
    on_exit(fn -> Application.put_env(:snippetwiki, :allowed_hosts, []) end)
    :ok
  end

  defp get_with_host(host) do
    build_conn()
    |> Map.put(:host, host)
    |> get(@login_path)
  end

  test "empty allowed hosts list allows any host" do
    Application.put_env(:snippetwiki, :allowed_hosts, [])

    conn =
      :get
      |> conn("/")
      |> Map.put(:host, "evil.com")
      |> AllowedHosts.call([])

    refute conn.halted
  end

  describe "dev ALLOWED_HOSTS=localhost,127.0.0.1" do
    setup do
      Application.put_env(:snippetwiki, :allowed_hosts, ["localhost", "127.0.0.1"])
      :ok
    end

    test "allows localhost and 127.0.0.1" do
      for host <- ["localhost", "127.0.0.1"] do
        assert html_response(get_with_host(host), 200) =~ "Log in"
      end
    end

    test "rejects other domain and ip" do
      for host <- ["evil.com", "192.168.1.50", "domain.com"] do
        conn = get_with_host(host)
        assert conn.status == 403
        assert conn.resp_body == ~s({"error":"Forbidden"})
      end
    end
  end

  describe "prod ALLOWED_HOSTS=domain.com" do
    setup do
      Application.put_env(:snippetwiki, :allowed_hosts, ["domain.com"])
      :ok
    end

    test "allows domain.com" do
      assert html_response(get_with_host("domain.com"), 200) =~ "Log in"
    end

    test "rejects localhost and other domain/ip" do
      for host <- ["localhost", "203.0.113.10", "notdomain.com"] do
        conn = get_with_host(host)
        assert conn.status == 403
        assert conn.resp_body == ~s({"error":"Forbidden"})
      end
    end
  end
end
