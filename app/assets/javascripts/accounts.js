$(document).ready(function () {
  $("input[value='Link device']").click(function () {
    // Validate Env
    if ($('#env input:radio:checked').length === 0) {
      return false;
    }

    // Validate Email
    var emailRegex = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    var $email = $('#atg_ld_email');
    if ($email.val().match(emailRegex)) {
      mark_control_status($email, 'valid');
    } else {
      mark_control_status($email, 'invalid');
      return false;
    }

    // Validate Password
    var $password = $('#atg_ld_password');
    if ($password.val() === '') {
      mark_control_status($password, 'invalid');
      return false;
    } else {
      mark_control_status($password, 'valid');
    }

    // Validate Device serial
    var $device_serial = $('#atg_ld_deviceserial');
    if ($('.manual').css('display') === 'block') {
      if ($device_serial.val() === '') {
        mark_control_status($device_serial, 'invalid');
        return false;
      } else {
        mark_control_status($device_serial, 'valid');
      }
    }

    // Show loading indicator
    $('.glb-loader').show();

    // specify method
    var url = '/accounts/process_linking_devices';
    var mydata = {
      'atg_ld_email': $email.val(),
      'atg_ld_password': $password.val(),
      'atg_ld_platform': $('#atg_ld_platform').val(),
      'atg_ld_env': $('#env label input:radio:checked').val(),
      'atg_ld_autolink': $("#atg_ld_autolink").is(":checked"),
      'atg_ld_children': $('#atg_ld_children').val(),
      'atg_ld_deviceserial': $device_serial.val()
    };

    $.ajax({
      type: 'GET',
      url: url,
      data: mydata,
      dataType: 'json',
      success: function () {
        $('.glb-loader').hide();
        alert('Your account is linked to devices successfully!');
      },
      error: function () {
        $('.glb-loader').hide();
        alert('Error while linking device. Please try again!');
      }
    });
  });

  function mark_control_status($element, status) {
    if (status === 'invalid') {
      $element.css({
        'background': 'url(\'/assets/ui-bg_diagonals-thick_18_b81900_40x40.png\') repeat scroll 50% 50% #b81900',
        'border': '1px solid #cd0a0a',
        'color': '#fff'
      });
      $element.focus();
    } else {
      $element.css({
        'border': '',
        'background': '',
        'color': '#000'
      });
    }
  }

  $('#atg_ld_autolink').click(function () {
    $('.manual').slideUp();
  });

  $('#atg_ld_noautolink').click(function () {
    $('.manual').slideDown();
  });

  $('#user_email').val($('#username').val());
  $('#user_password').val($('#password').val());
});
