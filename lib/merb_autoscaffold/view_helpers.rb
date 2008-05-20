module Merb
  module ViewHelpers
    def scaf_title( obj )
      obj.try(:title) || obj.try(:name) || "#{ obj.class.to_s } ##{ obj.id }"
    end

    def scaf_link( obj )
      <<-EOS
      <a href="#{ url( "scaffold_#{obj.class.singular_name}", obj ) }">
        #{ scaf_title( obj ) }
      </a>
      EOS
    end
  end
end
