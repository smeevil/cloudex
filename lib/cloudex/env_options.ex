defmodule Cloudex.EnvOptions do
  @moduledoc """
  A simple module to get System Environment Variables (ENV VARS)
  """

  @doc """
  Pass a Map to merge system variables with.
  Uses the keys of the map to match the system vars with

  ## Examples

      Cloudex.EnvOptions.merge %{my_env_key: nil}
      > %{my_env_key: "value from env"}
  """
  @spec merge(options :: Map.t) :: Map.t
  def merge(%{}=options) do
    options |> Map.keys |> merge(options)
  end

  @doc """
  Same as merge, but only merges settings which have a nil value in the given map
  """
  @spec merge_missing_settings(options :: Map.t) :: Map.t
  def merge_missing_settings(%{} = options) do
    options |> Map.keys |> merge_if_missing(options)
  end

  defp merge([], options) do
    options
  end

  defp merge([key|keys], options) do
    env_value = get_value(key)
    new_options = options |> merge_value(key, env_value)
    keys |> merge(new_options)
  end

  defp merge_if_missing([], options) do
    options
  end

  defp merge_if_missing([key|keys], options) do
    value = get_value(key)
    new_options = options |> merge_value_if_missing(key, value)
    keys |> merge_if_missing(new_options)
  end

  defp merge_value(options, _key , nil) do
    options
  end

  defp merge_value(options, key , value) do
    Map.put options, key, value
  end

  defp merge_value_if_missing(options, key , value) do
    case options[key] do
      nil -> Map.put options, key, value
      _   -> options
    end
  end

  defp get_value(key) do
    ("cloudex_" <> Atom.to_string(key)) |> String.upcase |> System.get_env
  end
end