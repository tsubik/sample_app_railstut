# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do
	before { @user = User.new name: "Tomasz Subik", email: "tsubik@gmail.com", password: "foobar", password_confirmation: "foobar" }

	subject { @user }

	it { should respond_to(:email) }
	it { should respond_to(:name) }
	it { should respond_to(:password_digest) }
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }
	it { should respond_to(:admin) }
	it { should respond_to(:authenticate) }
	it { should respond_to(:microposts) }
	it { should respond_to(:feed) }
	it { should respond_to(:remember_token)}
	it { should be_valid }
	it { should_not be_admin }

	describe "accessible attributes" do
		it "should not allow access to admin" do
			expect { User.new(admin: true) }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
	end

	describe "when admin attribute set to 'true'" do
		before do
			@user.save!
			@user.toggle!(:admin)
		end

		it { should be_admin }
	end

	describe "when name is not present" do
		
		before { @user.name = "" }
		it { should_not be_valid }
	end	

	describe "when email is not present" do
		before { @user.email = "" }
		it { should_not be_valid }
	end

	describe "when name is too long" do
		before { @user.name = "d"*51 }
		it { should_not be_valid }
	end

	describe "when email address is invalid" do
		it "should be invalid" do
			addresses = %w[user@foo,com dupa.org tsubik@sss. foo@barr foo@barr+sss.com]
			addresses.each do |address|
				@user.email = address
				@user.should_not be_valid
			end
		end
	end

	describe "when email adress is valid" do
		it "should be valid" do
			addresses = %w[user@foo.com dupa+org@tsubik.com tsubik@sss.pl ASA-ssa_asa@barr.pl]
			addresses.each do |address|
				@user.email = address
				@user.should be_valid
			end
		end
	end

	describe "when email address is already taken" do
		before do
		  user_dup = @user.dup
		  user_dup.email = user_dup.email.upcase
		  user_dup.save
		end

		it { should_not be_valid }
	end

	describe "when password is not present" do
		before do
		  @user.password = @user.password_confirmation = ' '
		end

		it { should_not be_valid }
	end

	describe "when password is not matching password_confirmation" do
		before do
		  @user.password_confirmation = "mismatch"
		end

		it { should_not be_valid }
	end

	describe "when password_confirmation is nil" do
		before do
		  @user.password_confirmation = nil
		end

		it { should_not be_valid }
	end

	describe "return value of authenticate method" do
		before { @user.save }
		let(:found_user) { User.find_by_email(@user.email) }

		describe "with valid password" do
			it { should == found_user.authenticate(@user.password) }
		end

		describe "with invalid password" do
			let(:user_for_invalid_password) { found_user.authenticate("dupa") }

			it { should_not == user_for_invalid_password }
			specify { user_for_invalid_password.should be_false }
		end
	end

	describe "with a password that is too short" do
		before { @user.password = @user.password_confirmation = "a"*5 }
		it { should be_invalid }
	end

	describe "email addresses with mixed keys" do
		let(:mixed_case_email) { "FooAb@s2D.pl" }

		it "should be saved all lower case" do
			@user.email = mixed_case_email
			@user.save
			@user.reload.email.should == mixed_case_email.downcase			
		end
	end

	describe "remember token" do
		before { @user.save }
		its(:remember_token) { should_not be_blank }
	end

	describe "micropost assocations" do
		before { @user.save }
		let!(:older_micropost) do
			FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago )
		end
		let!(:newer_micropost) do
			FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago )
		end

		it "should have the right microposts in the right order" do
			@user.microposts.should == [newer_micropost, older_micropost]
		end

		it "should destroy associated microposts" do
			microposts = @user.microposts.dup
			@user.destroy

			microposts.should_not be_empty
			microposts.each do |micropost|
				Micropost.find_by_id(micropost.id).should be_nil
			end	
		end

		describe "status" do
			let(:unfollowed_post) do
				FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
			end

			its(:feed) { should include(newer_micropost) }
			its(:feed) { should include(older_micropost) }
			its(:feed) { should_not include(unfollowed_post) }
		end
	end
end
