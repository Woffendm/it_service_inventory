# This class controls Fiscal Years, which are used for separating allocations into different years
#
# Author: Michael Woffendin 
# Copyright:

class FiscalYearsController < ApplicationController
  
  # View with a list of all current fiscal years, and a form to add additional fiscal years
  def index
    @new_fiscal_year = FiscalYear.new
    @fiscal_years = FiscalYear.order(:year)
  end
  
  
  # Updates a fiscal year's year or active status
  def update
    fiscal_year = FiscalYear.find(params[:id])
    unless fiscal_year.update_attributes(params[:fiscal_year])
      flash[:error] = "Fiscal year already exists"
      render :index
      return
    end
    flash[:notice] = t(:settings) + t(:updated)
    redirect_to fiscal_years_path
  end


  # Creates a new fiscal year
  def create
    if FiscalYear.create(params[:fiscal_year])
      flash[:notice] = "Fiscal year created"
      redirect_to fiscal_years_path
      return
    end
    flash[:error] = "Fiscal year already exists"
    render :index
  end


  # Destroys a fiscal year
  def destroy
    fiscal_year = FiscalYear.find(params[:id])
    fiscal_year.destroy
    flash[:notice] = "Fiscal year deleted"
    redirect_to fiscal_years_path
  end
end
