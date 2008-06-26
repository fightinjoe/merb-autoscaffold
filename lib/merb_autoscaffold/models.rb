%w(datamapper activerecord).each { |r| require File.join( File.dirname(__FILE__), 'orms', r ) }

module MerbAutoScaffold
  class Models
    MODEL_REGEXP = %r{^class ([\w\d_\-:]+) .*$}

    # Returns an array containing all of the models in the Merb app
    def self.all
      return @models if @models

      @models ||= []
      Dir.glob( Merb.dir_for(:model) / Merb.glob_for(:model) ).each { |f|
        if File.read(f).match( MODEL_REGEXP )
          model = full_const_get( $1 )
          model.class_eval {
            def self.singular_name() self.to_s.snake_case.to_sym; end
            def self.plural_name()   self.to_s.snake_case.pluralize.to_sym; end
          }
          extension = case model.new
            # wanted to use klass.superclass here, but the case statment seems to be checking the
            # class of klass.superclass instead of an equality check
            #
            # note: once the internals of Merb stabalize, use Merb's tracking of ORMs
            # to perform this test.
            # 0.9.3 - Merb.generator_scope.include?(:datamapper)
            # 0.9.4 - Merb.orm_generator_scope == :datamapper
            when ActiveRecord::Base then MerbAutoScaffold::ORMs::ActiveRecord
            when DataMapper::Base   then MerbAutoScaffold::ORMs::DataMapper
            else raise "Merb AutoScaffold does not currently support the #{ model.class.superclass } ORM"
          end

          model.meta_eval { include extension }
          @models << model
        end
      }
      @models
    end
  end
end

# These empty class definitions are necessary in order for the above where-clause to not fail when
# one of the ORMs is not present.
module ActiveRecord; class Base; end; end
module DataMapper;   class Base; end; end