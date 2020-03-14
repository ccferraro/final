# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

places_table = DB.from(:places)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

# homepage and list of events (aka "index")

get "/" do
    puts "params: #{params}"

    @places = places_table.all.to_a
    pp @places

    view "places"
end

# event details (aka "show")
get "/places/:id" do
    puts "params: #{params}"

    @users_table = users_table
    @place = places_table.where(id: params[:id]).to_a[0]
    pp @place
    
    @reviews = reviews_table.where(places_id: @place[:id]).to_a
    @recommend_count = reviews_table.where(places_id: @place[:id], recommend: true).count

    view "place"
end

# display the rsvp form (aka "new")
get "/places/:id/reviews/new" do
    puts "params: #{params}"

    @place = places_table.where(id: params[:id]).to_a[0]
    view "new_review"
end

# receive the submitted rsvp form (aka "create")
post "/places/:id/reviews/create" do
    puts "params: #{params}"

    # first find the event that rsvp'ing for
    @place = places_table.where(id: params[:id]).to_a[0]
    # next we want to insert a row in the reviews table with the review form data
    reviews_table.insert(
        places_id: @place[:id],
        users_id: session["users_id"],
        review: params["review"],
        recommend: params["recommend"]
    )

    redirect "/reviews/#{@place[:id]}"
end

# display the rsvp form (aka "edit")
get "/reviews/:id/edit" do
    puts "params: #{params}"

    @reviews = reviews_table.where(id: params["id"]).to_a[0]
    @place = places_table.where(id: @reviews[:places_id]).to_a[0]
    view "edit_review"
end

# receive the submitted rsvp form (aka "update")
post "/reviews/:id/update" do
    puts "params: #{params}"

    # find the rsvp to update
    @reviews = reviews_table.where(id: params["id"]).to_a[0]
    # find the rsvp's event
    @place = places_table.where(id: @reviews[:places_id]).to_a[0]

    if @current_user && @current_user[:id] == @reviews[:id]
        reviews_table.where(id: params["id"]).update(
            recommend: params["recommend"],
            review: params["review"]
        )

        redirect "/reviews/#{@place[:id]}"
    else
        view "error"
    end
end
