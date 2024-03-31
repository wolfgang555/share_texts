(() => {
  class myWebsocketHandler {
    setupSocket() {
      this.socket = new WebSocket(`ws://${host}/websocket`)

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