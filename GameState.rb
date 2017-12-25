require '.\Elements'
require 'yaml'
require 'win32screenshot'

class CardImage    
  attr_accessor :width, :height, :name
  attr_reader :data
  @@DEPTH = 4
  
  def to_s()
    return "Cardimage #{@name} #{@width}x#{@height}"
  end
  
  def self.grab(x0,y0,width,height)
    image = CardImage.new()
    image.width = width
    image.height = height
    
    autoit = Elements.autoit
    bytes = []
    (0..width-1).each do |x|
			puts( "Grabbhing height #{x}x#{height}" )

      (0..height-1).each do |y|
        colour = autoit.PixelGetColor( x0+x, y0+y )
        #bytes << colour.pack("l") #convert to series of bytes
        bytes << autoit.PixelGetColor( x0+x, y0+y )
      end
    end            
    image.data = bytes.pack("l*")
    return image    
  end
  
  def data=(value)
    expected = self.width * self.height * @@DEPTH
    raise "Size mismatch #{value.size} wanted #{self.width}x#{self.height}x#{@@DEPTH}=#{expected}" unless 
      value.size == expected
    @data = value
  end
  
  def compare(card)
    if self.class != card.class
      raise "Not a card: #{card}"
    end
    
    if card.width != self.width or card.height != self.height 
      #raise "Size mismatch: #{card.width}x#{card.height} wanted #{self.width}x#{self.height}"
      return 10000 
    end
    
    d1 = self.data.unpack("c*")
    d2 = card.data.unpack("c*")    
    
    #this might be faster...
    #dx =  Array.new(d1.size) {|i| d1[i]+d2[i]}
    
    differences = 0
    diffsum = 0
    (0..self.data.size-1).step(4) do |i|
      #diff = CardImage.colourDistanceString(self.data, card.data, i)
      diff = CardImage.colourDistanceString(d1, d2, i)  
      if diff != 0
        differences = differences+1
      end
      
      diffsum = diffsum + differences
      #print [9,diff/25].min      
      #if i % self.width == 0
      #  print "\n"
      #end
    end
    
    diffsum = diffsum/(self.width*self.height)
    
    return(diffsum )
    
  end
  
  def to_s
    return "Cardimage: #{self.width}x#{self.height}"    
  end
  
  private
  #I'm saving you from yourself here, these methods suck.
  
  def self.rgb( hex)
    #bewarned, this is dog-slow
    rgb = []
    #%w(r g b).inject(hex) {|a,i| rest, rgb[i] = a.divmod 256; rest}
    rest, rgb[1] = hex.divmod(256)
    rest, rgb[2] = rest.divmod(256)
    rest, rgb[3] = rest.divmod(256)
    
    return rgb
  end
  
  @@FUZZ = (255/10)*3
  
  def self.colourDistanceNumeric(a,b)
    
=begin
    rgbA = CardImage.rgb(a)
    rgbB = CardImage.rgb(b)
        
    sum = 0
    
    sum = sum +(rgbA[1]-rgbB[1]).abs
    sum = sum +(rgbA[2]-rgbB[2]).abs
    sum = sum +(rgbA[3]-rgbB[3]).abs
=end
    
    if a==b 
      return 0
    end
    
    #argh, I hate bitwise maths, but this is a whole bunch faster.
    #I suspect if I were a guru I could do this faster still. I think however that we're at the point
    #where it's number of Fixnum operations that hurts not the details of each one.
    sum = ((a-b)>>16).abs    
    a = a&0x00ffff
    b = 0x00ffff
    sum = sum + ((a-b)>>8).abs    
    a = a & 0x00ff
    b = b & 0x00ff
    sum = sum + (a-b).abs

    if sum < @@FUZZ 
      sum = 0
    else        
      sum = sum/3
    end    
        
    return sum
    
  end
  
  def self.colourDistanceString(aa,bb, index)
    sum = 0

    sum = (aa[index]-bb[index]).abs
    sum = sum + (aa[index+1] - bb[index+1]).abs
    sum = sum + (aa[index+2] - bb[index+2]).abs
    
    if sum < @@FUZZ 
      sum = 0
    else        
      sum = sum/3
    end    
        
    return sum    
  end  
