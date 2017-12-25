require 'Game.rb'

class TurnInfo
  attr_accessor :stoneTowers
  attr_accessor :graboids
  attr_accessor :shriekers
  attr_accessor :evolves
  attr_accessor :quanta
  attr_accessor :longsword
  
  def initialize()
    @stoneTowers = 0
    @graboids = 0
    @shriekers = 0
    @evolves = 0
    @longsword = 0
    
    @quanta = {
      :earth => 0,
      :time => 0,
      :life => 0,
    }
  end
end

class ShriekerRush < Game
  
  def initialize()
    super
    @quanta[:time] = 0
    @quanta[:earth] = 0
  end
  
  def addTurn(turninfo)
    current.stoneTowers += turninfo.stoneTowers
    current.graboids += turninfo.graboids
    current.shriekers += turninfo.shriekers
    
    @quanta[:time] += 1
    @quanta[:earth] += current.stoneTowers
    
  end
      
  def state=(newstate)
    @state = newstate
    self.adjustEnergy( "Elite Graboid", 3, :earth)
    self.adjustEnergy( "Elite Shrieker", 8, :earth)
    @state
  end
  
  def playTurn            
    ti = TurnInfo.new    
    
    ti.stoneTowers += self.state.playAll("Stone Tower")
    @quanta[:earth] += ti.stoneTowers
            
    #Now, are there any graboids on the field?
    self.state.units.each() do |k,v|
      if (v=="Elite Graboid (burrowed)")
        self.state.playUnit(k)
      end
    end
    
    if (ti.stoneTowers > 0) and (self.state.playable.index(false) != nil)
      #if we played some towers this turn, and we have some unplayable cards
      #extra delay to update the isplayable() state, it's a little slow stomeitmes after playing a pillar
      puts "pillar delay"
      sleep(0.5)
      GameState.waitForPlay()
    end
    
    if self.state.hand.index("Long Sword") != nil
      if GameState.getPermanent(:myweapon) == :noweapon
        if self.state.play("Long Sword")
          ti.longsword += 1
        end
      end
    end
    
    #Can we play any shriekers?
    ti.shriekers += playWhileYouCan( "Elite Shrieker") #, 8, :earth)
    ti.graboids += playWhileYouCan( "Elite Graboid") #, 3, :earth)
            
    puts "Turn done."
    
    if self.state.hand.size == 8
      raise
    end
    
    return ti
  end
end