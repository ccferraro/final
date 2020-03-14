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
  foreign_key :places_id
  foreign_key :users_id
  Boolean :recommend
  String :name
  String :email
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

places_table.insert(title: "Gite Le Moulin", 
                    description: "At the foot of the famous Mont Blanc between the glaciers of Tour and Argentiere located in an old windmill you will find Le Moulin gite, the perfect place to stay for setting out on sections of your GR Tour du Mont Blanc, close to the Tour Col de Balme and a stones throw from the Aiguilles Rouges.",
                    location: "32 Chemin du Moulin des Frasserands, 74400 Chamonix-Mont-Blanc, France")

places_table.insert(title: "Hotel Edelweiss", 
                    description: "Set at the foot of Mont Blanc, this cozy, family-run mountain hotel is 8 minutes' walk from Courmayeur Mont Blanc Funivie tramway and 7 km from Pointe Helbronner mountain.",
                    location: "Via Guglielmo Marconi, 42, 11013 Courmayeur AO, Italy")

places_table.insert(title: "La Folie Douce", 
                    description: "This hip hotel with ski-in/ski-out access is 8 minutes' walk from Chamonix-Mont-Blanc train station, and within 12 km of Mont Blanc and Le Brévent mountains.",
                    location: "823 Allée Recteur Payot, 74400 Chamonix-Mont-Blanc, France")

puts "Success!"