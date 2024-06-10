class MaintenanceController < ApplicationController
  skip_authorization_check

 def index
  render :index
 end

 def login
  if Setting["maintenance.password"] == params[:password]
    cookies[:maintenance] = {
      value: true,
      expires: 1.day.from_now
    }
    redirect_to root_path
  else
    redirect_to maintenance_path, notice: "Zabranjen pristup. Obratite se administratoru."
  end
 end
end
