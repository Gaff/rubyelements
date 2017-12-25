
require 'win32ole'
require '.\GameState'

class AllCards
  attr_accessor :deckname
  
  def initialize
    @cards = []
  end
  
  def find(card)
    @cards.each() do |c|
      if c.compare(card) < 365 then
        return(c)
      end
    end
    return( nil )    
  end
  
  def lookup(card, expected)
    c = self.find(card)
    if c != nil then
      puts "#{card.name} Found: #{c.name}"
      if expected != nil
        raise unless c.name == expected
      end
    else
      if expected != nil
        puts "#{card.name} New Card!"      
        card.name = expected
        self.add(card)
        return( true )
      else
        puts "#{card.name} Unknown Card"
      end
    end
  end
  
  def add(card)
    raise unless find(card) == nil
    @cards << card
  end
  
  def save!()
    file = self.deckname + ".yaml"
    File.open(file, "w") {|file| file.puts(self.to_yaml) }
  end
  
  def self.load(deckname)
    filename = deckname + ".yaml"
    
    if File.exists? (filename)
      ruby_obj = YAML::load( File.open( filename ) )

      if ruby_obj 
        ruby_obj.deckname = deckname
        return ruby_obj
      end    
    end
    
    out = AllCards.new()
    out.deckname = deckname
    return(out)
  end
end

  
class Elements  
  TITLE = "Adobe Flash Player 10" 

  Elements = [
    :earth,
    :time,
  ]
  
  #"self." and "@@" mean static
  @@autoit = nil
  @@deck = nil
  @deckname = nil

  class << self
    attr_accessor :deckname
  end 
  
  def self.allCards
    unless @@deck
      @@deck = AllCards.load(self.deckname)
    end
    @@deck
  end
  
  def self.autoit
    unless @@autoit
      begin
        @@autoit = WIN32OLE.new('AutoItX3.Control')
      rescue WIN32OLERuntimeError
        _register('AutoItX3.dll')
        @@autoit = WIN32OLE.new('AutoItX3.Control')
      end
      @@autoit.Opt("PixelCoordMode", 2)
      @@autoit.Opt("MouseCoordMode", 2)
    end      
    @@autoit
  end
  
  def self.focus
		
    self.autoit.WinActivate( TITLE ) 
    self.autoit.WinMove( TITLE,"", 80, 1, 926, 588 )
  end  
end
