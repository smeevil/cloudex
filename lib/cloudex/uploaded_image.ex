defmodule Cloudex.UploadedImage do
  @moduledoc """
  A simple struct containing all the information from cloudinary.

  * source
  * public_id
  * version
  * signature
  * width
  * hieght
  * format
  * resource_type
  * created_at
  * tags
  * bytes
  * type
  * etag
  * url
  * secure_url
  * original_filename
  """
  defstruct source: nil,
            public_id: nil,
            version: nil,
            signature: nil,
            width: nil,
            height: nil,
            format: nil,
            resource_type: nil,
            created_at: nil,
            tags: nil,
            bytes: nil,
            type: nil,
            etag: nil,
            url: nil,
            secure_url: nil,
            original_filename: nil

end