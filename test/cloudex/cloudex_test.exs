defmodule CloudexTest do
  use ExUnit.Case
  doctest Cloudex

  test "file not found" do
    assert [{:error, "File /non/existing/file.jpg does not exist."}] = Cloudex.upload("/non/existing/file.jpg")
  end

  test "Ignore if not an image" do
    assert [{:error, "test/assets/test.txt is not an image."}] = Cloudex.upload("test/assets/test.txt")
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

  test "not an image url" do
    assert [{:error, "http://example.org/example.txt is not an image url."}] = Cloudex.upload("http://example.org/example.txt")
  end

  test "upload image url" do
    assert [{:ok, %Cloudex.UploadedImage{}}] = Cloudex.upload("http://example.org/example.jpg")
  end

  test "mixed files / urls" do
    assert  [
      {:ok, %Cloudex.UploadedImage{}},
      {:ok, %Cloudex.UploadedImage{}},
      {:error, "http://example.org/faulty.html is not an image url."},
      {:error, "README.md is not an image."},
      {:error, "File nonexistent.png does not exist."}
    ] = Cloudex.upload(["./test/assets/test.jpg", "nonexistent.png", "README.md", "http://example.org/faulty.html", "http://example.org/images/cat.jpg"])
  end
end

