#!/usr/bin/env bash
#set -x

if ! [ $(id -u) = 0 ]
    then
        echo "Tou need to have root privileges to run this script
Please try again, this time using 'sudo'. Exiting."
        exit
fi


function exiting {
    echo "Do you want to do another operation? (Y/N)"
    read exitanswer
    if [ "$exitanswer" = "y" ] || [ "$exitanswer" = "Y" ]
        then
            bash ./linux-user-wizard.sh
    elif [ "$exitanswer" = "n" ] || [ "$exitanswer" = "N" ]
        then
            echo "GOOD BYE"
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

}

clear
echo       "##################################################"
echo       "        ***** LINUX USER WIZARD *****            #"
echo       "##################################################"
echo       "                                                 #"
echo       " - Create a user with SSH key         - Press 1  #"
echo       " - Remove a user and keys             - Press 2  #"
echo       " - Enable password login with no key  - Press 3  #"
echo       " - Disable password login with no key - Press 4  #"
echo       " - View users with a shell            - Press 5  #"
echo       " - View user's prvivte key            - Press 6  #"
echo       " - Exit                               - Press 7  #"
echo       "                                                 #"
echo       "##################################################"
echo       "                                                 "
echo       " - L.U.W. logs:/var/log/luw.log"
echo       "                                                 "
echo       "   Select a number and hit 'Enter' "

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
                    rm -rf /home/$luwuser
                    useradd $luwuser -s /bin/bash
                    mkdir /home/$luwuser/.ssh
                    touch /home/$luwuser/.ssh/authorized_keys
                    keypairgen
                    exiting
            else
                echo "Not creating the user since you want to keep the homefolder"
                echo "Leaving homefolder intact"
                echo "Do you still want to create SSH key and put in user's home folder? (y/n)"
                read keyans
                if [ "$keyans" = "y" ] || [ "$keyans" = "Y" ]
                    then
                    keypairgen
                fi
	   	    exiting
            fi
        fi


    if [ ! -d /home/$luwuser ]
        then
    	    useradd $luwuser -s /bin/bash
    	    if [ ! -d /home/$luwuser ]
    	        then
    	            mkdir /home/$luwuser # check due ubuntu does not create home folder on user creation
    	    fi
            mkdir /home/$luwuser/.ssh
	        touch /home/$luwuser/.ssh/authorized_keys
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
                userdel -r $luwuser
                echo "User and homefolder deleted"
                exiting
        else
            echo "Home folder does not exist"
            exiting
        fi
fi ### OPTION 2 END


if [ "$answer" = "3" ] ### OPTION 3 START
    then
        echo "not ready yet"
        exiting
fi ### OPTION 3 END


if [ "$answer" = "4" ]
    then
        echo "not ready yet"
        exiting
fi


if [ "$answer" = "5" ]
    then
        cat /etc/passwd | grep /bin/bash | less
        ./linux-user-wizard.sh
fi


if [ "$answer" = "6" ]
    then
        echo "Please enter the username to view it's private key"
        read keyviewuser
    if [ -f /home/$keyviewuser/id_rsa ]
        then
            cat /home/$keyviewuser/id_rsa | less
            exiting
    else
        echo "Private key is not under" /home/$keyviewuser "or not named id_rsa"
        exiting
    fi
fi


if [ "$answer" = "7" ]
    then
        echo "GOOD BYE"
        exit
fi


if [ "$answer" != "1" ] && [ "$answer" != "2" ] && [ "$answer" != "3" ] && [ "$answer" != "4" ] && [ "$answer" != "5" ] && [ "$answer" != "6" ]
    then
        bash ./linux-user-wizard.sh
fi


