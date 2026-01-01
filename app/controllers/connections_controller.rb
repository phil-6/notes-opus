class ConnectionsController < ApplicationController
  def index
    @connections = current_user.connections_as_user.includes(:connected_user)
    @connection = Connection.new
  end

  def create
    connected_user = User.find_by(email_address: params[:email_address])

    if connected_user.nil?
      redirect_to connections_path, alert: t("connections.user_not_found")
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
end
