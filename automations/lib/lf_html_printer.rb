require 'erb'

class LFHtmlPrinter
  include ERB::Util # for the #h method
  def initialize(output)
    @output = output
  end

  def print_html_start
    @output.puts HTML_HEADER
    @output.puts REPORT_HEADER
  end

  def print_example_group_end
    @output.puts "  </dl>"
    @output.puts "</div>"
  end

  def print_example_group_start( group_id, description, number_of_parents)
    @output.puts "<div id=\"div_group_#{group_id}\" class=\"example_group passed\">"
    @output.puts "  <dl #{indentation_style(number_of_parents)}>"
    @output.puts "  <dt id=\"example_group_#{group_id}\" class=\"passed\">#{h(description)}</dt>"
  end

  def print_example_passed( description, run_time )
    formatted_run_time = sprintf("%.5f", run_time)
    @output.puts "    <dd class=\"example passed\"><span class=\"passed_spec_name\">#{h(description)}</span><span class='duration'>#{formatted_run_time}s</span></dd>"
  end

  def print_example_failed( pending_fixed, description, run_time, failure_id, exception, extra_content, escape_backtrace = false )
    formatted_run_time = sprintf("%.5f", run_time)

    @output.puts "    <dd class=\"example #{pending_fixed ? 'pending_fixed' : 'failed'}\">"
    @output.puts "      <span class='failed_spec_name'>#{h(description)}</span>"
    @output.puts "      <span class=\"duration\">#{formatted_run_time}s</span>"
    @output.puts "      <div class=\"failure\" id=\"failure_#{failure_id}\">"
    if exception
      @output.puts "        <div class=\"message\"><pre>#{h(exception[:message])}</pre></div>"
      if escape_backtrace
        @output.puts "        <div class=\"backtrace\"><pre>#{h exception[:backtrace]}</pre></div>"
      else
        @output.puts "        <div class=\"backtrace\"><pre>#{exception[:backtrace]}</pre></div>"
      end
    end
    @output.puts "      </div>"
    @output.puts "    </dd>"
  end

  def print_example_pending( description, pending_message )
    @output.puts "    <dd class=\"example not_implemented\"><span class=\"not_implemented_spec_name\">#{h(description)} (PENDING: #{h(pending_message)})</span></dd>"
  end

  def print_summary( was_dry_run, duration, example_count, failure_count, pending_count )
    # TODO - kill dry_run?
    if was_dry_run
      totals = "This was a dry-run"
    else
      totals =  "#{example_count}"
      totals_pass = "#{example_count - failure_count - pending_count}"
      totals_fail = "#{failure_count}"
      totals_pending = "#{pending_count}"
    end

    #LGG: Convert time to hh:mm:ss
    time = duration
    hour = format("%02d",time/3600)
    time = time%3600
    min = format("%02d",time/60)
    time = time%60
    if(time < 1)
      sec = "01"
    else
      sec = format("%02d",time)
    end
    formatted_duration = "#{hour}:#{min}:#{sec}"
    #End editing

    @output.puts "<script type=\"text/javascript\">document.getElementById('duration').innerHTML = \"#{formatted_duration}\";</script>"
    @output.puts "<script type=\"text/javascript\">document.getElementById('totals').innerHTML = \"#{totals}\";</script>"
    #LGG: Adding total_pass, fail, pending
    @output.puts "<script type=\"text/javascript\">document.getElementById('totals_pass').innerHTML = \"#{totals_pass}\";</script>"
    @output.puts "<script type=\"text/javascript\">document.getElementById('totals_fail').innerHTML = \"#{totals_fail}\";</script>"
    @output.puts "<script type=\"text/javascript\">document.getElementById('totals_pending').innerHTML = \"#{totals_pending}\";</script>"
    #End editing

    @output.puts "</div>"
    @output.puts "</div>"
    @output.puts "</body>"
    @output.puts "</html>"
  end

  def flush
    @output.flush
  end

  def move_progress( percent_done )
    @output.puts "    <script type=\"text/javascript\">moveProgressBar('#{percent_done}');</script>"
    @output.flush
  end

  def make_header_red
    @output.puts "    <script type=\"text/javascript\">makeRed('rspec-header');</script>"
  end

  def make_header_yellow
    @output.puts "    <script type=\"text/javascript\">makeYellow('rspec-header');</script>"
  end

  def make_example_group_header_red(group_id)
    @output.puts "    <script type=\"text/javascript\">makeRed('div_group_#{group_id}');</script>"
    @output.puts "    <script type=\"text/javascript\">makeRed('example_group_#{group_id}');</script>"
  end

  def make_example_group_header_yellow(group_id)
    @output.puts "    <script type=\"text/javascript\">makeYellow('div_group_#{group_id}');</script>"
    @output.puts "    <script type=\"text/javascript\">makeYellow('example_group_#{group_id}');</script>"
  end

  private

  def indentation_style( number_of_parents )
    "style=\"margin-left: #{(number_of_parents - 1) * 15}px;\""
  end

