defmodule ShareTexts.Router do
  use Plug.Router

  require EEx

  plug Plug.Static,
    at: "/static",
    from: :share_texts,
    cache_control_for_etags: "public, max-age=0",
    only: ~w(js css images fonts)

  plug(:match)
  plug(:dispatch)

  # 从请求头中获取真实的 host 和协议（支持反向代理）
  defp get_host_and_protocol(conn) do
    # 优先使用 X-Forwarded-Host（来自反向代理）
    forwarded_host =
      conn
      |> Plug.Conn.get_req_header("x-forwarded-host")
      |> List.first()

    # 优先使用 X-Forwarded-Proto（来自反向代理）
    forwarded_proto =
      conn
      |> Plug.Conn.get_req_header("x-forwarded-proto")
      |> List.first()

    # 如果没有代理头，使用请求中的 host
    host = forwarded_host || conn.host || Application.get_env(:share_texts, :host, "localhost")

    # 确定协议：优先使用 X-Forwarded-Proto，否则根据连接 scheme 判断
    is_https = case forwarded_proto do
      "https" -> true
      "http" -> false
      nil -> conn.scheme == :https
      _ -> String.downcase(forwarded_proto) == "https"
    end

    # WebSocket 协议：如果原始请求是 HTTPS，使用 wss，否则使用 ws
    ws_protocol = if is_https, do: "wss", else: "ws"

    # 构建 WebSocket URL（不包含端口，因为浏览器会自动处理标准端口）
    "#{ws_protocol}://#{host}"
  end

  match _ do
    # 从请求中动态获取 host 和协议（支持反向代理）
    host_with_protocol = get_host_and_protocol(conn)

    page = EEx.eval_file("lib/application.html.eex", host: host_with_protocol)
    send_resp(conn, 200, page)
  end
end
