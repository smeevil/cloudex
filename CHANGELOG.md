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
