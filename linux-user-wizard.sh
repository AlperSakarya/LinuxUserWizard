#!/usr/bin/env bash
#set -x

if ! [ $(id -u) = 0 ]
    then
        echo "Tou need to have root privileges to run this script
Please try again, this time using 'sudo'. Exiting."
        exit
fi

###################################################################################
YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)
###################################################################################


function initializelogs {
    if [ ! -f /var/log/luw.log ]
        then
            touch /var/log/luw.log
            echo "################################" >> /var/log/luw.log
            echo `date` -- "Log file initiated"  >> /var/log/luw.log
            echo "################################" >> /var/log/luw.log
fi
}

initializelogs # initializing the log file at launch

function logentry {
    echo `date` "|" "Operation: "$logoperation "|" "User: "$luwuser >> /var/log/luw.log
}

function exiting {
    echo "Do you want to do another operation? (Y/N)"
    read exitanswer
    if [ "$exitanswer" = "y" ] || [ "$exitanswer" = "Y" ]
        then
            bash ./linux-user-wizard.sh
    elif [ "$exitanswer" = "n" ] || [ "$exitanswer" = "N" ]
        then
            echo ""
            echo "GOOD BYE -- LinuxUserWizard"
            echo ""
            exit
    else
        echo "Wrong option, please enter 'Y' or 'N'"
    exiting
    fi
}

function wrongoption {
    echo "Wrong option, please enter 'Y' or 'N'"
    exiting

}

function keypairgen {
    ssh-keygen -t rsa
    mv /root/.ssh/id_rsa* /home/$luwuser
    cat /home/$luwuser/id_rsa.pub >> /home/$luwuser/.ssh/authorized_keys
    chown -R $luwuser /home/$luwuser
    chmod 600 /home/$luwuser/.ssh/authorized_keys
    logoperation="SSH key generated"
    logentry

}

function sshdirmake {
    mkdir /home/$luwuser/.ssh
    logoperation="SSH directory created"
    logentry
    touch /home/$luwuser/.ssh/authorized_keys
    logoperation="authorized_keys file created"
    logentry
}

function packageinstaller {
    echo $YUM_CMD > /dev/null
    echo $APT_GET_CMD > /dev/null
    if [[ ! -z $YUM_CMD ]]
        then
            echo "Using 'yum' to install the requirements.." && sleep 2
            yum -y install $packagetoinstall
            #yum install $YUM_PACKAGE_NAME
    elif [[ ! -z $APT_GET_CMD ]]
        then
            echo "Using 'apt-get' to install the requirements.." && sleep 2
            apt-get install $packagetoinstall -y
            #apt-get $DEB_PACKAGE_NAME
    else
        echo "Can't find package manager" && sleep 2
        exiting
    fi
}

trap ctrl_c INT
function ctrl_c() {
        echo ""
        echo "GOOD BYE -- LinuxUserWizard"
        echo ""
        exit
}

clear
echo       "#########################################################"
echo       "#              ***** LINUX USER WIZARD *****            #"
echo       "#########################################################"
echo       "#                                                       #"
echo       "# - Create a user with SSH key              - Press 1   #"
echo       "# - Remove a user and keys                  - Press 2   #"
echo       "# - Enable password login with no key       - Press 3   #"
echo       "# - Disable password login with no key      - Press 4   #"
echo       "# - View users with a shell                 - Press 5   #"
echo       "# - View user's private key                 - Press 6   #"
echo       "# - View logs                               - Press 7   #"
echo       "# - Delete/Re-initialize logs               - Press 8   #"
echo       "# - Exit                                    - Press 9   #"
echo       "#                                                       #"
echo       "#########################################################"
echo       "#                ***** AWS TOOLBOX  *****               #"
echo       "#########################################################"
echo       "#                                                       #"
echo       "# - Install latest AWS CLI                  - Press 10  #"
echo       "# - Install/Configure systat SAR            - Press 11  #"
echo       "# - Install/Configure CloudWatch Logs Agent - Press 12  #"
echo       "# - Generate SOS report for AWS Support     - Press 13  #"
echo       "# - Install/Configure Java                  - Press 14  #"
echo       "#                                                       #"
echo       "#########################################################"
echo       "                                                        "
echo       " - L.U.W. logs:/var/log/luw.log                         "
echo       "                                                        "
echo       "   Select a number and hit 'Enter'                      "

read answer

if [ "$answer" = "1" ] ### OPTION 1 START
    then
        echo "Please enter a username"
        read luwuser
        if [ -d /home/$luwuser ]
            then echo "Homefolder exists do you want to overwrite it? (y/n)"
            read homefolderanswer
            if [ "$homefolderanswer" = "y" ] || [ "$homefolderanswer" = "Y" ]
                then
                    rm -rf /home/$luwuser && logoperation="Homefolder deleted" && logentry
                    useradd $luwuser -s /bin/bash
                    sshdirmake
                    keypairgen
                    exiting
            else
                echo "Not creating the user since you want to keep the homefolder"
                echo "Leaving homefolder intact"
                echo "Do you still want to create SSH key and put in user's home folder? (y/n)"
                read keyans
                if [ "$keyans" = "y" ] || [ "$keyans" = "Y" ]
                    then
                    if [ ! -d /home/$luwuser/.ssh]; then
                        sshdirmake
                    fi
                    keypairgen
                fi
	   	    exiting
            fi
        fi


    if [ ! -d /home/$luwuser ]
        then
    	    useradd $luwuser -s /bin/bash && logoperation="New user added" && logentry
    	    if [ ! -d /home/$luwuser ] # check due ubuntu does not create home folder on user creation
    	        then
    	            mkdir /home/$luwuser && logoperation="Homefolder created" && logentry
    	    fi
            sshdirmake
            keypairgen
            exiting
    fi
