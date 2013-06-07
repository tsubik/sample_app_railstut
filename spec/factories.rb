FactoryGirl.define do
	factory :user do
		sequence(:name) { |n| "Person #{n}" }
		sequence(:email) { |n| "person_xx#{n}@example.com" }
		password "example"
		password_confirmation "example"

		factory :admin do
			admin true
		end
	end	
end