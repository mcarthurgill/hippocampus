
class String

  def self.random i
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    return (0...i).map { o[rand(o.length)] }.join
  end

  def self.auth_token salt, offset
    time_spec = Time.now.to_i / 1000 + offset
    pre = self.salt[0,8]
    post = pre = self.salt[8..-1]
    return Digest::SHA1.hexdigest(Digest::SHA1.hexdigest("#{pre}#{time_spec}#{post}"))
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

end
