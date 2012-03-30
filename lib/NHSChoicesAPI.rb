require 'nokogiri'
require 'open-uri'

module NHSChoicesAPI
  include Nokogiri

  NHSAPIKEY = 'NOCRIYLM'
  API_URL = 'http://v1.syndication.nhschoices.nhs.uk/organisations/hospitals/'
  
  class Scraper
    # Get the available overview details for a given location ID
    def get_hospital_overview(id = nil)
      return nil if id.equal? nil

      # Check we've been given some kind of number
      id = id.to_i
      return nil if id.equal? 0

      url = make_hospital_overview_url id

      begin
        doc = Nokogiri::XML(open(url))
      rescue => e
        case e
        when OpenURI::HTTPError
          return nil
        when SocketError
          return nil
        end
      end

      doc.remove_namespaces!
      root = '//feed/entry/content/overview/'
      geo = 'geographicCoordinates/'

      overview = {
        'id' => id,
        'apiurl' => url,
        'updated' => Time.parse(doc.xpath('//feed/entry/updated').text),
        'name' => doc.xpath(root + 'name').text,
        'odscode' => doc.xpath(root + 'odsCode').text,
        'postcode' => doc.xpath(root + 'address/postcode').text,
        'coordinates' => {
          'northing' => doc.xpath(root + geo + 'northing').text,
          'easting' => doc.xpath(root + geo + 'easting').text,
          'latitude' => doc.xpath(root + geo + 'latitude').text,
          'longitude' => doc.xpath(root + geo + 'longitude').text
        }
      }
    end

    # Get an array of location overview urls. Memoized after first call.
    def get_hospital_overview_urls
      @overview_urls ||= get_hospital_overview_urls_from_server
    end

    # Get an array of hospital ids. Memoizes the result to @hospital_ids
    def get_hospital_ids
      @hospital_ids ||= get_hospital_ids_from_server
    end

    # All methods past this point will not be publicly available
    private

    def make_hospital_overview_url(id = nil)
      return nil if id.equal? nil
      return NHSChoicesAPI::API_URL + id.to_s + '/overview.xml' + '?apikey=' + NHSChoicesAPI::NHSAPIKEY
    end
    
    # Build up the URLs for gathering individual overviews for locations
    def get_hospital_overview_urls_from_server
      overview_urls = {}
      ids = get_hospital_ids

      ids.each do |id|
        url = make_hospital_overview_url id
        overview_urls[id] = url
      end

      overview_urls
    end

    # Scrapes the NHS Choices API for hospital ids
    def get_hospital_ids_from_server
      url = NHSChoicesAPI::API_URL + 'identifiermappings.xhtml' + api_key
      doc = Nokogiri::HTML(open(url))
      id_arr = []
      doc.css('#identifierMappings tr td.id').each do |id|
        id_arr << id.content
      end
      return id_arr
    end

    # Returns a string for easy appending of the api key to api urls that are being built
    def api_key
      return '?apikey=' + NHSChoicesAPI::NHSAPIKEY
    end
  end
end
