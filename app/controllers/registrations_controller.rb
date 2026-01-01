class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: t("registrations.rate_limited") }

  def new
    @user = User.new
    @invitation = find_invitation
    @user.email_address = @invitation.email_address if @invitation
  end

  def create
    @user = User.new(user_params)
    @invitation = find_invitation

    if @user.save
      accept_invitation(@invitation, @user) if @invitation
      start_new_session_for @user
      redirect_to root_path, notice: t("registrations.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :display_name)
  end

  def find_invitation
    return nil unless params[:invitation_token].present?

    Invitation.pending.find_by(token: params[:invitation_token])
  end

  def accept_invitation(invitation, user)
    invitation.accept!(user)
  rescue ActiveRecord::RecordInvalid
    # If connection creation fails, just continue without it
    Rails.logger.warn("Failed to accept invitation #{invitation.id} for user #{user.id}")
  end
end
