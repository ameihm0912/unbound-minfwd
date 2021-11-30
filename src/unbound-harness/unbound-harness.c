#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h>
#include <errno.h>
#include <signal.h>

/*
 * Provides a simple wrapper around the unbound process that can be
 * extended to filter logs prior to for example hitting the system
 * journal. Currently just aggregates output from the unbound process.
 */

#define PROC_PATH "/usr/local/sbin/unbound"
#define PROC      "unbound"

void logmsg(char *, ...);

int childpid = 0;

void
logmsg(char *fmt, ...) {
        char buf[2048];
        va_list ap;

        va_start(ap, fmt);
        vsnprintf(buf, sizeof(buf), fmt, ap);
        va_end(ap);

        printf("unbound-harness: %s\n", buf);
}

void
shandler(int s)
{
        if (childpid == 0) {
                exit(1);
        }

        if (s == SIGTERM && childpid != 0) {
                kill(childpid, SIGTERM);
        }
}

int
main(int argc, char *argv[])
{
        FILE *readfd;
        char buf[10240];
        char *p0;
        int status;
        int fds[2];
        int ret;

        setbuf(stdout, NULL);
        logmsg("initializing");
        ret = pipe(fds);
        if (ret == -1) {
                perror("pipe");
                exit(1);
        }

        readfd = fdopen(fds[0], "r");
        if (readfd == NULL) {
                perror("fdopen");
                exit(1);
        }

        ret = fork();
        if (ret == -1) {
                perror("fork");
                exit(1);
        } else if (ret == 0) {
                // Child
                close(fds[0]);
                ret = dup2(fds[1], STDOUT_FILENO);
                if (ret == -1) {
                        perror("dup2");
                        exit(1);
                }
                ret = dup2(fds[1], STDERR_FILENO);
                if (ret == -1) {
                        perror("dup2");
                        exit(1);
                }
                ret = execl(PROC_PATH, PROC, NULL);
                if (ret == -1) {
                        perror("execl");
                        exit(1);
                }
        }

        signal(SIGINT, shandler);
        signal(SIGTERM, shandler);

        childpid = ret;
        close(fds[1]);
        for (;;) {
                p0 = fgets(buf, sizeof(buf), readfd);
                if (p0 == NULL) {
                        if (ferror(readfd) != 0) {
                                if (ferror(readfd) == EINTR) {
                                        continue;
                                }
                        }
                        break;
                }
                printf("%s", p0);
        }

        if (waitpid(childpid, &status, 0) == -1) {
                perror("waitpid");
                exit(1);
        }

        if (WIFEXITED(status)) {
                logmsg("child process exit with code %d", WEXITSTATUS(status));
        } else if (WIFSIGNALED(status)) {
                logmsg("child process exit on signal %d", WTERMSIG(status));
        }

        return (0);
}
