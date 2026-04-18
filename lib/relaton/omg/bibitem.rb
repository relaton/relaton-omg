module Relaton
  module Omg
    class Bibitem < Item
      model ItemData
      include Bib::BibitemShared
    end
  end
end
