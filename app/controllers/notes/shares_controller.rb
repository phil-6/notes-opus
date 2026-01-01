module Notes
  class SharesController < ApplicationController
    before_action :set_note
    before_action :authorize_owner

    def create
      shared_with_user = User.find_by(email_address: params[:email_address])

      if shared_with_user.nil?
        redirect_to edit_note_path(@note), alert: t("shares.user_not_found")
        return
      end

      @share = @note.shared_withs.build(
        shared_with_user: shared_with_user,
        can_edit: params[:can_edit] == "1"
      )

      if @share.save
        redirect_to edit_note_path(@note), notice: t("shares.created")
      else
        redirect_to edit_note_path(@note), alert: @share.errors.full_messages.to_sentence
      end
    end

    def destroy
      @share = @note.shared_withs.find(params[:id])
      @share.destroy
      redirect_to edit_note_path(@note), notice: t("shares.removed"), status: :see_other
    end

    private
    def set_note
      @note = Note.find(params[:note_id])
    end

    def authorize_owner
      unless @note.user == current_user
        redirect_to notes_path, alert: t("shares.unauthorized")
      end
    end
  end
end
