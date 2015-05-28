xml.instruct!
xml.Response do |response|
  if !@call.has_recording?
    response.Say "Hey Will, it's your Hippocampus."
    response.Say "Store a thought:"
    response.Record :maxLength => '300', :action => '/calls.xml', :method => 'post', :transcribe => true, :transcribeCallback => '/transcribe'
  end
end