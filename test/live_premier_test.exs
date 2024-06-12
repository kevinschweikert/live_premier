defmodule LivePremierTest do
  use ExUnit.Case
  alias LivePremier.Error

  doctest LivePremier

  setup :req_test_verify_on_exit!

  defp req_test_verify_on_exit!(arg), do: Req.Test.verify_on_exit!(arg)

  test "system" do
    Req.Test.expect(
      LivePremierStub,
      fn %{path_info: ["api", "tpp", "v1", "system"]} = conn ->
        Req.Test.json(conn, %{
          type: "AQL RS4",
          label: "AQUILON",
          version: %{
            major: 1,
            minor: 0,
            patch: 23,
            beta: false
          }
        })
      end
    )

    Req.Test.expect(LivePremierStub, &Req.Test.transport_error(&1, :econnrefused))

    assert {:ok, %LivePremier.System{type: "AQL RS4", version: %LivePremier.Version{patch: 23}}} =
             LivePremier.new("http://example.com")
             |> LivePremier.system()

    assert {:error, %Error{message: :econnrefused}} =
             LivePremier.new("http://example.com")
             |> LivePremier.system()
  end

  test "reboot" do
    Req.Test.expect(
      LivePremierStub,
      fn %{path_info: ["api", "tpp", "v1", "system", "reboot"]} = conn ->
        Plug.Conn.send_resp(conn, 200, "")
      end
    )

    Req.Test.expect(LivePremierStub, &Req.Test.transport_error(&1, :econnrefused))

    assert :ok =
             LivePremier.new("http://example.com")
             |> LivePremier.reboot()

    assert {:error, %Error{message: :econnrefused}} =
             LivePremier.new("http://example.com")
             |> LivePremier.reboot()
  end

  test "shutdown" do
    Req.Test.expect(
      LivePremierStub,
      fn %{path_info: ["api", "tpp", "v1", "system", "shutdown"]} = conn ->
        {:ok, ~s|{"enableWakeOnLan":false}|, conn} = Plug.Conn.read_body(conn)
        Plug.Conn.send_resp(conn, 200, "")
      end
    )

    Req.Test.expect(LivePremierStub, &Req.Test.transport_error(&1, :econnrefused))

    assert :ok =
             LivePremier.new("http://example.com")
             |> LivePremier.shutdown()

    assert {:error, %Error{message: :econnrefused}} =
             LivePremier.new("http://example.com")
             |> LivePremier.shutdown()
  end

  test "shutdown with wake on lan" do
    Req.Test.expect(
      LivePremierStub,
      fn %{path_info: ["api", "tpp", "v1", "system", "shutdown"]} = conn ->
        {:ok, ~s|{"enableWakeOnLan":true}|, conn} = Plug.Conn.read_body(conn)
        Plug.Conn.send_resp(conn, 200, "")
      end
    )

    assert :ok =
             LivePremier.new("http://example.com")
             |> LivePremier.shutdown(enable_wake_on_lan: true)
  end
end