end

class Quanta
  attr_accessor :min, :max  
end

class GameState  
  COORDINATES = {
    :myweapon => [662, 454],
    :myshield => [600, 454],
    :theirshield => [538, 30],
    :theirweapon => [600, 30],
    
  }
  CARDSPACING = 24
  CARDHEIGHT = 22
  CARDWIDTH = 70  
  UNITSPACING = 78  
  
  PERMANENTWIDTH = 52
  PERMANENTHEIGHT = 52

	CONTROL_X_OFFSET = 0 #8
	CONTROL_Y_OFFSET = 0 #50

  class << self        
    
    def number_of_cards
      autoit = Elements.autoit    
      cards = 8
      
      #Magic co-ords of left border of the card stack...
      x = 792 + CONTROL_X_OFFSET
      y = 515 + CONTROL_Y_OFFSET
      
      while cards>0
        color = autoit.PixelGetColor(x, y)
				puts "colour at: #{x},#{y} is #{color.to_s(16)}"
        if color != 0xffffff         
          cards = cards - 1
          y = y - CARDSPACING
        else        
          break
        end
        
      end
          
      return cards    
    end
    
    def grabMyUnit(unitIndex)
      #FIXME: I only handle 1 row
      y0 = 323
      x0 = 199
      x0 = x0 + unitIndex*UNITSPACING
      if( unitIndex > 2)
        x0 = x0+1
      end
      image = CardImage.grab(x0, y0, CARDWIDTH, CARDHEIGHT)
      return image   
      #puts "Grabbing #{x0}x#{y0}" 
    end
    
    def isPlayable(cardIndex)
      x0 = 875
      y0 = 283+9 #watch out for cards that cost > 10 quanta to play
      y0 = y0 + cardIndex*CARDSPACING
      if( cardIndex > 2)
        y0 = y0+1
      end
      
      autoit = Elements.autoit
      colour = autoit.PixelGetColor( x0, y0 )
     
      #puts "Playable: #{cardIndex}@#{x0}x#{y0} = #{colour}"
      
      if (colour & 0x0000FF) > 0xB0
        return(true)        
      end
      return(false)
    end
    
    def waitForPlay()      
      while( !self.canPlay?)
        sleep( 0.05)
      end
    end
    
    def waitForMyTurn()
      timeout = 20
      poll = 0.05
      failcount = 0
      
      wait = 0
      while( wait < timeout)
        if(!canPlay? and !cantPlay?)
          failcount = failcount + 1
          if failcount > 10
            puts "I think the game is done"
            return(false)
          end
        else
          failcount = 0
        end
        if(isMyTurn?)
          return(true)
        end
        sleep(poll)
        wait += poll
      end      
      raise      
    end
    
    def waitForPvP()
      
      if (!pvpPage?)
        puts "Non on pvp page; oops"
        return(false)
      end
      
      timeout = 10
      poll = 0.1
      
      wait = 0
      while (wait < timeout)
        if(pvpReady?)
          return(true)
        end
        sleep(poll)
        wait += poll
      end
      
      GameState.click( 450, 392)
      sleep(2)
      return(false)
      
    end
    
    def canPlay?()
      autoit = Elements.autoit
      #The green I can play indicator
      colour = autoit.PixelGetColor(794,282)
      return( colour == 0x00FF00)
    end

    def cantPlay?()
      autoit = Elements.autoit
      #The green I can play indicator
      colour = autoit.PixelGetColor(794,307)
      ret = ( colour & 0xFF0000 >= 0xF00000)
      if !ret
        #puts "Cantplay: #{colour.to_s(16)}"
      end
      return ret
    end    
    
    def isMyTurn?()
      autoit = Elements.autoit
      #The "Done(spacebar)" icon
      colour = autoit.PixelGetColor(139,9)
      return( colour == 0xFEFEFE)
    end

    def won?()
      autoit = Elements.autoit
      #The "Done(spacebar)" icon
      colour = autoit.PixelGetColor(516,357)
      return( colour == 0xFEFEFE)
    end
    
    def elementalMaster?()
      autoit = Elements.autoit
      #The "Done(spacebar)" icon
      colour = autoit.PixelGetColor(127,134)
      return( colour == 0xFFFFFF)
    end
    
    def disconnected?()
      autoit = Elements.autoit
      #The "Done(spacebar)" icon
      colour = autoit.PixelGetColor(237,13)
      return( colour == 0xA73C2D)
    end    
    
    def pvpReady?()
      autoit = Elements.autoit
      #The "start the game" icon
      colour = autoit.PixelGetColor(422,332)
      return( colour == 0xFEFEFE)
    end 

    def pvpPage?()
      autoit = Elements.autoit
      #The "Back to menu" icon
      colour = autoit.PixelGetColor(495,392)
      return( colour == 0xFEFEFE)
    end     
    
    def grabPermanent(index)
      x0, y0  = COORDINATES[index]
      
      image = CardImage.grab(x0, y0, PERMANENTWIDTH, PERMANENTHEIGHT)
      image.name = index
      return image      
    end
    
    def getPermanent(index)
      permanent = GameState.grabPermanent(index)
      c = Elements.allCards.find(permanent)
      if c == nil
        return :unknown
      else
        return c.name
      end
    end    
    
    def grabCard(cardIndex)
      x0 = 791 + CONTROL_X_OFFSET
      y0 = 277 + CONTROL_Y_OFFSET
      y0 = y0 + cardIndex*CARDSPACING
      if cardIndex > 2
        #hack since there seems to be a pixel error with the cards
        y0 = y0-1
      end    

      image = CardImage.grab(x0, y0, CARDWIDTH, CARDHEIGHT)
      return image    
    end
    
    def grabHand()
      ans = []
      (0..self.number_of_cards() - 1).each do |i|
				puts "Getting card #{i}"
        ans[i] = self.grabCard(i)
        ans[i].name = "Hand #{i}"
      end  
      return( ans)
    end
    
    def grabMyUnits()
      ans = []
      (0..6).each do |i|
        ans[i] = self.grabMyUnit(i)
        ans[i].name = "Unit #{i}"
      end
      return(ans)
    end
    
    def getCardHash (cardIndex)
      #Sadly pixel checksum ain't too hot :(
      x = 800+3
      y0 = 283
      y0 = 297
      
      y = y0+cardIndex*CARDSPACING
      if cardIndex > 2
        #hack since there seems to be a pixel error with the cards
        y = y-1
      end
      
      
      autoit = Elements.autoit
      checksum = autoit.PixelChecksum(x, y, x+CARDWIDTH, y + CARDHEIGHT)
      
      puts "Card #{cardIndex}: #{x}:#{y} - #{x+CARDWIDTH}:#{y+CARDHEIGHT} = #{checksum}"
      
      return checksum  
    end
    
    def cardDump
      hexes = []
      (0..GameState.number_of_cards).each { |i|
        hexes << GameState.getCardHash(i)  
      }
      
      puts hexes    
    end
    
    def click(x0,y0)
      autoit = Elements.autoit
      autoit.MouseMove( x0-1, y0-1, 0 )
      x0 = x0+rand(8)
      y0 = y0+rand(3)
      #puts "Clicking #{x0}x#{y0}"
      autoit.MouseMove( x0, y0, 1 )
      autoit.MouseDown("left")
      autoit.MouseUp("left")
      autoit.MouseMove( 0, 0, 0 )
      #autoit.MouseClick("left", x0, y0,0)
    end
    
  end #end <<self
  
  attr_reader :hand
  attr_reader :playable
  attr_reader :units
	attr_reader :bitmap

	def screenshot()
		bitmap = Win32::Screenshot::Take.of(:foreground)
	end
  
  def initialize()
    #hand...    
    @hand = []
    hand = GameState.grabHand()
    hand.each() do |h|
      c = Elements.allCards.find(h)
      if c == nil
        @hand << :unknown
      else
        @hand << c.name
      end            
    end
    
    #units...
    self.updateUnits()
    
    #is playable..
    self.updatePlayable()   
        
  end  
  
  def updateUnits()
    units = self.class.grabMyUnits()
    @units = {}
    units.each_index() do |i|
      c = Elements.allCards.find(units[i])
      if c == nil
        @units[i] = :unknown
      elsif c.name == "No Unit"
      else
        @units[i] = c.name
      end   
    end
  end
  
  def updateMyUnits()
    tries = 0
    
    while tries < 5 do            
      GameState.waitForPlay()
      units = GameState.grabMyUnits()
      #puts "Upadting units: #{units}"
      units.each_index() do |i|
        if units[i] == :unknown and @units[i] != :unknown
          #we should know every unit we can play.
          tries += 1
          sleep (0.5)
        else
          self.updateUnits()
          return
        end
      end
    end
    
    puts "Couldn't update my units"
    raise
  end
  
  def updatePlayable()
    #raise unless GameState.number_of_cards() == self.hand.size()
    GameState.waitForPlay()
    @playable = []
    (0..hand.size()-1).each() do |i|
      @playable[i] = self.class.isPlayable(i)
    end        
  end
  
  def playAll(card)    
    towers = 0
    while( self.hand.index(card) != nil)
      ans = self.play(card) 
      if( ans == false )
        #puts "Click failed"
        raise
      end
      towers = towers + 1   
    end
    
    return( towers)
  end  
  
  def playUnit(unitIndex)        
    #FIXME: I only handle 1 row
    y0 = 323
    x0 = 199
    x0 = x0 + unitIndex*GameState::UNITSPACING
    if( unitIndex > 2)
      x0 = x0+1
    end
    
    #for safety:
    x0 += 2
    y0 += 2
    
    GameState.waitForPlay()    
    GameState.click(x0,y0)
    
    puts "Played unit (#{unitIndex})"
    
  end
  
  def playBuff(card, unitIndex)
    #puts "Playing #{card}"
    index = playInternal(card)
    sleep(0.25)
    #puts "Playing unit #{unitIndex}"
    playUnit(unitIndex)
    #puts "Buffed"
    ret = playCardWaitInternal(index)
    puts "Played buff #{card} (#{index}) on #{unitIndex} - #{ret}  (#{self.hand.size} remain)"
    return ret    
  end
  
  def play(card)
    index = playInternal(card)
    ret = playCardWaitInternal(index)
    puts "Played card #{card} (#{index}) - #{ret} (#{self.hand.size} remain)"
    return ret
  end
  
  def playCardWaitInternal(index)
    ret = false
    #need to sleep a bit before we can click on the next card anyway.    
    (0..50).each do
      if GameState.number_of_cards() == self.hand.size - 1
        self.hand.delete_at(index)
        self.playable.delete_at(index)
        #TODO: What about the creatures?                
        
        ret = true
        break
      end
      sleep(0.05)
    end
    
    return(ret)
  end
  
  def playInternal(card)
    index = nil
    if(card.class == 0.class )
      index = card
    else
      index = self.hand.index(card)
    end        
    
    if index == nil
      return false
    end
    
    x0 = 800+2
    y0 = 283+2
    y0 = y0 + index*GameState::CARDSPACING
    if index > 2
      #hack since there seems to be a pixel error with the cards
      y0 = y0-1
    end    

    GameState.waitForPlay()    
    GameState.click(x0,y0)    

    return(index)
  end
  
  def to_s
    #puts "GameState:"
    puts "Hand: #{hand}"
    puts "Playable: #{playable}"
    puts "Units: #{units}"
  end
  
  
end
