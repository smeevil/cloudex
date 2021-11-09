defmodule Cloudex do
  @moduledoc """
  Cloudex takes care of uploading image files or urls to Cloudinary
  """

  @callback start(settings :: map) :: {:ok, pid}
  @callback upload(list | [String.t()], map) :: upload_result
  @callback delete([String.t()]) :: :ok

  @doc """
  You can start the GenServer that holds the cloudinary api settings by hand using this function.
  ## example

      start %{api_key: "key", secret: "s3cr3t", cloud_name: "heaven"}
  """
  @spec start(settings :: map) :: {:ok, pid}
  defdelegate start(settings), to: Cloudex.Settings

  @type upload_result ::
          {:ok, Cloudex.UploadedImage.t()}
          | {:error, any}
          | [{:ok, Cloudex.UploadedImage.t()} | {:error, any}]

  @doc ~S"""
    Uploads a (list of) image file(s) and/or url(s) to cloudinary
  """
  @spec upload(list | String.t()) :: upload_result
  @spec upload(list | [String.t()], map) :: upload_result
  def upload(list, options \\ %{}) do
    result =
      list
      |> sanitize_list()
      |> Enum.map(fn item ->
        Task.async(fn ->
          case item do
            {:ok, item} -> Cloudex.CloudinaryApi.upload(item, options)
            {:error, error} -> {:error, error}
          end
        end)
      end)
      |> Enum.map(&Task.await(&1, 60_000))

    case Enum.count(result) do
      1 -> List.first(result)
      _ -> result
    end
  end

  @doc """
  Delete a list of images
  """
  @spec delete([String.t()]) :: :ok
  def delete(item_list) when is_list(item_list), do: Enum.map(item_list, &delete/1)

  @doc """
  Delete an image
  """
  def delete(item, opts \\ %{}) do
    Cloudex.CloudinaryApi
    |> Task.async(:delete, [item, opts])
    |> Task.await(60_000)
  end

  @doc """
  Deletes a prefix
  """
  def delete_prefix(prefix) do
    Cloudex.CloudinaryApi
    |> Task.async(:delete_prefix, [prefix])
    |> Task.await(60_000)
  end

  @spec sanitize_list(list | String.t(), list) :: [{:ok, String.t()} | {:error, String.t()}]
  defp sanitize_list(list, sanitized_list \\ [])
  defp sanitize_list(item, _sanitized_list) when is_binary(item), do: sanitize_list([item])
  defp sanitize_list([], sanitized_list), do: List.flatten(sanitized_list)

  defp sanitize_list([item | tail], sanitized_list) do
    result =
      if Regex.match?(~r/^(http|s3)/, item), do: {:ok, item}, else: handle_file_or_directory(item)

    new_list = [result | sanitized_list]
    sanitize_list(tail, new_list)
  end

  @spec handle_file_or_directory(String.t()) ::
          {:ok, String.t()} | {:error, String.t()} | [{:ok, String.t()} | {:error, String.t()}]
  defp handle_file_or_directory(file_or_directory) do
    case File.dir?(file_or_directory) do
      true ->
        file_or_directory
        |> String.replace(~r{/$}, "")
        |> get_image_files_in_path!

      _ ->
        check_file(file_or_directory)
    end
  end

  @spec check_file(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defp check_file(path),
    do: if(File.exists?(path), do: {:ok, path}, else: {:error, "File #{path} does not exist."})

  @spec get_image_files_in_path!(String.t()) :: [{:ok, String.t()} | {:error, String.t()}]
  defp get_image_files_in_path!(path) do
    path
    |> File.ls!()
    |> Enum.map(fn file -> check_file("#{path}/#{file}") end)
  end
end
