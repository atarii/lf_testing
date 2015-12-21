#1. Test Central API
* __Authentication__
* __Register Outpost__
* __Upload Test Result__

##Authentication

**URL**: /rest/v1/sso

**Method**: POST

**Additional Parameters:**

- header: content-type: application/x-www-form-urlencoded
- email
- password

**Description:**
This API allows users to login using their TC account credentials. A token is returned for the user upon successful login.

**JSON Schema**

	POST http://localhost:3000/rest/v1/sso

	email=tin.trinh%40logigear.com&password=123456

	// response
	{
	  "status": true,
	  "session": "00265371-099c-4ac3-881f-e9a5e72921af"
	}

##Register Outpost

**URL**: /rest/v1/register

**Method**: POST

**Additional Parameters:**

- header: content-type: application/x-www-form-urlencoded, tc-session-token
- body: JSON data

	{
	  "name": "outpost",
	  "silo": "narnia",
	  "ip": "192.168.191.132",
	  "status_url": "#{host}/rest/v1/status?silo=#{CONST_SILO}",
	  "exec_url": "#{host}/rest/v1/execute"
	}

**Description:**
This API allows users register their Outpost to TC. API returns status is true when users register successfully.

**JSON Schema**

	POST http://localhost:3000/rest/v1/register
	
	tc-session-token: 2a28c994-48b6-471c-bd60-44c5dc747425
	Content-Type: application/json
	{
		"name": "outpost",
		"silo": "narnia",
		"ip": "192.168.191.132",
		"status_url": "http://192.168.191.132/rest/v1/status?silo=narnia",
		"exec_url": "http://192.168.191.132/rest/v1/execute"
	}
	// response
	{
	  "status": true,
	  "message": [
		{
		  "id": 1,
		  "name": "outpost",
		  "silo": "narnia",
		  "ip": "192.168.191.132",
		  "status": null,
		  "status_url": "http://192.168.191.132/rest/v1/status?silo=narnia",
		  "exec_url": "http://192.168.191.132/rest/v1/execute",
		  "available_tests": null,
		  "created_at": "2015-08-10T11:17:28.000+07:00",
		  "updated_at": "2015-08-10T11:17:28.000+07:00",
		  "checked_at": null
		}
	  ]
	}

##Upload Test Result

**URL**: /rest/v1/upload_outpost_json_file

**Method**: POST

**Additional Parameters:**

- header: content-type: application/json, tc-session-token
- body: is json data of outpost result.

**Description:**
This API allows users upload and save report in TC Database. API returns status is true when users upload successfully.

**JSON Schema**

	POST http://localhost:3000/rest/v1/upload_outpost_json_file
	
	tc-session-token: 2a28c994-48b6-471c-bd60-44c5dc747425
	Content-Type: application/json
	{
		"run_id": "3035",
		"user": "",
		"email": "",
		"silo": "narnia",
		"suite_path": "test",
		"suite_name": "Narnia Pass Fast",
		"env": "QA",
		"locale": "US",
		"web_driver": "",
		"release_date": "",
		"data_driven_csv": "",
		"inmon_version": "",
		"system_version": "1.0.123",
		"start_datetime": "2015-08-19T15:34:43.375+07:00",
		"end_datetime": "2015-08-19T15:34:52.958+07:00",
		"total_cases": 1,
		"total_passed": 1,
		"total_failed": 0,
		"total_uncertain": 0,
		"schedule_info": null,
		"config": null,
		"tc_version": "2015.8.19-15.12.46_572b057\n",
		"station_name": "",
		"cases": [
			{
				"file_name": "pass_fast.rb",
				"comment": "Narnia Pass Fast",
				"total_steps": 7,
				"total_failed": 0,
				"total_uncertain": 0,
				"steps": [
					{
						"name": "TC01 - 2 passes",
						"steps": [
							{
								"name": "Check pass 1",
								"status": "passed",
								"duration": "00:00:03.03739"
							},
							{
								"name": "Check pass 2",
								"status": "passed",
								"duration": "00:00:00.00000"
							}
						]
					},
					{
						"name": "TC02 - 5 passes",
						"steps": [
							{
								"name": "Check pass 1",
								"status": "passed",
								"duration": "00:00:00.00000"
							},
							{
								"name": "Check pass 2",
								"status": "passed",
								"duration": "00:00:00.00000"
							},
							{
								"name": "Check pass 3",
								"status": "passed",
								"duration": "00:00:00.00000"
							},
							{
								"name": "Check pass 4",
								"status": "passed",
								"duration": "00:00:00.00000"
							},
							{
								"name": "Check pass 5",
								"status": "passed",
								"duration": "00:00:02.99940"
							}
						]
					}
				],
				"name": "TS - TestCentral Self Check - PassFast",
				"total_passed": 7,
				"duration": "00:00:06"
			}
		]
	}

	// response
	{
		status: true
		message: "<a href='/narnia/view/2015-08-10_van.ngoc.nguyen_QA_US/130038959_oobe'>150810_130036934.json<br>/narnia/view/2015-08-10_van.ngoc.nguyen_QA_US/130038959_oobe</a>"
	}	
	
