require 'json'

class TreasuresController < ApplicationController

  def index
    max_distance = 500000
    max_results = 20

    location = {lat: params[:lat].to_f, lon: params[:lon].to_f, radius: (params[:radius] || max_distance).to_i}

    # @treasures = Treasure.find_treasures_sorted(location[:lat],
    #                                             location[:lon],
    #                                             location[:radius],
    #                                             params[:sort],
    #                                             (params[:max_results] || max_results).to_i)

    @treasures = Treasure.all
    # raise @treasures[0].to_json
    respond_to do |format|
      format.html # index.html.haml
      format.json  { render :json => @treasures }
    end
  end

  def new
    render :layout => false
    @treasure = Treasure.new
  end

  def create
    @treasure = Treasure.new(params[:treasure])
    @treasure.save

    respond_to do |format|
      format.js
    end
  end
end
