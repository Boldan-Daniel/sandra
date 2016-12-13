# README

Sandra is a Rails 5 ecommerce API to store and sell books. I make this just for fun. Please enjoy.

Things you may want to cover:

* Ruby version
    * 2.3.1

* System dependencies
    * at first, install nokogiri, bundler and rails `gem install nokogiri` / `gem install bundler` / `gem install rails`
    * run `bundle install`

* Configuration
    * when install rails app type `rails new sandra --api --skip-test-unit`
    * after install carrierwave, run in terminal `rails g uploader Cover`
    * add column to books table with `rails g migration add_cover_to_books cover:string`
    * don't forget to run `rails db:migrate && rails db:migrate RAILS_ENV=test`

* Database creation
    * We will use sqlite3

* Database initialization

* How to run the test suite
    * after you configured rspec with dependency type `rspec` in your root folder

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
