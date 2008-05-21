module MerbAutoScaffold
module ORMs
module DataMapper
  def scaf_columns() scaf_table.columns;      end
  def scaf_assocs()  scaf_table.associations; end

  def scaf_serial_columns
    scaf_columns.select { |c| c.options[:serial] }
  end

  def scaf_has_manys
    scaf_assocs.select { |a|
      a.is_a?(::DataMapper::Associations::HasManyAssociation) ||
        a.is_a?(::DataMapper::Associations::HasAndBelongsToManyAssociation)
    }
  end

  def scaf_belongs_tos
    scaf_assocs.select { |a|
      a.is_a?(::DataMapper::Associations::BelongsToAssociation)
    }
  end

  def scaf_assoc_hash
    Hash[*scaf_belongs_tos.collect {|a| [a.foreign_key_name, a]}.flatten]
  end

  def scaf_foreign_keys
    scaf_belongs_tos.collect(&:foreign_key_name)
  end

  def scaf_foreign_key_name( assoc )
    assoc.foreign_key_name
  end

  def scaf_find_all_available_items_to_association( assoc )
    assoc.associated_table.klass.all
  end

  private
    def scaf_table()   database.schema[ self ]; end
end
end
end