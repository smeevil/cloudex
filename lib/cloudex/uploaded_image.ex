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
  * phash
  """

  @type t :: %__MODULE__{
          source: String.t | nil,
          public_id: String.t | nil,
          version: String.t | nil,
          width: non_neg_integer | nil,
          height: non_neg_integer | nil,
          format: String.t | nil,
          created_at: String.t | nil,
          resource_type: String.t | nil,
          tags: [String.t] | [] | nil,
          bytes: non_neg_integer | nil,
          type: String.t | nil,
          etag: String.t | nil,
          url: String.t | nil,
          secure_url: String.t | nil,
          signature: String.t | nil,
          original_filename: String.t | nil,
          phash: String.t | nil
        }

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
            original_filename: nil,
            phash: nil
end
