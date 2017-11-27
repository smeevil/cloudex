defmodule Cloudex do
  @moduledoc """
  Cloudex takes care of uploading image files or urls to Cloudinary
  """

  @doc """
  You can start the GenServer that holds the cloudinary api settings by hand using this function.
  ## example

      start %{api_key: "key", secret: "s3cr3t", cloud_name: "heaven"}
  """
  @spec start(settings :: map) :: {:ok, pid}
  defdelegate start(settings), to: Cloudex.Settings

  @type upload_result :: {:ok, Cloudex.UploadedImage.t} | {:error, any}
                       | [{:ok, Cloudex.UploadedImage.t} | {:error, any}]

  @doc ~S"""
    Uploads a (list of) image file(s) and/or url(s) to cloudinary
  """
  @spec upload(list | String.t) :: upload_result
  @spec upload(list | [String.t], map) :: upload_result
  def upload(list, options \\ %{}) do
    sanitized_list = sanitize_list(list)
    invalid_list = Enum.filter(sanitized_list, &(match?({:error, _}, &1)))
    valid_list = Enum.filter(sanitized_list, &(match?({:ok, _}, &1)))

    upload_results =
      valid_list
      |> Enum.map(&(Task.async(Cloudex.CloudinaryApi, :upload, [&1, options])))
      |> Enum.map(&Task.await(&1, 60_000))

    result = upload_results ++ invalid_list

    case Enum.count(result) do
      1 -> List.first(result)
      _ -> result
    end
  end

  @doc """
  Delete a list of images
  """
  @spec delete([String.t]) :: :ok
  def delete(item_list) when is_list(item_list), do: Enum.map(item_list, &delete/1)

  @doc """
  Delete an image
  """
  def delete(item) do
    Cloudex.CloudinaryApi
    |> Task.async(:delete, [item])
    |> Task.await(60_000)
  end

  @spec sanitize_list(list | String.t, list) :: [{:ok, String.t} | {:error, String.t}]
  defp sanitize_list(list, sanitized_list \\ [])
  defp sanitize_list(item, _sanitized_list) when is_binary(item), do: sanitize_list([item])
  defp sanitize_list([], sanitized_list), do: List.flatten(sanitized_list)
  defp sanitize_list([item | tail], sanitized_list) do
    result = if Regex.match?(~r/^http/, item), do: {:ok, item}, else: handle_file_or_directory(item)
    new_list = [result | sanitized_list]
    sanitize_list(tail, new_list)
  end

  @spec handle_file_or_directory(String.t) :: {:ok, String.t} | {:error, String.t} | [{:ok, String.t} | {:error, String.t}]
  defp handle_file_or_directory(file_or_directory) do
    case File.dir?(file_or_directory) do
      true ->
        file_or_directory
        |> String.replace(~r{/$}, "")
        |> get_image_files_in_path!

      _ -> check_file(file_or_directory)
    end
  end

  @spec check_file(String.t) :: {:ok, String.t} | {:error, String.t}
  defp check_file(path), do: if File.exists?(path), do: {:ok, path}, else: {:error, "File #{path} does not exist."}

  @spec get_image_files_in_path!(String.t) :: [{:ok, String.t} | {:error, String.t}]
  defp get_image_files_in_path!(path) do
    path
    |> File.ls!
    |> Enum.map(fn file -> check_file("#{path}/#{file}") end)
  end
end
