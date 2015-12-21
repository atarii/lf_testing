require 'active_support/core_ext/hash/deep_merge'
require 'rspec/core/formatters/base_formatter'
require 'json'

class LFJsonFormatter < RSpec::Core::Formatters::BaseFormatter
  attr_reader :output_hash, :example_group_number

  def initialize(output)
    super
    @output_hash = {}
    @example_group_number = 0
    @example_number = 0
    @group_example_in_group = false
    @groups = []
    @index = 0
    @pending_count_to_minus = 0
    @current_example_group = []
    @current_examples = []
  end

  def start(notification)
    super
    @output_hash[:cases] = {}
    print_to_file
  end

  # groups is an array that includes contexts
  def recur_groups(groups)
    temp = groups.clone
    return @current_examples = {
      name: temp.last.description,
      steps: []
    } if temp.length == 1

    {
      name: temp.shift.description,
      steps: [recur_groups(temp)]
    }
  end

  def example_group_started(notification)
    super
    @example_group_number += 1
    @output_hash[:cases][:name] = notification.description if @example_group_number == 1

    if @groups.any? && !notification.to_s.include?(@groups.last.to_s)
      @groups.pop
      @index += 1
    else
      @index += 1 if notification.parent_groups.length == 2
    end

    if @example_group_number > 1
      @groups << notification
      @group_example_in_group = @groups.length == 1 && notification.examples.any? && notification.children.any?
      @current_example_group << recur_groups(@groups) if @group_example_in_group
    end

    unless notification.children.any?
      temp_group = recur_groups(@groups)
      temp_example = @current_example_group[@index - 1]

      case @groups.length
      when 2
        if temp_example && (temp_example[:steps].empty? || temp_example[:name] == temp_group[:name])
          @current_example_group[@index - 1].deep_merge!(temp_group) do |_k, v1, v2|
            v1 == v2 ? v1 : v1 + v2
          end
        else
          @current_example_group << temp_group
        end
      when 1
        @current_example_group << temp_group
      end
    end

    @output_hash[:cases][:steps] = @current_example_group
    print_to_file
  end

  def start_dump
    print_to_file
  end

  def example_started(_notification)
    @example_number += 1
  end

  def custom_example_name_status(example)
    if example.execution_result[:pending_fixed] && example.execution_result[:pending_message].start_with?('***')
      @pending_count_to_minus += 1
      name = example.execution_result[:pending_message]
      name.slice! '***'
      { status: 'passed', name: name }
    else
      name = example.description
      name += " (PENDING: #{example.execution_result[:pending_message]})" if example.execution_result[:status].downcase == 'pending'
      if name.downcase.include? 'blocked:'
        name.slice! '(PENDING: No reason given)' if example.execution_result[:pending_message] == 'No reason given'
        name.slice! 'PENDING: ' if example.execution_result[:pending_message].include? 'Precondition failed'
      end
      { status: example.execution_result[:status], name: name }
    end
  end

  def save_example(example)
    status_name = custom_example_name_status example

    it = {
      name: status_name[:name],
      status: status_name[:status],
      duration: Time.at(example.execution_result[:run_time]).utc.strftime('%H:%M:%S.%5N')
    }.tap do |it|
      if e = example.exception
        rindex = e.backtrace.rindex { |n| n.include? example.metadata[:file_path][1..-1] } || -1

        if e.class == RSpec::Expectations::ExpectationNotMetError
          message = e.message
          backtrace = ''
        else
          message = 'Error with testing page - see debug info for details'
          backtrace = "#{e} \n" + e.backtrace[0..rindex].join("\n")
        end

        it[:exception] = {
          message: message,
          backtrace: backtrace,
          file_path: example.metadata[:location]
        }
      end
    end

    if example.example_group.description == @output_hash[:cases][:name]
      @output_hash[:cases][:steps] << it
      @index += 1
    else
      @current_examples[:steps] << it
    end

    @groups.pop if @groups.any? && example.example_group.description == @groups.last.description && !@group_example_in_group
  end

  def example_passed(passed)
    save_example passed
    print_to_file
  end

  def example_failed(failure)
    save_example failure
    print_to_file
  end

  def example_pending(pending)
    save_example pending
    print_to_file
  end

  def dump_summary(duration, example_count, failure_count, pending_count)
    failure_count -= @pending_count_to_minus if @pending_count_to_minus != 0
    super(duration, example_count, failure_count, pending_count)

    @output_hash[:cases][:total_steps] = example_count
    @output_hash[:cases][:total_passed] = example_count - failure_count - pending_count
    @output_hash[:cases][:total_failed] = failure_count
    @output_hash[:cases][:total_uncertain] = pending_count
    @output_hash[:cases][:duration] = Time.at(duration).utc.strftime('%H:%M:%S')

    print_to_file
  end

  def close
    output.close if IO == output && output != $stdout
  end

  private

  def print_to_file
    output.rewind
    output.flush
    output.write @output_hash[:cases].to_json
  end
end
