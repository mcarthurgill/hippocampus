class String

  def parse_for_time
    Time.zone = 'Central Time (US & Canada)'
    Chronic.time_class = Time.zone
    time = Chronic.parse(self)
    length_check = 36
    if !time && self.length > length_check
      time = Chronic.parse(self[(-1*length_check+2)..-1])
    end
    if !time && self.length > length_check
      time = Chronic.parse(self[0...(length_check-2)])
    end
    return time
  end

end