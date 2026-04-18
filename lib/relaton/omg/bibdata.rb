module Relaton
  module Omg
    class Bibdata < Item
      model ItemData
      include Bib::BibdataShared
    end
  end
end
