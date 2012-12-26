class CommentsController < ApplicationController
  before_filter :get_parent, only: :create
  before_filter :correct_user, only: :destroy
  def new
    @comment = @parent.comments.build
    @comment.user = current_user
    #publish_to_fb if @parent.class.to_s == "Link"
  end

  def show

    @comment = Comment.find_by_id(params[:id])
    @comments = @comment.comments
    respond_to do |format|
      format.html
      format.js
    end
  end

  #def create
      #@comment = @parent.comments.build(params[:comment])
    #if params[:comment][:body]!=''
      #@comment.user = current_user
      #if @comment.save
        #flash[:notice] = "Commented"
        #publish_to_fb if @parent.class.to_s == "Link"
        #redirect_to @parent
      #else
        #redirect_to @parent
      #end
    #else
      #redirect_to @parent 
    #end
  #end

  def create
    @comment = @parent.comments.build(params[:comment])
    if params[:comment][:body]!=''
      @comment.user = current_user
      if @comment.save
        publish_to_fb if @parent.class.to_s == "Link"
      else
        flash[:notice] = "Could not add comment, try again"
      end

    end
      respond_to do |format|
        format.html { redirect_to @parent }
        format.js
       end
  end

  def destroy
    if @comment
      @comment_id = @comment.id
      @comment.destroy
    end
    respond_to do |format|
      format.html { redirect_to @parent }
      format.js 
    end
  end

  protected

  def get_parent
    if params[:val]=="1"     
    @parent = Link.find_by_id(params[:comment_id]) 
    else
    @parent = Comment.find_by_id(params[:comment_id]) 
    end
  end

  def correct_user

    @comment = current_user.comments.find_by_id(params[:id])
    @parent = @comment.commentable       
    redirect_to @parent if @comment.nil?

  end

  def publish_to_fb
  FacebookCommentNotifyWorker.perform_async(current_user.oauth_token, comment_url(@comment), @comment.body) 
  end
end
