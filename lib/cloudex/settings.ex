defmodule Cloudex.Settings do
  @moduledoc """
  This is a GenServer that contains the API settings for cloudinary
  You can interact with the `get` function to retreive the settings you want.
  """

  use GenServer
  alias Cloudex.EnvOptions
  @doc """
  Called by the supervisor, this will use settings defined in config.exs or ENV vars
  """
  def start(:normal, []) do
    [:api_key, :secret, :cloud_name]
      |> get_app_config
      |> EnvOptions.merge_missing_settings
      |> start
  end

  @doc """
    Actually starting the GenServer with given settings
  """
  def start(%{} = settings) do
    settings
      |> Map.merge(settings)
      |> validate
      |> do_start
  end

  def do_start({:error, :placeholder_settings}) do
    {:error, placeholder_settings_error_message}
  end

  def do_start({:error, _} = error) do
    error
  end

  @doc """
  Helper function to start or restart the GenServer when already started with given settings
  """
  def do_start({:ok, settings}) do
    case GenServer.start(__MODULE__, settings, name: :cloudex) do
      {:error, {:already_started, _pid}} ->
        stop
        start(settings)
      {:ok, pid} -> {:ok, pid}
    end
  end

  @doc """
  Helper function to stop the GenServer
  """
  def stop do
    GenServer.call(:cloudex, :stop)
  end

  def handle_call(:stop, _caller, state) do
    {:stop, :normal,:ok, state}
  end

  def handle_call(:settings, _caller, state) do
    {:reply, state, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  @doc """
  Get the cloudinary credentials as map.

  ## Examples

      Cloudex.Settings.get
      > %{api_key: "mykey", secret: "s3cr3t", cloud_name: "heaven"}
  """
  @spec get() :: Map.t
  def get do
    GenServer.call(:cloudex, :settings)
  end

  @doc """
  Get a specific cloudinary credential by key.

  ## Examples
      Cloudex.Settings.get(:secret)
      > "s3cr3t"

      Cloudex.Settings.get(:bogus)
      > {:error, "key not found"}
  """
  def get(key) when is_atom(key) do
    env_key = ("cloudinary_" <> Atom.to_string(key)) |> String.upcase
    env_value = System.get_env(env_key)
    case env_value do
      nil ->
        result = GenServer.call(:cloudex, :settings)
        case key do
          nil -> {:error, "key not found"}
          _ -> result[key]
        end
      _ -> env_value
    end
  end

  defp get_app_config(keys, map \\ %{})
  defp get_app_config([], map) do
    map
  end

  defp get_app_config([key|keys], map) do
    new_map = Map.put map, key, Application.get_env(:cloudex, key)
    get_app_config(keys, new_map)
  end

  defp validate(%{api_key: "placeholder", secret: "placeholder", cloud_name: "placeholder"}) do
    {:error, :placeholder_settings}
  end

  defp validate(%{api_key: api_key, secret: secret, cloud_name: cloud_name} = settings) when is_binary(api_key) and is_binary(secret) and is_binary(cloud_name) do
    {:ok, settings}
  end

  defp validate(settings) do
    {:error, ~s<
We received the following incorrect settings : #{inspect settings}
You can solve this in two ways :
add the following to your config.exs or config/[dev/test/prod]: cloudex, api_key: YOUR_CLOUDINARY_API_KEY, secret: YOUR_CLOUDINARY_SECRET, cloud_name: YOUR_CLOUDINARY_CLOUD_NAME
-or-
Set the following ENV vars CLOUDEX_API_KEY CLOUDEX_SECRET CLOUDEX_CLOUD_NAME
>}
  end

  defp placeholder_settings_error_message do
   "Please add the following settings to your config.exs or config/[dev/test/prod].exs : config :cloudex, api_key: YOUR_CLOUDINARY_API_KEY, secret: YOUR_CLOUDINARY_SECRET, cloud_name: YOUR_CLOUDINARY_CLOUD_NAME"
  end
end
