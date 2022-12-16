class Admin::Poll::StreetsController < Admin::Poll::BaseController
  load_and_authorize_resource class: "Poll::Street"

  before_action :set_street, only: [:edit, :update, :destroy]



  def show
    @streets = @streets.search(params[:search])
    @streets = @streets.order(name: :asc).page(params[:page])
  end

  def new
  end

  def create
    @street = Poll::Street.create(street_params)
    if @street.save
      redirect_to admin_streets_path, notice: "Ulica je uspješno dodana."
    else
      redirect_to admin_streets_path, notice: "Dogodila se greška! Pokušajte ponovno."
    end
  end

  def edit
  end

  def update
    if @street.update(street_params)
      redirect_to admin_streets_path, notice: "Ulica je uspješno ažurirana."
    else
      redirect_to admin_streets_path, notice: "Greška prilikom ažuriranja!"
    end
  end

  def destroy
    if @street.delete
      redirect_to admin_streets_path, notice: "Ulica je uspješno obrisana."
    else
      redirect_to admin_streets_path, notice: "Greška prilikom brisanja!."
    end
  end


  private
    def set_street
      @street = Poll::Street.find(params[:id] || params[:format])
    end

    def street_params
      params.require(:poll_street).permit(:name, :county)
    end
end
