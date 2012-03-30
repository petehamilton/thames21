@module "T21", ->
  class @LocationHandler
    constructor: () ->
      
    unhighlightAllLocations: () ->
      for location in T21.locations
        log location
        location.removeHighlight()

    # Repaints both the sidebar using the list that we have
    repaintLocationsSidebar: () ->
      $("ul#treasure_list").empty()
      for location in T21.locations
        location.paintToSidebar()
