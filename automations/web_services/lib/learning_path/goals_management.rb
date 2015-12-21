class GoalsManagementRest
  def self.fetch_goals(caller_id, milestone)
    header = { 'x-caller-id' => caller_id }
    LFCommon.rest_call(LFRESOURCES::CONST_FETCH_GOALS % milestone, nil, header, 'get')
  end
end
