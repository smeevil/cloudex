defmodule Cloudex.Url do
  @moduledoc "A module that helps creating urls to your cloudinary image, which can optionally transform the image as well."

  @base_url "//res.cloudinary.com"

  @doc """
  Given a cloudinary public id string, this will generate an image url of where the image is hosted.
  You can also pass a map with options to apply transformations to the image, for more information see the documentation.

  ## examples :
  An url to the image at its original dimensions and no transformations

      iex> Cloudex.Url.for("a_public_id")
      "//res.cloudinary.com/my_cloud_name/image/upload/a_public_id"

  An url to the image with just a signature

      iex> Cloudex.Url.for("a_public_id", %{sign_url: true})
      "//res.cloudinary.com/my_cloud_name/image/upload/s--MXxhpIBQ--/a_public_id"

  An url to the image adjusted to a specific width and height

      iex> Cloudex.Url.for("a_public_id", %{width: 400, height: 300})
      "//res.cloudinary.com/my_cloud_name/image/upload/h_300,w_400/a_public_id"

  An url to the image using multiple transformation options and a signature

      iex> Cloudex.Url.for("a_public_id", %{crop: "fill", fetch_format: 'auto', flags: 'progressive', width: 300, height: 254, quality: "jpegmini", sign_url: true})
      "//res.cloudinary.com/my_cloud_name/image/upload/s--jwB_Ds4w--/c_fill,f_auto,fl_progressive,h_254,q_jpegmini,w_300/a_public_id"

  An url to the image using a named transformation

      iex> Cloudex.Url.for("a_public_id", %{transformation: "my_transformation"})
      "//res.cloudinary.com/my_cloud_name/image/upload/t_my_transformation/a_public_id"

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

  An url to the resource type with a named transformation.

      iex> Cloudex.Url.for("a_public_id", %{resource_type: "video", transformation: "my_transformation"})
      "//res.cloudinary.com/my_cloud_name/video/upload/t_my_transformation/a_public_id"

  An url with an overlay
      iex> Cloudex.Url.for("a_public_id", [
      ...>   %{border: "5px_solid_rgb:c22c33", radius: 5, crop: "fill", height: 246, width: 470, quality: 80},
      ...>   %{overlay: "my_overlay", crop: "scale", gravity: "south_east", width: 128 ,x: 5, y: 15}
      ...> ])
      "//res.cloudinary.com/my_cloud_name/image/upload/bo_5px_solid_rgb:c22c33,c_fill,h_246,q_80,r_5,w_470/c_scale,g_south_east,l_my_overlay,w_128,x_5,y_15/a_public_id"

  An url with a face
      iex> Cloudex.Url.for("a_public_id", %{width: 400, height: 300, face: true})
      "//res.cloudinary.com/my_cloud_name/image/upload/g_face,h_300,w_400/a_public_id"


  An url with zoom applied to a face

      iex> Cloudex.Url.for("a_public_id", %{zoom: 1.3, face: true, crop: "crop", version: 1471959066})
      "//res.cloudinary.com/my_cloud_name/image/upload/c_crop,g_face,z_1.3/v1471959066/a_public_id"

  An url retaining aspect ratio

      iex> Cloudex.Url.for("a_public_id", %{aspect_ratio: 2.5, width: 400, height: 300, version: 1471959066})
      "//res.cloudinary.com/my_cloud_name/image/upload/ar_2.5,h_300,w_400/v1471959066/a_public_id"
  """

  @spec for(String.t) :: String.t
  @spec for(String.t, map) :: String.t
  def for(public_id, options \\ %{}) do
    transformations = transformation_string_from(options)

    [
      base_url(),
      resource_type(options),
      "upload",
      signature_for(public_id, options, transformations),
      (if String.length(transformations) > 0, do: transformations),
      version_for(options),
      public_id
    ]
    |> Enum.reject(&(&1 == nil))
    |> Enum.join("/")
    |> append_format(options)
  end

  defp base_url, do: "#{@base_url}/#{Cloudex.Settings.get(:cloud_name)}"

  defp append_format(url, options), do: url <> format(options)

  defp signature_for(public_id, %{sign_url: true}, transformations) do
    to_sign = transformations <> "/#{public_id}" <> Cloudex.Settings.get(:secret)

    signature = :sha
                |> :crypto.hash(to_sign)
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

  defp transformation_string_from(options) when is_list(options) do
    options
    |> Enum.map(&transformation_string_from/1)
    |> Enum.join("/")
  end
  defp transformation_string_from(options) when is_map(options) do
    options
    |> Enum.sort()
    |> process()
    |> join_transformations()
  end

  defp join_transformations([]), do: ""
  defp join_transformations(transformations), do: Enum.join(transformations, ",")

  defp process(options) do
    Enum.reduce(
      options,
      [],
      fn ({key, value}, acc) ->
        acc ++ process_option(key, value)
      end
    )
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
  defp process_option(:rotation, value), do: ["a_#{value}"]
  defp process_option(:face, true), do: ["g_face"]
  defp process_option(_, _), do: []
end
