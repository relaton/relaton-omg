module Relaton
  module Omg
    class Ext < Bib::Ext
      def get_schema_version = Relaton.schema_versions["relaton-model-omg"]
    end
  end
end
