#!/usr/bin/python
#
# Description : Python script to validate if Jenkins need build the project
#               or ignore it
#
# Author : thomas.boutry@x3rus.com
# Licence : GPLv3
# TODO :
#   - Validation avec le Merge PAS juste le Push Request
#   - Ajouter les exclusions user et inclusion directory dans fic config
#   - Ajout parametre pour l'attente d'un processus de build
############################################################################

# Argument :
#   # Exclusion user
#   # Exclusion repertoire
#   # Disable validation jenkins build file in directory

###########
# Modules #


import argparse                                    # Process command line argument
import sys
import os
from gitBuildTriggerValidation import gitBuildTriggerValidation

#########
# Main  #


if __name__ == '__main__':

    # Set default value for last commit processed with success
    lastCommitBuildSuccess = None

    # #######################
    # Command Line Arguments
    parser = argparse.ArgumentParser(description='Process git Push Request and \
                                    stop jenkins process or continue with task.')
    parser.add_argument('--build-timeout', '-b', type=int, help='Setup timeout for one build ', default=60)
    parser.add_argument('--conf', '-c', help='passe configue file default: jenkins-build.cfg',
                        default="jenkins-build.cfg")
    parser.add_argument('--exclude-user', '-u', help='Exclude users for \
                        a git commit , list of users separated with comma ; \
                        you can use regex ')
    parser.add_argument('--exclude-msg', '-m', help='Exclude build if specifique word in the commit')
    parser.add_argument('--include-dir', '-D', help='Include directory for jenkins \
                        build , list of directory separated with comma ; You can \
                        use regex', required=True)
    parser.add_argument('--test', '-t', action='store_true', help='Perform a dry run no build ', default=False)
    parser.add_argument('--verbose', '-v', action='store_true', help='Unable Verbose mode', default=False)

    args = parser.parse_args()

    # Get Jenkins Variables
    jenkinsInfo = os.environ.get('BUILD_TAG')

    # instance Class and Search build required
    app = gitBuildTriggerValidation(args.exclude_user, args.include_dir, args.exclude_msg, args.verbose, None,
                                    args.build_timeout, args.conf)
    b_mustRunBuild, lstDirectory = app.getCommitHistoryAndValidate(lastCommitBuildSuccess)

    # If Build must be perform process each directory
    if b_mustRunBuild:
        print("Build must RUN")
        if lstDirectory:
            if (args.test is True):
                print("Dry-run only enable , not performing Make")
                print("Lst directory to build : ")
                print(lstDirectory)
            else:
                # set Env variable to specifie to build
                print(b_mustRunBuild)
                print(lstDirectory)
                sys.exit(0)
    else:
        print("NO Build to perform, creteria not meet")
        sys.exit(10)

    # Not suppose to go there but :D
    sys.exit(0)
