defmodule Cloudex.UploadedVideo do
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
  * audio
  * video
  * frame_rate
  * bit_rate
  * duration
  """

  @type t :: %__MODULE__{
          audio: map() | %{},
          bit_rate: non_neg_integer | nil,
          bytes: non_neg_integer | nil,
          created_at: String.t() | nil,
          duration: float() | nil,
          etag: String.t() | nil,
          format: String.t() | nil,
          frame_rate: String.t() | nil,
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
          video: map() | %{},
          width: non_neg_integer | nil,
          context: struct | nil
        }

  defstruct audio: %{},
            bit_rate: nil,
            bytes: nil,
            created_at: nil,
            duration: nil,
            etag: nil,
            format: nil,
            frame_rate: nil,
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
            video: %{},
            width: nil,
            context: nil
end
