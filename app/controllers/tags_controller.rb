class TagsController < ApplicationController
  def index
    @tags = current_user.tags.order(:name)
    @tag = Tag.new
  end

  def create
    @tag = current_user.tags.build(tag_params)

    if @tag.save
      respond_to do |format|
        format.html { redirect_to tags_path, notice: t("tags.created") }
        format.turbo_stream
      end
    else
      redirect_to tags_path, alert: @tag.errors.full_messages.to_sentence
    end
  end

  def destroy
    @tag = current_user.tags.find(params[:id])
    @tag.destroy
    redirect_to tags_path, notice: t("tags.deleted"), status: :see_other
  end

  private
  def tag_params
    params.require(:tag).permit(:name)
  end
end
