require 'metaid'

module MerbAutoScaffold
  class Controller

    def initialize( model )
      # Create the class
      controller_name = model.to_s.pluralize
      controller = eval("class ::#{ controller_name } < Application; end; #{ controller_name }")

      # Add the instance methods
      controller.meta_def( 'Model' ) { model }

      controller.class_eval {
        include ::MerbAutoScaffold::Controller::InstanceMethods
        # include TestIndex
        # extend(TestIndex)
      }

      # Not sure why, but neither of these work:
      # controller.extend( TestIndex )
      #
      # class << controller
      #   include TestIndex
      # end
    end

    # module TestIndex
    #   def index() 'works'; end
    # end

    module InstanceMethods
      def self.included(base)
        base.class_eval {
          unless instance_methods.include?('index')
            def index
              @models = self.class.Model.all
              display @models
            end
          end

          unless instance_methods.include?('show')
            def show
              @model = self.class.Model.first(params[:id])
              raise NotFound unless @model
              display @model
            end
          end

          unless instance_methods.include?('new')
            def new
              only_provides :html
              @model = self.class.Model.new
              render
            end
          end

          unless instance_methods.include?('edit')
            def edit
              only_provides :html
              @model = self.class.Model.first(params[:id])
              raise NotFound unless @model
              render
            end
          end


          unless instance_methods.include?('create')
            def create
              @model = self.class.Model.new(params[:model])
              if @model.save
                redirect url(self.class.Model.singular_name, @model)
              else
                render :new
              end
            end
          end

          unless instance_methods.include?('update')
            def update
              @model = self.class.Model.first(params[:id])
              raise NotFound unless @model
              if @model.update_attributes(params[:model])
                redirect url(self.class.Model.singular_name, @model)
              else
                raise BadRequest
              end
            end
          end

          unless instance_methods.include?('destroy')
            def destroy
              @model = self.class.Model.first(params[:id])
              raise NotFound unless @model
              if @model.destroy!
                redirect url(self.class.Model.plural_name)
              else
                raise BadRequest
              end
            end
          end

          private

          def _template_location(action, type = nil, controller = controller_name)
            undo   = Merb.dir_for(:view).gsub(%r{[^/]+}, '..')
            prefix = File.dirname(__FILE__)
            folder = 'views'
            file   = controller == "layout" ? "layout.#{type}" : "#{action}.#{type}"
            File.join( '.', undo, prefix, folder, file )
          end
        }
      end
    end
  end
end