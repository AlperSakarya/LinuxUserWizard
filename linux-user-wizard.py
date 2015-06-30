__author__ = 'AlperSakarya'

import os, subprocess, shutil, sys
from Crypto.PublicKey import RSA
import platform


if os.geteuid() != 0:
    exit("You need to have root privileges to run this script.\nPlease try again, this time using 'sudo'. Exiting.")

def wrongopt():
    print "Wrong option please enter 'Y' or 'N'".upper()
    exiting()

def exiting():
    exitoption = raw_input("\nDo you want to do another operation (Y/N)\n").upper()
    if exitoption == "y" or exitoption == "Y":
        mainmenu()
    elif exitoption == "n" or exitoption == "N":
        print "Good bye".upper()
        exit()
    else:
        wrongopt()


def priv_key(bits=2048):
    new_key = RSA.generate(bits, e=65537)
    private_key = new_key.exportKey("PEM")
    return private_key


def pub_key(bits=2048):
    new_key = RSA.generate(bits, e=65537)
    public_key = new_key.publickey().exportKey("PEM")
    return public_key


def mainmenu():
    subprocess.call("clear")
    print "##################################################"
    print "        ***** LINUX USER WIZARD *****            #"
    print "##################################################\n" \
          "                                                 #\n" \
          " - Create a user with SSH key         - Press 1  #\n" \
          " - Remove a user and keys             - Press 2  #\n" \
          " - Enable password login with no key  - Press 3  #\n" \
          " - Disable password login with no key - Press 4  #\n" \
          " - View users with a shell            - Press 5  #\n" \
          " - Exit                               - Press 6  #\n" \
          "                                                 #\n" \
          "##################################################\n"
    print " - L.U.W. logs:/var/log/luw.log"
    print " -", platform.platform(), "\n"

    answer = raw_input("Select a number and hit 'Enter'\n").lower()
    if answer == "1":
        username = raw_input("Please enter a username\n")
        subprocess.call(["useradd", username, "-s", "/bin/bash"])
        directory = ("/home/" + username)
        if not os.path.exists(directory):
            os.makedirs(directory)
            sshdir = directory + "/" + ".ssh"
            os.makedirs(sshdir)
            authkeys = sshdir + "/" + "authorized_keys"
            if not os.path.exists(authkeys):
                open(authkeys, 'w').close()
            file = open("/home/%s/privatekey.pem" % username, "w")
            file.write(priv_key())
            file.close()
            file = open("/home/%s/publickey.pub" % username, "w")
            file.write(pub_key())
            file.close()
            file = open("/home/%s/.ssh/authorized_keys" % username, "w")
            file.write(pub_key())
            file.close()
            subprocess.call(["chown", "-R", username, directory])
            subprocess.call(["chmod", "600", "/home/%s/.ssh/authorized_keys" % username])
            print("\nUser has been created under " + directory + "\n")
            exiting()
        else:
            answer = raw_input("Home folder exists should I overwrite it? (Y/N)\n")
            if answer == "y" or answer == "Y":
                shutil.rmtree(directory)
                os.makedirs(directory)
                print "\nHome folder is overwritten"
                exiting()
            elif answer == "n" or answer == "N":
                print "Not overwriting the home folder"
                exiting()
            else:
                wrongopt()

    if answer == "2":
        username = raw_input("Please enter a user to delete:\n")
        subprocess.call(["userdel", username])
        directory = ("/home/" + username)
        if os.path.exists(directory):
            shutil.rmtree(directory)
            print "User deleted"
            print "Home folder removed"
            exiting()
        else:
            print "Home folder does not exist"
            exiting()
    if answer == "5":
        subprocess.call(["cat", "/etc/passwd", "|", "grep", "bash"])
        exiting()
    if answer == "6":
        print "Good bye\n" \
              "Linux User Wizard".upper()
        exit()

mainmenu()
