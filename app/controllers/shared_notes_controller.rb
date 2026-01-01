class SharedNotesController < ApplicationController
  def index
    @shared_notes = current_user.notes_shared_with_me
      .includes(:user, :tags, :rich_text_content)
      .order(updated_at: :desc)
  end
end
