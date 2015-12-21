/**
 * This is used for Tool/checksum comparison
 * Updated 08/12/2014
 */
$(document).ready(function () {
  $('#chk_header_only').change(function () {
    if ($('#chk_header_only').is(':checked')) {
      $('#folder').val('upload file to temp folder');
      $('#folder').attr('disabled', 'disabled');
      $('#header_response').show();
    } else {
      $('#folder').val('');
      $('#folder').removeAttr('disabled', 'disabled');
      $('#header_response').hide();
    }
  });

  $("input[value='Check checksum']").click(function () {
    var folder = $('#folder').val(),
      file = $('#excel_file').val();

    if (folder !== '' && file !== '') {
      $('.glb-loader').show();
      $('#msg').html('');
      $('#content').html('');

      // specify method
      var url = '/checksum_comparison/get_checksum';

      var header_only;
      if ($('#chk_header_only').is(':checked')) {
        header_only = '1';
      } else {
        header_only = '0';
      }

      var formdata = new FormData();
      excel_file = document.getElementById('file').files[0];

      formdata.append('excel_file', excel_file);
      formdata.append('folder', folder);
      formdata.append('chk_header_only', header_only);

      $.ajax({
        type: 'POST',
        url: url,
        enctype: 'multipart/form-data',
        data: formdata,
        autoUpload: true,
        processData: false,
        contentType: false,
        dataType: 'html',
        success: function (data) {
          $('.glb-loader').hide();
          if (header_only == '1' && data.indexOf('<tr><td>') >= 0) {
            $('#content').html(data);
            $('.fail').parent().parent().css('background-color', '#F7FE2E');
            $('.socket_error').parent().parent().css('background-color', '#424242');
            $('.socket_error').parent().parent().css("color", '#FFFFFF');
          } else {
            $('#msg').html(data);
            $('#msg').show();
          }
        },
        error: function (xhr, status, error) {
          alert('error: ' + xhr.responseText);
        }
      });
    }
  });
});