defmodule CloudexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.cassette_library_dir("test/assets/vcr_cassettes")
    :ok
  end

  doctest Cloudex

  test "file not found" do
    assert [{:error, "File /non/existing/file.jpg does not exist."}] = Cloudex.upload("/non/existing/file.jpg")
  end

  test "upload image file" do
    use_cassette "test_upload" do
      assert [{:ok, %Cloudex.UploadedImage{}}] = Cloudex.upload("test/assets/test.jpg")
    end
  end

  test "upload multiple image files" do
    use_cassette "multi_upload" do
      assert [
               {:ok, %Cloudex.UploadedImage{}},
               {:ok, %Cloudex.UploadedImage{}},
               {:ok, %Cloudex.UploadedImage{}}
             ] = Cloudex.upload("test/assets/multiple")
    end
  end

  test "upload image url" do
    use_cassette "test_upload_url" do
      assert [{:ok, %Cloudex.UploadedImage{}}] = Cloudex.upload("https://cdn.mhpbooks.com/uploads/2014/10/shutterstock_172896005.jpg")
    end
  end

  test "mixed files / urls" do
    use_cassette "test_upload_mixed" do
      assert  [
                {:ok, %Cloudex.UploadedImage{}},
                {:ok, %Cloudex.UploadedImage{}},
                {:error, "File nonexistent.png does not exist."}
              ] = Cloudex.upload(["./test/assets/test.jpg", "nonexistent.png", "https://cdn.mhpbooks.com/uploads/2014/10/shutterstock_172896005.jpg"])
    end
  end

  test "upload with tags" do
    use_cassette "test_upload_with_tags" do
      tags = ["foo", "bar"]
      [
        {:ok, %Cloudex.UploadedImage{tags: ^tags}}
      ] = Cloudex.upload(["./test/assets/test.jpg"], %{tags: Enum.join(tags, ",")})
      # or simply
      [
        {:ok, %Cloudex.UploadedImage{tags: ^tags}}
      ] = Cloudex.upload(["./test/assets/test.jpg"], %{tags: tags})
    end
  end

  test "delete image with public id" do
    use_cassette "test_delete" do
      assert {:ok, %Cloudex.DeletedImage{public_id: "rurwrndtvgzfajljllnr"}} = Cloudex.delete("rurwrndtvgzfajljllnr")
    end
  end

  test "delete images from a list of public id's" do
    use_cassette "test_delete_list" do
      assert [
               {:ok, %Cloudex.DeletedImage{public_id: "vv7cxdopasmev61rhnzo"}},
               {:ok, %Cloudex.DeletedImage{public_id: "mdqzqlszjmfg9ih5tjsw"}}
             ] = Cloudex.delete(["vv7cxdopasmev61rhnzo", "mdqzqlszjmfg9ih5tjsw"])
    end
  end
end
