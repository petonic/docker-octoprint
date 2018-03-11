#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#define LED_STR "import gpio; gpio.setup(%d, gpio.OUT); gpio.output(%d, %s)"
#define PYTHON_PATH "/usr/local/bin/python"

void usage(progname, str)
char *progname;
char *str;
{
    if (str != NULL) {
        fprintf(stderr, "%s: Error: %s\n", progname, str);
    }
    fprintf(stderr, "Usage: %s <gpio_pin> <on|off>\n", progname, str);
    (void)  exit(2);
}



int main(argc, argv)
int argc;
char **argv;
{
    int pin;
    char *new_verb = NULL;
    char cmd_str[1024];
    char *new_argv[4];

    if (argc != 3) {
        usage(argv[0], "Improper usage");
    }

    if (!(pin = atoi(argv[1]))) {
        usage(argv[0], "First parameter is not an INT");
    }

    if ((pin < 1) || (pin > 40)) {
        usage(argv[0], "Pin number is out of range: [0-40]");
    }

    if (!strcmp(argv[2], "on")) {
        new_verb = "True";
    } else if (!strcmp(argv[2], "off")) {
        new_verb = "False";
    } else {
        usage(argv[0], "third argument, verb, must be either 'on' or 'off'.");
    }

    sprintf(cmd_str, LED_STR, pin, pin, new_verb);
    new_argv[0] = PYTHON_PATH;
    new_argv[1] = "-c";
    new_argv[2] = cmd_str;
    new_argv[3] = (char *) NULL;

    /* setreuid(geteuid(), getuid()); */
    
    seteuid(0);
    execv(PYTHON_PATH, new_argv);
}
