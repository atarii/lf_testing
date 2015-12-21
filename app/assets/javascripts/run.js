//= require papaparse

$(document).ready(function () {
  var $body = $('body'), silo;

  // Load View result by Silo
  loadViewResult();

  // Load Run content base on browser history
  if (history.pushState) {
    window.addEventListener('popstate', function () {
      var silo = '';
      var path = location.pathname;
      var run_index = path.indexOf('/run');

      if (run_index == -1) {
        loadViewResult();
        silo = path.slice(1, path.indexOf('/view'));
      } else {
        silo = path.slice(1, run_index);
        tc.run.loadComponentBySilo(false, {silo: silo});
      }

      // Set selected Silo and active class
      $('#silo').find("label:has(input[value='" + silo + "']) > input").prop('checked', true);
      $('label:has(input:checked)').addClass('active');
      $('label:has(input:not(:checked))').removeClass('active');
    });
  }

  // click to select silo
  $body.on('change', '#new_run label:has(input) > input[name="silo"]', function () {
    var silo = $('#silo').find('label:has(input:checked) > input').val().trim();
    changeUrlBySilo(silo, 'run');

    if (tc.run.is_import) {
      tc.run.is_import = false;
    } else {
      tc.run.loadComponentBySilo(false, {silo: silo});
    }
  });

  // click to select silo
  $body.on('change', '#view_result label:has(input) > input[name="silo"]', function () {
    var silo = $('#silo').find('label:has(input:checked) > input').val().trim();
    changeUrlBySilo(silo, 'view');
    loadViewResult();
  });

  // click to select Outpost
  $body.on('change', 'label:has(input) > input[name="outpost"]', function () {
    tc.run.buildTSsFromOutpost();
    setTimeout(function () {
      tc.run.buildTCsFromTS();
    }, 500);
  });

  // change test suites
  $body.on('change', '#testsuite', function () {
    var $test_suite = $('#testsuite');
    if ($test_suite.val() === 'new_testsuite') tc.run.atgBuildCreateTSModal();

    tc.run.atgChangeLocaleByTS("#testsuite");
    tc.run.buildTCsFromTS();
    tc.run.loadReleaseDateByTS();
  });

  // click to select locales, device stores, payment types
  $body.on('click', '.select_all label > input', function () {
    var name, select_all_name;

    if (this.value === 'all') {
      select_all_name = this.name;
      name = select_all_name.replace('_all', '[]');

      if ($('label:has(input[name="' + select_all_name + '"]) > input').is(':checked')) {
        $('label:has(input) > input[name="' + name + '"]:not(:checked)').click();
      } else {
        $('label:has(input) > input[name="' + name + '"]:checked').click();
      }
    } else {
      name = this.name;
      select_all_name = name.replace('[]', '_all');

      var $lbl_all_obj = $('label:has(input[name="' + select_all_name + '"])'),
        $ip_all_obj = $('label:has(input[name="' + select_all_name + '"]) > input');

      if ($('label:has(input) > input[name="' + name + '"]:not(:checked)').length > 0) {
        $lbl_all_obj.removeClass('active');
        $ip_all_obj.removeAttr('checked');
      } else {
        $lbl_all_obj.addClass('active');
        $ip_all_obj.prop('checked', true);
      }
    }
  });

  // click to select release checkboxes
  $body.on('click', 'ul#release_date_opts input[type=checkbox]', function () {
    var $release_date_chk = $('ul#release_date_opts input[type=checkbox]');
    if (releaseDateValue(this) === 'ALL') {
      if ($(this).is(':checked')) {
        selectReleaseDate($release_date_chk, true, 'ALL');
      } else {
        selectReleaseDate($release_date_chk, false, '');
      }
    } else {
      var is_all_checked = true,
        release_str = '';

      for (var x = 0; x < $release_date_chk.length; x++) {
        if ($($release_date_chk[x]).is(':checked')) {
          release_str += releaseDateValue($release_date_chk[x]) + ';';
        } else if (releaseDateValue($release_date_chk[x]) !== 'ALL') {
          is_all_checked = false;
        }
      }

      if (is_all_checked) {
        selectReleaseDate($release_date_chk, true, 'ALL');
      } else {
        var $all_release_date_chk = $('ul#release_date_opts input[value=ALL]');
        $($all_release_date_chk).prop('checked', false);
        $('#release_date').val(release_str.substring(0, release_str.length - 1).replace('ALL;', ''));
      }
    }
  });

  // change release date
  $body.on('change', '#release_date', function () {
    var release_str = $('#release_date').val().toUpperCase();
    var $release_date_chk = $('ul#release_date_opts input[type=checkbox]');

    if (release_str === 'ALL') {
      selectReleaseDate($release_date_chk, true, release_str);
    } else if (release_str === '') {
      selectReleaseDate($release_date_chk, false, release_str);
    } else {
      var arr = release_str.split(';');
      for (var x = 0; x < $release_date_chk.length; x++) {
        if (arr.indexOf(releaseDateValue($release_date_chk[x])) === -1) {
          $($release_date_chk[x]).prop('checked', false);
        } else {
          $($release_date_chk[x]).prop('checked', true);
        }
      }
    }

    if (areAllReleaseDatesChecked()) {
      selectReleaseDate($release_date_chk, true, 'ALL');
    }
  });

  // continue show realease date dropdown
  $body.on('click', 'ul.dropdown-menu>li>label', function (e) {
    e.stopPropagation();
  });

  // import run config CSV file
  $body.on('change', '#csv-file', tc.run.importFromCSV);

  // click on running note on ATG page
  $body.on('click', '#atg_running_note', function () {
    $('#atg_running_note_content').modal('show');
  });

  // click to create new test suite
  $body.on('click', '#dAtgSubmit', function () {
    if (!(tc.custom.validateData('#tsname') && tc.custom.validateData('#d_testcase'))) return false;
    tc.run.atgCreateNewTestSuite();
  });

  // click to add run to queue
  $body.on('click', 'input[value="QUEUE"]', function () {
    var status = true,
      temp = true;
    var defaults = ['#testsuite', '#testcase', '#note', '#user_email'];

    status = tc.run.validateEmail('#user_email');
    for (var i = 0; i < defaults.length; i++) {
      temp = tc.custom.validateData(defaults[i]);
      if (status) status = temp;
    }

    var silo = $('#silo').find('label:has(input:checked) > input').val().toLowerCase();
    if (silo === 'tc') return status;

    var options = ['#env', '#webdriver', '#locale', '#language', '#release_date', '#data_driven_csv', '#device_store', '#payment_type'];
    for (var x = 0; x < options.length; x++) {
      temp = runValidateData(options[x]);
      if (status) status = temp;
    }

    return status;
  });

  $body.on('click', '.delete', function () {
    return confirm("Are you sure you want to delete?");
  });

  function runValidateData(element_id) {
    var $object = $(element_id);
    if (element_id === '#release_date') $object = $('#release_cover');
    if (isRealObject($object) && $object.css('display') !== 'none') return tc.custom.validateData(element_id);
    return true;
  }

  function releaseDateValue($element) {
    return $($element).val();
  }

  function selectReleaseDate($element, status, text) {
    $element.prop('checked', status);
    $("#release_date").val(text);
  }

  function areAllReleaseDatesChecked() {
    var $release_date_chk = $('ul#release_date_opts input[type=checkbox]');
    for (var x = 1; x < $release_date_chk.length; x++) {
      if ($($release_date_chk[x]).is(':checked') === false) {
        return false;
      }
    }
    return true;
  }

  function isRealObject(obj) {
    return obj && obj !== null && obj !== undefined && obj.length !== 0;
  }

  function clearValidation(element) {
    $(element).change(function () {
      $(element).removeClass('run_info_error');
    });
  }

  function changeUrlBySilo(silo, page) {
    if (typeof (history.pushState) === 'undefined') {
      alert('Browser does not support HTML5.');
    } else {
      var url = location.protocol + '//' + location.hostname + (location.port ? ':' + location.port : '') + '/' + silo + '/' + page;
      var obj = { title: '', url: url };
      history.pushState(obj, obj.title, obj.url);
    }
  }

  function loadViewResult() {
    var path = location.pathname,
      view_index = path.indexOf('/view');
    var silo = path.slice(1, view_index),
      view_path = path.slice(view_index + 5, path.length);

    tc.run.loadViewResultBySilo(silo, view_path);
  }

  // clear validation
  clearValidation('#env>label');
  clearValidation('#locale>label');
  clearValidation('#webdriver>label');
  clearValidation('#release_date');
  clearValidation('#testsuite');
  clearValidation('#testcase');
});
