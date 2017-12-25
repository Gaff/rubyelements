if __FILE__ == $0
  puts "Loading.."
  require '.\Elements.rb'
  require '.\GameState.rb'
  require 'yaml'

  require 'rubygems'
  #require 'ruby-prof'
  
  
  Elements.focus
  autoit = Elements.autoit
  
  def elapsed
      start_time = Time.now
      yield
      Time.now - start_time
  end
  puts GameState.number_of_cards, " cards"
  
  
  #RubyProf.start
  
  hand = GameState.grabHand()
  puts "Got hand."
    
  (0..7).each{|j|
    card0 = hand[j]
    #card1 = GameState.grabCard(7)
    ans = []
    (0..7).each { |i|
      ans[i]=card0.compare(hand[i])
    }
    puts "Differences#{j}: #{ans}"
  }
  
  #puts hand[0].to_yaml

  #result = RubyProf.stop

  # Print a flat profile to text
  #printer = RubyProf::FlatPrinter.new(result)
  #printer.print(STDOUT)
  
end
