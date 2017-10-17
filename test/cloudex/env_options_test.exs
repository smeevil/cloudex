defmodule Cloudex.EnvOptionsTest do
  use ExUnit.Case
  test "it can merge options merge" do
    System.put_env("CLOUDEX_API_KEY", "TEST_API_KEY")
    assert %{api_key: "TEST_API_KEY", foo: "bar"} = Cloudex.EnvOptions.merge(%{foo: "bar", api_key: nil})
  end
end



