defmodule ShareTexts.Router do
  use Plug.Router

  require EEx

  plug Plug.Static,
    at: "/static",
    from: :share_texts

  plug(:match)
  plug(:dispatch)

  match _ do
    page = EEx.eval_file("lib/application.html.eex", host: Application.fetch_env!(:share_texts, :host))
    send_resp(conn, 200, page)
  end
end
