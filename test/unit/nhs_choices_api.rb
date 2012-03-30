require 'test_helper'
require_relative '../../lib/NHSChoicesApi'

class NHSChoicesAPITest < ActiveSupport::TestCase
  test "can build the scraper object" do
    scraper = NHSChoicesAPI::Scraper.new
    assert_not_nil(scraper)
    assert_instance_of(NHSChoicesAPI::Scraper, scraper)
  end

  test "grabbing hospital IDs produces an array" do
    scraper = NHSChoicesAPI::Scraper.new
    ids = scraper.get_hospital_ids
    assert_instance_of(Array, ids)
    assert(ids.include? "1960")
  end

  test "get hospital overview urls" do
    scraper = NHSChoicesAPI::Scraper.new
    overview_urls = scraper.get_hospital_overview_urls
    assert_instance_of(Hash, overview_urls)

    # Checking internal vals like this should be mocked
    assert(overview_urls.include? "71591")
    assert_equal overview_urls["71591"], "http://v1.syndication.nhschoices.nhs.uk/organisations/hospitals/71591/overview.xml?apikey=NOCRIYLM"
  end

  test "bad overview input fails" do
    scraper = NHSChoicesAPI::Scraper.new

    assert_nil scraper.get_hospital_overview
    assert_nil scraper.get_hospital_overview("asdf")
  end

  test "get full overview for location 71591" do
    scraper = NHSChoicesAPI::Scraper.new
    overview = scraper.get_hospital_overview(71591)

    assert_equal 71591, overview['id']
    assert_equal "http://v1.syndication.nhschoices.nhs.uk/organisations/hospitals/71591/overview.xml?apikey=NOCRIYLM", overview['apiurl']
    assert_equal 'Huddersfield Medical Services HQ', overview['name']
    assert_equal 'NL401', overview['odscode']
    assert_equal 'HD7 5AB', overview['postcode']
    assert_equal '414100', overview['coordinates']['northing']
    assert_equal '408100', overview['coordinates']['easting']
    assert_equal '53.6233761079265', overview['coordinates']['latitude']
    assert_equal '-1.87900971515463', overview['coordinates']['longitude']
  end
end
