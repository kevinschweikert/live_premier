defmodule LivePremierTest do
  use ExUnit.Case, async: true

  doctest LivePremier

  setup :req_test_verify_on_exit!

  defp req_test_verify_on_exit!(arg), do: Req.Test.verify_on_exit!(arg)

  defp assert_get(conn), do: assert(conn.method == "GET")
  defp assert_post(conn), do: assert(conn.method == "POST")

  defp assert_request_path(conn, path) do
    assert conn.request_path == LivePremier.api_path() <> path
  end

  defp assert_json(conn, map) do
    assert {:ok, data, _conn} = Plug.Conn.read_body(conn)
    assert ^map = Jason.decode!(data)
  end

  defp no_content(conn), do: Plug.Conn.send_resp(conn, 204, "")

  test "system info" do
    Req.Test.expect(
      LivePremierStub,
      fn conn ->
        assert_get(conn)
        assert_request_path(conn, "/system")

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

    assert {:ok,
            %LivePremier.System.Info{
              type: "AQL RS4",
              version: %LivePremier.System.Version{patch: 23}
            }} =
             LivePremier.new("http://example.com")
             |> LivePremier.system_info()
  end

  test "reboot" do
    Req.Test.expect(
      LivePremierStub,
      fn conn ->
        assert_post(conn)
        assert_request_path(conn, "/system/reboot")
        no_content(conn)
      end
    )

    assert :ok =
             LivePremier.new("http://example.com")
             |> LivePremier.reboot()
  end

  test "shutdown" do
    Req.Test.expect(
      LivePremierStub,
      fn conn ->
        assert_post(conn)
        assert_request_path(conn, "/system/shutdown")
        assert_json(conn, %{"enableWakeOnLan" => false})
        no_content(conn)
      end
    )

    assert :ok =
             LivePremier.new("http://example.com")
             |> LivePremier.shutdown()
  end

  test "shutdown with wake on lan" do
    Req.Test.expect(
      LivePremierStub,
      fn conn ->
        assert_post(conn)
        assert_request_path(conn, "/system/shutdown")
        assert_json(conn, %{"enableWakeOnLan" => true})
        no_content(conn)
      end
    )

    assert :ok =
             LivePremier.new("http://example.com")
             |> LivePremier.shutdown(enable_wake_on_lan: true)
  end

  test "reading screen information" do
    Req.Test.expect(
      LivePremierStub,
      fn conn ->
        assert_get(conn)
        assert_request_path(conn, "/screens/1")

        Req.Test.json(conn, %{
          isEnabled: true,
          label: "Center"
        })
      end
    )

    assert {:ok,
            %LivePremier.Screen.Info{
              isEnabled: true,
              label: "Center"
            }} =
             LivePremier.new("http://example.com")
             |> LivePremier.screen_info(1)
  end

  test "recalling a preset from memory to a single screen" do
    Req.Test.expect(
      LivePremierStub,
      fn conn ->
        assert_post(conn)
        assert_request_path(conn, "/screens/3/load-memory")
        assert_json(conn, %{"memoryId" => 123, "target" => "program"})
        no_content(conn)
      end
    )

    assert :ok =
             LivePremier.new("http://example.com")
             |> LivePremier.load_memory(3, memory_id: 123, target: "program")
  end

  test "recalling a preset from master memory" do
    Req.Test.expect(
      LivePremierStub,
      fn conn ->
        assert_post(conn)
        assert_request_path(conn, "/screens/load-master-memory")
        assert_json(conn, %{"memoryId" => 123, "target" => "program"})
        no_content(conn)
      end
    )

    assert :ok =
             LivePremier.new("http://example.com")
             |> LivePremier.load_master_memory(memory_id: 123, target: "program")
  end

  test "reading a layer information" do
    Req.Test.expect(
      LivePremierStub,
      fn conn ->
        assert_get(conn)
        assert_request_path(conn, "/screens/23/layers/112")

        Req.Test.json(conn, %{
          capacity: 3,
          canUseMask: true
        })
      end
    )

    assert {:ok, %LivePremier.Screen.LayerInfo{capacity: 3, canUseMask: true}} =
             LivePremier.new("http://example.com")
             |> LivePremier.layer_info(23, 112)
  end

  test "reading a layer status" do
    Req.Test.expect(
      LivePremierStub,
      fn conn ->
        assert_get(conn)
        assert_request_path(conn, "/screens/23/layers/112/presets/preview")

        Req.Test.json(conn, %{
          status: "open",
          sourceType: "input",
          sourceId: 8
        })
      end
    )

    assert {:ok,
            %LivePremier.Screen.LayerStatus{
              status: :open,
              sourceType: :input,
              sourceId: 8
            }} =
             LivePremier.new("http://example.com")
             |> LivePremier.layer_status(23, 112, :preview)
  end
end
