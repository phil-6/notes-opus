class NotesController < ApplicationController
  include Pagy::Backend

  before_action :set_note, only: %i[show edit update destroy pin unpin update_position]
  before_action :authorize_note, only: %i[edit update destroy pin unpin update_position]

  def index
    @pinned_notes = current_user.notes.pinned.includes(:tags, :rich_text_content)
    @unpinned_notes = current_user.notes.unpinned.includes(:tags, :rich_text_content)
  end

  def show
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new
    @note = current_user.notes.build
  end

  def create
    @note = current_user.notes.build(note_params)
    @note.position = next_position

    if @note.save
      respond_to do |format|
        format.html { redirect_to notes_path, notice: t("notes.created") }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    acquire_lock
  end

  def update
    if @note.update(note_params)
      respond_to do |format|
        format.html { redirect_to notes_path, notice: t("notes.updated") }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    respond_to do |format|
      format.html { redirect_to notes_path, notice: t("notes.deleted"), status: :see_other }
      format.turbo_stream
    end
  end

  def pin
    @note.update!(pinned: true, position: next_pinned_position)
    redirect_to notes_path, status: :see_other
  end

  def unpin
    @note.update!(pinned: false, position: next_position)
    redirect_to notes_path, status: :see_other
  end

  def update_position
    @note.update!(position: params[:position].to_i)
    head :ok
  end

  private
  def set_note
    @note = Note.find(params[:id])
  end

  def authorize_note
    unless @note.can_edit?(current_user)
      redirect_to notes_path, alert: t("notes.unauthorized")
    end
  end

  def acquire_lock
    if @note.locked? && @note.locked_by != current_user
      redirect_to notes_path, alert: t("notes.locked_by", name: @note.locked_by.display_name)
    else
      @note.lock!(current_user)
    end
  end

  def note_params
    params.require(:note).permit(:title, :content, :color, tag_ids: [])
  end

  def next_position
    (current_user.notes.unpinned.maximum(:position) || 0) + 1
  end

  def next_pinned_position
    (current_user.notes.pinned.maximum(:position) || 0) + 1
  end
end
