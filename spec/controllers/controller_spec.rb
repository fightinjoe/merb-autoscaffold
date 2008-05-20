require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "controller creation" do
  it "should create scaffolding controllers" do
    Scaffold::Blogs.superclass.should    == Application
    Scaffold::Comments.superclass.should == Application
  end
end

describe "controller CRUD actions" do
  before(:each) do
    Blog.delete_all
    @b1 = Blog.create({})
    @b2 = Blog.create({})
  end

  it "should respond to index" do
    controller = blog_request( :index )

    controller.status.should == 200

    models = controller.assigns(:models).page(nil)
    models.collect(&:id).should == [@b1, @b2].collect(&:id)
  end

  it "should respond to show" do
    controller = blog_request( :show, :id => @b1.id )

    controller.status.should == 200
    controller.assigns(:model).should == @b1
  end

  it "should respond to new" do
    controller = blog_request( :new )

    controller.status.should == 200
    controller.assigns(:model).should == Blog.new
  end

  it "should create a new blog" do
    count = Blog.count
    controller = blog_request( :create, :model => blog_options )

    controller.status.should == 302
    Blog.count.should == count + 1
  end

  it "should respond to edit" do
    controller = blog_request( :edit, :id => @b1.id )

    controller.status.should == 200
    controller.assigns(:model).should == @b1
  end

  it "should update the blog" do
    title  = 'new title'
    params = {:id => @b1.id, :model => blog_options.merge( :title => title )}
    controller = blog_request( :update, params )

    controller.status.should          == 302
    controller.assigns(:model).should == @b1
    @b1.reload.title.should           == title
  end

  it "should delete the blog" do
    count = Blog.count
    controller = blog_request( :destroy, :id => @b1.id )

    controller.status.should == 302
    Blog.count.should == count - 1
  end
end

def blog_request( action, params = {})
  dispatch_to( Scaffold::Blogs, action, params ) { |r| stub_request_for(r, :render) }
end

def blog_options
  { :title => 'title' }
end

def stub_request_for( req, *opts )
  req.stub!(:render)      if opts.include?( :render )
  req.stub!(:current_user).and_return( user ) if opts.include?( :login )
end