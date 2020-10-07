defmodule Cloudex.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [Cloudex.Settings]

    opts = [strategy: :one_for_one, name: Cloudex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
