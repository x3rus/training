#!/usr/bin/python3
#
# Description : The goal is to validate with a directory name and a git commit hash
#               if the conteneur is already in the registry
#
# Author : thomas.boutry@x3rus.com
# Licence : GPLv3
# TODO :
#   - Validation avec le Merge PAS juste le Push Request
#   - Ajouter les exclusions user et inclusion directory dans fic config
#   - Ajout parametre pour l'attente d'un processus de build
############################################################################

###########
# Modules #


from subprocess import Popen, PIPE, STDOUT         # Execute os command , here the git cmd
import argparse                                    # Process command line argument
import json
import sys


#########
# Class #

class dockerRegistryValidation():
    """
        Class to validate if a docker image is in the docker registry with a specifique tag
        Author : Thomas.boutry@x3rus.com
        Licence: GPLv3+
    """
    TIMEOUT_WAIT_PROCESS_OPS = 20

    def __init__(self, strUserName=None, strPassword=None, strImgName=None, strImgProjectName="xerus",
                 dockerRegistryHost="harbor.x3rus.com", buildTimeout=60, scriptHarborCli="../harbor/harbor_cli.py"):
        """ Init class , get user exclusion and directory include / exclude , set parameters """

        # ######################
        # process class argument
        if strUserName:
            self.dckRegistryUserName = strUserName
        else:
            raise "strUserName must be set"

        if strPassword:
            self.dckRegistryPassword = strPassword
        else:
            raise "strPassword must be set"

        if strImgName:
            self.dckRegistryImgName = strImgName
        else:
            raise "strPassword must be set"

        if strImgProjectName:
            self.dckRegistryProjectName = strImgProjectName
        else:
            raise "strImgProjectName must be set"

        self.cmdScriptHarborCli = scriptHarborCli
        self.buildTimeout = buildTimeout
        self.dckRegistryHost = 'https://' + dockerRegistryHost

        self.jsonCntInfo = self.loadJsonInfo(self.dckRegistryImgName)

    # END init

    def loadJsonInfo(self, ImgName):
        """ Load tags info from harbor server"""

        # Start make in the good directory ( -C .... )
        cmdOs_harborCli = Popen([self.cmdScriptHarborCli,
                                 '--username', self.dckRegistryUserName,
                                 '--password', self.dckRegistryPassword,
                                 '--registry_endpoint', self.dckRegistryHost,
                                 'tag', 'list',
                                 '--repo', self.dckRegistryProjectName + '/' + ImgName],
                                stdout=PIPE, stderr=STDOUT)

        # Wait the process finish to get return code
        cmdOs_harborCli.wait(self.buildTimeout)

        rawOutputHarbor = cmdOs_harborCli.stdout.read()

        return json.loads(rawOutputHarbor)

    # END loadJsonInfo

    def validationImgTag(self, strTag=None):
        """ Ask to the docker resgistry if the tag is associate to the docker image

            Arguments:
                strTag: Git commit number or Tag name

            Return:
        """
        if strTag in self.jsonCntInfo['tags']:
            return True

        return False
    # END vaildationImgTag

    def listImgTag(self):
        return self.jsonCntInfo['tags']

#########
# Main  #


if __name__ == '__main__':

    # #######################
    # Command Line Arguments
    parser = argparse.ArgumentParser(description='Request Harbor docker registry server \
                                    to look for a docker image with specifique tag.')
    parser.add_argument('--imageName', '-c', help='Container Image name', required=True)
    parser.add_argument('--tag', '-t', help='Tag name who look ', default='latest')
    parser.add_argument('--list', '-l', help='List tag for the images', default=False, action='store_true')
    parser.add_argument('--user', '-u', help='Username for auth to harbor', default='marvin')
    parser.add_argument('--password', '-p', help='Password for auth to harbor', default='')
    parser.add_argument('--script-harbor', '-s', help='Path to harbor script to request srv',
                        default='../harbor/harbor_cli.py')

    args = parser.parse_args()
    #
    dckCheck = dockerRegistryValidation(args.user, args.password, args.imageName, scriptHarborCli=args.script_harbor)

    if (args.list):
        print(dckCheck.listImgTag())

    if dckCheck.validationImgTag(args.tag):
        sys.exit(0)
    else:
        sys.exit(10)
