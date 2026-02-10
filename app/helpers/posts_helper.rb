module PostsHelper
  def post_preview_image(post)
    return unless post.image.attached?

    # Only attempt thumbnail logic in production
    if Rails.env.production?
      original_key = post.image.key
      thumb_key = original_key.gsub(/\Auploads\//, "thumbnails/")

      # Check S3 for the thumbnail
      if ActiveStorage::Blob.service.exist?(thumb_key)
        return ActiveStorage::Blob.service.url(
          thumb_key, 
          expires_in: 1.hour, 
          disposition: :inline,
          filename: post.image.blob.filename,
          content_type: post.image.content_type
        )
      end
    end

    # Fallback for local dev OR if production thumb isn't ready yet
    post.image
  end
end