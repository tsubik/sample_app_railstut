require 'spec_helper'

describe "User pages" do
  subject { page }
  describe "signup page" do
  	before { visit signup_path }

  	it { should have_selector "h1", title: "Sign up" }
  	it { should have_selector "title", title: full_title("Sign up") }
  end

  describe "signup" do
 		before { visit signup_path }

 		let(:submit) { "Create my account" }

 		describe "with invalid information" do
 			it "should not create a user" do
 				expect { click_button submit }.not_to change(User, :count)
 			end
 		end

 		describe "with valid information" do
 			before do
 				fill_in "Name", with: "Tomasz Subik"
 				fill_in "Email", with: "tsubik@gmail.com"
 				fill_in "Password", with: "z dupy"
 				fill_in "Confirmation", with: "z dupy"
 			end

 			it "should create a user" do
 				expect { click_button submit }.to change(User, :count).by(1)
 			end
 		end
  end

  describe "profile page" do
  	let(:user) { FactoryGirl.create(:user) }

  	before { visit user_path(user) }
		it { should have_selector "h1", text: user.name }
		it { should have_selector "title", text: user.name }  	
  end
end
