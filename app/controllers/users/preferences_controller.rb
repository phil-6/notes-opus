module Users
  class PreferencesController < ApplicationController
    def update
      current_user.update!(dark_mode: params[:dark_mode])
      head :ok
    end
  end
end
