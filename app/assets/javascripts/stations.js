function update_machine_config() {
  var is_update = confirm('This update might affect your schedulers. Are you sure you want to update?');

  if (is_update) {
    var station_name = $('#station_name').val();
    var network_name = $('#network_name').val();
    var ip_address = $('#ip_address').val();
    var port = $('#port').val();

    var myData = {
      station_name: station_name,
      network_name: network_name,
      ip_address: ip_address,
      port: port
    };

    var request = $.ajax({
      type: 'POST',
      url: '/stations/update_machine_config',
      data: myData,
      dataType: 'html'
    });

    var $mcm = $('#machine_config_msg');
    $mcm.empty();

    request.done(function (data) {
      $mcm.html(data);
      reload_station_list().done(function (data) {
        var $station_list = $('.result .table > tbody');
        $station_list.empty();
        $station_list.html(data);
      });
    });

    request.fail(function (jqXHR) {
      $mcm.html(jqXHR.responseText);
    });
  }
}

function delete_station(network_name) {
  var cf = confirm('Are you sure you want to delete?');
  if (cf) {
    var myData = {
      network_name: network_name
    };

    var request = $.ajax({
      type: 'POST',
      url: '/stations/delete_station',
      data: myData,
      dataType: 'html'
    });

    var $dmm = $('#delete_machine_msg');
    $dmm.empty();

    request.done(function (data) {
      $dmm.html(data);
      reload_station_list().done(function (data) {
        var $station_list = $('.result .table > tbody');
        $station_list.empty();
        $station_list.html(data);
      });
    });

    request.fail(function (jqXHR) {
      $dmm.html(jqXHR.responseText);
    });
  }
}

function reload_station_list() {
  return $.ajax({
    type: 'GET',
    url: '/stations/station_list',
    dataType: 'html'
  });
}
