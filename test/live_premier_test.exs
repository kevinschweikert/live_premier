defmodule LivePremierTest do
  use ExUnit.Case

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

    assert {:ok, %LivePremier.System{type: "AQL RS4", version: %LivePremier.Version{patch: 23}}} =
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

    assert :ok =
             LivePremier.new("http://example.com")
             |> LivePremier.reboot()
  end

  test "shutdown" do
    Req.Test.expect(
      LivePremierStub,
      fn %{path_info: ["api", "tpp", "v1", "system", "shutdown"]} = conn ->
        assert {:ok, data, conn} = Plug.Conn.read_body(conn)
        assert %{"enableWakeOnLan" => false} = Jason.decode!(data)
        Plug.Conn.send_resp(conn, 200, "")
      end
    )

    assert :ok =
             LivePremier.new("http://example.com")
             |> LivePremier.shutdown()
  end

  test "shutdown with wake on lan" do
    Req.Test.expect(
      LivePremierStub,
      fn %{path_info: ["api", "tpp", "v1", "system", "shutdown"]} = conn ->
        assert {:ok, data, conn} = Plug.Conn.read_body(conn)
        assert %{"enableWakeOnLan" => true} = Jason.decode!(data)
        Plug.Conn.send_resp(conn, 200, "")
      end
    )

    assert :ok =
             LivePremier.new("http://example.com")
             |> LivePremier.shutdown(enable_wake_on_lan: true)
  end

  test "reading screen information" do
    id = 3
    id_string = Integer.to_string(id)

    Req.Test.expect(
      LivePremierStub,
      fn %{path_info: ["api", "tpp", "v1", "screens", ^id_string]} = conn ->
        Req.Test.json(conn, %{
          isEnabled: true,
          label: "Center"
        })
      end
    )

    assert {:ok,
            %LivePremier.Screen{
              isEnabled: true,
              label: "Center"
            }} =
             LivePremier.new("http://example.com")
             |> LivePremier.screen(id)
  end

  test "recalling a preset from memory to a single screen" do
    id = 3
    id_string = Integer.to_string(id)

    Req.Test.expect(
      LivePremierStub,
      fn %{path_info: ["api", "tpp", "v1", "screens", ^id_string, "load-memory"]} = conn ->
        assert conn.method == "POST"
        assert {:ok, data, conn} = Plug.Conn.read_body(conn)
        assert %{"memoryId" => 123, "target" => "program"} = Jason.decode!(data)
        Plug.Conn.send_resp(conn, 200, "")
      end
    )

    assert :ok =
             LivePremier.new("http://example.com")
             |> LivePremier.load_memory(id, memory_id: 123, target: "program")
  end
end
