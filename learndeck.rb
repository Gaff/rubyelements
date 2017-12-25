
if __FILE__ == $0  
  require 'Elements.rb'
  require 'GameState.rb'
  require 'yaml'
  require 'readline'
  
  Elements.deckname = "fire"
  Elements.focus
  autoit = Elements.autoit
  
  cards = Elements.allCards
  puts "#{GameState.number_of_cards} cards"
  hand = GameState.grabHand()
  
  puts cards
  
  names = {};
  #names[0] = "Ruby Dragon"
  #names[1] = "Ash Eater"
  #names[2] = "Farenheit"
  #names[3] = "Gavel"
  #names[6] = "Burning Tower"  
  #names[4] = "Shard of Divinity"
  #names[5] = "Brimstone Eater"
  unitnames = {};
  #unitnames[0] = "No Unit"
  #unitnames[3] = "Ruby Dragon"
  #unitnames[5] = "Emerald Dragon"
  #names[0] = "Quantum Pillar";
  
  updated = false
  
  hand.each_index() do |i|    
    ans = cards.lookup( hand[i], names[i])
    updated = ans || updated
  end
  
  units = GameState.grabMyUnits()
  units.each_index() do |i|
    ans = cards.lookup( units[i], unitnames[i])
    updated = ans || updated
  end
  
  myweapon = GameState.grabPermanent(:myweapon)  
  ans = cards.lookup(myweapon, nil ) #:noweapon ) #"Farenheit")
  updated = ans || updated

  myweapon = GameState.grabPermanent(:theirshield)  
  ans = cards.lookup(myweapon, nil ) #"Gravity Shield")
  updated = ans || updated

  myshield = GameState.grabPermanent(:myshield)  
  ans = cards.lookup(myshield, nil ) #"Thorn Carapace")
  updated = ans || updated
  
  
  if updated
    puts( "Saving")
    cards.save!
  end
    
  
  
end