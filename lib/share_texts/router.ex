defmodule ShareTexts.Router do
  use Plug.Router

  require EEx

  plug Plug.Static,
    at: "/static",
    from: :share_texts

  plug(:match)
  plug(:dispatch)

  match _ do
    host = Application.fetch_env!(:share_texts, :host)
    port = Application.fetch_env!(:share_texts, :port)

    page = EEx.eval_file("lib/application.html.eex", host: "#{host}:#{port}")
    send_resp(conn, 200, page)
  end
end
