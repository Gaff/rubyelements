class Unit
  attr_accessor :name
  attr_accessor :born, :died
  #attr_accessor :hp, :ap #how the hell can I do this?
  attr_accessor :adrenaline
  attr_accessor :poison
  attr_accessor :invokations
  attr_accessor :position
  
  
  def initialize()
    @name = name
    @position = position
    @invokations = 0
  end
  
  def to_s
    return "Unit #{@name} #{@adrenaline}"
  end
end



class Game
  
  attr_accessor :state, :turns, :current, :result, :elapsed, :units, :unitshistory
  
  def initialize()      
    @turns = []
    @quanta = {}
    @state = nil
    @result = nil
    @units = {}
    @unitshistory = []
  end
  
  def findUnits( name )
     found = @units.select {|k,v| v.name == name }
     return found
  end
  
  def mergeUnits(refresh = false)    
    if refresh then
      self.state.updateMyUnits()
    end
    
    newUnits = self.state.units    
    
    @units.each() do |k,v|
      if newUnits[k] == nil then
        #A unit has died, RIP.
        puts "Rip #{k}:#{v}"
        v.died = self.turns.size
        @unitshistory << v
        @units.delete(k)
      end      
    end
    
    newUnits.each() do |k,v|
      if @units[k] == nil then
        unit = Unit.new()
        unit.name = v
        unit.position = k
        unit.born = self.turns.size()
        puts "Spawned #{k}:#{unit} = #{v}"
        @units[k] = unit
      end
    end    
  end
  
  def adjustEnergy(cardname, cost, element)    
    index = @state.hand.index(cardname)
    if index != nil
      playable = @state.playable[index]
      if playable
        if @quanta[element] == nil
          @quanta[element] = cost
        elsif @quanta[element] < cost
          #We think we can't play this card, but we can.
          @quanta[element] = cost
        end
      else
        if @quanta[element] == nil
          #not much we can do here...
        elsif @quanta[element] >= cost
          #We think we can play this card but we can't.
          @quanta[element] = cost - 1
        end
      end      
    end
  end
  
  def playWhileYouHaveQuanta(cardname, cost, element)    
    counter = 0
    while( @quanta[element] >= cost)
      if self.state.play(cardname)
        @quanta[element] -= cost
        counter += 1
        @state.updatePlayable()
        #this line seems odd but should update our quanta if we got the calculation wrong
        self.state = @state
      else
        break
      end
    end
    
    return counter
  end

  def playWhileYouCan(cardname)    
    counter = 0
    while self.state.hand.index(cardname) != nil
      self.state.updatePlayable()
      index = self.state.hand.index(cardname)            
      if self.state.playable[index]
        if self.state.play(cardname)
          counter += 1
        else
          break
        end
      else
        break
      end
    end    
    return counter
  end 
  
  def playTurn
    raise "not implemented!"
  end
  
  def dumpcard
    self.state.play(0)
  end
  
  def playGame
    
    start = Time.now()
    
    begin
    
      while( GameState.waitForMyTurn())
        sleep(0.25)
        
        oldstate = self.state
        
        #Do the state update.
        3.times do              
          self.state = GameState.new
          
          if (oldstate == nil)
            break
          end                              
          
          if (self.state.hand.size == oldstate.hand.size+1)
            break
          end
          
          puts "Hand state problem, retrying..."
          sleep(2)
        end                
        
        puts self.state
        
        if (oldstate != nil ) and (self.state.hand.size != oldstate.hand.size+1)
          raise
        end
        
        mergeUnits()
        
        turn = self.playTurn
        self.turns << turn
        
        #raise if self.turns.size > 20
        GameState.waitForPlay()
        mergeUnits(true)
        Elements.autoit.Send("{SPACE}")
        
        if self.state.hand.size == 8
          puts "Hand is full :("
          sleep(1)
          dumpcard()
        end
        
        sleep(2)
      end
      
      self.elapsed = Time.now() - start
      
      if GameState.won?
        self.result = :win
        if GameState.elementalMaster?
          self.result = :mastery
        end        
        GameState.click(516,357)
        sleep(10.5)
      else
        self.result = :loss
      end
=begin    
    rescue Exception => e
      puts e.message  
      puts e.backtrace.inspect  
      puts "Abandoning game"
      
      GameState.click(53,9)
      sleep(2)
      GameState.click(347,292)
      sleep(2) 
      self.result = :abandoned
      self.elapsed = Time.now() - start
=end    
    end

    puts "Game Over"
    
    GameState.click(454,471)    
  end  
  
end