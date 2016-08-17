
defmodule Cloudex do
  @moduledoc """
  Cloudex takes care of uploading image files or urls to Cloudinary
  """
  @extension_regex ~r/\.(jpg|jpeg|gif|png)$/i

  @doc """
  You can start the GenServer that holds the cloudinary api settings by hand using this function.
  ## example

      start %{api_key: "key", secret: "s3cr3t", cloud_name: "heaven"}
  """
  @spec start(settings :: Map.t) :: {:ok, PID.t}
  defdelegate start(settings), to: Cloudex.Settings

  @doc ~S"""
    Uploads a (list of) image file(s) and/or url(s) to cloudinary
  """
  @spec upload(list :: String.t) :: [Cloudex.UploadedImage.t]
  @spec upload(list :: [String.t]) :: [Cloudex.UploadedImage.t]
  def upload(list) do
    sanitized_list = list |> sanitize_list

    invalid_list = Enum.filter(sanitized_list, fn item -> match?({:error, _}, item) end)
    valid_list = Enum.filter(sanitized_list, fn item -> match?({:ok, _}, item) end)
    upload_results = valid_list
      |> Enum.map(fn image -> Task.async(cloudinary_api, :upload, [image]) end)
      |> Enum.map(&Task.await/1)
    upload_results ++ invalid_list
  end

  defp sanitize_list(list, sanitized_list \\ [])
  defp sanitize_list(item, _sanitized_list) when is_binary(item) do
    [item] |> sanitize_list
  end

  defp sanitize_list([], sanitized_list) do
    sanitized_list |> List.flatten
  end

  defp sanitize_list([item|tail], sanitized_list) do
    result = case Regex.match?(~r/^http/, item) do
      true -> item |> check_url
      _    -> item |> handle_file_or_directory
    end

    new_list = [result|sanitized_list]
    sanitize_list(tail, new_list)
  end

  defp check_url(url) do
    case Regex.match?(@extension_regex, url) do
      true -> {:ok, url}
      _    -> {:error, "#{url} is not an image url."}
    end
  end

  defp handle_file_or_directory(file_or_directory) do
    case File.dir?(file_or_directory) do
      true ->
        file_or_directory
          |> String.replace(~r{/$},"")
          |> get_image_files_in_path!

      _ -> file_or_directory |> check_file
    end
  end

  defp check_file(path) do
    case path |> File.exists? do
      true -> path |> is_image?
      _    -> {:error, "File #{path} does not exist."}
    end
  end

  defp get_image_files_in_path!(path) do
    path
    |> File.ls!
    |> Enum.map(fn file -> check_file("#{path}/#{file}") end)
  end

  defp is_image?(path) do
    case Regex.match?(@extension_regex, path) do
      true -> {:ok, path}
      _ -> {:error, "#{path} is not an image."}
    end
  end

  defp cloudinary_api do
    api = Application.get_env(:cloudex, :cloudinary_api)
    case api do
     nil -> Cloudex.CloudinaryApi.Live
     _   -> api
    end
  end
end
