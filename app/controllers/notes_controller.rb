class NotesController < ApplicationController
  include Pagy::Backend

  before_action :set_note, only: %i[show edit update destroy pin unpin archive unarchive update_position]
  before_action :authorize_note, only: %i[edit update destroy pin unpin archive unarchive update_position]

  def index
    @pinned_notes = current_user.notes.active.pinned.includes(:user, :tags, :rich_text_content)
    @unpinned_notes = current_user.notes.active.unpinned.includes(:user, :tags, :rich_text_content)
    @shared_notes = current_user.notes_shared_with_me.active.includes(:user, :tags, :rich_text_content)
  end

  def archived
    @archived_notes = current_user.notes.archived.order(archived_at: :desc).includes(:tags, :rich_text_content)
  end

  def show
    respond_to do |format|
      format.html { redirect_to edit_note_path(@note) }
      format.turbo_stream { redirect_to edit_note_path(@note) }
    end
  end

  def new
    @note = current_user.notes.build
  end

  def create
    @note = current_user.notes.build(note_params)
    prepend_note_position

    if @note.save
      respond_to do |format|
        format.html { redirect_to notes_path, notice: t("notes.created") }
        format.turbo_stream
        format.json { render json: { id: @note.id }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    acquire_lock
  end

  def update
    capture_previous_values_for_version if should_create_version?

    if @note.update(note_params)
      create_version if @previous_values
      respond_to do |format|
        format.html { redirect_to notes_path, notice: t("notes.updated") }
        format.turbo_stream
        format.json { render json: { id: @note.id }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    unless @note.archived?
      redirect_to notes_path, alert: t("notes.must_archive_first")
      return
    end

    @note.destroy
    respond_to do |format|
      format.html { redirect_to archived_notes_path, notice: t("notes.deleted"), status: :see_other }
      format.turbo_stream
    end
  end

  def pin
    # Shift pinned notes and place this at the beginning
    current_user.notes.active.pinned.update_all("position = position + 1")
    @note.update!(pinned: true, position: 0)
    load_notes_for_list
    respond_to do |format|
      format.html { redirect_to notes_path, status: :see_other }
      format.turbo_stream
    end
  end

  def unpin
    # Shift unpinned notes and place this at the beginning
    current_user.notes.active.unpinned.update_all("position = position + 1")
    @note.update!(pinned: false, position: 0)
    load_notes_for_list
    respond_to do |format|
      format.html { redirect_to notes_path, status: :see_other }
      format.turbo_stream
    end
  end

  def archive
    @note.archive!
    load_notes_for_list
    respond_to do |format|
      format.html { redirect_to notes_path, notice: t("notes.archived"), status: :see_other }
      format.turbo_stream
    end
  end

  def unarchive
    @note.unarchive!
    load_archived_notes
    respond_to do |format|
      format.html { redirect_to archived_notes_path, notice: t("notes.unarchived"), status: :see_other }
      format.turbo_stream
    end
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

  def prepend_note_position
    # Shift all unpinned notes down and place new note at position 0
    current_user.notes.active.unpinned.update_all("position = position + 1")
    @note.position = 0
  end

  def next_pinned_position
    # Shift all pinned notes down and return position 0 for new pinned note
    current_user.notes.active.pinned.update_all("position = position + 1")
    0
  end

  def should_create_version?
    return false unless @note.content.present?

    last_version = @note.versions.ordered.first
    return true unless last_version

    last_version.created_at < 5.minutes.ago
  end

  def capture_previous_values_for_version
    @previous_values = {
      title: @note.title,
      content: @note.content&.to_plain_text,
      color: @note.color
    }
  end

  def create_version
    @note.versions.create!(
      user: current_user,
      change_type: "edit",
      title: @note.title,
      content: @note.content&.to_plain_text,
      color: @note.color,
      previous_title: @previous_values[:title],
      previous_content: @previous_values[:content],
      previous_color: @previous_values[:color]
    )
  end

  def load_notes_for_list
    @pinned_notes = current_user.notes.active.pinned.includes(:tags, :rich_text_content)
    @unpinned_notes = current_user.notes.active.unpinned.includes(:tags, :rich_text_content)
  end

  def load_archived_notes
    @archived_notes = current_user.notes.archived.order(archived_at: :desc).includes(:tags, :rich_text_content)
  end
end
