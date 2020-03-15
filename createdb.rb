# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :places do
  primary_key :id
  String :title
  String :description, text: true
  String :location
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key :place_id
  foreign_key :user_id
  Boolean :recommend
  String :review, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
places_table = DB.from(:places)

places_table.insert(title: "Gite Le Vagabond", 
                    description: "Set in an 1860s coach house, this budget hostel is a 15-minute walk from several ski slopes and 1.3 km from the Train du Montenvers-Mer de Glace.",
                    location: "365 Avenue Ravanel le Rouge, 74400 Chamonix-Mont-Blanc, France")

places_table.insert(title: "Chalet Hotel Les Campanules", 
                    description: "Overlooking Mont Blanc and the Aiguille du Midi mountain, this chalet hotel is 2 km from the ski lifts in Les Houches.",
                    location: "450 Route de Coupeau, 74310 Les Houches, France")

places_table.insert(title: "Hôtel Mont-Blanc", 
                    description: "This upscale hotel sits in Chamonix-Mont-Blanc town center, surrounded by mountains, and is a 10-minute walk from the ski lifts at Brévent.",
                    location: "62 Allée du Majestic, 74400 Chamonix-Mont-Blanc, France")

puts "Success!"