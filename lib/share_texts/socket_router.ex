defmodule ShareTexts.SocketRouter do
  @behaviour :cowboy_websocket

  require Logger

  @path "priv/static/data.txt"

  @impl true
  def init(req, _opts) do
    state = %{registry_key: req.path}
    IO.puts("req.path is #{req.path}")
    {
      :cowboy_websocket,
      req,
      state,
      %{
        # 1 min w/o a ping from the client and the connection is closed
        idle_timeout: 60_000,
        # Max incoming frame size of 1 MB
        max_frame_size: 1_000_000
      }
    }
  end

  @impl true
  def terminate(reason, _req, state ) do
    ShareTexts.WebsocketConnections.remove_connection(self())
    Logger.info("[ws.gate:terminate] disconnected, reason:[#{inspect reason}], client[#{inspect state}]")
		:ok
  end

  @impl true
  def websocket_init(state) do
    Registry.ShareTexts
    |> Registry.register(state.registry_key, {})

    # 初始连接的时候， 读取文件， 将文件的内容返回到前端， 渲染至页面
    file_content = if File.exists?(@path) do
      File.read!(@path)
    else
      File.write!(@path, "请输入你想分享的内容")
      "请输入你想分享的内容"
    end

    # Registry.ShareTexts
    # |> Registry.dispatch("/websocket", fn(entries) ->
    #   for {pid, _} <- entries do
    #     Process.send(pid, file_content, [])
    #   end
    # end)
    Process.send(self(), file_content, [])
		{:ok, state}
  end

  @impl true
  def websocket_handle(:ping, state) do
    {[:pong], state}
  end

  @impl true
  def websocket_handle({:ping}, state) do
    {[:pong], state}
  end

  @impl true
  def websocket_handle({:text, msg}, state) do
    IO.inspect(msg, label: "Received message")
    # html_path = "lib/share_texts/templates/submit_text_page.html.eex"
    # content = File.read!(html_path)
    # new_content = Regex.replace(~r/<textarea id="messageBox">.*?<\/textarea>/s, content, "<textarea id=\"messageBox\">#{msg}</textarea>")
    # # IO.inspect(new_content)
    case Jason.decode(msg) do
      {:ok, decoded} ->
        # 从解析后的数据中获取内容
        content = decoded
        |> Map.get("data")
        |> Map.get("message")

        IO.inspect(content, label: "Extracted Content")

        Registry.ShareTexts
        |> Registry.dispatch(state.registry_key, fn(entries) ->
          for {pid, _} <- entries do
            if pid != self() do
              Process.send(pid, content, [])
            end
          end
        end)

        # 接下来，您可以根据需要处理这个内容
        File.write!(@path, content)

        {[{:text, content}], state}
      {:error, _reason} ->
        IO.puts("Failed to decode JSON")
        {:reply, {:text, "Error: Failed to decode JSON"}, state}
    end
  end

  @impl true
  def websocket_info(info, state) do
    IO.puts("got info #{info}")
    {:reply, {:text, info}, state}
  end
end
