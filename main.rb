if __FILE__ == $0
  require "Elements"
  require "GameState"
  require "ShriekerRush"
  require "LifeRush"
  require "FireRush"
  
  puts "Let the games begin"
    
  #Elements.deckname = "life"
  Elements.deckname = "shrieker"
  #Elements.deckname = "fire"
  Elements.focus
    
  #gs = GameState.new
  #puts GameState.elementalMaster?
  #puts gs  
  #gs.playBuff("Adrenaline", 1)  
  #exit(0)
  #raise
  
  games = 0
  turns = 0
  elapsed = 0
  wins = 0
  losses = 0
  masteries = 0
  
  2000.times() do    
    #AI3
    #GameState.click( 638, 165)    
    #AI5
    #GameState.click( 814, 165)    
    
    #Top50
    GameState.click( 726, 165)
    sleep(2)
    GameState.waitForPvP()
    GameState.click( 455, 333)
    
    sleep(2)
    #game = LifeRush.new
    game = ShriekerRush.new
    #game = FireRush.new
    game.playGame()
    
    next if game.elapsed < 10

    games += 1
    if game.result == :mastery
      puts "Mastery: #{game.turns.size} #{game.elapsed}"
      masteries += 1
    elsif game.result == :win
      puts "Won: #{game.turns.size} #{game.elapsed}"
      wins += 1
    else
      puts "Lost: #{game.turns.size} #{game.elapsed}"
      losses += 1
    end
    
    elapsed += game.elapsed
    turns += game.turns.size
    
    exp = elapsed / (2*masteries + wins)
    
    puts "Played #{games}, Mastery: #{masteries} Won: #{wins} Lost: #{losses}"
    puts "Turns: #{(Float(turns)/games)} Secs: #{(elapsed/games)} - Expectation #{exp}"    
    
    
  end    

end