require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true
BlackJack_Goal = 21
Dealer_min_Goal = 17
Initial_money = 100

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
	end #end cards_category

   def cards_total(cards)
   	sum = cards.map{|element|element[1]}
    
    total = 0
   	sum.each do |s|
   		if s == 'A'
   			total +=11
   		else
   			total += s.to_i ==0 ? 10 : s.to_i
   		end
   	  end

   	sum.select{|element|element =="A"}.count.times do 
   		if total >21
   			total -=10
   		end
   	end
       return total
   end #end cards_total

   def cards_shuffle
   	suits = ['H','D','C','S']
	values = ['A','2','3','4','5','6','7','8','9','10','J','Q','K']
 
 	session[:deck] = (suits.product(values)).shuffle!
 	session[:player_cards] = []
 	session[:dealer_cards] = []
   end #end cards_shuffle

   def player_hit(player_total)
		if player_total	== BlackJack_Goal
    		winner!("#{session[:player_name]} has hit Blackjack!")
    	elsif player_total > BlackJack_Goal
    		loser!("BUST! #{session[:player_name]}'s cards add up to #{player_total}.")
    	end
   end #end player hit

   def winner!(msg)
    @show_hit_stay = false
    @success = "<strong>#{session[:player_name]} wins the bet #{session[:player_bet]}!</strong> #{msg}"
    session[:player_money]=session[:player_money]+session[:player_bet]
    @play_again = true
   end

   def loser!(msg)
   	@show_hit_stay = false
   	@error = "<strong>#{session[:player_name]} lose the bet #{session[:player_bet]}!</strong> #{msg}"
    session[:player_money]=session[:player_money]-session[:player_bet]
    @play_again = true
   end

   def tie!(msg)
   	@success = "<strong>It's a tie</strong>#{msg}"
    @show_hit_stay = false
    @play_again = true
   end

   def compare(player_total,dealer_total)
   	  if player_total > dealer_total 
    	winner!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  	  elsif dealer_total > player_total 
    	loser!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  	  else
    	tie!("Both #{session[:player_name]} and the dealer stayed at #{player_total}.")
  		end
   end #end compare

   def dealer_or_player_win(player_total,dealer_total)
   	 if dealer_total == BlackJack_Goal 
        loser!("#{session[:player_name]} stayed at #{player_total}, and the dealer hit #{dealer_total}.")
        @dealer_going_to_hit = false
     elsif dealer_total > BlackJack_Goal
        winner!("#{session[:player_name]} stayed at #{player_total}, and the dealer busted at #{dealer_total}.")
        @dealer_going_to_hit= false
     elsif dealer_total > Dealer_min_Goal
        compare(player_total,dealer_total)
        @dealer_going_to_hit = false
     else
        @dealer_going_to_hit = true
     end
   end #end of comparing dealer and player

end #end helpers

before do 
	@show_hit_stay = true
	@new_game = true
	@dealer_going_to_hit = false
end

get '/' do 
	if session[:player]
		redirect '/game'
	else
		redirect '/new_game'
	end
end 

get '/new_game' do
  session[:player_money] = Initial_money
	erb :new_game
end

post '/new_game' do
    if params[:player_name_field].empty?
    	@error = "please enter your name"
    	halt erb(:new_game)
    end
    session[:player_name] = params[:player_name_field]
    session[:turn]= session[:player_name]
    redirect '/place_bet'
end

get '/place_bet' do 
  erb :place_bet
end

post '/place_bet' do 
  session[:turn]=session[:player_name]
  if params[:bet_amount].nil? || params[:bet_amount].to_i ==0
    @error ="Please enter a bet"
    halt erb(:place_bet)
  elsif params[:bet_amount].to_i > session[:player_money].to_i
    @error="You can't bet more than $#{session[:player_money]}"
    halt erb(:place_bet)
  else
    session[:player_bet]=params[:bet_amount].to_i
    redirect '/game'
  end
    
end


post '/game' do
    	if params[:player_hit] == "true"
    		session[:player_cards] << session[:deck].pop
    		player_hit(cards_total(session[:player_cards]))
    	end

    	if params[:player_stay] == "true"
    		@success = "#{session[:player_name]} has chosen to stay."
            @show_hit_stay = false
            session[:turn] = "dealer"
            dealer_or_player_win(cards_total(session[:player_cards]),cards_total(session[:dealer_cards]))
    	end
    		
    	if params[:dealer_hit] == "true"
            session[:dealer_cards] << session[:deck].pop
            dealer_or_player_win(cards_total(session[:player_cards]),cards_total(session[:dealer_cards]))
        end

      if params[:play_again] == "true"
        redirect  '/game'
      end

    erb :game
end #end post 'game'


get '/game' do 
 if @new_game
 	cards_shuffle
 	session[:player_cards] << session[:deck].pop 
 	session[:player_cards] << session[:deck].pop
 	session[:dealer_cards] << session[:deck].pop
 	session[:dealer_cards]  << session[:deck].pop
 end
 erb :game
end 

post '/game_over' do 
erb :game_over
end