fi ### OPTION 1 END


if [ "$answer" = "2" ] ### OPTION 2 START
    then
        echo "Please enter a username to delete"
        read luwuser
        if [ -d /home/$luwuser ]
            then
                userdel -r $luwuser && logoperation="User deleted" && logentry
                echo "User and homefolder deleted"
                exiting
        else
            echo "Home folder does not exist" && logoperation="Homefolder could not be found" && logentry
            exiting
        fi
fi ### OPTION 2 END


if [ "$answer" = "3" ] ### OPTION 3 START
    then
        if [ -f /etc/ssh/sshd_config ]
            then
                sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config && logoperation="SSH via password enabled" && logentry
                echo "SSH with password is enabled"
                service sshd restart
                service ssh restart
                exiting
        else
            echo "sshd_config file is not under /etc/ssh, please edit manually and set
#PasswordAuthentication yes to PasswordAuthentication yes | remove # (uncomment)" && logoperation="sshd_config can't be found" && logentry
            exiting
        fi
fi ### OPTION 3 END


if [ "$answer" = "4" ] ### OPTION 4 START
    then
        if [ -f /etc/ssh/sshd_config ]
            then
                sed -i 's/PasswordAuthentication/#PasswordAuthentication/' /etc/ssh/sshd_config && logoperation="SSH via password disabled" && logentry
                echo "SSH with password is disabled"
                service sshd restart
                service ssh restart
                exiting
        else
            echo "sshd_config file is not under /etc/ssh, please edit manually and set
#PasswordAuthentication yes to PasswordAuthentication yes | remove # (uncomment)" && logoperation="sshd_config can't be found" && logentry
            exiting
        fi
fi ### OPTION 4 END


if [ "$answer" = "5" ]
    then
        cat /etc/passwd | grep /bin/bash | less && logoperation="Viewed users with shell" && logentry
        bash ./linux-user-wizard.sh
fi


if [ "$answer" = "6" ]
    then
        echo "Please enter the username to view it's private key"
        read keyviewuser
    if [ -f /home/$keyviewuser/id_rsa ]
        then
            cat /home/$keyviewuser/id_rsa | less && logoperation="Private Key viewed" && logentry
            exiting
    else
        echo "Private key is not under" /home/$keyviewuser "or not named id_rsa" && logoperation="Private key can't be found" && logentry
        exiting
    fi
fi

if [ "$answer" = "7" ]
    then
        logoperation="Viewed logs" && logentry && less /var/log/luw.log
        bash ./linux-user-wizard.sh
fi

if [ "$answer" = "8" ]
    then
        rm -f /var/log/luw.log
        initializelogs
        exiting
fi

if [ "$answer" = "9" ]
    then
        echo ""
        echo "GOOD BYE -- LinuxUserWizard"
        echo ""
        exit
fi

if [ "$answer" = "10" ]
    then
    packagetoinstall="unzip" && packageinstaller
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    echo "Would you like to configure AWS CLI now? (y/n)"
        read awsclians
	if [ "$awsclians" = "y" ] || [ "$awsclians" = "Y" ]
	    then
	        aws configure && exiting
	    else
	        echo "Please issue 'aws configure' command after closing this tool"
		exiting
	fi
    rm -f awscli-bundle.zip
    exiting
fi

if [ "$answer" = "11" ]
    then
        #packagetoinstall="sysstat" && packageinstaller
        sed -i 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat
        sed -i 's/5-55\/10/*\/2/' /etc/cron.d/sysstat
        service sysstat restart
        echo "SYSSTAT installed & configured"
        echo "SAR logs are under /var/log/sa and will be kept in rotation for 30 days" && sleep 2
        exiting
fi

if [ "$answer" = "12" ]
    then
        echo "Coming soon."
        exiting
fi

if [ "$answer" = "13" ]
    then
        wget -q -O ginfo.sh 'http://bit.ly/1scykJV'
        chmod 755 ginfo.sh
        ./ginfo.sh
        exiting
fi

if [ "$answer" = "14" ]
    then
        echo "Coming soon."
        exiting
fi

if [ "$answer" != "1" ] && [ "$answer" != "2" ] && [ "$answer" != "3" ] && [ "$answer" != "4" ] && [ "$answer" != "5" ] && [ "$answer" != "6" ] \
&& [ "$answer" != "7" ] && [ "$answer" != "8" ] && [ "$answer" != "9" ] && [ "$answer" != "10" ] && [ "$answer" != "11" ] && [ "$answer" != "12" ] \
 && [ "$answer" != "13" ] && [ "$answer" != "14" ] && [ "$answer" != "15" ]
    then
        bash ./linux-user-wizard.sh
fi



