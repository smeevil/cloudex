Cloudex
======

Cloudex is an Elixir library that can upload image files or urls to Cloudinary.
There is also a [CLI tool](https://github.com/smeevil/cloudex_cli) available.

## Getting started

```elixir
defp deps do
  [  {:cloudex, "~> 0.0.1"},  ]
end
```

The Cloudex app must be started. This can be done by adding :cloudex to
the applications list in your mix.exs file. An example:

```elixir
  def application do
    [applications: [:logger, :cloudex],
    ]
  end
```

## Settings

Cloudex requires the API credentials of your Cloudinary account.
You can define either as ENV settings using the keys :
```CLOUDEX_API_KEY``` ```CLOUDEX_SECRET``` and  ```CLOUDEX_CLOUD_NAME```

or in your config.exs using :

```elixir
  config :cloudex,
    api_key: "my-api-key",
    secret: "my-secret",
    cloud_name: "my-cloud-name"
```

## Example

For uploading a url :
```elixir
Cloudex.upload("http://example.org/test.jpg")
```

For uploading a file :
```elixir
Cloudex.upload("test/assets/test.jpg")
```
You can also upload a list of files, urls, or mix by giving upload a list like :
```elixir
["test/assets/test.jpg", "http://example.org/test.jpg"]
|> Cloudex.upload
```
The response will be a Cloudex.UploadedImage Struct, or a list of those when you uploaded a list, like :

```elixir
%Cloudex.UploadedImage{
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
}
```
## Documentation

Documentation can be found at docs/index.html or [online](http://smeevil.github.io/cloudex)

## License

The Cloudex Elixir library is released under the DWTFYW license. See the LICENSE file.
