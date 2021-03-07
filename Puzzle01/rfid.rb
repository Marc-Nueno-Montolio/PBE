require 'ruby-nfc'
class Rfid
    # get all readers available with ruby-nfc gem
    @@readers = NFC::Reader.all
    @@debug = false

    # returns UID in hex format
    def read_uid
        if @@debug
            puts "Available readers: #{@@readers}"
        end
        
        @@readers[0].poll(Mifare::Classic::Tag) do |tag|
            begin
                uid = tag.to_s.split()[0].upcase
                if @@debug
                    puts "#{uid}"
                end
                return uid
            rescue Exception => e
                puts e
            end
        end
    end
end


if __FILE__ == $0
    rf = Rfid. new
    puts "Please login with your university card"
    uid = rf.read_uid
    puts uid
end
