class ChildManagementRest
  def self.fetch_child(caller_id, child_id, session)
    header = { 'x-caller-id' => caller_id, 'x-session-token' => session }
    LFCommon.rest_call(LFRESOURCES::CONST_FETCH_CHILD % child_id, nil, header, 'get')
  end

  def self.fetch_child_goals(caller_id, session, child_id, child_goal, child_goal_status)
    params = { 'childGoal' => child_goal, 'childGoalStatus' => child_goal_status }
    header = { 'x-caller-id' => caller_id, 'x-session-token' => session }
    LFCommon.rest_call(LFRESOURCES::CONST_FETCH_CHILD_GOALS % child_id, params, header, 'get')
  end

  def self.update_child_goals(caller_id, session, child_id, child_goal, child_goal_status)
    params = { 'childGoal' => child_goal, 'childGoalStatus' => child_goal_status }
    header = { 'x-caller-id' => caller_id, 'x-session-token' => session }
    LFCommon.rest_call(LFRESOURCES::CONST_UPDATE_CHILD_GOALS % child_id, params, header, 'put')
  end
end
