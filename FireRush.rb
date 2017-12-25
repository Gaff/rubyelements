class FireRush < Game
  def playTurn
   
    pillars = self.state.playAll("Burning Tower")
    
    if (pillars > 0) and (self.state.playable.index(false) != nil)
      #if we played some towers this turn, and we have some unplayable cards
      #extra delay to update the isplayable() state, it's a little slow stomeitmes after playing a pillar
      puts "pillar delay"
      sleep(0.5)
      GameState.waitForPlay()
    end
    
    cremateMeNot = false
    
    until cremateMeNot
      #puts "main loop!"
      #puts self.state
      
      cremateMeNot = false
      
      playWhileYouCan( "Ruby Dragon")    
      playWhileYouCan( "Lava Destroyer")
      playWhileYouCan( "Brimstone Eater")
      playWhileYouCan( "Ash Eater")
      
      #Do we have cremation and ash eaters? Cremate where possible.
      if self.state.hand.index( "Cremation") == nil 
        cremateMeNot = true
      elsif (self.state.hand.index("Lava Destroyer") == nil) and (self.state.hand.index("Ruby Dragon") == nil)
        #no point in cremating for fun, there must be something we've yet to play
        cremateMeNot = true
      else
        #Do we have asheaters to play it on?
        mergeUnits(true)
        eaters = findUnits( "Brimstone Eater")
        if eaters.size > 0
          #puts "Units: #{self.units}"
          self.state.playBuff("Cremation", eaters.keys.first)
          sleep(1.8)
          mergeUnits(true)
          self.state.updatePlayable()          
        else
          cremateMeNot = true
        end
      end   
    end
    
    #finally invoke the golemns, meh can do that later.
    f = self.units.select() { |k,v| v.name == "Lava Destroyer"}
    #f = f.sort { |lhs, rhs| -lhs[1].invokations <=> -rhs[1].invokations }
    puts "Destroyers: #{f}"

    f.keys.each do |v|
      self.state.playUnit(v)
    end    


    if self.state.hand.index("Gavel") != nil
      if GameState.getPermanent(:myweapon) == :noweapon
        self.state.play("Gavel")
      end
    end    
    
    if self.state.hand.index("Farenheit") != nil
      if GameState.getPermanent(:myweapon) == :noweapon
        self.state.play("Farenheit")
      end
    end
    
  end
end