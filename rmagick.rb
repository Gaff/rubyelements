require 'RMagick'

canvas = Magick::Image.new(240, 300,
              Magick::HatchFill.new('white','lightcyan2'))
gc = Magick::Draw.new

