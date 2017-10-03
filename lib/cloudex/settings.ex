defmodule Cloudex.Settings do
  @moduledoc """
  This is a GenServer that contains the API settings for cloudinary
  You can interact with the `get` function to retreive the settings you want.
  """

  use GenServer

  @doc """
  Called by the supervisor, this will use settings defined in config.exs or ENV vars
  """
  def start(:normal, []) do
    [:api_key, :secret, :cloud_name]
    |> get_app_config
    |> Cloudex.EnvOptions.merge_missing_settings
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

  def do_start({:error, :placeholder_settings}), do: {:error, placeholder_settings_error_message()}

  def do_start({:error, _} = error), do: error

  @doc """
  Helper function to start or restart the GenServer when already started with given settings
  """
  def do_start({:ok, settings}) do
    case GenServer.start(__MODULE__, settings, name: :cloudex) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, _pid}} ->
        stop()
        start(settings)
    end
  end

  @doc """
  Helper function to stop the GenServer
  """
  def stop, do: GenServer.call(:cloudex, :stop)

  def handle_call(:stop, _caller, state), do: {:stop, :normal, :ok, state}

  def handle_call(:settings, _caller, state), do: {:reply, state, state}

  def terminate(_reason, _state), do: :ok

  @doc """
  Get the cloudinary credentials as map.

  ## Examples

      Cloudex.Settings.get
      > %{api_key: "mykey", secret: "s3cr3t", cloud_name: "heaven"}
  """
  @spec get() :: map
  def get, do: GenServer.call(:cloudex, :settings)

  @doc """
  Get a specific cloudinary credential by key.

  ## Examples
      Cloudex.Settings.get(:secret)
      > "s3cr3t"

      Cloudex.Settings.get(:bogus)
      > {:error, "key not found"}
  """
  def get(key) when is_atom(key) do
    env_key = String.upcase("cloudinary_" <> Atom.to_string(key))
    System.get_env(env_key) || get_from_settings(key)
  end

  defp get_from_settings(nil), do: {:error, "key not found"}
  defp get_from_settings(key), do: GenServer.call(:cloudex, :settings)[key]

  defp get_app_config(keys, map \\ %{})
  defp get_app_config([], map), do: map

  defp get_app_config([key | keys], map) do
    new_map = Map.put(map, key, Application.get_env(:cloudex, key))
    get_app_config(keys, new_map)
  end

  defp validate(%{api_key: "placeholder", secret: "placeholder", cloud_name: "placeholder"}) do
    {:error, :placeholder_settings}
  end

  defp validate(%{api_key: api_key, secret: secret, cloud_name: cloud_name} = settings)
       when is_binary(api_key) and is_binary(secret) and is_binary(cloud_name) do
    {:ok, settings}
  end

  defp validate(settings) do
    {
      :error,
      ~s<
We received the following incorrect settings : #{inspect settings}
You can solve this in two ways :
add the following to your config.exs or config/[dev/test/prod]: cloudex, api_key: YOUR_CLOUDINARY_API_KEY, secret: YOUR_CLOUDINARY_SECRET, cloud_name: YOUR_CLOUDINARY_CLOUD_NAME
-or-
Set the following ENV vars CLOUDEX_API_KEY CLOUDEX_SECRET CLOUDEX_CLOUD_NAME
>
    }
  end

  defp placeholder_settings_error_message do
    "Please add the following settings to your config.exs or config/[dev/test/prod].exs : config :cloudex, api_key: YOUR_CLOUDINARY_API_KEY, secret: YOUR_CLOUDINARY_SECRET, cloud_name: YOUR_CLOUDINARY_CLOUD_NAME"
  end
end
