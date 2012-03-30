@module "T21", ->
  class @Location
    constructor: (json) ->
      @lat = json.latitude
      @lon = json.longitude
      @name = json.name
      @postcode = json.postcode
      @distance = json.distance
      @delay = json.delay
      @last_updated_at = json.last_updated_at
      @odscode = json.odscode
      @hashcode = this.hash()
      @marker = false
      @infowindow = new google.maps.InfoWindow
        content: "<h1>" + @name + "</h1>" +
                 @postcode + "</br>"  +
                 "Distance: " + @distance/1000 + " km</br></br>"  +
                 "<h2>Current waiting time: " + @delay + " min</h2>" +
                 "Updated " + @last_updated_at

    getLocation: ->
      return {
        'lat': @lat,
        'lon': @lon
      }
    
    getHashcode: ->
      return @hashcode

    getName: ->
      @name

    getOdsCode: ->
      @odscode

    setMarker: (m) ->
      @marker = m
      
    setListElement: (le) ->
      @listElement = le
    
    paintToSidebar: ->
      $("ul#treasure_list").append(@listElement)

    clearMarker: ->
      @marker.setMap(null)

    clearListEntry: ->
      $('#' + @hascode).remove();
    
    remove: ->
      this.clearMarker()
      this.clearListEntry()

    hash: ->
      # Memoize the return value! If this class gets updated,
      # make sure to call this function (minus memoizing) again!
      return @hashcode if @hashcode != 0
      filter = " " + @lat + @lon + @name + @odscode
      hash = 0
      for f in filter
        hash = ((hash << 5) - hash) + f.charCodeAt()
        @hashcode = Math.abs(hash & hash) # Make it 32bit
      return @hashcode

    highlight: ->
      @infowindow.open(T21.map,@marker)
      @listElement.addClass("highlighted")
    
    removeHighlight: ->
      @infowindow.close()
      @listElement.removeClass("highlighted")
