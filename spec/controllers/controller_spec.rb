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
  end

  it "should respond to index" do
    b1 = Blog.create({})
    b2 = Blog.create({})

    controller = dispatch_to( Scaffold::Blogs, :index ) { |r| stub_request_for(r, :render) }

    controller.status.should == 200

    models = controller.assigns(:models).page(nil)
    models.collect(&:id).should == [b1, b2].collect(&:id)
  end

  it "should respond to show"

  it "should respond to new"

  it "should respond to create"

  it "should respond to edit"

  it "should respond to update"

  it "should respond to delete"
end

def stub_request_for( req, *opts )
  req.stub!(:render)      if opts.include?( :render )
  req.stub!(:current_user).and_return( user ) if opts.include?( :login )
end