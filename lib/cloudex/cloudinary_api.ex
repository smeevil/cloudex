defmodule Cloudex.CloudinaryApi do
  @moduledoc "Defines behaviour of the API implementation of Cloudinary"
  @callback upload(item :: String.t, opts :: map) :: {:ok, %Cloudex.UploadedImage{}}
  @callback upload({:ok, item :: String.t}, opts :: map) :: {:ok, %Cloudex.UploadedImage{}}
end
