(() => {
  class myWebsocketHandler {
    setupSocket() {
      try {
        // host 变量已经包含了协议（ws:// 或 wss://）
        // 如果 host 不包含协议，则根据当前页面协议自动选择
        let wsUrl;
        if (typeof host !== 'undefined' && (host.startsWith('ws://') || host.startsWith('wss://'))) {
          wsUrl = `${host}/websocket`;
        } else {
          // 如果 host 不包含协议，根据当前页面协议选择
          const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
          const hostname = typeof host !== 'undefined' ? host : window.location.hostname;
          wsUrl = `${protocol}//${hostname}/websocket`;
        }
        
        // 确保使用安全的 WebSocket 协议（在 HTTPS 页面上必须使用 wss://）
        if (window.location.protocol === 'https:' && wsUrl.startsWith('ws://')) {
          wsUrl = wsUrl.replace('ws://', 'wss://');
        }
        
        console.log('Connecting to WebSocket:', wsUrl);
        this.socket = new WebSocket(wsUrl)

      this.socket.addEventListener("message", (event) => {
        // const pTag = document.createElement("p")
        // pTag.innerHTML = event.data

        // document.getElementById("messageBox").value(event.data)
      const messageBox = document.getElementById("messageBox");
      if (messageBox) {
        messageBox.value = event.data;
      }})

      this.socket.addEventListener("close", () => {
        this.setupSocket()
      })
      
      this.socket.addEventListener("error", (error) => {
        console.error('WebSocket error:', error);
      })
      } catch (error) {
        console.error('Failed to setup WebSocket:', error);
        // 延迟重试
        setTimeout(() => this.setupSocket(), 3000);
      }
    }

    submit(event) {
      event.preventDefault()
      const input = document.getElementById("messageBox")
      const message = input.value
      input.value = ""

      this.socket.send(
        JSON.stringify({
          data: {message: message},
        })
      )
    }
  }

  const websocketClass = new myWebsocketHandler()
  websocketClass.setupSocket()
  
  document.getElementById("submitBtn")
    .addEventListener("click", (event) => websocketClass.submit(event))
})()