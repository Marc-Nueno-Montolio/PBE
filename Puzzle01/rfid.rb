class Rfid
    # return uid in hexa str
    def read_uid
        #TODO: rad uid from sensor
    end

    if __FILE__ == $0
        rf = Rfid....new
        uid = rf.read_uid
        puts uid
    end