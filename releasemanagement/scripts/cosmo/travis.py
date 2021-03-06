import os
import json
import subprocess
import smtplib

from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText


def send_email(sender,receivers):
	msg = MIMEMultipart()
    	msg['From'] = sender
    	msg['To'] = receivers
    	msg['Subject'] = "Travis tests report from Nigthly build"
    	body = "Failed tests: {0}".format(fail_repos)
    	msg.attach(MIMEText(body, 'plain'))
    	message = msg.as_string()
	
	try:
	   smtpObj = smtplib.SMTP('192.168.10.6')
	   smtpObj.sendmail(sender, receivers, message)
	   print "Successfully sent email"
	except SMTPException:
	   print "Error: unable to send email"

os.environ["DEFAULT_CONFIG_FILE_PATH"]="yoci/config.yml"

import yoci.travis.functional_api

fail_repos=""
utests_fail_file="unit_tests_failure.log"
itests_fail_file="i_tests_failure.log"
if os.path.exists(utests_fail_file):
    os.remove(utests_fail_file)
if os.path.exists(itests_fail_file):
    os.remove(itests_fail_file)

tests_repos_sha_list=os.environ["TESTS_REPO_SHA_LIST"]
for i in tests_repos_sha_list:
	if i == "[":
		tests_repos_sha_list=tests_repos_sha_list.replace(i,"{")
	if i == "]":
		tests_repos_sha_list=tests_repos_sha_list.replace(i,"}")
print "tests_repos_sha_list="+tests_repos_sha_list

branch_name=os.environ["BRANCH_NAME"]
release_build=os.environ["RELEASE_BUILD"]
core_branch_name=os.environ["RELEASE_CORE_BRANCH_NAME"]
plugins_branch_name=os.environ["RELEASE_PLUGINS_BRANCH_NAME"]
#travis_repos=['cloudify-rest-client','cloudify-dsl-parser','cloudify-plugins-common','cloudify-cli','cloudify-manager','cloudify-fabric-plugin','cloudify-openstack-plugin','cloudify-script-plugin']
travis_repos=['cloudify-rest-client','cloudify-dsl-parser','cloudify-plugins-common','cloudify-cli','cloudify-manager','cloudify-fabric-plugin','cloudify-openstack-plugin','cloudify-script-plugin','cloudify-chef-plugin','cloudify-diamond-plugin','cloudify-manager-blueprints','cloudify-nodecellar-example','cloudify-plugin-template','cloudify-puppet-plugin','cloudify-softlayer-plugin','cloudify-system-tests']


d = json.loads(tests_repos_sha_list)

for repo,sha in d.items():
	if repo in travis_repos:
		print repo
		print sha
		get_name=subprocess.Popen(['bash', '-c', '. generic_functions.sh ; get_version_name {0} {1} {2}'.format(repo, core_branch_name, plugins_branch_name)],stdout = subprocess.PIPE).communicate()[0]
		#branch_name=get_name.rstrip()+"-build"
		#make travis api waiting for tag tests
		branch_name=get_name.rstrip()
		print "branch_name="+branch_name
	
		if repo == 'cosmo-ui':
			parent_repo='CloudifySource/'
		else:
			parent_repo='cloudify-cosmo/'
		try:

			jobs_state = yoci.travis.functional_api.get_jobs_status(sha,
			parent_repo+repo,
			branch_name=branch_name,
			timeout_min=180)
			for key,value in jobs_state.items():
				print(key, ":", value)
				if value=='passed':
					print key + ' success'
				else:
					if repo == "cloudify-manager" and "run-integration-tests" in key:
						print 'integration tests failed'
						f1 = open(itests_fail_file, 'w')
						f1.write("failed")
						f1.close()
					elif repo not in fail_repos:
						fail_repos=fail_repos+','+repo
						print key + ' failure'
					else:
						print key + ' failure'
				
		
		except RuntimeError:
			print 'Exception'
			fail_repos=fail_repos+','+repo		

if fail_repos:
	print 'fail_repos='+fail_repos
	fail_repos=fail_repos.strip(',')
	print 'fail_repos='+fail_repos
	#send_email('quickbuild@build64A.gspaces.com','limor@gigaspaces.com')
	send_email('limor@gigaspaces.com','rnd_cosmo@gigaspaces.com')
	#send_email('limor@gigaspaces.com','limor@gigaspaces.com')
	f1 = open(utests_fail_file, 'w')
	f1.write(fail_repos)
	f1.close()


