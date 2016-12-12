source 'https://rubygems.org'

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'sqlite3'                                   # Use sqlite3 as the database for Active Record
gem 'puma', '~> 3.0'                            # Use Puma as the app server

group :development, :test do
  gem 'byebug', platform: :mri                  # Call 'byebug' to get a debugger console
  gem 'rspec-rails', '~> 3.5', '>= 3.5.2'       # A testing framework for Rails
  gem 'factory_girl_rails', '~> 4.7'            # Easier to work with factory_girl than fixtures
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'spring'                                  # Keeping your application running in the background.
  gem 'spring-watcher-listen', '~> 2.0.0'       # Provides integration between factory_girl and rails
end

group :test do
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.1'  # Provides RSpec one-liners that test common Rails functionality
  gem 'webmock', '~> 2.3', '>= 2.3.1'           # Allows stubbing HTTP requests
  gem 'database_cleaner', '~> 1.5', '>= 1.5.3'  # Strategies for cleaning databases
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]  # Bundle the tzinfo-data gem
