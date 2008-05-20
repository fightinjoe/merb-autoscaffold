require 'metaid'
require 'merb_autoscaffold/view_helpers'
require 'paginator'

module MerbAutoScaffold
  class Controller

    def initialize( model )
      # Create the class
      controller_name = model.to_s.pluralize
      controller = eval(
      <<-EOS
        class ::Scaffold
          class #{ controller_name } < Application
          end
        end
        ::Scaffold::#{ controller_name }
      EOS
      )

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
      #
      # Possibly need to use Merb::Controller#show_action() to register
      # the actions
    end

    # module TestIndex
    #   def index() 'works'; end
    # end

    module InstanceMethods
      def self.included(base)

        base.class_eval {
          include ::Merb::ViewHelpers

          class << self
            attr_accessor :native_actions
            def native_actions() @native_actions ||= []; end
          end

          if instance_methods.include?('index')
            native_actions << 'index'
          else
            def index
              @models = Paginator.new( self.class.Model.count, 20) do |offset, per_page|
                self.class.Model.all(:limit => per_page, :offset => offset)
              end
              display @models
            end
          end

          if instance_methods.include?('show')
            native_actions << 'show'
          else
            def show
              @model = self.class.Model.first(params[:id])
              raise NotFound unless @model
              display @model
            end
          end

          if instance_methods.include?('new')
            native_actions << 'new'
          else
            def new
              only_provides :html
              @model = self.class.Model.new
              render
            end
          end

          if instance_methods.include?('edit')
            native_actions << 'edit'
          else
            def edit
              only_provides :html
              @model = self.class.Model.first(params[:id])
              raise NotFound unless @model
              render
            end
          end


          if instance_methods.include?('create')
            native_actions << 'create'
          else
            def create
              associations = scaf_has_manys.collect { |a|
                [ a, params['model'].delete( a.name ) ]
              }

              params[:model].each { |k,v| params[:model][k] = nil if v.blank? }

              @model = self.class.Model.new(params[:model])
              if @model.save
                associations.each { |a, ids| update_has_many_association( a, @model, ids ) }
                redirect url( "scaffold_#{self.class.Model.singular_name}", @model)
              else
                render :new
              end
            end
          end

          if instance_methods.include?('update')
            native_actions << 'update'
          else
            def update
              params[:model].each { |k,v| params[:model][k] = nil if v.blank? }

              @model = self.class.Model.first(params[:id])
              raise NotFound unless @model

              associations = scaf_has_manys.collect { |a|
                [ a, params['model'].delete( a.name ) ]
              }

              if @model.update_attributes(params[:model])
                associations.each { |a, ids| update_has_many_association( a, @model, ids ) }
                redirect url( "scaffold_#{self.class.Model.singular_name}", @model)
              else
                raise BadRequest
              end
            end
          end

          if instance_methods.include?('destroy')
            native_actions << 'destroy'
          else
            def destroy
              @model = self.class.Model.first(params[:id])
              raise NotFound unless @model
              if @model.destroy!
                redirect url( "scaffold_#{self.class.Model.plural_name}" )
              else
                raise BadRequest
              end
            end
          end

          private
          
          alias :_orig_template_location :_template_location
          
          def _template_location(action, type = nil, controller = controller_name)
            if self.class.native_actions.include?( action_name )
              _orig_template_location( action, type, controller )
            else
              undo   = Merb.dir_for(:view).gsub(%r{[^/]+}, '..')
              prefix = File.dirname(__FILE__)
              folder = 'views'
              file   = controller == "layout" ? "layout.#{type}" : "#{action}.#{type}"
              File.join( '.', undo, prefix, folder, file )
            end
          end

          def update_has_many_association( assoc, model, ids )
            rel = model.send( assoc.name )
            # remove all of the associated items
            rel.nullify_association

            # add all of the objects to the relationship
            for obj in assoc.associated_table.klass.all( :id.in => ids )
              rel << obj
            end
            model.save
          end
        }
      end
    end
  end
end