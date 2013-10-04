require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

helpers do 

	def cards_category(card)

	suits = case card[0]
	when 'H' then "hearts"
	when 'D' then "diamonds"
	when 'C' then "clubs"
	when 'S' then "spades"
	end
	values = card[1]
		if ['J','Q','K','A'].include?(values)
			values = case card[1]
			when 'J' then 'jack'
			when 'Q' then 'queen'
			when 'K' then 'king'
			when 'A' then 'ace'
			end
		end 
	"<img src = '/image/cards/#{suits}_#{values}.jpg' class cards_category>"
	end

   def cards_total(cards)
   	sum = cards.map{elelement|element[1]}
    
    total = 0
   	sum.each do |s|
   		if s == 'A'
   			total +=11
   		else
   			total += s.to_i ==0 ? 10 : s.to_i
   		end
   	end
 
   end
end

get '/' do 
	if session[:player]
		redirect '/game'
	else
		redirect '/new_game'
	end
end 

get '/new_game' do
	erb :new_game
end

post '/new_game' do
    if params[:player_name_field].empty?
    	@error = "please enter your name"
    	halt erb(:new_game)
    end
    session[:player_name] = params[:player_name_field]
    redirect '/game'
end

get '/game' do 

session[:turn]= session[:player_name]
suits = ['H','D','C','S']
values = ['A','2','3','4','5','6','7','8','9','10','J','Q','K']
 
 session[:deck] = (suits.product(values)).shuffle!
 
 session[:player_cards] = []
 session[:dealer_cards] = []
 session[:player_cards] << session[:deck].pop 
 session[:player_cards] << session[:deck].pop
 session[:dealer_cards] << session[:deck].pop
 session[:dealer_cards]  << session[:deck].pop 
 erb :game
end 
