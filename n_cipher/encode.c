#include <stdio.h>
#include <stdlib.h>
#include <n_cipher.h>

int main(int argc, char* argv[])
{
    char*   buf = NULL;

    if (argc < 0)
        return 1;

    if ((buf = encode_n_cipher(argv[1], "くそぅ", "！")) != NULL)
        fprintf(stdout, "%s\n", buf);
    else
        return 2;

    free(buf);

    return 0;
}
