$(document).ready(function () {
  $('#refresh_outpost').click(function () {
    var request = $.ajax({
      type: 'GET',
      url: '/outpost/refresh',
      dataType: 'JSON'
    });

    request.done(function () {
      location.reload();
    });

    request.error(function () {
      alert('Failed to refresh. Please try again later!');
    });

    return false;
  });
});

function refreshEnv() {
  $('.glb-loader-small').css('display', 'block');
  $.ajax({
    type: 'GET',
    url: '/dashboard/refresh_env',
    dataType: 'json',
    success: function () {
      location.reload();
    },
    error: function () {
      $('.glb-loader-small').css('display', 'none');
      alert('Failed to refresh');
    }
  });
}

function deleteOutpost(id, silo) {
  var cf = confirm('Are you sure you want to delete?')
  if (cf) {
    var myData = {
      id: id
    };

    var request = $.ajax({
      type: 'POST',
      url: '/outpost/delete',
      data: myData,
      dataType: 'JSON'
    });

    request.done(function () {
      var isRpCol = $('#outpost_' + id + '  > td[rowspan]').size() !== 0 && $('#outpost_' + id).next().attr('data-outpost-silo') === silo,
        rp = $('tr[data-outpost-silo="' + silo + '"]').size() - 1,
        $op_removed = $('#outpost_' + id);

      if (isRpCol) {
        $op_removed.next().children().first().before('<td rowspan="' + rp + '">' + silo + '</td>');
        $op_removed.remove();
      }
      else {
        $('tr[data-outpost-silo="' + silo + '"]' + ' > td[rowspan]').prop('rowspan', rp);
        $op_removed.remove();
      }
    });

    request.error(function () {
      alert('Failed to delete. Please try again!');
    });
  }
}
