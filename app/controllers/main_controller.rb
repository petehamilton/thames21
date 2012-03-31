require 'json'

class MainController < ApplicationController
  def index
  end
  def mobile
    render :layout => "mobile"
  end
end
