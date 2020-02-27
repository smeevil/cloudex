defmodule Cloudex.CloudinaryApi do
  @moduledoc """
  The live API implementation for Cloudinary uploading
  """

  @base_url "https://api.cloudinary.com/v1_1/"
  @cloudinary_headers [
    {"Content-Type", "application/x-www-form-urlencoded"},
    {"Accept", "application/json"}
  ]

  @json_library Application.get_env(:cloudex, :json_library, Jason)

  @doc """
  Upload either a file or url to cloudinary
  `opts` can contain:
    %{resource_type: "video"}
  which will cause a video upload to occur.
  returns {:ok, %UploadedFile{}} containing all the information from cloudinary
  or {:error, "reason"}
  """
  @spec upload(String.t() | {:ok, String.t()}, map) ::
          {:ok, Cloudex.UploadedImage.t()} | {:error, any}
  def upload(item, opts \\ %{})
  def upload({:ok, item}, opts) when is_binary(item), do: upload(item, opts)

  def upload(item, opts) when is_binary(item) do
    case item do
      "http://" <> _rest -> upload_url(item, opts)
      "https://" <> _rest -> upload_url(item, opts)
      "s3://" <> _rest -> upload_url(item, opts)
      _ -> upload_file(item, opts)
    end
  end

  def upload(invalid_item, _opts) do
    {
      :error,
      "Upload/1 only accepts a String.t or {:ok, String.t}, received: #{inspect(invalid_item)}"
    }
  end

  @doc """
  Deletes an image given a public id
  """
  @spec delete(String.t(), map) :: {:ok, %Cloudex.DeletedImage{}} | {:error, any}
  def delete(item, opts \\ %{})

  def delete(item, opts) when is_bitstring(item) do
    case delete_file(item, opts) do
      {:ok, _} -> {:ok, %Cloudex.DeletedImage{public_id: item}}
      error -> error
    end
  end

  def delete(invalid_item, _opts) do
    {:error, "delete/1 only accepts valid public id, received: #{inspect(invalid_item)}"}
  end

  @doc """
  Deletes images given their prefix
  """
  @spec delete_prefix(String.t(), map) :: {:ok, String.t()} | {:error, any}
  def delete_prefix(prefix, opts \\ %{})

  def delete_prefix(prefix, opts) when is_bitstring(prefix) do
    case delete_by_prefix(prefix, opts) do
      {:ok, _} -> {:ok, prefix}
      error -> error
    end
  end

  def delete_prefix(invalid_prefix, _opts) do
    {:error, "delete_prefix/1 only accepts a valid prefix, received: #{inspect(invalid_prefix)}"}
  end

  @doc """
    Converts the json result from cloudinary to a %UploadedImage{} struct
  """
  @spec json_result_to_struct(map, String.t()) :: %Cloudex.UploadedImage{}
  def json_result_to_struct(result, source) do
    converted = Enum.map(result, fn {k, v} -> {String.to_atom(k), v} end) ++ [source: source]
    struct(%Cloudex.UploadedImage{}, converted)
  end

  @spec upload_file(String.t(), map) :: {:ok, %Cloudex.UploadedImage{}} | {:error, any}
  defp upload_file(file_path, opts) do
    options =
      opts
      |> extract_cloudinary_opts
      |> prepare_opts
      |> sign
      |> unify
      |> Map.to_list()

    body = {:multipart, [{:file, file_path} | options]}

    post(body, file_path, opts)
  end

  @spec extract_cloudinary_opts(map) :: map
  defp extract_cloudinary_opts(opts) do
    Map.delete(opts, :resource_type)
  end

  @spec upload_url(String.t(), map) :: {:ok, %Cloudex.UploadedImage{}} | {:error, any}
  defp upload_url(url, opts) do
    opts
    |> Map.merge(%{file: url})
    |> prepare_opts
    |> sign
    |> URI.encode_query()
    |> post(url, opts)
  end

  defp credentials do
    [
      hackney: [
        basic_auth: {Cloudex.Settings.get(:api_key), Cloudex.Settings.get(:secret)}
      ]
    ]
  end

  @spec delete_file(bitstring, map) ::
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
          | {:error, HTTPoison.Error.t()}
  defp delete_file(item, opts) do
    HTTPoison.delete(delete_url_for(opts, item), @cloudinary_headers, credentials())
  end

  defp delete_url_for(%{resource_type: resource_type}, item), do: delete_url(resource_type, item)
  defp delete_url_for(_, item), do: delete_url("image", item)

  defp delete_url(resource_type, item) do
    "#{@base_url}#{Cloudex.Settings.get(:cloud_name)}/resources/#{resource_type}/upload?public_ids[]=#{
      item
    }"
  end

  @spec delete_file(bitstring, map) ::
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
          | {:error, HTTPoison.Error.t()}
  defp delete_by_prefix(prefix, opts) do
    HTTPoison.delete(delete_prefix_url_for(opts, prefix), @cloudinary_headers, credentials())
  end

  defp delete_prefix_url_for(%{resource_type: resource_type}, prefix) do
    delete_prefix_url(resource_type, prefix)
  end

  defp delete_prefix_url_for(_, prefix), do: delete_prefix_url("image", prefix)

  defp delete_prefix_url(resource_type, prefix) do
    "#{@base_url}#{Cloudex.Settings.get(:cloud_name)}/resources/#{resource_type}/upload?prefix=#{
      prefix
    }"
  end

  @spec post(tuple | String.t(), binary, map) :: {:ok, %Cloudex.UploadedImage{}} | {:error, any}
  defp post(body, source, opts) do
    with {:ok, raw_response} <- common_post(body, opts),
         {:ok, response} <- @json_library.decode(raw_response.body),
         do: handle_response(response, source)
  end

  defp common_post(body, opts) do
    HTTPoison.request(:post, url_for(opts), body, @cloudinary_headers, credentials())
  end

  defp context_to_list(context) do
    context
    |> Enum.reduce([], fn {k, v}, acc -> acc ++ ["#{k}=#{v}"] end)
    |> Enum.join("|")
  end

  @spec prepare_opts(map | list) :: map

  defp prepare_opts(%{context: context, tags: tags} = opts) when is_list(tags),
    do: %{opts | context: context_to_list(context), tags: Enum.join(tags, ",")}

  defp prepare_opts(%{tags: tags} = opts) when is_list(tags),
    do: %{opts | tags: Enum.join(tags, ",")}

  defp prepare_opts(%{context: context} = opts) when is_map(context),
    do: %{opts | context: context_to_list(context)}

  defp prepare_opts(opts), do: opts

  defp url_for(%{resource_type: resource_type}), do: url(resource_type)
  defp url_for(_), do: url("image")

  def url(resource_type) do
    "#{@base_url}#{Cloudex.Settings.get(:cloud_name)}/#{resource_type}/upload"
  end

  @spec handle_response(map, String.t()) :: {:error, any} | {:ok, %Cloudex.UploadedImage{}}
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

    data_without_secret =
      data
      |> Map.drop([:file, :resource_type])
      |> Map.merge(%{"timestamp" => timestamp})
      |> Enum.map(fn {key, val} -> "#{key}=#{val}" end)
      |> Enum.sort()
      |> Enum.join("&")

    signature = sha(data_without_secret <> Cloudex.Settings.get(:secret))

    Map.merge(
      data,
      %{
        "timestamp" => timestamp,
        "signature" => signature,
        "api_key" => Cloudex.Settings.get(:api_key)
      }
    )
  end

  @spec sha(String.t()) :: String.t()
  defp sha(query) do
    :sha
    |> :crypto.hash(query)
    |> Base.encode16()
    |> String.downcase()
  end

  @spec current_time :: String.t()
  defp current_time do
    Timex.now()
    |> Timex.to_unix()
    |> round
    |> Integer.to_string()
  end
end
