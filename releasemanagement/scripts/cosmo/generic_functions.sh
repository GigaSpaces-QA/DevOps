function pre_git_pull {
    pushd $1
    git fetch -v --dry-run
    if [ $? != 0 ] ; then
      	popd
      	rm -rf $1
        git clone $2
    else
    	popd
    fi
}

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)" 
		exit 1
      fi

}

function  get_product_version_for_npm {
	case "$MILESTONE" in
	        ga)
	            PRODUCT_VERSION=$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION
	            ;;

	        *)
	            PRODUCT_VERSION=$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"-"$MILESTONE
	 
	esac

}

function run_command 
{
  
	status=256
   
  	echo "*** Running $1"      
   	$1
  	status=$?   
    
     	if [ $status != 0 ] ; then
            echo "Failed with exit code $status"
            exit $status
      	fi   
}

function retry 
{
   nTrys=0
   maxTrys=10
   status=256
   until [ $status == 0 ] ; do
      echo "*** Running $1"      
      $1
      status=$?
      nTrys=$(($nTrys + 1))
      if [ $nTrys -gt $maxTrys ] ; then
            echo "Number of re-trys exceeded. Exit code: $status"
            exit $status
      fi
      if [ $status != 0 ] ; then
            echo "Failed (exit code $status)... retry $nTrys"
            sleep 15
      fi
   done
}

function get_version_name
{
	proj=$1
	core_tag_name=$2
	plugins_tag_name=$3

	#case "$proj" in
		#cloudify-bash-plugin)
			##VERSION_BRANCH_NAME=$cloudify_bash_majorVersion
			#VERSION_BRANCH_NAME=$plugins_tag_name
			#;;			 
		#cloudify-chef-plugin)
			##VERSION_BRANCH_NAME=$cloudify_chef_majorVersion
			#VERSION_BRANCH_NAME=$plugins_tag_name
			#;;			 
		#cloudify-openstack-plugin)
			##VERSION_BRANCH_NAME=$cloudify_openstack_plugin_majorVersion
			#VERSION_BRANCH_NAME=$plugins_tag_name
			#;;
		#cloudify-openstack-provider)
			##VERSION_BRANCH_NAME=$cloudify_openstack_provider_majorVersion
			#VERSION_BRANCH_NAME=$plugins_tag_name
			#;;
		#cloudify-python-plugin)
			##VERSION_BRANCH_NAME=$cloudify_python_majorVersion
			#VERSION_BRANCH_NAME=$plugins_tag_name
			#;;
		#cloudify-puppet-plugin)
			##VERSION_BRANCH_NAME=$cloudify_puppet_majorVersion
			#VERSION_BRANCH_NAME=$plugins_tag_name
			#;;
		#cloudify-script-plugin)
			#VERSION_BRANCH_NAME=$plugins_tag_name
			#;;
		#cloudify-libcloud-plugin)
			#VERSION_BRANCH_NAME=$plugins_tag_name
			#;;
		#cloudify-libcloud-provider)
			#VERSION_BRANCH_NAME=$plugins_tag_name
			#;;
		#cloudify-fabric-plugin)
			#VERSION_BRANCH_NAME=$plugins_tag_name
			#;;
		#cloudify-diamond-plugin)
			#VERSION_BRANCH_NAME=$plugins_tag_name
			#;;
		##cloudify-packager-ubuntu|packman|cloudify-packager-centos|cloudify-cli-packager|cloudify-packer)	
			##VERSION_BRANCH_NAME=$cloudify_packager_majorVersion
			##VERSION_BRANCH_NAME=$plugins_tag_name
			#;;			 
		#*)
			#VERSION_BRANCH_NAME=$core_tag_name	 
	
	#esac
	
	if [[ "$proj" == *-plugin ]] || [[ "$proj" == *-provider ]]
	then
	    VERSION_BRANCH_NAME=$plugins_tag_name
	else
	    VERSION_BRANCH_NAME=$core_tag_name
	fi

	echo $VERSION_BRANCH_NAME
	
}
