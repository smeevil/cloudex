defmodule Cloudex.CloudinaryApi.Live do
  @moduledoc """
  The live API implementation for Cloudinary uploading
  """

  @base_url "https://api.cloudinary.com/v1_1/"
  @cloudinary_headers [{"Content-Type", "application/x-www-form-urlencoded"}, {"Accept", "application/json"}]
  @behaviour Cloudex.CloudinaryApi

  alias Cloudex.UploadedImage
  alias Cloudex.Settings

  def upload(item, opts \\ %{})

  @doc """
  Helper function to enable piping of {:ok, path} tuples into upload
  """
  @spec upload({:ok, item :: String.t}, %{}) :: Cloudex.UploadedImage.t
  def upload({:ok, item}, opts) when is_binary(item) do
    upload(item, opts)
  end

  @doc """
  Upload either a file or url to cloudinary
  returns {:ok, %UploadedFile{}} containing all the information from cloudinary
  or {:error, "reason"}
  """
  @spec upload(item :: String.t, opts :: map) :: Cloudex.UploadedImage.t
  def upload(item, opts)
  def upload(item, opts) when is_binary(item) do
    case item do
      "http://" <> _rest  -> item |> upload_url(opts)
      "https://" <> _rest -> item |> upload_url(opts)
      _                   -> item |> upload_file(opts)
    end
  end

  @doc """
  Catches upload called without a string argument
  """
  def upload(invalid_item, _opts) do
    {:error, "Upload/1 only accepts a String or {:ok, String}, received: #{inspect invalid_item}"}
  end

  @doc """
  Deletes an image given a public id
  """
  def delete(item) when is_bitstring(item) do
    case delete_file(item) do
      {:ok, _} -> {:ok, %Cloudex.DeletedImage{public_id: item}}
      {:error, response} -> {:error, response.body}
    end
  end

  @doc """
  Catches error when public id was invalid
  """
  def delete(invalid_item) do
    {:error, "delete/1 only accepts valid public id, received: #{inspect invalid_item}"}
  end

  defp upload_file(file_path, opts) do
    body = {:multipart, (opts |> prepare_opts |> sign |> unify |> Map.to_list) ++ [{:file, file_path}]}
    body |> post(file_path)
  end

  defp upload_url(url, opts) do
    opts
      |> Map.merge(%{file: url})
      |> prepare_opts
      |> sign
      |> URI.encode_query
      |> post(url)
  end

  defp delete_file(item) do
    options = [hackney: [basic_auth: {Settings.get(:api_key), Settings.get(:secret)}]]
    url = "#{@base_url}#{Settings.get(:cloud_name)}/resources/image/upload?public_ids[]=#{item}"
    HTTPoison.delete(url, @cloudinary_headers, options)
  end

  defp post(body, source) do
    with {:ok, raw_response} <- HTTPoison.request(
      :post,
      "http://api.cloudinary.com/v1_1/#{Settings.get(:cloud_name)}/image/upload",
      body,
      [
        {"Content-Type", "application/x-www-form-urlencoded"},
        {"Accept", "application/json"},
      ]
    ),
    {:ok, response} <- Poison.decode(raw_response.body),
    do: handle_response(response, source)
  end

  defp prepare_opts(%{tags: tags} = opts) when is_list(tags), do: %{opts | tags: Enum.join(tags, ",")}
  defp prepare_opts(opts), do: opts

  defp handle_response(%{"error" => %{"message" => error}}, _source) do
    {:error, error}
  end

  defp handle_response(response, source) do
    {:ok, json_result_to_struct(response, source)}
  end

  @docp """
  Unifies hybrid map into string-only key map.
  ie. `%{a: 1, "b" => 2} => %{"a" => 1, "b" => 2}`
  """
  defp unify(data) do
    data
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.put(acc, "#{k}", v)
      end)
  end

  defp sign(data) do
    timestamp = current_time

    data_to_sign = data
      |> Map.delete(:file)
      |> Map.merge(%{"timestamp" => (timestamp <> Settings.get(:secret))})

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
    Timex.now
      |> Timex.to_unix
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
