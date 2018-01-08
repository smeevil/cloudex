## 1.1.0 (2018-01-08)
- Thanks @angelikatyborska for adding Phash support to detect duplicate images

## 1.0.1 (2017-11-27)
- Thanks @joshsmith for fixing some dialyzer errors and adding a proper type for Cloudex.UploadedImage

## 1.0.0 (2017-10-17)
- Breaking change : When uploading a single file or url you will no
  longer get a `[{:ok, %Cloudex.UploadedImage{}}]` but just a tuple like
  `{:ok, %Cloudex.UploadedImage{}}`, uploading multiple files/urls will
  return a list of tuples just like it already did.
- Increased test coverage

## 0.2.2 (2017-10-16)
- bumped specs

## 0.2.1 (2017-10-06)
- Enforced strict checking of dialyzer

## 0.2.0 (2017-10-03)
- minor version bump
- Clean up and reformatting of code
- added specs and dialyzed
- Removed unnecessary complicated api split from live and test
- Its no longer needed to add `config :cloudex, :cloudinary_api,
  Cloudex.CloudinaryApi` in you config
- Added VCR test actually test real responses from the live api

## 0.1.20 (2017-08-29)
Thanks @Tyler-pierce for adding support to rotate images

## 0.1.19 (2017-07-10)
Thanks @nbancajas for fixing signing bug when appending secret

## 0.1.18 (2017-07-05)
Thanks @dkln for added the g_face option

## 0.1.17 (2017-04-12)
You can add multiple effects using Cloudex.Url.for/2, an example would be adding an overlay to your image, using:

```
Cloudex.Url.for("a_public_id", [
  %{border: "5px_solid_rgb:c22c33", radius: 5, crop: "fill", height: 246, width: 470, quality: 80},
  %{overlay: "my_overlay", crop: "scale", gravity: "south_east", width: 128 ,x: 5, y: 15}
])

"//res.cloudinary.com/my_cloud_name/image/upload/bo_5px_solid_rgb:c22c33,c_fill,h_246,q_80,r_5,w_470/c_scale,g_south_east,l_my_overlay,w_128,x_5,y_15/a_public_id"
```

## 0.1.16 (2017-04-03)
Thanks to @sudostack for fixing a bug when not passing a transformation string and using signed_urls
- Bumped deps

## 0.1.15 (2017-01-16)
Thanks to @pauloancheta you can now also delete a list with ```Cloudex.delete/1```

## 0.1.13 (2017-01-09)
Thanks to @pauloancheta its now possible to also delete image given their public id using ```Cloudex.delete/1```

- bumped deps
- fixed deprecation warnings for elixir 1.4


## 0.1.12 (2016-11-24)
@remiq added support for tags. Quite appreciated :)

## 0.1.11 (2016-10-25)
@jprincipe added support for video urls. Thank you !

Also bumped dependencies.

## 0.1.10 (2016-08-26)
@bgeihsgt (Thanks!) added the following changes :

Whenever an HTTPoison call failed, it would fail with a match error.
This uses with goodness to bubble up request or JSON parsing errors.

I also increased the task timeout on upload to 60 seconds.


## 0.1.9 (2016-08-23)
Cloudex.Url.for now accepts a version as well, thank you @manukall
bumped deps

## 0.1.8 (2016-08-19)
Removed the file and url extension check as requested.
It is not the responsibility of this lib.

## 0.1.7 (2016-08-17)
The file extension regex is now case insensitive

## 0.1.6 (2016-08-16)
keys for upload opts (like "folder") need to be binaries. sorting however puts atoms before binaries, so signing did not work in such cases. Thank you @manukall!

## 0.1.5 (2016-08-11)
bumped deps

## 0.1.4 (2016-07-13)
updated timex dep

## 0.1.3 (2016-07-13)
allow uploading images from https urls, thank you @manukall !

## 0.1.2 (2016-06-27)
Bumped dependencies

## 0.1.1 (2016-06-21)
added timex to the applications list to allow for exrm releases (@manukall)

## 0.1.0 (2016-06-21)
Features:
  - You can now pass %{public_id: "my_public_id"} as options to the cloudinary upload, thanks @manukall !

## 0.0.2 (2016-03-24)

Features:
  - Added a url generator Cloudex.Url.for(public_id, options)
  - Added example of a Phoenix Helper

## 0.0.1 (2016-03-24)

  - Initial commit
