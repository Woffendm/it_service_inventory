class ThemesController < ApplicationController
   before_filter :load_theme, :only => [:edit, :update, :destroy]



# View-related methods

  # List of all themes
  def index
     @themes = Theme.order(:name)
  end


  # Page for creating a new theme
  def new
    @theme=Theme.new
  end


  # Page for editing an existing theme
  def edit
  end



# Action-related methods

  # Creates a new theme using the information entered on the "new" page
  def create
    @theme=Theme.new(params[:theme])
    if @theme.save
      redirect_to edit_theme_path(@theme.id)
      return
    end
    render :new
  end


  # Updates a theme based on the information endered on the "edit" page
  def update
    @theme.update_attributes(params[:theme])
    redirect_to edit_theme_path 
  end



  # The selected theme is forced to listen to Justin Beiber until it destroys itself
  def destroy
    @theme.destroy 
    redirect_to themes_path 
  end



# Loading methods

  private
    # Loads a theme based on given parameters
    def load_theme
      @theme=Theme.find(params[:id])
    end
end