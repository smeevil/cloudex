defmodule Cloudex.Url do
  @moduledoc "A module that helps creating urls to your cloudinary image, which can optionally transform the image as well."

  alias Cloudex.Settings
  @base_url "//res.cloudinary.com"

  @spec for(String.t) :: String.t
  @spec for(String.t, Map.t) :: String.t
  @doc """
Given a cloudinary public id string, this will generate an image url of where the image is hosted.
You can also pass a map with options to apply transformations to the image, for more information see the documentation.

## examples :
An url to the image at its original dimensions and no transformations

      iex> Cloudex.Url.for("a_public_id")
      "//res.cloudinary.com/my_cloud_name/image/upload/a_public_id"

An url to the image adjusted to a specific width and height

      iex> Cloudex.Url.for("a_public_id", %{width: 400, height: 300})
      "//res.cloudinary.com/my_cloud_name/image/upload/h_300,w_400/a_public_id"

An url to the image using multiple transformation options and a signature

      iex> Cloudex.Url.for("a_public_id", %{crop: "fill", fetch_format: 'auto', flags: 'progressive', width: 300, height: 254, quality: "jpegmini", sign_url: true})
      "//res.cloudinary.com/my_cloud_name/image/upload/s--jwB_Ds4w--/c_fill,f_auto,fl_progressive,h_254,q_jpegmini,w_300/a_public_id"

  An url to a specific version of the image

      iex> Cloudex.Url.for("a_public_id", %{version: 1471959066})
      "//res.cloudinary.com/my_cloud_name/image/upload/v1471959066/a_public_id"

  An url to a specific version of the image adjusted to a specific width and height

      iex> Cloudex.Url.for("a_public_id", %{width: 400, height: 300, version: 1471959066})
      "//res.cloudinary.com/my_cloud_name/image/upload/h_300,w_400/v1471959066/a_public_id"

  An url to the image with the file extension of the requested delivery format for the resource. The resource is delivered in the original uploaded format if the file extension is not included.

      iex> Cloudex.Url.for("a_public_id", %{format: "png"})
      "//res.cloudinary.com/my_cloud_name/image/upload/a_public_id.png"

  An url to the resource type.  If resource type not specified, "image" is the default

      iex> Cloudex.Url.for("a_public_id", %{resource_type: "video"})
      "//res.cloudinary.com/my_cloud_name/video/upload/a_public_id"
  """

  def for(public_id, options \\ %{}) do
    transformations = transformation_string_from(options)
    [base_url(), resource_type(options), "upload", signature_for(public_id, options, transformations), transformations, version_for(options), public_id]
    |> Enum.reject(fn (x) -> x == nil end)
    |> Enum.join("/")
    |> append_format(options)
  end

  defp base_url do
    "#{@base_url}/#{Settings.get(:cloud_name)}"
  end

  defp append_format(url, options) do
    url <> format(options)
  end

  defp signature_for(public_id, %{sign_url: true}, transformations) do
    to_sign = transformations <> "/#{public_id}" <> Settings.get(:secret)
    signature = :crypto.hash(:sha, to_sign)
    |> Base.encode64
    |> String.slice(0..7)
    |> String.replace("+", "-")
    |> String.replace("/", "_")
    "s--" <> signature <> "--"
  end

  defp signature_for(_, _, _), do: nil

  defp version_for(%{version: version}) when is_integer(version), do: "v#{version}"
  defp version_for(_), do: nil

  defp resource_type(%{resource_type: resource_type}), do: to_string(resource_type)
  defp resource_type(_), do: "image"

  defp format(%{format: format}), do: ".#{format}"
  defp format(_), do: ""

  defp transformation_string_from(%{} = options) do
    options
    |> Enum.sort
    |> process
    |> join_transformations
  end

  defp join_transformations([]), do: nil
  defp join_transformations(transformations) do
    Enum.join(transformations, ",")
  end

  defp process(options) do
    Enum.reduce(options, [], fn({key, value}, acc) ->
      acc ++ process_option(key, value)
    end)
  end

  defp process_option(:width, value), do: ["w_#{value}"]
  defp process_option(:height, value), do: ["h_#{value}"]
  defp process_option(:crop, value), do: ["c_#{value}"]
  defp process_option(:aspect_ratio, value), do: ["ar_#{value}"]
  defp process_option(:gravity, value), do: ["g_#{value}"]
  defp process_option(:zoom, value), do: ["z_#{value}"]
  defp process_option(:x, value), do: ["x_#{value}"]
  defp process_option(:y, value), do: ["y_#{value}"]
  defp process_option(:fetch_format, value), do: ["f_#{value}"]
  defp process_option(:quality, value), do: ["q_#{value}"]
  defp process_option(:radius, value), do: ["r_#{value}"]
  defp process_option(:effect, value), do: ["e_#{value}"]
  defp process_option(:opacity, value), do: ["o_#{value}"]
  defp process_option(:border, value), do: ["bo_#{value}"]
  defp process_option(:overlay, value), do: ["l_#{value}"]
  defp process_option(:underlay, value), do: ["u_#{value}"]
  defp process_option(:default_image, value), do: ["d_#{value}"]
  defp process_option(:delay, value), do: ["dl_#{value}"]
  defp process_option(:color, value), do: ["c_#{value}"]
  defp process_option(:coulor, value), do: ["c_#{value}"]
  defp process_option(:dpr, value), do: ["dpr_#{value}"]
  defp process_option(:density, value), do: ["dn_#{value}"]
  defp process_option(:flags, value), do: ["fl_#{value}"]
  defp process_option(:transformation, value), do: ["t_#{value}"]
  defp process_option(_, _), do: []
end
