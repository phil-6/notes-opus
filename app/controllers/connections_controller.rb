class ConnectionsController < ApplicationController
  def index
    @connections = current_user.connections_as_user.includes(:connected_user)
    @pending_invitations = current_user.sent_invitations.pending
    @connection = Connection.new
  end

  def create
    email = params[:email_address]&.strip&.downcase
    connected_user = User.find_by(email_address: email)

    if connected_user.nil?
      # Check if there's already a pending invitation
      existing_invitation = current_user.sent_invitations.pending.find_by(email_address: email)

      if existing_invitation
        redirect_to connections_path, notice: t("connections.invitation_already_sent")
      else
        @invitation = current_user.sent_invitations.build(email_address: email)

        if @invitation.save
          redirect_to connections_path, notice: t("connections.invitation_sent", email: email)
        else
          redirect_to connections_path, alert: @invitation.errors.full_messages.to_sentence
        end
      end
      return
    end

    @connection = current_user.connections_as_user.build(connected_user: connected_user)

    if @connection.save
      redirect_to connections_path, notice: t("connections.created")
    else
      redirect_to connections_path, alert: @connection.errors.full_messages.to_sentence
    end
  end

  def destroy
    @connection = current_user.connections_as_user.find(params[:id])
    @connection.destroy
    redirect_to connections_path, notice: t("connections.removed"), status: :see_other
  end

  def cancel_invitation
    @invitation = current_user.sent_invitations.find(params[:id])
    @invitation.destroy
    redirect_to connections_path, notice: t("connections.invitation_cancelled"), status: :see_other
  end
end
