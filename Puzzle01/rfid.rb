class Rfid
    require 'ruby-nfc'

    # return uid in hexa str
    def read_uid
        readers = NFC::Reader.all
        if debug
            p "Available readers: #{readers}"
        end

        readers[0].poll(IsoDep::Tag, Mifare::Classic::Tag, Mifare::Ultralight::Tag) do |tag|
            begin
                if tag
                    uid = tag
                    uid.upcase!
                    tag.processed!
                end
            rescue Exception => e
                puts e
            end
        end
    end


    if __FILE__ == $0
        rf = Rfid
        uid = rf.read_uid
        puts uid
    end
end