$(document).ready(function () {
  $('#fetch_status').click(function () {
    var pin = $('#lf_pin').val(),
      env = $('input[name="env"]:checked').val();

    if (env !== null) {
      $('.glb-loader').show();
      $.ajax({
        type: 'POST',
        url: '/fetch_pin_attributes/get_pins_status',
        data: {
          lf_pin: pin,
          pin_env: env
        },
        dataType: 'html',
        success: function (data) {
          $('#pins_status').html(data);
          $('.glb-loader').hide();
        },
        error: function (xhr) {
          alert('error: ' + xhr.responseText);
        }
      });
    }
  });
});
