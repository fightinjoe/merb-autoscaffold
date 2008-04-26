module Merb
  module ViewHelpers
    def scaf_title( obj )
      obj.try(:title) || obj.try(:name) || "#{ obj.class.to_s } ##{ obj.id }"
    end

    def scaf_link( obj )
      <<-EOS
      <a href="#{ url( obj.class.singular_name, obj ) }">
        #{ scaf_title( obj ) }
      </a>
      EOS
    end

    def scaf_table()   database.schema[ self.class.Model ]; end
    def scaf_columns() scaf_table.columns;                       end
    def scaf_assocs()  scaf_table.associations;                  end

    def scaf_has_manys
      scaf_assocs.select { |a|
        a.is_a?(DataMapper::Associations::HasManyAssociation)
      }
    end

    def scaf_belongs_tos
      scaf_assocs.select { |a|
        a.is_a?(DataMapper::Associations::BelongsToAssociation)
      }
    end

    def scaf_assoc_hash
      Hash[*scaf_belongs_tos.collect {|a| [a.foreign_key_name, a]}.flatten]
    end

    def scaf_foreign_keys
      scaf_belongs_tos.collect(&:foreign_key_name)
    end

  end
end
