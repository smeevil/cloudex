defmodule Cloudex.EnvOptionsTest do
  use ExUnit.Case, async: true

  setup do
    previous = System.get_env("CLOUDEX_API_KEY")

    on_exit(fn ->
      if previous == nil do
        System.delete_env("CLOUDEX_API_KEY")
      else
        System.put_env("CLOUDEX_API_KEY", previous)
      end
    end)

    :ok
  end

  test "it can merge options merge" do
    System.put_env("CLOUDEX_API_KEY", "TEST_API_KEY")

    assert %{api_key: "TEST_API_KEY", foo: "bar"} =
             Cloudex.EnvOptions.merge(%{foo: "bar", api_key: nil})
  end
end
