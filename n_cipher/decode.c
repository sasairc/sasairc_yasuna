#include <stdio.h>
#include <stdlib.h>
#include <n_cipher.h>

int main(int argc, char* argv[])
{
    int         ret = 0;

    char*       buf = NULL;

    N_CIPHER*   n_cipher;

    if (argc < 0)
        return 1;

    init_n_cipher(&n_cipher);
    n_cipher->config(&n_cipher, "くそぅ\0", "！\0");

    if ((buf = n_cipher->decode(&n_cipher, argv[1])) != NULL)
        fprintf(stdout, "%s\n", buf);
    else
        ret = 2;

    free(buf);
    n_cipher->release(n_cipher);

    return ret;
}
