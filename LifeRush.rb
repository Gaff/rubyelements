require "Game"

=begin
class Unit
  attr_accessor :name, :adrenaline
  def initialize
    @name = nil
    @adrenaline = false
  end
  
  def to_s
    return "Liferush Unit #{@name} #{@adrenaline}"
  end
end
=end

class LifeRush < Game
  
  def initialize
    super
    @units = {}
  end
  
  def mergeUnits(newUnits)
    @units.each() do |k,v|
      if newUnits[k] == nil
        #A unit has died, RIP.
        puts "Rip #{k}:#{v}"
        @units.delete(k)
      end      
    end
    
    newUnits.each() do |k,v|
      if @units[k] == nil
        unit = Unit.new
        unit.name = v
        unit.adrenaline = false
        puts "Spawned #{k}:#{unit} = #{v}"
        @units[k] = unit
      end
    end    
  end
  
  def adrenalineTarget
    adrenalines = self.state.hand.select {|k| k == "Epinephrine"}    
    
    #For now, let's just pick any unit prefering frogs to cockatrices.    
    u = @units.reject() { |k,v| v.adrenaline == true }
    #reject anything that is CCed, harsh maybe? Only basilisks blood would be sucky to buff I guess...
    #u = u.reject() { |k,v| v.name != self.state.units[k]} 
    f = u.select() { |k,v| v.name == "Giant Frog"}
    c = u.select() { |k,v| v.name == "Cockatrice"}
    ce = u.select() { |k,v| v.name == "Elite Cockatrice"}
    js = u.select() { |k,v| v.name == "Jade Staff"}
    dragons = u.select() { |k,v| v.name == "Emerald Dragon"}
    dragons2 = u.select() { |k,v| v.name == "Jade Dragon"}
    
    puts "Adrenaline Targets: #{u}"
    puts "Staves: #{js}, Frogs: #{f}, Elite Cocks: #{ce}"
        
    if js.size > 0
      k = js.keys.last
      return(k)
    elsif (adrenalines.size > 1 and dragons2.size > 0)
      k = dragons2.keys.last
      return(k)
    elsif (adrenalines.size > 1 and dragons.size > 0)
      #if we have spare adrenalines then buff a dragon
      k = dragons.keys.last
      return(k)
    elsif ce.size > 0
      k = ce.keys.last
      return(k)
    elsif f.size > 0
      k = f.keys.last
      return(k)
    elsif c.size > 0 
      k = c.keys.last
      return(k)
    else
      return nil
    end        
  end
  
  def playAndAnimateWeapon
    weapon = false
    ret = false
    
    #puts "Can I animate?"
    
    if GameState.getPermanent(:myweapon) == :noweapon
      if self.state.hand.index("Jade Staff") != nil      
        if self.state.play("Jade Staff")
          weapon = true
          ret = true
        end
      end
    else
      weapon = true
    end
    
    if weapon
      if self.state.hand.index("Animate Weapon") != nil 
        if (state.hand.index("Jade Staff") == nil) and (state.hand.index("Epinephrine") == nil)
          #no point in playing animate if theres no staff / epinephrine to replace / buff it.
          #FIXME: Edge case - if there is already an unbuffed flying staff and only 
          #one Epinephrine don't fly 2nd staff!
        elsif (GameState.getPermanent(:theirshield) == "Gravity Shield") and (state.hand.index("Jade Staff") == nil)
          #if they have a gravity shield up, we don't want to animate unless there's another weapon to play
          #'cos otherwise we can't break down their shield.
        elsif self.state.play("Animate Weapon")
          ret = true
        end
      end     
    end
    
    return ret
  end
  
  def bail?
    if GameState.getPermanent(:theirshield) == "Gravity Shield"
      #FIXME: Actually we can do it with frogs / cocks, but we can't win with just dragons / staves.
      return true
    end
    
    #Firewall and thorns can be a problem too.
    
    return false
  end
  
  def playTurn
    
    #This isn't cut and dry, if they are low hp and we have a weapon then we can
    #play vs shields, infact good chance of mastery in this case.
    #if bail?
    #  raise
    #end
    
    pillars = self.state.playAll("Emerald Tower")
    mergeUnits(self.state.units)
    
    playWhileYouCan( "Shard of Divinity")
    
    if (pillars > 0) and (self.state.playable.index(false) != nil)
      #if we played some towers this turn, and we have some unplayable cards
      #extra delay to update the isplayable() state, it's a little slow stomeitmes after playing a pillar
      puts "pillar delay"
      sleep(0.4)
      GameState.waitForPlay()
    end
    
    while playAndAnimateWeapon() do      
    end
    
    playWhileYouCan( "Giant Frog")
    playWhileYouCan( "Jade Dragon")
    playWhileYouCan( "Emerald Dragon")
    playWhileYouCan( "Elite Cockatrice")    
    playWhileYouCan( "Cockatrice")
        
    #update the game field...
    #GameState.waitForPlay()    
    #newstate = GameState.new    
    #mergeUnits(newstate.units)
    self.state.updateMyUnits()
    mergeUnits(self.state.units)
    
    adrenaline = 0
    #That just leaves adrenaline
    while self.state.hand.index("Epinephrine") != nil && adrenalineTarget != nil 
      self.state.updatePlayable()
      index = self.state.hand.index("Epinephrine")  
      if self.state.playable[index]
        index = adrenalineTarget()
        if self.state.playBuff("Epinephrine", index)
          @units[index].adrenaline = true
          adrenaline+=1
        end
      else
        break
      end
    end
    
    if adrenaline > 0
      sleep (0.25)
    end
    
    if GameState.getPermanent(:myshield) == :noweapon
      #if (self.state.hand.size == 8 or 
      #  ((self.state.hand.index("Jade Dragon") == nil) and (self.state.hand.index("Emerald Dragon") == nil )))
        #FIXME: I assume you don't have both in your deck!
      playWhileYouCan("Thorn Carapace")
      playWhileYouCan("Spine Carapace")
      #end
    end
    
    playWhileYouCan( "Shard of Gratitude")
  end
end