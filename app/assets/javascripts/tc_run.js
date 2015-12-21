tc.using("tc.run", function () {
  var showStatusBar = function (path) {
    fillStatus(path);
    setInterval(function () {
      fillStatus(path);
    }, 30000);
  };

  var validateEmail = function (element_id) {
    var $email_box = $(element_id);
    var emailRegex = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i;

    if ($email_box.val().length) {
      var listemail = $email_box.val().split(/,|;/);
      for (var i = 0; i < listemail.length; i++) {
        if (!listemail[i].match(emailRegex)) {
          $email_box.css({
            'background': 'url(\'/assets/ui-bg_diagonals-thick_18_b81900_40x40.png\') repeat scroll 50% 50% #b81900',
            'border': '1px solid #cd0a0a',
            'color': '#fff'
          });
          $email_box.focus();
          return false;
        } else {
          $email_box.css({
            'border': '',
            'background': ''
          });
        }
      }
    }
    return true;
  };

  var populateRepeat = function () {
    var $repeat_on = $('#repeat[value="on"]');
    var $inputs = $('.repeat_area').find('input');
    var $buttons = $('.repeat_area').find('.btn');

    $repeat_on.attr('checked', false);
    $inputs.prop('disabled', true);
    $buttons.addClass('disabled');

    $repeat_on.click(function () {
      $inputs.prop('disabled', !$repeat_on.is(':checked'));
      $buttons.toggleClass('disabled');
    });
  };

  var buildTSsFromOutpost = function () {
    $('#testsuite').empty();
    var url = '/run/build_test_suite_from_outpost';
    var outpost = $('label:has(input) > input[name="outpost"]:checked').val() || '';
    var mydata = {
      outpost: outpost
    };

    $.ajax({
      type: 'GET',
      url: url,
      data: mydata,
      dataType: 'html',
      success: function (data) {
        $('#testsuite').append(data);
      },
      error: function () {
        alert('Error while loading test suites!');
      }
    });
  };

  var buildTCsFromTS = function (ts, tc) {
    // empty test run
    $('#testcase').empty();

    ts = ts || '#testsuite';
    tc = tc || '#testcase';
    var valTs = $(ts).val() || null;
    if (valTs === null) return false;

    var outpost = $('label:has(input) > input[name="outpost"]:checked').val() || '';
    var url = '/run/get_test_cases';
    var mydata = {
      test_suite: valTs,
      outpost: outpost
    };

    $.ajax({
      type: 'GET',
      url: url,
      data: mydata,
      dataType: 'json',
      success: function (data) {
        $(tc).empty();
        var option_exist = '',
          i = 0;
        if (data.length === 1) $(tc).text('Please select a Test Suite');
        if (data.length > 0 && data[0] == 'file_type') {
          for (i = 1; i < data.length; i++) {
            option_exist += '<label><input type="checkbox" name="testrun[]" value=\"' + data[i][0] + '"/><span>' + i + '. ' + data[i][1] + '</span></label>';
          }
          $(tc).append(option_exist);
        } else if (data.length > 0 && data[0] == 'folder_type') {
          $(ts).empty();
          for (i = 1; i < data.length; i++) {
            option_exist += '<option value="' + data[i][0] + '">' + data[i][1] + '</option>';
          }
          $(ts).append(option_exist);
        }
      },
      error: function () {
        alert('Error while loading test cases!');
      }
    });
  };

  var atgBuildCreateTSModal = function () {
    // open dialog
    $('#d_atgs').modal('show');

    // bind data to fields on dialog
    var request = atgGetTestSuites(),
      $existing_ts = $('#d_existing_ts');

    request.done(function (data) {
      var option = '';
      if (data[0] !== '') {
        for (var i = 0; i < data.length; i++) {
          option += '<option value=\'' + data[i][1] + '\'>' + (i + 1) + ' - ' + data[i][0] + '</option>';
        }
      }

      $existing_ts.empty();
      $existing_ts.append(option);

      // get test cases
      buildTCsFromTS('#d_existing_ts', '#d_testcase');
    });
    request.fail(function (jqXHR) {
      alert('Cannot get test suites\n' + jqXHR.responseText);
    });

    $existing_ts.change(function () {
      buildTCsFromTS('#d_existing_ts', '#d_testcase');
    });
  };

  var atgChangeLocaleByTS = function (ts_id) {
    var request = atgGetParentSuiteId($(ts_id).val());
    request.done(function (data) {
      var ts_id_value = (data !== -1 && data.length > 0) ? data[0][0] : $(ts_id).val(),
        $ts_selected = $('#testsuite').find(':selected'),
        $release_cv = $('#release_cover'),
        $locale = $('#locale');

      //If TS = Heart Beat -> Hide the Locale combobox
      atgShowHideLocale(ts_id_value !== '50' && ts_id_value !== '65');
      atgShowHideDataDriven(ts_id_value === '60');
      atgShowHideDeviceStore(ts_id_value === '65');

      var label_parts = [
        '<label class="btn btn-default hidden-input"><input type="checkbox" name="locale[]" value="',
        '" /><span> ',
        '</span></label>'
      ];
      var locale_values = [], locale_names = [];

      //If TS is: ATG, ATG CABO
      if (['45', '46', '52', '62', '64'].indexOf(ts_id_value) !== -1) {
        locale_values = ['US', 'CA', 'UK', 'IE', 'AU', 'ROW'];
        locale_names = ['US', 'CA', 'UK', 'IE', 'AU', 'ROW'];
      } else if ((ts_id_value === '47') || ($ts_selected.text().toLowerCase().indexOf('french') !== -1)) {
        locale_values = ['FR_FR', 'FR_CA', 'FR_ROW'];
        locale_names = ['France', 'French Canada', 'French ROW'];
      } else {
        locale_values = ['US', 'CA'];
        locale_names = ['US', 'CA'];
      }

      var option_locale = '';
      for (var i = 0; i < locale_values.length; i++) {
        option_locale += label_parts[0] + locale_values[i] + label_parts[1] + locale_names[i] + label_parts[2];
      }
      $locale.html(option_locale);

      //If TS = HeartBeat => Set default locale is US
      if (ts_id_value === '50') $locale.find(':nth-child(2)').prop('selected', true);

      // display release day
      var content_index = $ts_selected.text().toLowerCase().indexOf('content');
      var ymal_index = $ts_selected.text().toLowerCase().indexOf('ymal');
      if (content_index !== -1 || ymal_index !== -1) {
        $release_cv.show();
      } else {
        $release_cv.hide();
      }
    });
  };

  var loadReleaseDateByTS = function loadReleaseDateByTS() {
    var silo = $("#silo input[type='radio']:checked").val().toUpperCase(),
      $test_suite = $('#testsuite').find(':selected'),
      language = 'EN';

    if ($test_suite.text().toLowerCase().indexOf('french atg') !== -1) language = 'FR';
    var my_data = {
      'silo': silo,
      'language': language
    };

    $.ajax({
      type: 'GET',
      url: '/atg/load_release_date',
      data: my_data,
      dataType: 'html',
      success: function (data) {
        $('#release_date_opts').html(data);
      },
      error: function () {
        alert('Error while loading release dates');
      }
    });
  };

  function atgShowHideLocale(is_show) {
    var $locale = $('#locale'),
      $locale_all = $('#locale_all'),
      $label_locale = $('label[for="locale"]');
    if (is_show) {
      $locale.show();
      $locale_all.show();
      $label_locale.show();
    } else {
      $locale.hide();
      $locale_all.hide();
      $label_locale.hide();
    }
  }

  function atgShowHideDataDriven(is_show) {
    var $data_driven = $('#data_driven_csv'),
      $label_data_driven = $('.data_driven_csv');
    if (is_show) {
      $data_driven.show();
      $label_data_driven.show();
    } else {
      $data_driven.hide();
      $label_data_driven.hide();
    }
  }

  function atgShowHideDeviceStore(is_show) {
    var $device_store = $('#device_store_cover');
    if (is_show) {
      $device_store.show();
    } else {
      $device_store.hide();
    }
  }

  function atgCheckTestSuiteName(tsName, eTestSuites) {
    var flag = true,
      testSuites = eTestSuites.toArray();
    testSuites.forEach(function (entry) {
      var entry_str = $(entry).text().split('-')[1].trim();
      if (entry_str.toUpperCase() === tsName.val().trim().toUpperCase()) flag = false;
    });

    if (flag === false) {
      tsName.css({
        'background': 'url(\'/assets/ui-bg_diagonals-thick_18_b81900_40x40.png\') repeat scroll 50% 50% #b81900',
        'border': '1px solid #cd0a0a',
        'color': '#fff'
      });
      tsName.val('Suite should be unique');
    }
    return flag;
  }

  var atgCreateNewTestSuite = function () {
    var $tcs = $('#d_testcase').find('input:checkbox:checked'),
      $tsId = $('#d_existing_ts'),
      $eTestSuites = $tsId.find('option'),
      $tsName = $('#tsname');
    var valid = atgCheckTestSuiteName($tsName, $eTestSuites, $tcs);
    if (valid) {
      var opt_vals = '';
      $tcs.map(function () {
        opt_vals = opt_vals + ($(this).val()) + ',';
      });
      var myData = {
        'tsname': $tsName.val(),
        'tcs': opt_vals,
        'tsId': $tsId.val()
      };

      $.ajax({
        type: 'GET',
        url: '/atgs/ajax/create_ts',
        data: myData,
        dataType: 'json',
        success: function () {
          location.reload();
        },
        error: function () {
          alert('Fail to create new Test Suite');
        }
      });
    }
    return valid;
  };

  function atgGetTestSuites() {
    return $.ajax({
      type: 'GET',
      url: '/atg/first_parent_level_tss',
      dataType: 'json'
    });
  }

  function atgGetParentSuiteId(testSuiteId) {
    var myData = {
      'ts_id': testSuiteId
    };

    return $.ajax({
      type: 'GET',
      url: '/atg/parent_suite_id',
      data: myData,
      dataType: 'json'
    });
  }

  // For WS
  var back = function () {
    $.ajax({
      type: 'GET',
      url: '/web_services/back',
      data: null,
      dataType: 'json',
      success: function (data) {
        // data is whatever you RETURN from your controller.
        // an array, string, object...something
        var $tsuite = $('#testsuite');
        $tsuite.empty();
        if (data.length === 0) return;

        var option_list = '';
        for (var i = 0; i < data.length; i++) {
          if (Array.isArray(data[i])) {
            option_list += '<option value="' + data[i][1] + '">' + data[i][0] + '</option>';
          }
          else {
            option_list += '<option>' + data[i] + '</option>';
          }
        }
        $tsuite.append(option_list);
        $('#testcase').empty();
      },
      error: function () {
        alert('error');
      }
    });
  };

  var is_import = false;

  // For export and import run config data-drive
  var exportToCSV = function () {
    var request = atgGetParentSuiteId($('#testsuite :selected').val());
    request.done(function (data) {
      var silo = $("#silo input[type='radio']:checked").val();
      var locale = $('#locale :input:checkbox:checked').map(function () {
        return this.value;
      }).get().join(";") || '';

      var env = $("input[type='radio'][name='env']:checked").val() || '',
        release_date = $("#release_date").val() || '',
        browser = $("#webdriver input[type='radio']:checked").val() || '',
        selected_ts_name = $('#testsuite :selected').text();

      if (data !== -1 && data.length > 0) selected_ts_name = data[0][1] + '/' + selected_ts_name;

      var testsuite = ignoreCommas(selected_ts_name);
      var testcase = ignoreCommas($('#testcase :checkbox:checked').map(function () {
        return $(this).next("span").text();
      }).get().join(";"));

      var run_info = {
        silo: silo,
        env: env,
        locale: locale,
        release_date: release_date,
        browser: browser,
        testsuite: testsuite,
        testcase: testcase
      };

      var columns = ['silo', 'env', 'locale', 'release_date', 'browser', 'testsuite', 'testcase'],
        csvContent = "data:text/csv;charset=utf-8,";
      csvContent += columns.join(',') + "\n";
      csvContent += columns.map(function (a) {
        return run_info[a];
      }).join(',');

      var encodedUri = encodeURI(csvContent);
      var a = document.createElement('a');
      a.style.display = 'none';
      a.download = 'exported-data.csv';
      a.href = encodedUri;
      document.body.appendChild(a);
      a.click();
    });
    request.fail(function () {
      alert('Fail to get run config data!');
    });
  };

  function ignoreCommas(str) {
    return str.indexOf(',') > -1 ? '"' + str + '"' : str;
  }

  var importFromCSV = function (evt) {
    var file = evt.target.files[0];
    Papa.parse(file, {
      header: true,
      dynamicTyping: true,
      complete: function (results) {
        var run_info = getRunInfoFromCSV(results.data[0]);
        var current_silo = $("#silo input[type='radio']:checked").val();

        // Bind data into RUN fields
        if (current_silo != run_info.silo) tc.run.is_import = true;
        $('#silo').find("label:has(input[value='" + run_info.silo + "'])").click();
        loadComponentBySilo(true, run_info);
      },
      error: function () {
        alert('Failed to load file!');
      }
    });
  };

  function getRunInfoFromCSV(data) {
    return {
      silo: data.silo,
      env: data.env,
      locale: data.locale.split(';'),
      release_date: data.release_date,
      browser: data.browser,
      testsuite: data.testsuite,
      testcase: data.testcase.split(';')
    };
  }

  function loadComponentBySilo(is_imported_from_csv, run_info) {
    var $component = $('#component');
    $component.load('/run/show_run_silo/' + run_info.silo, function (status, xhr) {
      if (status == 'error') {
        $component.html('Sorry but there was an error: ' + xhr.status + ' ' + xhr.statusText);
        return;
      }

      atgChangeLocaleByTS('#testsuite');
      buildTCsFromTS();
      populateRepeat();
      loadReleaseDateByTS();

      if (is_imported_from_csv === false) return;

      var t = 0,
        ts_arr = run_info.testsuite.split('/');
      $.each(ts_arr, function (index, ts) {
        setTimeout(function () {
          $("#testsuite").val($("#testsuite option:contains('" + ts + "')").val());
          $("#testsuite").change();
        }, t += 500);
      });

      setTimeout(function () {
        if (run_info.env !== '') $('#env').find("label:has(input[value='" + run_info.env + "'])").click();
        if (run_info.browser !== '') $('#webdriver').find("label:has(input[value='" + run_info.browser + "'])").click();
        if (run_info.release_date !== '') $("#release_date").val(run_info.release_date);

        findAndClickLabels('#locale', run_info.locale);
        findAndClickLabels('#testcase', run_info.testcase);
      }, (ts_arr.length + 1) * 500);
    });
  }

  function loadViewResultBySilo(silo, view_path) {
    var $component = $('#view_result_component');
    $component.load('/run/show_view_silo/' + silo + '/view' + view_path, function (status, xhr) {
      if (status == 'error') alert('Error while loading results: ' + xhr.status + ' ' + xhr.statusText);
    });
  }

  function findAndClickLabels(jquery_path, values) {
    if ($(jquery_path).find("label:contains('" + values[0] + "')").text() !== '') {
      $.each(values, function (value) {
        $(jquery_path).find("label:contains('" + value + "')").click();
      });
    } else {
      window.setTimeout(function () {
        $.each(values, function (value) {
          $(jquery_path).find("label:contains('" + value + "')").click();
        });
      }, 500);
    }
  }

  function fillStatus(path) {
    var status = $('#run_status');
    var running = status.find('#srunning');
    var queued = status.find('#squeued');
    var today = status.find('#sdaily');
    var scheduled = status.find('#sscheduled');
    var outpost = status.find('#soutpost');

    $.get(path, function (data) {
      running.text(data.running);
      queued.text(data.queued);
      today.text(data.today);
      scheduled.text(data.scheduled);
      outpost.text(data.outpost);
    });
  }

  return {
    showStatusBar: showStatusBar,
    validateEmail: validateEmail,
    populateRepeat: populateRepeat,
    buildTCsFromTS: buildTCsFromTS,
    exportToCSV: exportToCSV,
    importFromCSV: importFromCSV,
    is_import: is_import,
    atgChangeLocaleByTS: atgChangeLocaleByTS,
    atgBuildCreateTSModal: atgBuildCreateTSModal,
    loadComponentBySilo: loadComponentBySilo,
    loadViewResultBySilo: loadViewResultBySilo,
    atgCreateNewTestSuite: atgCreateNewTestSuite,
    loadReleaseDateByTS: loadReleaseDateByTS,
    buildTSsFromOutpost: buildTSsFromOutpost,
    back: back
  };
}());
