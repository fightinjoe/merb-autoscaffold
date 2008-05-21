module MerbAutoScaffold
module ORMs
module ActiveRecord
  def scaf_columns() self.columns;            end
  def scaf_assocs()  self.reflections.values; end

  # The array of columns that should be immutable, e.g. primary keys
  def scaf_serial_columns
    scaf_columns.select { |c| c.primary }
  end

  # The array of all has_many and has_and_belongs_to_many associations
  def scaf_has_manys
    scaf_assocs.select { |a|
      [:has_and_belongs_to_many, :has_many].include?( a.macro )
    }
  end

  # The array of all belongs_to associations
  def scaf_belongs_tos
    scaf_assocs.select { |a|
      [:belongs_to].include?( a.macro )
    }
  end

  # A hash that is used to look up if a column is a foreign key in a relationship
  # or not.
  def scaf_assoc_hash
    Hash[*scaf_belongs_tos.collect {|a| [a.primary_key_name, a]}.flatten]
  end

  # An array of the columns that are foreign keys in associations for the model
  def scaf_foreign_keys
    scaf_belongs_tos.collect(&:primary_key_name)
  end

  # Given an association will return the foreign key that defines the association
  def scaf_foreign_key_name( assoc )
    assoc.primary_key_name
  end

  # Queries the database for all items available to the passed in association
  def scaf_find_all_available_items_to_association( assoc )
    assoc.klass.find(:all)
  end
end
end
end