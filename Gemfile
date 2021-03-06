source 'https://rubygems.org'

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'pg', '~> 0.19.0'                           # Use postgresql as the database for Active Record
gem 'puma', '~> 3.0'                            # Use Puma as the app server

group :development, :test do
  gem 'byebug', platform: :mri                  # Call 'byebug' to get a debugger console
  gem 'rspec-rails', '~> 3.5', '>= 3.5.2'       # A testing framework for Rails
  gem 'factory_girl_rails', '~> 4.7'            # Easier to work with factory_girl than fixtures
  gem 'awesome_print', '~> 1.7'                 # Pretty print Ruby objects
  gem 'vcr', '~> 3.0', '>= 3.0.3'               # Record test suite's HTTP interactions
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

gem 'carrierwave', '~> 0.11.2'                  # Upload files in your Ruby applications, map them to a range of ORMs
gem 'carrierwave-base64', '~> 2.3', '>= 2.3.4'  # Upload files to your API from mobile devises
gem 'kaminari', '~> 0.17.0'                     # Scope & Engine based paginator for Rails
gem 'pg_search', '~> 2.0', '>= 2.0.1'           # Take advantage of PostgreSQL's full text search
gem 'bcrypt', '~> 3.1', '>= 3.1.11'             # Secure hash algorithm for hashing passwords
gem 'pundit', '~> 1.1'                          # Object oriented authorization
gem 'money-rails', '~> 1.8'                     # Integration of RubyMoney
gem 'stripe', '~> 1.58'                         # accept payments online
gem 'oj', '~> 2.18', '>= 2.18.1'                # Fastest JSON parser and object serializer.
gem 'rack-cors', '~> 0.4.1', :require => 'rack/cors' # Middleware that will make Rack-based apps CORS compatible