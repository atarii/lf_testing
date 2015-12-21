$(document).ready(function () {
  $('#btn_smtp_settings').click(function () {
    var $glbLoader = $('.glb-loader');
    $glbLoader.show();

    var address = $('#address').val(),
      port = $('#port').val(),
      domain = $('#domain').val(),
      user_name = $('#username').val(),
      password = $('#password').val(),
      attachment_type = $('#attachment_type').find('label:has(input:checked) > input').val();

    var request = update_smtp_settings(address, port, domain, user_name, password, attachment_type);
    request.done(function (data) {
      $('#smtp_settings_msg').html(data);
      $glbLoader.hide();
    });
    request.fail(function (jqXHR) {
      $('#smtp_settings_msg').html(jqXHR.responseText);
      $glbLoader.hide();
    });

    return false;
  });

  function validateNumber($ele, name, $error_div) {
    var number = $ele.val();
    number = $.isNumeric(number) ? parseInt(number) : -1;

    var min = parseInt($ele.attr('min')),
      max = parseInt($ele.attr('max')),
      minMaxErr = number > max || number < min;

    if (number === -1) {
      appendErrorMsg(name + ', please enter a number!', $error_div);
      return false;
    }
    else if (minMaxErr) {
      appendErrorMsg(name + ', must be between ' + min + ' and ' + max, $error_div);
      return false;
    }
    return true;
  }

  // Click to update Outpost refresh rate
  $('#btn_outpost_setting').click(function () {
    var $refresh = $('#outpost_refresh_rate'),
      $error_div = $('#outpost_settings_msg');

    $('.glb-loader').show();
    $error_div.empty();

    if (validateNumber($refresh, 'Refresh rate', $error_div)) {
      updOutpostSettings($refresh.val());
    }
  });

  // Click to update Running refresh rate
  $('#btn_run_queue_settings').click(function () {
    var $limit = $('#limit_running_test'),
      $refresh = $('#refresh_rate'),
      $error_div = $('#run_queue_settings_msg');

    $('.glb-loader').show();
    $error_div.empty();

    if (validateNumber($limit, 'Limit max', $error_div) && validateNumber($refresh, 'Refresh rate', $error_div)) {
      upd_queue_option($limit.val(), $refresh.val());
    }
  });

  // Click to update Email refresh rate
  $('#btn_email_queue_settings').click(function () {
    var $email_refresh_rate = $('#email_refresh_rate'),
      $error_div = $('#email_queue_settings_msg');

    $('.glb-loader').show();
    $error_div.empty();

    if (validateNumber($email_refresh_rate, 'Refresh rate', $error_div)) {
      update_email_queue_setting($email_refresh_rate.val());
    }
  });

  function update_smtp_settings(address, port, domain, username, password, att_type) {
    var myData = {
      'address': address,
      'port': port,
      'domain': domain,
      'username': username,
      'password': password,
      'attachment_type': att_type
    };
    return $.ajax({
      type: 'POST',
      url: '/rails_app_config/update_smtp_settings',
      data: myData,
      dataType: 'html'
    });
  }

  function upd_queue_option(limit_number, refresh_rate) {
    var myData = {
      'limit_number': limit_number,
      'refresh_rate': refresh_rate
    };
    var request = $.ajax({
      type: 'POST',
      url: '/auto_config/update_run_queue_option',
      data: myData,
      dataType: 'html'
    });
    request.done(function (data) {
      $('#run_queue_settings_msg').html(data);
      $('.glb-loader').hide();
    });
    request.error(function () {
      $('#run_queue_settings_msg').html('<div class="alert alert-error">Fail to update</div>');
      $('.glb-loader').hide();
    });
  }

  function update_email_queue_setting(email_refresh_rate) {
    var myData = {
      'email_refresh_rate': email_refresh_rate
    };
    var request = $.ajax({
      type: 'POST',
      url: '/auto_config/update_email_queue_setting',
      data: myData,
      dataType: 'html'
    });
    request.done(function (data) {
      $('#email_queue_settings_msg').html(data);
      $('.glb-loader').hide();
    });
    request.error(function () {
      $('#email_queue_settings_msg').html('<div class="alert alert-error">Fail to update</div>');
      $('.glb-loader').hide();
    });
  }

  function updOutpostSettings(refreshRate) {
    var myData = {
      'outpost_refresh_rate': refreshRate
    };

    var request = $.ajax({
      type: 'POST',
      url: '/auto_config/update_outpost_settings',
      data: myData,
      dataType: 'html'
    });

    request.done(function (data) {
      $('#outpost_settings_msg').html(data);
      $('.glb-loader').hide();
    });

    request.error(function () {
      $('#outpost_settings_msg').html('<div class="alert alert-error">Fail to update</div>');
      $('.glb-loader').hide();
    });
  }

  function appendErrorMsg(msg, $error_div) {
    $error_div.append('<div class="alert alert-error">' + msg + '</div>');
    $('.glb-loader').hide();
  }
});
