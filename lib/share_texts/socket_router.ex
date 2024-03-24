defmodule ShareTexts.SocketRouter do
  @behaviour :cowboy_websocket

  require Logger

  def init(req, _opts) do
    {
      :cowboy_websocket,
      req,
      %{},
      %{
        # 1 min w/o a ping from the client and the connection is closed
        idle_timeout: 60_000,
        # Max incoming frame size of 1 MB
        max_frame_size: 1_000_000
      }
    }
  end

  def terminate(reason, _req, state ) do
    Logger.info("[ws.gate:terminate] disconnected, reason:[#{inspect reason}], client[#{inspect state}]")
		:ok
  end

  def websocket_init(_info, state) do
		{:ok, state}
  end

  def websocket_handle(:ping, state) do
    {[:pong], state}
  end

  def websocket_handle({:ping}, state) do
    {[:pong], state}
  end

  def websocket_handle({:text, msg}, state) do
    IO.inspect(msg, label: "Received message")

    html_path = "lib/share_texts/templates/submit_text_page.html.eex"
    content = File.read!(html_path)
    new_content = Regex.replace(~r/<textarea id="messageBox">.*?<\/textarea>/s, content, "<textarea id=\"messageBox\">#{msg}</textarea>")
    IO.inspect(new_content)
    File.write!(html_path, new_content)

    {[{:text, msg}], state}
  end

  def websocket_info(any, state) do
    IO.inspect(any)
    {:ok, state}
  end
end
