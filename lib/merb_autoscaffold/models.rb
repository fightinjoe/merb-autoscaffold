require File.join( File.dirname(__FILE__), 'orms', 'datamapper' )

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
          model.meta_eval { include MerbAutoScaffold::ORMs::DataMapper }
          @models << model
        end
      }
      @models
    end
  end
end