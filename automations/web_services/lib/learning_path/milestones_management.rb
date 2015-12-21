class MilestonesManagementRest
  def self.fetch_milestones(caller_id)
    header = { 'x-caller-id' => caller_id }
    LFCommon.rest_call(LFRESOURCES::CONST_FETCH_MILESTONES, nil, header, 'get')
  end

  def self.fetch_milestones_details(caller_id, milestones)
    header = { 'x-caller-id' => caller_id }
    LFCommon.rest_call(LFRESOURCES::CONST_FETCH_MILESTONES_DETAIL % milestones, nil, header, 'get')
  end
end
