module Merb
  module ViewHelpers
    def scaf_title( obj )
      obj.try(:title) || obj.try(:name) || "#{ obj.class.to_s } ##{ obj.id }"
    end
  end
end
