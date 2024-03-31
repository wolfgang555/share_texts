defmodule ShareTexts.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def dispatcher do
    [
      {:_,
       [
         {"/websocket", ShareTexts.SocketRouter, []},
         {:_, Plug.Cowboy.Handler, {ShareTexts.Router, []}}
       ]}
    ]
  end

  @impl true

  def start(_type, _args) do
    children = [
      {
        Plug.Cowboy,
        scheme: :http,
        plug: ShareTexts.Router,
        options: [
          port: 3000,
          dispatch: ShareTexts.Application.dispatcher
        ]
      },

      Registry.child_spec(
        keys: :duplicate,
        name: Registry.ShareTexts
      )
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]

    Supervisor.start_link(children, opts)
  end
end
