module Notes
  class VersionsController < ApplicationController
    before_action :set_note
    before_action :authorize_access

    def index
      @versions = @note.versions.includes(:user).ordered
    end

    private
    def set_note
      @note = Note.find(params[:note_id])
    end

    def authorize_access
      unless @note.can_view?(current_user)
        redirect_to notes_path, alert: t("versions.unauthorized")
      end
    end
  end
end
