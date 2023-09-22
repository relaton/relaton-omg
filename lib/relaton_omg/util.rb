module RelatonOmg
  module Util
    extend RelatonBib::Util

    def self.logger
      RelatonOmg.configuration.logger
    end
  end
end
