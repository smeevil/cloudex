defmodule LiveTest do
  use ExUnit.Case
  doctest Cloudex

  test "create a uploaded image from a map" do
    {:ok, data} = Poison.decode(File.read!("./test/cloudinary_response.json"))
    result = Cloudex.CloudinaryApi.Live.json_result_to_struct(data, "http://example.org/test.jpg")
    assert %Cloudex.UploadedImage{
      bytes: 22659,
      created_at: "2015-11-27T10:02:23Z",
      etag: "dbb5764565c1b77ff049d20fcfd1d41d",
      format: "jpg",
      height: 167,
      original_filename: "test",
      public_id: "i2nruesgu4om3w9mtk1z",
      resource_type: "image",
      secure_url: "https://d1vibqt9pdnk2f.cloudfront.net/image/upload/v1448618543/i2nruesgu4om3w9mtk1z.jpg",
      signature: "77b447746476c82bb4921fdea62a9227c584974b",
      source: "http://example.org/test.jpg",
      tags: [],
      type: "upload",
      url: "http://images.cloudassets.mobi/image/upload/v1448618543/i2nruesgu4om3w9mtk1z.jpg",
      version: 1448618543,
      width: 250
    } = result
  end
end
