defmodule CloudexTest do
  use ExUnit.Case
  doctest Cloudex

  test "file not found" do
    assert [{:error, "File /non/existing/file.jpg does not exist."}] = Cloudex.upload("/non/existing/file.jpg")
  end

  test "upload image file" do
    assert [{:ok, %Cloudex.UploadedImage{}}] = Cloudex.upload("test/assets/test.jpg")
  end

  test "upload multiple image files" do
    assert [
      {:ok, %Cloudex.UploadedImage{}},
      {:ok, %Cloudex.UploadedImage{}},
      {:ok, %Cloudex.UploadedImage{}}
    ] = Cloudex.upload("test/assets/multiple")
  end

  test "upload image url" do
    assert [{:ok, %Cloudex.UploadedImage{}}] = Cloudex.upload("http://example.org/example.jpg")
  end

  test "mixed files / urls" do
    assert  [
      {:ok, %Cloudex.UploadedImage{}},
      {:ok, %Cloudex.UploadedImage{}},
      {:error, "File nonexistent.png does not exist."}
    ] = Cloudex.upload(["./test/assets/test.jpg", "nonexistent.png", "http://example.org/images/cat.jpg"])
  end

  test "upload with tags" do
    tags = ["foo", "bar"]
    [
      {:ok, %Cloudex.UploadedImage{tags: ^tags}}
    ] = Cloudex.upload(["./test/assets/test.jpg"], %{tags: Enum.join(tags, ",")})
  end
end
