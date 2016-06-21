defmodule Cloudex.CloudinaryApi.Live do
  @moduledoc """
  The live API implementation for Cloudinary uploading
  """

  @behaviour Cloudex.CloudinaryApi
  use Timex

  alias Cloudex.UploadedImage
  alias Cloudex.Settings

  @doc """
  Helper function to enable piping of {:ok, path} tuples into upload
  """
  @spec upload({:ok, item :: String.t}) :: Cloudex.UploadedImage.t
  def upload({:ok, item}) when is_binary(item) do
    upload(item)
  end

  @doc """
  Upload either a file or url to cloudinary
  returns {:ok, %UploadedFile{}} containing all the information from cloudinary
  or {:error, "reason"}
  """
  @spec upload(item :: String.t, opts :: map) :: Cloudex.UploadedImage.t
  def upload(item, opts \\ %{})
  def upload(item, opts) when is_binary(item) do
    case item do
      "http://" <> _rest -> item |> upload_url(opts)
      _                  -> item |> upload_file(opts)
    end
  end

  @doc """
  Catches upload called without a string argument
  """
  def upload(invalid_item, _opts) do
    {:error, "Upload/1 only accepts a String or {:ok, String}, received: #{inspect invalid_item}"}
  end

  defp upload_file(file_path, opts) do
    body = {:multipart, (opts |> sign |> Map.to_list) ++ [{:file, file_path}]}
    body |> post(file_path)
  end

  defp upload_url(url, opts) do
    opts
      |> Map.merge(%{file: url})
      |> sign
      |> URI.encode_query
      |> post(url)
  end

  defp post(body, source) do
    {:ok, raw_response} = HTTPoison.request(
      :post,
      "http://api.cloudinary.com/v1_1/#{Settings.get(:cloud_name)}/image/upload",
      body,
      [
        {"Content-Type", "application/x-www-form-urlencoded"},
        {"Accept", "application/json"},
      ]
    )
    {:ok, response} = raw_response.body |> Poison.decode
    response |> handle_response(source)
  end

  defp handle_response(%{"error" => %{"message" => error}}, _source) do
    {:error, error}
  end

  defp handle_response(response, source) do
    {:ok, json_result_to_struct(response, source)}
  end

  defp sign(data) do
    timestamp = current_time

    data_to_sign = data
      |> Map.delete(:file)
      |> Map.merge(%{timestamp: (timestamp <> Settings.get(:secret))})

    signature = data_to_sign
      |> Enum.sort
      |> Enum.map(fn {key, val} -> "#{key}=#{val}" end)
      |> Enum.join("&")
      |> sha

    Map.merge(data, %{
      "timestamp" => timestamp,
      "signature" => signature,
      "api_key" => Settings.get(:api_key)
    })
  end

  defp sha(query) do
    :crypto.hash(:sha, query) |> Base.encode16 |> String.downcase
  end

  defp current_time do
    Time.now
      |> Time.to_seconds
      |> round
      |> Integer.to_string
  end

  @doc """
    Converts the json result from cloudinary to a %UploadedImage{} struct
  """
  def json_result_to_struct(result, source) do
    converted = (result |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)) ++ [source: source]
    struct %UploadedImage{}, converted
  end
end
