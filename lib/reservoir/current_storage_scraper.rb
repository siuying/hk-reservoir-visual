require 'open-uri'
require 'nokogiri'

module Reservoir
  class CurrentStoraceScraper
    BASE_URL = {
      "tc" => "http://www.wsd.gov.hk/tc/publications_and_statistics/statistics/current_storage_position_of_reservoirs/index.html",
      "en" => "http://www.wsd.gov.hk/en/publications_and_statistics/statistics/current_storage_position_of_reservoirs/index.html"
    }

    DISCARDED_ROWS = [
      "本港水塘總存水量(百萬立方米)", 
      "佔總容量百分比(%)", "總和  :", 
      "", 
      "TOTAL  :", 
      "Total Storage of Impounding Resevoirs(Million Cubic Metre)", 
      "% Full"]

    attr_reader :lang

    def initialize(lang="tc")
      @lang = lang
      raise "Language #{tc} not found!" unless BASE_URL[lang]
    end

    def last_update_at
      update_at = page.xpath("//h2[contains(., '個別水塘存水量')]").first.text
      match = update_at.match(/個別水塘存水量\(([0-9]{4})年([0-9]{1,2})月([0-9]{1,2})日\)/)
      Date.new(match[1].to_i, match[2].to_i, match[3].to_i)
    end

    def current_storage
      current_storage_table = page.xpath("//table[contains(@summary, '本港水塘存水量') or contains(@summary, 'Storage Position')]").first
      current_storage_table.xpath("//tr").collect { |row|
        {
          name: row.xpath("./td[1]").text,
          storage: row.xpath("./td[2]").text.to_f,
          percentage: row.xpath("./td[3]").text.to_f
        }
      }.select {|rows| !DISCARDED_ROWS.include?(rows[:name]) }
    end

    def page
      @page ||= Nokogiri::HTML(open(BASE_URL[lang]))
    end
  end
end