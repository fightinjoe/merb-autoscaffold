require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "controller creation" do
  it "should create scaffolding controllers" do
    Scaffold::Blogs.superclass.should    == Application
    Scaffold::Comments.superclass.should == Application
  end
end

describe "controller CRUD actions" do
  it "should respond to index"

  it "should respond to show"

  it "should respond to new"

  it "should respond to create"

  it "should respond to edit"

  it "should respond to update"

  it "should respond to delete"
end