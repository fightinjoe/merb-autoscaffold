require File.join(File.dirname(__FILE__), 'spec_helper.rb')

#### CONTROLLER TESTS ####

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

#### VIEW TESTS ####

describe "index view" do
  before(:each) do
    Blog.delete_all
    30.times { |i| Blog.create({}) }
    @body = blog_request( :index ).body
  end

  it "should show all of the blogs" do
    @body.should have_tag( 'ol.models li' ) #, :count => 20 )
  end

  it "should paginate the blogs" do
    @body.should have_tag( 'ul.pages li' ) #, 3 )
  end
end

describe "show view" do
  before(:each) do
    [Blog, Comment].collect(&:delete_all)
    @b1 = Blog.create({})
    @c1 = Comment.create({ :blog => @b1 })

    @body = blog_request( :show, :id => @b1.id ).body
  end

  it "should show a single blog" do
    @body.should have_tag( 'div.model' ) # :count => 1
  end

  it "should link to the blog's comments" do
    @body.should have_tag( 'div.model' ).with_tag( 'a' ) { |p| p.should contain("Comment #{@c1.id}") }
  end

  it "should link to the comment's blog" do
    @body = comment_request( :show, :id => @c1.id ).body
    @body.should have_tag( 'div.model' ).with_tag( 'a' ) { |p| p.should contain("Blog #{@b1.id}") }
  end
end

describe "new view" do
  before(:each) do
    [Blog, Comment].collect(&:delete_all)
    @b1 = Blog.create({})
    @c1 = Comment.create({ :blog => @b1 })
    @body = blog_request( :new ).body
  end

  it "should show the form for creating a new blog" do
    @body.should have_tag( 'form', :action => '/scaffolds/blogs' )
  end

  it "should show a select box for choosing comments" do
    @body.should have_tag( 'select', :multiple => 'multiple' ).with_tag( 'option' ) { |p| p.should contain("Comment #{@c1.id}")}
  end

  it "should show dropdown for choosing a blog" do
    @body = comment_request( :new ).body
    @body.should have_tag( 'select' ).with_tag( 'option' ) { |p| p.should contain("Blog #{@b1.id}")}
  end
end

describe "edit view" do
  before(:each) do
    [Blog, Comment].collect(&:delete_all)
    @b1 = Blog.create({})
    @c1 = Comment.create({ :blog => @b1 })
    @body = blog_request( :edit, :id => @b1.id ).body
  end

  it "should show the form for creating a new blog" do
    @body.should have_tag( 'form', :action => "/scaffolds/blogs/#{ @b1.id }" )
  end

  it "should have the comments selected" do
    @body.should have_tag( 'select', :multiple => 'multiple' ).
      with_tag( 'option', :selected => 'selected' ) { |p| p.should contain("Comment #{@c1.id}")}
  end

  it "should have the blog selected" do
    @body = comment_request( :edit, :id => @c1.id ).body
    @body.should have_tag( 'select' ).
      with_tag( 'option', :selected => 'selected' ) { |p| p.should contain("Blog #{@b1.id}")}
  end
end

private

  def blog_request( action, params = {})
    dispatch_to( Scaffold::Blogs, action, params )
  end

  def comment_request( action, params = {})
    dispatch_to( Scaffold::Comments, action, params )
  end

  def blog_options
    { :title => 'title' }
  end

  def stub_request_for( req, *opts )
    req.stub!(:render)      if opts.include?( :render )
    req.stub!(:current_user).and_return( user ) if opts.include?( :login )
  end