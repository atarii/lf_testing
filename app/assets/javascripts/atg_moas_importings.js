/**
 * This jquery code for import excel to mysql function
 * Updated 08/12/2014
 */
$(document).ready(function () {
  $("input[value='english']").attr('checked', true);
  $('label:has(input:checked)').addClass('active');

  // enable import button when selecting file
  $('#excel_file').change(function () {
    var fileName = $(this).val();
    $('.filename').html(fileName);
  });
});

function fn_import() {
  $('.glb-loader').show();
  return;
}
