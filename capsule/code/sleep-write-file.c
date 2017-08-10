

/* 
 * Licence : GPL v2+
 * Author : Thomas Boutry <thomas.boutry@x3rus.com>
 * Description : demo setgid
 */


#include<stdio.h>
#include <unistd.h>

int main()
{
        printf("start App");

        printf("Wait ...");
        sleep(10);


        FILE *fp;
        fp=fopen("/tmp/test-bin.txt", "w");
        fprintf(fp, "Testing...\n");

        fclose(fp);

        printf("Fin...");
}

