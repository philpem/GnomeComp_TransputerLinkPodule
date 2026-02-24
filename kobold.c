/**
 * Kobold: a lunchbox-sized licence key forger and decrypter for Gnome Computers Transputer products.
 * philpem, 2026-02-24
 *
 * $ gcc -o kobold kobold.c
 * $ ./kobold
 *
 * all the best-worst code happens at 2:14 am
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

// turn a keycode (r0) into a serial number
// (mode) selects the product
static uint32_t get_serial_for_key(uint32_t r0, int mode)
{
    uint32_t r1, r2, r3;
    uint32_t multiplier;

    switch (mode) {
    case 0: // afserver, nbserver
        multiplier = 1234567891u;
        break;
    case 1: // server14
        multiplier = 2236133941u;
        break;
    default:
        fprintf(stderr, "Bad mode\n");
        exit(EXIT_FAILURE);
    }

    /* Phase 1: multiply by product-specific constant (mod 2^32) */
    r1 = r0 * multiplier;

    /* Phase 2: XOR with (input + constant) */
    uint32_t x = r1 ^ (r0 + 0xCC7D1E7Du);

    /* Phase 3: extract three nibbles at data-dependent positions */
    uint32_t mask = 0xF;
    r3 = (x >> 23) & mask;   /* shift amount for nibble 0 */
    r2 = (x >> 17) & mask;   /* shift amount for nibble 1 */
    r1 = (x >>  7) & mask;   /* shift amount for nibble 2 */

    r3 = (x >> r3) & 0xF;
    r2 = (x >> r2) & 0xF;
    uint32_t r0out = (x >> r1) & 0xF;

    r0out = (r0out << 8) | (r2 << 4) | r3;
    return r0out;
}

// find a key for podule s/n (cardserial), starting at (start), for product (mode)
uint32_t find_key(const uint32_t cardserial, uint32_t start, int mode)
{
    uint32_t key = start;

    // brute force search - should find a match within about 2^12 tries, give or take.
    while (true) {
        if (get_serial_for_key(key, mode) == cardserial) {
            //printf("  MATCH: 0x%08X => serial number %d (0x%x)\n", key, cardserial, cardserial);
            break;
        }
        key++;
    }
    return key;
}

// all the programs we support in order of their -p value
const char *PROGRAMS[] = { "afserver/m2server/nbserver", "server14" };

int main(int argc, char **argv)
{
    int opt;

    uint32_t k, s;
    int program = 0;
    int mode = -1;

    // for key finding: set starting key to a random value
    srand(time(NULL));
    k = rand();

    while ((opt = getopt(argc, argv, "d:e:p:s:")) != -1) {
        switch(opt) {
        case 'd':
            // decrypt a hex key
            sscanf(optarg, "%x", &k);
            mode = 0;
            break;
        case 'e':
            // find a key for a serial number
            sscanf(optarg, "%d", &s);
            mode = 1;
            break;
        case 'p':
            // set program id
            program = atoi(optarg);
            if (program < 0 || program >= (int)(sizeof(PROGRAMS)/sizeof(PROGRAMS[0]))) {
                fprintf(stderr, "Invalid program ID %d\n", program);
                exit(EXIT_FAILURE);
            }
            break;
        case 's':
            // set starting key
            sscanf(optarg, "%x", &k);
            break;
        default:
            mode = -1;
            break;
        }
    }

    // do the thing
    switch (mode) {
    case -1:
        // nuh-uh-uhh, you didn't say the magic word
        fprintf(stderr,
            "Usage: %s [-p PRODUCT] [ -d HEX_KEY_TO_DECRYPT | -e SERIAL_NUMBER [-s STARTING_KEY] ]\n\n"
            "Kobold decrypts and finds Podule keys for Gnome Computers Transputer products.\n\n"
            "Use -pN to select the product:\n"
            "   0: afserver, nbserver, m2server (default)\n"
            "   1: server14\n\n"
            "May Kurtulmak bless your fingertips!\n",
            argv[0]);
        exit(EXIT_FAILURE);
        break;
    case 0:
        // decrypt a key
        s = get_serial_for_key(k, program);
        printf("Key %x for %s => serial %d (0x%x)\n", k, PROGRAMS[program], s, s);
        break;
    case 1:
        // find a key for a given serial number
        k = find_key(s, k, program);
        printf("Serial %d (0x%x) for %s => Key %x\n", s, s, PROGRAMS[program], k);
        break;
    }

    return 0;
}
