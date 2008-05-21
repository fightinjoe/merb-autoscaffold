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
                find_all( self.class.Model, :limit => per_page, :offset => offset )
              end
              render
            end
          end

          if instance_methods.include?('show')
            native_actions << 'show'
          else
            def show
              @model = find_first( self.class.Model, params[:id] )
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
              @model = find_first( self.class.Model, params[:id] )
              raise NotFound unless @model
              render
            end
          end


          if instance_methods.include?('create')
            native_actions << 'create'
          else
            def create
              associations = self.class.Model.scaf_has_manys.collect { |a|
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

              @model = find_first( self.class.Model, params[:id] )
              raise NotFound unless @model

              associations = self.class.Model.scaf_has_manys.collect { |a|
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
              @model = find_first( self.class.Model, params[:id] )
              raise NotFound unless @model
              if delete( @model )
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
              undo   = Pathname(Merb.dir_for(:view)).cleanpath.to_s.gsub(%r([^/]{2,}), '..')
              prefix = File.dirname(__FILE__)
              folder = 'views'
              file   = controller == "layout" ? "layout.#{type}" : "#{action}.#{type}"
              File.join( '.', undo, prefix, folder, file )
            end
          end

          def find_first( klass, *params )
            # wanted to use klass.superclass here, but the case statment seems to be checking the
            # class of klass.superclass instead of an equality check
            case klass.new
              when ActiveRecord::Base then return klass.find(:first, *params)
              when DataMapper::Base   then return klass.first( *params )
            end
          end

          def find_all( klass, *params )
            case klass.new
              when ActiveRecord::Base then return klass.find(:all, *params)
              when DataMapper::Base   then return klass.all( *params )
            end
          end

          def delete( obj )
            case obj
              when ActiveRecord::Base then return obj.destroy
              when DataMapper::Base   then return obj.destroy!
            end
          end

          def clear_association( object, assoc )
            rel = object.send( assoc.name )
            case object
              when ActiveRecord::Base then rel.clear
              when DataMapper::Base   then rel.nullify_association
            end
            rel
          end

          def update_has_many_association( assoc, model, ids )
            # remove all of the associated items
            rel = clear_association( model, assoc )

            # add all of the objects to the relationship
            for obj in find_all( assoc.klass, :conditions => ['id in (?)', ids] )
              rel << obj
            end
            model.save
          end
        }
      end
    end
  end
end