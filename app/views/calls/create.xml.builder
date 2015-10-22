xml.instruct!
xml.Response do |response|
  if !@call.has_recording? && @call.user
    response.Say "Hey #{@call.user.first_name}." if @call.user.first_name
    response.Say "Store a thought:"
    response.Record :maxLength => '300', :action => '/calls.xml', :method => 'post', :transcribe => true, :transcribeCallback => '/transcribe'
  end
end