class DiscussionManagementRest
  def self.fetch_discussions(caller_id, milestone)
    header = { 'x-caller-id' => caller_id }
    LFCommon.rest_call(LFRESOURCES::CONST_FETCH_DISCUSSION % milestone, nil, header, 'get')
  end
end
