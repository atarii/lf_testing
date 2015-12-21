$(document).ready(function () {
  var $repeat_on = $('#repeat[value="on"]');
  var $inputs = $('.repeat_area').find('input');
  var $buttons = $('.repeat_area').find('.btn');

  $repeat_on.click(function () {
    $inputs.prop('disabled', !$repeat_on.is(':checked'));
    $buttons.toggleClass('disabled');
  });

  $('#d_scheduler button[data-dismiss="modal"]').click(function () {
    window.location.replace(window.location.origin + '/admin/scheduler');
  });
});

function update_scheduler(id, description, start_date, repeat_min, weekly, emaillist) {
  // Step 1: Fresh the scheduler popup
  var $buttons = $('.repeat_area').find('.btn');
  var $repeat_on = $('#repeat[value="on"]');
  $buttons.addClass('disabled');
  $buttons.removeClass('active');
  $repeat_on.attr('checked', false);

  $('#d_scheduler form').append('<input type="hidden" name="id" value=' + id + ' />');
  $('#d_scheduler').modal('show');

  //  Step 2: Load data from current scheduler
  $('#user_email').val(emaillist);
  $('#note').val(description);
  $('#start_time').val(start_date);
  $('#minute').val(repeat_min);

  if (repeat_min !== '') {
    $repeat_on.click();
    $buttons.removeClass('active');
  }
  else if (weekly !== '') {
    var weekly_arr = weekly.split(',');

    $repeat_on.click();
    $buttons.removeClass('active');

    $.each(weekly_arr, function (index, value) {
      $('#dow_[value=\'' + value + '\']').click();
    });
  }
}

function update_scheduler_status(id, obj) {
  var status = obj.checked === true ? 1 : 0;
  var mydata = {
    'id': id,
    'status': status
  };
  var request = $.ajax({
    type: 'POST',
    url: '/scheduler/update_scheduler_status',
    data: mydata
  });

  request.done(function () {
    $('#msg').html('<div class=\'alert alert-success\'>Your scheduler is updated successfully.</div>');
  });

  request.error(function () {
    $('#msg').html('<div class="alert alert-error">An error occurred while updating. Please re-check!</div>');
  });

  setTimeout(function () {
    location.reload();
  }, 1000);
}

function update_scheduler_location(id, obj) {
  var location = obj.value;
  var mydata = {
    'id': id,
    'location': location
  };
  var request = $.ajax({
    type: 'POST',
    url: '/scheduler/update_scheduler_location',
    data: mydata
  });

  request.done(function () {
    $('#msg').html('<div class=\'alert alert-success\'>Your scheduler is updated successfully.</div>');
  });

  request.error(function () {
    $('#msg').html('<div class="alert alert-error">An error occurred while updating. Please re-check!</div>');
  });

  setTimeout(function () {
    location.reload();
  }, 1000);
}
