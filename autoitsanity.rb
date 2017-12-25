require 'win32ole'

begin
  autoit = WIN32OLE.new('AutoItX3.Control')
    
  loop do
   autoit.ControlClick("Microsoft Internet Explorer",'', 'OK')
   sleep(5)
  end
       
rescue Exception => e
  puts e
end

