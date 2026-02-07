class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :load_post_with_associations, only: [:show]
  before_action :authenticate_user!, except: [:index, :show]

  # GET /posts or /posts.json
  def index
    @posts = Rails.cache.fetch('posts_index', expires_in: 5.minutes) do
      Post.includes(:user, image_attachment: :blob)
          .order(created_at: :desc)
          .to_a
    end
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = current_user.posts.build(post_params)

    respond_to do |format|
      if @post.save
        Rails.cache.delete('posts_index')
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        Rails.cache.delete('posts_index')
        Rails.cache.delete("post_#{@post.id}")
        format.html { redirect_to @post, notice: "Post was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!
    Rails.cache.delete('posts_index')
    Rails.cache.delete("post_#{@post.id}")

    respond_to do |format|
      format.html { redirect_to posts_path, notice: "Post was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    
    def set_post
      # Simple find for edit/update/destroy
      @post = Post.find(params[:id])
    end

    def load_post_with_associations
      # Cache with all associations only for show action
      @post = Rails.cache.fetch("post_#{params[:id]}", expires_in: 10.minutes) do
        Post.includes(:user, { comments: :user }, :likes, { image_attachment: :blob })
          .find(params[:id])
      end
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :content, :image)
    end
end
