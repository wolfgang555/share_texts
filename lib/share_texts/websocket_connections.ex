defmodule ShareTexts.WebsocketConnections do
  use GenServer

  # 启动 GenServer
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  # GenServer 回调
  def init(:ok) do
    {:ok, []} # 初始状态为空列表
  end

  # 添加新的 WebSocket 连接
  def add_connection(pid) do
    GenServer.cast(__MODULE__, {:add_conn, pid})
  end

  # 从列表中删除 WebSocket 连接
  def remove_connection(pid) do
    GenServer.cast(__MODULE__, {:remove_conn, pid})
  end

  # 广播消息给所有连接
  def broadcast_message(message) do
    GenServer.call(__MODULE__, {:broadcast, message})
  end

  # 处理添加连接的请求
  def handle_cast({:add_conn, pid}, state) do
    {:noreply, [pid | state]}
  end

  # 处理删除连接的请求
  def handle_cast({:remove_conn, pid}, state) do
    {:noreply, Enum.reject(state, &(&1 == pid))}
  end

  # 处理广播消息的请求
  def handle_call({:broadcast, message}, _from, state) do
    Enum.each(state, fn pid ->
      send(pid, {:websocket_send, {:text, message}})
    end)
    {:reply, :ok, state}
  end
end
