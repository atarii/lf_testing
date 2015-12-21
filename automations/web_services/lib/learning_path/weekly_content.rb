class WeeklyContent
  def self.fetch_weekly_content_baby_center(caller_id, week_since_birth)
    header = { 'x-caller-id' => caller_id }
    LFCommon.rest_call(LFRESOURCES::CONST_FETCH_WEEKLY_CONTENT_BABY_CENTER % week_since_birth, nil, header, 'get')
  end

  def self.fetch_weekly_content_milestones(caller_id, milestone, calendar_week)
    header = { 'x-caller-id' => caller_id }
    LFCommon.rest_call(LFRESOURCES::CONST_FETCH_WEEKLY_CONTENT_MILESTONES % [milestone, calendar_week], nil, header, 'get')
  end
end