#2. Test Outpost API
* __Get status__
* __Execute__

##Get status

**URL**: /rest/v1/status?silo=narnia

**Method**: GET

**Description:**
This API allows users to get Outpost status (ready, running, error). Response will return data, outpost status and test runs data.

- data: contains available tests
- outpost status: is Ready, Running or Error
- test runs data: will be test run results if Outpost is running

**JSON Schema**

	GET http://localhost:4567/rest/v1/status?silo=narnia

	// response
	{
	  "data": {
		"available_test": [
		  {
			"testsuite": "app_center_integration",
			"testcases": "app_center_parameter_generation_from_hand_off.rb,app_center_parameter_generation_from_kid_ui.rb,app_center_parameter_generation_from_parent_launcher_checking.rb,purchase_flow_checking.rb"
		  },
		  {
			"testsuite": "fw_update",
			"testcases": "start_firmware_update.rb"
		  },
		  {
			"testsuite": "oobe",
			"testcases": "oobe.html,oobe_connect_wifi_and_login_existing_parent_account.rb,oobe_connect_wifi_and_skip_parent_account.rb,oobe_golden_path.html,oobe_golden_path.rb,oobe_golden_path_result.html,oobe_login.html,oobe_skip_wifi_and_skip_parent_account.rb,skip_wifi.html,wifi_skip.html"
		  }
		],
		"outpost_status": "Ready",
		"test_runs": [
		]
	  }
	}

##Execute

**URL**: /rest/v1/execute

**Method**: POST

**Additional Parameters:**

- header: content-type: application/json
- body: JSON data

	{
	  "run_id": "[Test Central db run id]",
	  "name": "outpost",
	  "silo": "narnia",
	  "testsuite": "test suite",
	  "testcases": "test case 1, test case 2",
	  "config": "[config data]"
	}

**Description:**
This API allows users to execute Outpost's scripts.

JSON data input:

- run_id: the id of runs table of Test Central db
- name: the name that user registers Outpost to Test Central
- silo: the name of automation folder, e.g. **narnia**
- testsuite: the name of test suite that Outpost has
- testcases: the name of test cases that Outpost has
- config: data driven, currently it is empty

**JSON Schema**

	POST http://localhost:4567/rest/v1/execute

	{
	  "run_id": 1,
	  "name": "tintrinh",
	  "silo": "narnia",
	  "testsuite": "app_center_checking",
	  "testcases": "test_case_1.rb, test_case_2.rb",
	  "config": ""
	}

	// response
	{
	  "status": true
	}

**Note** : To use **Get status** and **Execute** APIs, we perform pre-conditions below:

- Outpost must be registered to Test Central server.
- Outpost is started before calling APIs.
