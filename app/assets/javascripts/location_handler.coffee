@module "EMG", ->
  class @LocationHandler
    constructor: () ->
      
    unhighlightAllLocations: () ->
      for location in EMG.locations
        log location
        location.removeHighlight()

    # Repaints both the sidebar using the list that we have
    repaintLocationsSidebar: () ->
      $("ul#hospital_list").empty()
      for location in EMG.locations
        location.paintToSidebar()
