defmodule Cloudex.CloudinaryApi do
  @moduledoc """
  The live API implementation for Cloudinary uploading
  """

  @base_url "https://api.cloudinary.com/v1_1/"
  @cloudinary_headers [{"Content-Type", "application/x-www-form-urlencoded"}, {"Accept", "application/json"}]

  @doc """
  Upload either a file or url to cloudinary
  returns {:ok, %UploadedFile{}} containing all the information from cloudinary
  or {:error, "reason"}
  """
  @spec upload(String.t | {:ok, String.t}, map) :: {:ok, Cloudex.UploadedImage.t} | {:error, any}
  def upload({:ok, item}, opts) when is_binary(item), do: upload(item, opts)
  def upload(item, opts)
  def upload(item, opts) when is_binary(item) do
    case item do
      "http://" <> _rest -> upload_url(item, opts)
      "https://" <> _rest -> upload_url(item, opts)
      _ -> upload_file(item, opts)
    end
  end
  def upload(invalid_item, _opts) do
    {:error, "Upload/1 only accepts a String.t or {:ok, String.t}, received: #{inspect invalid_item}"}
  end

  @doc """
  Deletes an image given a public id
  """
  @spec delete(String.t) :: {:ok, %Cloudex.DeletedImage{}} | {:error, any}
  def delete(item) when is_bitstring(item) do
    case delete_file(item) do
      {:ok, _} -> {:ok, %Cloudex.DeletedImage{public_id: item}}
      error -> error
    end
  end
  def delete(invalid_item) do
    {:error, "delete/1 only accepts valid public id, received: #{inspect invalid_item}"}
  end

  @doc """
    Converts the json result from cloudinary to a %UploadedImage{} struct
  """
  @spec json_result_to_struct(map, String.t) :: %Cloudex.UploadedImage{}
  def json_result_to_struct(result, source) do
    converted = (Enum.map(result, fn ({k, v}) -> {String.to_atom(k), v} end)) ++ [source: source]
    struct(%Cloudex.UploadedImage{}, converted)
  end

  @spec upload_file(String.t, map) :: {:ok, %Cloudex.UploadedImage{}} | {:error, any}
  defp upload_file(file_path, opts) do
    body = {
      :multipart,
      (
        opts
        |> prepare_opts
        |> sign
        |> unify
        |> Map.to_list) ++ [{:file, file_path}]
    }

    post(body, file_path)
  end

  @spec upload_url(String.t, map) :: {:ok, %Cloudex.UploadedImage{}} | {:error, any}
  defp upload_url(url, opts) do
    opts
    |> Map.merge(%{file: url})
    |> prepare_opts
    |> sign
    |> URI.encode_query
    |> post(url)
  end

  @spec delete_file(bitstring) :: {:ok, %Cloudex.DeletedImage{}} | {:error, %Elixir.HTTPoison.Error{}}
  defp delete_file(item) do
    options = [
      hackney: [
        basic_auth: {Cloudex.Settings.get(:api_key), Cloudex.Settings.get(:secret)}
      ]
    ]
    url = "#{@base_url}#{Cloudex.Settings.get(:cloud_name)}/resources/image/upload?public_ids[]=#{item}"
    HTTPoison.delete(url, @cloudinary_headers, options)
  end

  @spec post(tuple | String.t, binary) :: {:ok, %Cloudex.UploadedImage{}} | {:error, any}
  defp post(body, source) do
    with {:ok, raw_response} <- HTTPoison.request(
      :post,
      "http://api.cloudinary.com/v1_1/#{Cloudex.Settings.get(:cloud_name)}/image/upload",
      body,
      [
        {"Content-Type", "application/x-www-form-urlencoded"},
        {"Accept", "application/json"},
      ]
    ),
         {:ok, response} <- Poison.decode(raw_response.body),
         do: handle_response(response, source)
  end

  @spec prepare_opts(map | list) :: map
  defp prepare_opts(%{tags: tags} = opts) when is_list(tags), do: %{opts | tags: Enum.join(tags, ",")}
  defp prepare_opts(opts), do: opts

  @spec handle_response(map, String.t) :: {:error, any} | {:ok, %Cloudex.UploadedImage{}}
  defp handle_response(
         %{
           "error" => %{
             "message" => error
           }
         },
         _source
       ) do
    {:error, error}
  end
  defp handle_response(response, source) do
    {:ok, json_result_to_struct(response, source)}
  end

  #  Unifies hybrid map into string-only key map.
  #  ie. `%{a: 1, "b" => 2} => %{"a" => 1, "b" => 2}`
  @spec unify(map) :: map
  defp unify(data), do: Enum.reduce(data, %{}, fn {k, v}, acc -> Map.put(acc, "#{k}", v) end)

  @spec sign(map) :: map
  defp sign(data) do
    timestamp = current_time()

    data_without_secret = data
                          |> Map.delete(:file)
                          |> Map.merge(%{"timestamp" => timestamp})
                          |> Enum.map(fn {key, val} -> "#{key}=#{val}" end)
                          |> Enum.sort
                          |> Enum.join("&")

    signature = sha((data_without_secret <> Cloudex.Settings.get(:secret)))

    Map.merge(
      data,
      %{
        "timestamp" => timestamp,
        "signature" => signature,
        "api_key" => Cloudex.Settings.get(:api_key)
      }
    )
  end

  @spec sha(String.t) :: String.t
  defp sha(query) do
    :sha
    |> :crypto.hash(query)
    |> Base.encode16
    |> String.downcase
  end

  @spec current_time :: String.t
  defp current_time do
    Timex.now
    |> Timex.to_unix
    |> round
    |> Integer.to_string
  end
end
