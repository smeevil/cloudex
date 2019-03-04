Cloudex
======
![](https://img.shields.io/hexpm/v/cloudex.svg) ![](https://img.shields.io/hexpm/dt/cloudex.svg) ![](https://img.shields.io/hexpm/dw/cloudex.svg) ![](https://img.shields.io/coveralls/smeevil/cloudex.svg) ![](https://img.shields.io/github/issues/smeevil/cloudex.svg) ![](https://img.shields.io/github/issues-pr/smeevil/cloudex.svg) ![](https://semaphoreci.com/api/v1/smeevil/cloudex/branches/master/shields_badge.svg)

Cloudex is an Elixir library that can upload image files or urls to Cloudinary.
There is also a [CLI tool](https://github.com/smeevil/cloudex_cli) available.

## Getting started

```elixir
defp deps do
  [  {:cloudex, "~> 1.2.1"},  ]
end
```

If you are using elixir 1.4, you can skip this step.
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

## Uploading
You can upload image files or urls pointing to an image as follows :

### example
For uploading a url :
```elixir
iex> Cloudex.upload("http://example.org/test.jpg")
{:ok, %Cloudex.UploadedImage{...}}
```

For uploading a file :
```elixir
iex> Cloudex.upload("test/assets/test.jpg")
{:ok, %Cloudex.UploadedImage{...}}
```
You can also upload a list of files, urls, or mix by giving upload a list like :
```elixir
iex> Cloudex.upload(["/non/existing/file.jpg", "http://example.org/test.jpg"])
[{:error, "File /non/existing/file.jpg does not exist."}, {:ok, %Cloudex.UploadedImage{...}}]
```

An example of the %Cloudex.UploadedImage{} Struct looks as follows:

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

You can tag uploaded images with strings:

```elixir
# as array
Cloudex.upload("test/assets/test.jpg", %{tags: ["foo", "bar"]})
# as comma-separated string
Cloudex.upload("test/assets/test.jpg", %{tags: "foo,bar"})

# result
{:ok, %Cloudex.UploadedImage{
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
    tags: ["foo", "bar"],
    type: "upload",
    url: "http://images.cloudassets.mobi/image/upload/v1448618543/i2nruesgu4om3w9mtk1z.jpg",
    version: 1448618543,
    width: 250
}}
```

List of additional parameters you can use with `upload/2`:
http://cloudinary.com/documentation/image_upload_api_reference#upload

## Cloudinary URL generation

This package also provides an helper to generate urls from cloudinary given a public id of the image.
As a second argument you can pass in options to transform your image according via cloudinary.

Current supported options are :
```
  :aspect_ratio
  :border
  :color
  :coulor
  :crop
  :default_image
  :delay
  :density
  :dpr
  :effect
  :fetch_format
  :flags
  :gravity
  :height
  :opacity
  :overlay
  :quality
  :radius
  :transformation
  :underlay
  :width
  :x
  :y
  :zoom
```
### Example
```
Cloudex.Url.for("a_public_id")
"//res.cloudinary.com/my_cloud_name/image/upload/a_public_id"
```

```
Cloudex.Url.for("a_public_id", %{width: 400, height: 300})
"//res.cloudinary.com/my_cloud_name/image/upload/h_300,w_400/a_public_id"
```

```
Cloudex.Url.for("a_public_id", %{crop: "fill", fetch_format: 'auto', flags: 'progressive', width: 300, height: 254, quality: "jpegmini", sign_url: true})
"//res.cloudinary.com/my_cloud_name/image/upload/s--jwB_Ds4w--/c_fill,f_auto,fl_progressive,h_254,q_jpegmini,w_300/a_public_id"
```

You can add multiple effects using Cloudex.Url.for/2, an example would be adding an overlay to your image, using:
```
Cloudex.Url.for("a_public_id", [
  %{border: "5px_solid_rgb:c22c33", radius: 5, crop: "fill", height: 246, width: 470, quality: 80},
  %{overlay: "my_overlay", crop: "scale", gravity: "south_east", width: 128 ,x: 5, y: 15}
])
"//res.cloudinary.com/my_cloud_name/image/upload/bo_5px_solid_rgb:c22c33,c_fill,h_246,q_80,r_5,w_470/c_scale,g_south_east,l_my_overlay,w_128,x_5,y_15/a_public_id"
```
## Deleting images
You can request deletion from cloudinary using ```Cloudex.delete/1``` function where the first argument should be the public id of the image you want to delete.

### example:
```
iex> Cloudex.delete("public-id-1")
{:ok, %Cloudex.DeletedImage{public_id: "public-id-1"}}

iex> Cloudex.delete(["public-id-1", "public-id-2"])
[
  {:ok, %Cloudex.DeletedImage{public_id: "public-id-1"}},
  {:ok, %Cloudex.DeletedImage{public_id: "public-id-2"}}
]
```



## Phoenix helper
If you are using phoenix, you can create a small helper called for example cl_image_tag
Create a file containing the following :

```elixir
defmodule MyApp.CloudexImageHelper do
  import Phoenix.HTML.Tag

  def cl_image_tag(public_id, options \\ []) do
    transformation_options = %{}
    if Keyword.has_key?(options, :transforms) do
      transformation_options = Map.merge(%{}, options[:transforms])
    end

    image_tag_options = Keyword.delete(options, :transforms)

    defaults = [
      src: Cloudex.Url.for(public_id, transformation_options),
      width: picture.width,
      height: picture.height,
      alt: "image with name #{public_id}"
    ]

    attributes = Keyword.merge(defaults, image_tag_options)

    tag(:img, attributes)
  end
end
```

Then in your ```web.ex``` add the following line in the ```def view``` section:

```elixir
import MyApp.CloudexImageHelper
```

You should now be able to use the helper in your views as follows :

```elixir
cl_image_tag(public_id, class: "thumbnail", transforms: %{opacity: "50", quality: "jpegmini", sign_url: true})
```

## Documentation

Documentation can be found at docs/index.html or [online](http://smeevil.github.io/cloudex)

## License

The Cloudex Elixir library is released under the DWTFYW license. See the LICENSE file.
