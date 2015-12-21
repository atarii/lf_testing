$(document).ready(function () {
  var $body = $('body');
  $body.on('change', function () {
    var $code_type = $('#file_name'),
      $code_file = $('.code_file_cover').find('input[type="text"]');

    if ($code_type.val() !== '--- Select a code type ---') $code_type.removeClass('run_info_error');
    if ($code_file.val() !== '') $code_file.removeClass('run_info_error');
  });
});
