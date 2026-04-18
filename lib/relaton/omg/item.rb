module Relaton
  module Omg
    class Item < Bib::Item
      model ItemData
      attribute :ext, Ext
    end
  end
end
