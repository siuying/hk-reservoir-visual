require_relative './reservoir/capacity_scraper'
require_relative './reservoir/current_storage_scraper'
require 'digest/md5'

module Reservoir
  module_function

  def data
    capacity_scraper = CapacityScraper.new
    storage_scraper = CurrentStoraceScraper.new
    
    last_updated = storage_scraper.last_update_at
    capacities = capacity_scraper.capacities.reduce({}) { |data, item|
      data[item["name"]] = item
      data
    }

    counter = 1
    storage = storage_scraper.current_storage.reduce({}) { |data, item|
      name = item["name"]
      data[name] = item

      data[name]["id"] = "reservoir#{counter}"
      data[name]["volumn"] = "%.2f" % [capacities[name]["volumn"] * 100]
      data[name]["storage"] = "%.2f" % [data[name]["storage"] * 100]
      data[name]["updateAt"] = "#{last_updated.strftime("%Y-%m-%d")}"
      data[name]["daliyNetflow"] = nil
      data[name]["daliyInflow"] = nil
      data[name]["daliyOverflow"] = nil
      counter = counter + 1
      data
    }

    return storage
  end
end