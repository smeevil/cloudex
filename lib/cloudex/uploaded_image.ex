defmodule Cloudex.UploadedImage do
  @moduledoc """
  A simple struct containing all the information from cloudinary.

  * source
  * public_id
  * version
  * signature
  * width
  * height
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
          bytes: non_neg_integer | nil,
          created_at: String.t() | nil,
          etag: String.t() | nil,
          format: String.t() | nil,
          height: non_neg_integer | nil,
          moderation: [String.t()] | [] | nil,
          original_filename: String.t() | nil,
          phash: String.t() | nil,
          public_id: String.t() | nil,
          resource_type: String.t() | nil,
          secure_url: String.t() | nil,
          signature: String.t() | nil,
          source: String.t() | nil,
          tags: [String.t()] | [] | nil,
          type: String.t() | nil,
          url: String.t() | nil,
          version: String.t() | nil,
          width: non_neg_integer | nil,
          context: struct | nil
        }

  defstruct bytes: nil,
            created_at: nil,
            etag: nil,
            format: nil,
            height: nil,
            moderation: nil,
            original_filename: nil,
            phash: nil,
            public_id: nil,
            resource_type: nil,
            secure_url: nil,
            signature: nil,
            source: nil,
            tags: nil,
            type: nil,
            url: nil,
            version: nil,
            width: nil,
            context: nil
end
