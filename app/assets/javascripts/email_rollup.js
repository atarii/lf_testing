$(document).ready(function () {
    if ($('#dre_enabled').prop('checked') === false) {
        $('#dre_emails').prop('disabled', true);
        $('#dre_time_amount').prop('disabled', true);
        $('#dre_start_time').prop('disabled', true);
        $('#btn_dre').prop('disabled', true);
    }

    if ($('#sch_enabled').prop('checked') === false) {
        $('#sch_emails').prop('disabled', true);
        $('#sch_time_amount').prop('disabled', true);
        $('#sch_start_time').prop('disabled', true);
        $('#btn_sch').prop('disabled', true);
    }

    $('#btn_dre').click(function () {
        var dre_enabled = $("#dre_enabled").is(":checked");
        var request = configure_rollup_email('dashboard', dre_enabled, $('#dre_time_amount').val(), $('#dre_start_time').val(), $('#dre_emails').val());
        request.done(function () {
            $('#dre_msg').html('<div class=\'alert alert-success\'>Executed configure dashboard rollup email successfully</div>');
        });
        request.fail(function (jqXHR) {
            $('#dre_msg').html('<div class=\'alert alert-error\'>' + jqXHR.responseText + '</div');
        });
    });

    $('#btn_sch').click(function () {
        var sch_enabled = $("#sch_enabled").is(":checked");
        var request = configure_rollup_email('schedules', sch_enabled, $('#sch_time_amount').val(), $('#sch_start_time').val(), $('#sch_emails').val());
        request.done(function () {
            $('#sch_msg').html('<div class=\'alert alert-success\'>Executed configure schedules rollup email successfully</div>');
        });
        request.fail(function (jqXHR) {
            $('#sch_msg').html('<div class=\'alert alert-error\'>' + jqXHR.responseText + '</div');
        });
    });

    $('#dre_enabled').change(function () {
        var request;
        var type = 'dashboard';
        if (this.checked === false) {
            $('#dre_emails').prop('disabled', true);
            $('#dre_time_amount').prop('disabled', true);
            $('#dre_start_time').prop('disabled', true);
            $('#btn_dre').prop('disabled', true);

            request = configure_rollup_email(type, false, $('#dre_time_amount').val(), $('#dre_start_time').val(), $('#dre_emails').val());
            request.done(function () {
                $('#dre_msg').html('<div class=\'alert alert-success\'>Disabled configure dashboard rollup email successfully</div>');
            });
            request.fail(function (jqXHR) {
                $('#dre_msg').html('<div class=\'alert alert-error\'>' + jqXHR.responseText + '</div>');
            });
        } else {
            $('#dre_emails').prop('disabled', false);
            $('#dre_time_amount').prop('disabled', false);
            $('#dre_start_time').prop('disabled', false);
            $('#btn_dre').prop('disabled', false);
            $('#dre_msg').html('<div class=\'alert alert-success\'>Enabled configure dashboard rollup email successfully. Please enter values then Submit to execute.</div>');
        }
    });

    $('#sch_enabled').change(function () {
        var request;
        var type = 'schedules';
        if (this.checked === false) {
            $('#sch_emails').prop('disabled', true);
            $('#sch_time_amount').prop('disabled', true);
            $('#sch_start_time').prop('disabled', true);
            $('#btn_sch').prop('disabled', true);

            request = configure_rollup_email(type, false, $('#sch_time_amount').val(), $('#sch_start_time').val(), $('#sch_emails').val());
            request.done(function () {
                $('#sch_msg').html('<div class=\'alert alert-success\'>Disabled configure schedules rollup email successfully</div>');
            });
            request.fail(function (jqXHR) {
                $('#sch_msg').html('<div class=\'alert alert-error\'>' + jqXHR.responseText + '</div>');
            });
        } else {
            $('#sch_emails').prop('disabled', false);
            $('#sch_time_amount').prop('disabled', false);
            $('#sch_start_time').prop('disabled', false);
            $('#sch_dre').prop('disabled', false);
            $('#btn_sch').prop('disabled', false);
            $('#sch_msg').html('<div class=\'alert alert-success\'>Enabled configure schedules rollup email successfully. Please enter values then Submit to execute.</div>');
        }
    });

    function configure_rollup_email(type, enabled, repeat_min, start_time, emails) {
        var mydata = {
            'type': type,
            'enabled': enabled,
            'time_amount': repeat_min,
            'start_time': start_time,
            'emails': emails
        };
        return $.ajax({
            type: 'POST',
            url: '/email_rollup/configure_rollup_email',
            data: mydata,
            dataType: 'json'
        });
    }
}); 