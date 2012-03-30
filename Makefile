default:
	rake db:drop
	rake db:create
	rake db:migrate
	rake db:fixtures:load
	rake bootstrap:all
	rake test:units
	rake cucumber
	rake test_data:all
