$(document).ready(function () {
  $("input[value='english']").attr('checked', true);
  $('label:has(input:checked)').addClass('active');
});
