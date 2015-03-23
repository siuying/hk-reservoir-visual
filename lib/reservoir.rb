require_relative './reservoir/capacity_scraper'
require_relative './reservoir/current_storage_scraper'

module Reservoir
  module_function

  def data
    capacity_scraper = CapacityScraper.new
    storage_scraper = CurrentStoraceScraper.new

    capacities = capacity_scraper.capacities.reduce({}) { |data, item|
      data[item[:name]] = item
      data
    }
    storage = storage_scraper.current_storage.reduce({}) { |data, item|
      data[item[:name]] = item
      data
    }
    data = capacities.merge(storage)
    last_updated = storage_scraper.last_update_at

    {
      "data": data,
      "last_updated": last_updated
    }
  end
end