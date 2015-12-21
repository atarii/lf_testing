class Timer
  @@data = []

  def self.loc_to_s
    loc = caller_locations(2,2)[0]
    "#{Pathname.new(loc.path).basename}:#{loc.lineno} #{loc.label}"
  end

  def self.check(message = '')
    @@data = [] if @@data.nil?
    now = Time.now

    if @@data.size == 0
      Rails.logger.info "|| Timer | #{@@data.size.to_s.rjust(2, ' ')} | Starting at #{now.strftime '%I:%M.%6N %P'} | #{Timer.loc_to_s} | message ||"
      @@data << [now, rand(36**8).to_s(36)]
    end

    Rails.logger.info " | Timer | #{@@data.size.to_s.rjust(2, ' ')} | #{'%.6f' % (now - @@data[-1][0])} | #{Timer.loc_to_s} | #{message} |"
    @@data << [now, message]
  end

  def self.end
    now = Time.now
    Rails.logger.info " | Timer | #{@@data.size.to_s.rjust(2, ' ')} | Stopped at #{now.strftime '%I:%M.%6N %P'} | #{Timer.loc_to_s} | Total: #{'%.6f' % (now - @@data[0][0])} |"
    @@data = []
  end

  def example_usage
    Timer.check 'starting usage_example'

    range = (1..100).to_a
    range.each do |n|
      sleep(rand(0.001..0.09))
    end
    Timer.check 'range.each - sleep'

    count = 0
    range.each do |n|
      count += n
    end
    Timer.check 'range.each - count'

    Timer.end
  end
end
