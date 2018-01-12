#!/usr/bin/python3
#
# Description : Permet d'extraire l'information d'un docker-compose
#
# Author : Thomas Boutry <thomas.boutry@x3rus.com>
#
#####################################################################

###########
# Modules #

import yaml
import argparse                                    # Process command line argument

#########
# Class #


class DockerCmpAnalyse():
    """
        Class to extract information from docker-compose
        Author : Thomas.boutry@x3rus.com
        Licence: GPLv3+
    """
    def __init__(self, dockerCmpDir="./", dockerCmpFile=['docker-compose.yml'], verbose=False):
        """ Init class , get directory PATH where dockercompose is located and docker-compose file name """

        self.dockerCmpDir = dockerCmpDir

        self.lstDockerCmpFile = dockerCmpFile
        self.yamlDcmp = None
        self.VerboseMode = verbose

    def loadDockerCmp(self, dockerCmpFileOverride=None):
        """
            Load Yaml file in memory for processing load all docker-compose file set in self.lstDockerCmpFile
            It's possible to overwrite the value with the argument
        """

        if (dockerCmpFileOverride is not None):
            self.lstDockerCmpFile = dockerCmpFileOverride

        with open(self.dockerCmpDir + "/" + self.lstDockerCmpFile, 'r') as stream:
            try:
                self.yamlDcmp = yaml.load(stream)
            except yaml.YAMLError as exc:
                print(exc)

    def extractImgInfo(self, filterPattern=None):
        """ Extraction from docker-compose the image in it """

        srvNameWithImg = {}

        if (self.yamlDcmp is None):
            self.loadDockerCmp()

        for serviceName, serviceInfo in self.yamlDcmp['services'].items():
            if (self.VerboseMode):
                print(serviceName)
                print("\t" + serviceInfo['image'])
        # TODO : mettre option regex
            if (filterPattern is None):
                srvNameWithImg[serviceName] = serviceInfo['image']
            else:
                if (filterPattern in serviceInfo['image']):
                    srvNameWithImg[serviceName] = serviceInfo['image']

        return srvNameWithImg


#########
# Main  #


if __name__ == '__main__':

    # #######################
    # Command Line Arguments
    parser = argparse.ArgumentParser(description='Read Docker-compose file Version 2 \
                                    extract info requested.')
    parser.add_argument('--dir', '-d', help='directory where search docker-compose file', default='./')
    parser.add_argument('--dcmp', '-f', help='docker-compose file name', default='docker-compose.yml')
    parser.add_argument('--imgsInfo', help='Etraction Images name for each service')
    parser.add_argument('--imgsPattern', help='Filter Images returned with regex pattern', default=None)
    parser.add_argument('--verbose', '-v', action='store_true', help='Unable Verbose mode', default=False)
    parser.add_argument('operation', choices=['getImg', 'getImgOnly'])

    args = parser.parse_args()

    # init class and load docker-compose
    dockerCmp = DockerCmpAnalyse(args.dir, args.dcmp, args.verbose)
    dockerCmp.loadDockerCmp()

    if (args.operation == 'getImg'):
        srvAndImg = dockerCmp.extractImgInfo(filterPattern=args.imgsPattern)
        print(srvAndImg)
    elif (args.operation == 'getImgOnly'):
        srvImgOnly = dockerCmp.extractImgInfo(filterPattern=args.imgsPattern)
        for service, Imgs in srvImgOnly.items():
            print(Imgs)
