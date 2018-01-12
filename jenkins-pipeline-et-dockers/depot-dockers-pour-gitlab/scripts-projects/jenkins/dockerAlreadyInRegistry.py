#!/usr/bin/python3
#
# Description : Passethrow directory extract githash and check if the image
#               is already in docker
#
# Author : thomas.boutry@x3rus.com
# Licence : GPLv3
############################################################################

###########
# Modules #


from subprocess import Popen, PIPE, STDOUT         # Execute os command , here the git cmd
import argparse                                    # Process command line argument
import re                                          # Regex use to remove data in strings
import sys                                         # First return status code

#########
# Main  #


if __name__ == '__main__':

    # #######################
    # Command Line Arguments
    parser = argparse.ArgumentParser(description='Process docker directory with docker-compose and Dockerfile \
                                    extract git hash and images and look if container is already builded.')
    parser.add_argument('--script-extCmpInfo', help="Script PATH for script to extract info from docker-compose",
                        default='../dockers/extractImgDockerCmp.py')
    parser.add_argument('--script-checkRegistry', help="Script PATH for script to check docker Registry",
                        default='../dockers/dockerRegistryValidation.py')
    parser.add_argument('--script-harbor', help="Script PATH for script to communicate with harbor",
                        default='../harbor/harbor_cli.py')
    parser.add_argument('--include-dir', '-D', help='Include directory for processing \
                        build , list of directory separated with comma , You can \
                        use regex', required=True)
    parser.add_argument('--getGitHash', '-g', action='store_true', help='Don\'t use Tag but extract git hash, \
                                                    from directory the tag option is not use', default=False)
    parser.add_argument('--jenkins', '-j', action='store_true', help='Return code always 0 for jenkins', default=False)
    parser.add_argument('--password', '-p', help='Password for auth to harbor', default='Tasoeur123')
    parser.add_argument('--registry', '-r', help='Harbor host registry', default='harbor.x3rus.com')
    parser.add_argument('--tag', '-t', help='Tag name who look ', default='latest')
    parser.add_argument('--user', '-u', help='Username for auth to harbor', default='BobLeRobot')
    parser.add_argument('--verbose', '-v', action='store_true', help='Unable Verbose mode', default=False)

    args = parser.parse_args()

    # Variables
    extractDocker_CmpInfo = args.script_extCmpInfo
    checkDockerRegistry_Tag = args.script_checkRegistry
    harborScript = args.script_harbor
    buildTimeout = 60
    tag2Validate = args.tag

    # Set list of directory to process
    LstDirDockerToValidate = args.include_dir.split(',')

    # I don't use variable LstDirDockerToValidate because I change it in the process
    for dockerDir in args.include_dir.split(','):
        # Start make in the good directory ( -C .... )
        # ./extractImgDockerCmp.py --dir "../../dockers-projects/x3-webdav/" --imgsPattern harbor.x3rus.com getImgOnly

        cmdOs_extractImgsName = Popen([extractDocker_CmpInfo,
                                       '--dir', dockerDir,
                                       '--imgsPattern', args.registry,
                                       'getImgOnly'],
                                      stdout=PIPE, stderr=STDOUT)

        # Wait the process finish to get return code
        codeReturned = cmdOs_extractImgsName.wait(buildTimeout)

        lstImg2Check4Dir = cmdOs_extractImgsName.stdout.readlines()

        if args.verbose is True:
            print(lstImg2Check4Dir)

        if codeReturned != 0:
            sys.exit(1)

        for img2Check in lstImg2Check4Dir:

            # convert from binary to real string
            imgflat = img2Check.decode('ascii')
            imgWithoutHost = re.sub('^'+args.registry+'/', '', imgflat.rstrip())

            imgSplited = imgWithoutHost.split("/")

            # If the tag ID not pass directly the script can check with the current directory
            if args.getGitHash is True:
                # Check tag hash
                cmdOs_gitGetHashFromDir = Popen(['git', '-C', dockerDir,
                                                'rev-parse', '--short', 'HEAD'],
                                                stdout=PIPE, stderr=STDOUT)
                cmdOs_gitGetHashFromDir.wait(buildTimeout)

                # Fix output to have it as string wihtout carriage return
                tag2Validate = cmdOs_gitGetHashFromDir.stdout.readline().decode('ascii').strip()

            # Start make in the good directory ( -C .... )
            # ./dockerRegistryValidation.py -u BobLeRobot -p Tasoeur123 -c x3-webdav -t latest
            cmdOs_checkDockerRegistry = Popen([checkDockerRegistry_Tag,
                                               '-u', args.user,
                                               '-p', args.password,
                                               '-c', imgSplited[1],
                                               '-t', tag2Validate,
                                               '--script-harbor', harborScript],
                                              stdout=PIPE, stderr=STDOUT)

            # Wait the process finish to get return code
            codeReturnedContactRegistry = cmdOs_checkDockerRegistry.wait(buildTimeout)
            lstImgFoundRegistry = cmdOs_checkDockerRegistry.stdout.readlines()

            # Remove from docker list to build only if we have a full success
            if codeReturnedContactRegistry == 0:
                LstDirDockerToValidate.remove(dockerDir)
            elif codeReturnedContactRegistry == 10:
                if args.verbose is True:
                    print("Docker tag not found")
            else:
                print(codeReturnedContactRegistry)
                print(lstImgFoundRegistry)
                sys.exit(1)

    # return list of directory
    if (args.jenkins):
        if len(LstDirDockerToValidate) == 0:
            print("No_Docker_img_to_build")
        else:
            # Fix output for manipulation
            # lstDirectory == ['x3-webdav', 'x3-harbor']
            # after regex sub == x3-webdac,x3-harbor
            bad_chars = '\[\]\' '
            rgxRmChars = re.compile('[%s]' % bad_chars)
            print(rgxRmChars.sub('', str(LstDirDockerToValidate)))
    else:
        print(LstDirDockerToValidate)
        sys.exit(0)
