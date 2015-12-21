class SetupInfo
  def self.fetch_setup_info(caller_id)
    header = { 'x-caller-id' => caller_id }
    LFCommon.rest_call(LFRESOURCES::CONST_FETCH_SETUP_INFO, nil, header, 'get')
  end
end
