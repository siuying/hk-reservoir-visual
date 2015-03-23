require 'open-uri'
require 'nokogiri'

module Reservoir
  class CapacityScraper
    BASE_URL = {
      "tc" => "http://www.wsd.gov.hk/tc/publications_and_statistics/statistics/capacity_of_impounding_reservoirs_in_hong_kong/index.html",
      "en" => "http://www.wsd.gov.hk/en/publications_and_statistics/statistics/capacity_of_impounding_reservoirs_in_hong_kong/index.html"
    }

    DISCARDED_ROWS = [
      "水塘名稱", 
      "總容量：", 
      "", 
      "TOTAL  :", 
      "Name of Impounding Reservoirs", 
      "Total capacity :"]

    attr_reader :lang

    def initialize(lang="tc")
      @lang = lang
      raise "Language #{tc} not found!" unless BASE_URL[lang]
    end

    def capacities
      capacity_table = page.xpath("//table[contains(@summary, '各水塘容量') or contains(@summary, 'Capacity')]").first
      capacity_table.xpath("//tr").collect { |row|
        {
          name: row.xpath("./td[1]").text,
          capacity: row.xpath("./td[2]").text.to_f
        }
      }.select {|rows| !DISCARDED_ROWS.include?(rows[:name]) }
    end

    def page
      @page ||= Nokogiri::HTML(open(BASE_URL[lang]))
    end
  end
end