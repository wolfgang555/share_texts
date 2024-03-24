defmodule ShareTexts.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  match _ do
    file_path = "lib/share_texts/templates/submit_text_page.html.eex"
    # html_form = File.read!("")
    page = EEx.eval_file(file_path, host: "192.9.180.156:3000")
    send_resp(conn, 200, page)
  end
end
