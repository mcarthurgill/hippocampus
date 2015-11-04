
class String

  def self.random i
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    return (0...i).map { o[rand(o.length)] }.join
  end

  def self.auth_token salt, offset
    time_spec = Time.now.to_i / 1000 + offset
    pre = salt[0,8]
    post = salt[8..-1]
    return Digest::SHA1.hexdigest(Digest::SHA1.hexdigest("#{pre}#{time_spec}#{post}"))
  end

  def sha_encrypted
    return Digest::SHA1.hexdigest(Digest::SHA1.hexdigest(self))
  end

  def parse_for_time
    begin  
      Time.zone = 'Central Time (US & Canada)'
      Chronic.time_class = Time.zone
      time = Chronic.parse(self)
      length_check = 36
      if !time && self.length > length_check
        time = Chronic.parse(self[(-1*length_check+2)..-1])
      end
      if !time && self.length > length_check
        time = Chronic.parse(self[0...length_check])
      end
      return time
    rescue
    end 
  end

  def cut_off_signatures_and_replies
    string = "#{self}"
    index = string.index("\n\n\n")
    if index
      string = string[0...index]
    end
    index = string.index("\n--")
    if index
      string = string[0...index]
    end
    index = string.index("----")
    if index
      string = string[0...index]
    end
    index = string.index("> > >")
    if index
      string = string[0...index]
    end
    return string
  end

end