REPORT_HEADER = <<-EOF
<div class="rspec-report">
  <div id="rspec-header">
    <!--LGG: Create summary table-->
    <h1>Leapfrog Automation</h1>
    <table id="table">
      <tr>
        <td align=center><b>Show</b></td>
        <td align=left><b>Total</b></td>
        <td align=right><strong id="totals">&#160;</strong></td>
      </tr>
      <tr>
        <td width=15% align=center><input id="passed_checkbox"  name="passed_checkbox"  type="checkbox" checked="checked" onchange="apply_filters()" value="1" /></td>
        <td width=60% align=left><font color = "65C400">✓ </font>Passed</td>
        <td width=25% align=right><font color="#65C400"><strong id = "totals_pass"></strong></font></td>
      </tr>
      <tr>
        <td align=center><input id="failed_checkbox"  name="failed_checkbox"  type="checkbox" checked="checked" onchange="apply_filters()" value="2" /></td>
        <td align=left><font color = "FF0000">✗  </font>Failed</td>
        <td align=right><font color="#FF0000"><strong id = "totals_fail"></strong></font></td>
      </tr>
      <tr>
        <td align=center><input id="pending_checkbox" name="pending_checkbox" type="checkbox" checked="checked" onchange="apply_filters()" value="3" /></td>
        <td align=left><font color = "0000CC">Δ </font>Pending</td>
        <td align=right><font color="#0000CC"><strong id = "totals_pending"></strong></font></td>
      </tr>
      <tr>
        <td colspan="2" align=right>Execution time (hh:mm:ss)</td>
        <td colspan="2" align=right><label id="duration">&#160;</label></td>
      </tr>
    </table>
    <!--End editting -->
  </div>

  <div class="results">
  EOF

  GLOBAL_SCRIPTS = <<-EOF

  function addClass(element_id, classname) {
    document.getElementById(element_id).className += (" " + classname);
  }

  function removeClass(element_id, classname) {
    var elem = document.getElementById(element_id);
    var classlist = elem.className.replace(classname,'');
    elem.className = classlist;
  }

  function moveProgressBar(percentDone) {
    document.getElementById("rspec-header").style.width = percentDone +"%";
  }

  function makeRed(element_id) {
    removeClass(element_id, 'passed');
    removeClass(element_id, 'not_implemented');
    addClass(element_id,'failed');
  }

  function makeYellow(element_id) {
    var elem = document.getElementById(element_id);
    if (elem.className.indexOf("failed") == -1) {  // class doesn't includes failed
      if (elem.className.indexOf("not_implemented") == -1) { // class doesn't include not_implemented
        removeClass(element_id, 'passed');
        addClass(element_id,'not_implemented');
      }
    }
  }

  function apply_filters() {
    var passed_filter = document.getElementById('passed_checkbox').checked;
    var failed_filter = document.getElementById('failed_checkbox').checked;
    var pending_filter = document.getElementById('pending_checkbox').checked;

    assign_display_style("example passed", passed_filter);
    assign_display_style("example failed", failed_filter);
    assign_display_style("example not_implemented", pending_filter);
  }

  function get_display_style(display_flag) {
    var style_mode = 'none';
    if (display_flag == true) {
      style_mode = 'block';
    }
    return style_mode;
  }

  function assign_display_style(classname, display_flag) {
    var style_mode = get_display_style(display_flag);
    var elems = document.getElementsByClassName(classname)
    for (var i=0; i<elems.length; i++) {
      elems[i].style.display = style_mode;
    }
  }

  function assign_display_style_for_group(classname, display_flag, subgroup_flag) {
    var display_style_mode = get_display_style(display_flag);
    var subgroup_style_mode = get_display_style(subgroup_flag);
    var elems = document.getElementsByClassName(classname)
    for (var i=0; i<elems.length;i++) {
      var style_mode = display_style_mode;
      if ((display_flag != subgroup_flag) && (elems[i].getElementsByTagName('dt')[0].innerHTML.indexOf(", ") != -1)) {
        elems[i].style.display = subgroup_style_mode;
      } else {
        elems[i].style.display = display_style_mode;
      }
    }
  }
  EOF

  GLOBAL_STYLES = <<-EOF

  .rspec-report {
    width: 900px; margin: 20px auto; position: relative;
  }

  pre {
    word-wrap: break-word;
  }

  #rspec-header {
    background: #FFFFFF; color: #fff; height: 13em; margin-left: 20px;
  }

  .rspec-report h1 {
    margin: 0px 10px 0px 10px;
    padding: 10px 0px 0px 0px;
    font-family: Helvetica, Arial;
    font-size: 1.8em;
    color: #000000;
  }

  #table{
    border-spacing: 0;
    width: 300px;
    margin-left: 10px;
    margin-top: 10px;
    border: 1px solid #DDD;
  }
  table td{
    border-bottom: 1px solid #DDDDDD;
    border-left: 1px solid #DDDDDD;
    color: #000000;
    padding: 2px 5px 2px 5px;
    font-family: Helvetica, Arial;
    font-size: 12pt;
  }

  #display-filters {
    padding: 5px 10px;
    font-family: Helvetica, Arial;
  }

  #summary {
    padding: 5px 10px;
    font-family: Helvetica, Arial;
  }

  #summary p {
    font-family: Helvetica, Arial;
    font-size: 12pt;
  }

  #summary #totals {
    font-family: Helvetica, Arial;
    font-size: 12pt;
  }

  .example_group {
    margin: 0 10px 5px;
    background: #fff;
  }

  #example_group_1 {
    font-family: Helvetica, Arial;
    font-size: 12pt;
    padding: 0px 0px 0px 5px;
  }

  dl {
    margin: 0; padding: 0 0 5px;
    font-family: Helvetica, Arial;
  }

  #totals_pass, #totals_fail, #totals_pending{
    font-weight: normal;
  }

  dt {
    padding: 0px 0px 5px 20px;
    background: #FFFFFF;
    color: #000000;
    font-weight: bold;
    font-family: Helvetica, Arial;
    font-size: 12pt;
  }

  dt::before {
    color: #65c400;
    content: "✓ ";
    margin-left: -10px;
  }

  dt.not_implemented {
    color: #000000;
    background: #FFFFFF
  }

  dt.not_implemented::before {
    content: "Δ ";
    color:#0000CC;
  }

  dt.pending_fixed {
    color: #000000;
    background: #FFFFFF
  }

  dt.pending_fixed::before {
    content: "℗";
    position: absolute;
    left: 10px;
    color:#FFA500;
  }

  dt.failed {
    color: #000000;
    background: #FFFFFF
  }

  dt.failed:nth-of-type(n + 1)::before {
    content: "✗ ";
    color:#FF0000;
  }

  dd {
    margin: 0px 0px 0px 40px;
    padding: 3px 3px 3px 10px;
    font-family: Helvetica, Arial;
    font-size: 12pt;
  }

  dd .failure{
    font-size: 10pt;
    color: #FF0000;
  }

  dd .duration {
    padding-left: 5px;
    text-align: right;
    right: 0px;
    float:right;
    font-weight: normal;
  }

  dd.example.passed {
    border-left: 5px solid #65C400;
    background: #FFFFFF;
    color: #000000;
  }

  dd.example.passed:nth-child(2n+1)::before {
    color: #65c400;
    content: "✓ \u00A0\u00A0\u00A0";
    margin-left: -30px;
  }

  dd.example.failed {
    border-left: 5px solid #FF0000;
    background: #FFFFFF;
    color: #000000;
  }

  dd.example.failed::before {
    content: "✗ \u00A0\u00A0\u00A0";
    color: #FF0000;
    margin-left: -30px;
  }

  dd.example.not_implemented {
    border-left: 5px solid #0000CC;
    background: #FFFFFF;
    color: #000000;
  }

  dd.example.not_implemented::before {
    content: "Δ \u00A0\u00A0\u00A0";
    color: #0000CC;
    margin-left: -30px;
  }

  dd.example.pending_fixed {
    border-left: 5px solid #FFA500;
    background: #FFFFFF;
    color: #0000CC;
  }

  dd.example.pending_fixed::before {
    content: "℗";
    position: absolute;
    left: 45px;
    color:#FFA500;
  }

  dd.example:nth-of-type(2n + 1) {
    background: #E8E8E8 ;
  }

  #rspec-header.not_implemented {
    color: #000000;
    background: #FFFFFF;
  }

  #rspec-header.pending_fixed {
    color: #000000;
    background: #FFFFFF;
  }

  #rspec-header.failed {
    color: #000000;
    background: #FFFFFF;
  }

  .backtrace {
    color: #FF0000;
    font-family: Helvetica, Arial;
    font-size: 10pt;
  }

  a {
    color: #BE5C00;
  }
  EOF

  HTML_HEADER = <<-EOF
  <!DOCTYPE html>
  <html lang='en'>
  <head>
    <title>Leapfrog Automation Result</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="Expires" content="-1" />
    <meta http-equiv="Pragma" content="no-cache" />
    <style type="text/css">
    body {
      margin: 0;
      padding: 0;
      background: #fff;
      font-size: 12pt;
      font-family: "Helvetica, Arial";
    }
    </style>
    <script type="text/javascript">
      // <![CDATA[
      #{GLOBAL_SCRIPTS}
      // ]]>
    </script>
    <style type="text/css">
      #{GLOBAL_STYLES}
    </style>
  </head>
  <body>
  EOF
end