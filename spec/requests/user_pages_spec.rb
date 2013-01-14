# encoding: UTF-8
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

      describe "after submission" do
        before { click_button submit }

        it { should have_selector "title", text: "Sign up" }
        it { should have_content "error" }
        it { should have_content "* Name can't be blank" }
        it { should have_content "* Email can't be blank" }
        it { should have_content "* Email is invalid" }
        it { should have_content "* Password can't be blank" }
        it { should have_content "* Password is too short (minimum is 6 characters)" }
        it { should have_content "* Password confirmation can't be blank" }
      end
 		end

 		describe "with valid information" do
 			before do
 				fill_in "Name", with: "Tomasz Subik"
 				fill_in "Email", with: "tsubik@gmail22.com"
 				fill_in "Password", with: "tojesthaslo"
 				fill_in "Confirmation", with: "tojesthaslo"
 			end

 			it "should create a user" do
 				expect { click_button submit }.to change(User, :count).by(1)
 			end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email("tsubik@gmail22.com") }

        it { should have_selector('title', text: user.name)}
        it { should have_selector('div.alert.alert-success', text: "Welcome") }
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
