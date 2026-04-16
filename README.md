# Recreation of Gnome Computers Transputer Podules

Phil Pemberton, Feb-Apr 2026.

This is a recreation of the Transputer Link and TRAM Podules by Gnome Computers Ltd.

For the Link card, I initially recreated the PROM contents and PAL equations from the schematic. I fixed these when Chris sent me the originals from his archives.

Thanks are due to Chris Stenton of the former Gnome Computers Ltd., who graciously dug into his archives to find some blank PCBs and the PAL/PROM programming files, which were used to build this.


## Files included

  * `doc/*`: Documentation in GCAL and PDF format.
  * `LinkAdapter/*`: KiCAD schematic and PCB and programming files for the Link Adapter.
  * `kobold.c`: Kobold, a brutish licence key forger for Gnome's Transputer `afserver`, `nbserver`, `m2server` and `server14` iservers. Included for documentary, and historical preservation purposes only.


### Gnome Transputer product licensing

The Gnome port of the standard Inmos `iserver` seems to have no licence checks.

The other Transputer host servers (`afserver`, `nbserver`, `m2server` and `server14`) have licensing which is based on the Podule serial number.

The Podule serial number is stored in the second and third bytes of the Podule ID PROM: `serial = (rom[1] >> 4) + (rom[2] << 4)`. The low nibble of `rom[1]` must remain at zero.

From here, you can use Kobold to generate licence keys:

```
$ gcc -o kobold kobold.c

$ ./kobold
Usage: ./kobold [-p PRODUCT] [ -d HEX_KEY_TO_DECRYPT | -e SERIAL_NUMBER [-s STARTING_KEY] ]

Kobold decrypts and finds Podule keys for Gnome Computers Transputer products.

Use -pN to select the product:
   0: afserver, nbserver, m2server (default)
   1: server14

May Kurtulmak bless your fingertips!

# Generate random product keys for serial number 69
$ ./kobold -p0 -e47
Serial 69 (0x45) for afserver/m2server/nbserver => Key 313a5167
$ ./kobold -p1 -e47
Serial 69 (0x45) for server14 => Key 2f51eee5

# Generate product keys starting from a certain value
$ ./kobold -p1 -e69 -s55aa55aa
Serial 69 (0x45) for server14 => Key 55aa798a

# Decrypt product keys
$ ./kobold -p1 -d55aa798a
Key 55aa798a for server14 => serial 69 (0x45)
```

The keys you've generated need to go in `$.library.keys` on the drive you have selected when you run the `*server`. **Note that the Gnome tools only check the first 20 keys in the file!**.

#### Some notes on the algorithm

The algorithm used is a one-way function which contains a linear-congruential-generator-like structure. Both the multiplicative constants are prime, and the additive constant is the same for all the `iserver`s. The multiplied output and adder output are XORed together to produce an accumulator value. A compression function picks three spaced-out 3-bit values from the accumulator: these are used to select three 4-bit numbers which are used to generate the final result. This result needs to match the serial number of the card for the licence to be considered valid.

I'd tell you why the key finder was called Kobold, but explaining a joke would kill it. If you don't get the reference, assume it means something like "Kobold Outputs Benign Obviously-Legal Data". For educational purposes only, not for use in the State of Delaware, void where prohibited, may cause cancer if operated in the State of California.


## About GCAL

The documents for Gnome products were prepared using the University of Cambridge GCAL system, developed by Philip Hazel and [mentioned in his autobiography](https://gwern.net/doc/cs/algorithm/2017-hazel.pdf#page=48) (and very few other places).

GCAL had a successor, SGCAL, which is similarly lightly documented on the public internet. The [source code to version 1.33](https://web.archive.org/web/20151030064313/https://www-uxsup.csx.cam.ac.uk/~bjh21/sgcal_1.33.orig.tar.gz) is preserved, but precious little else. I haven't tried to use SGCAL.

The GCAL manual is preserved in the `doc` directory, and has been converted to PDF format.

Unsurprisingly, [GCAL output is supported by the Aspic utility](https://manpages.ubuntu.com/manpages/trusty/man1/aspic.1.html), which converts a text description of an line-art graphic into EPS, SVG or GCAL line-art.


### Podule ID PROMs

The Podule ID on the various cards is an 8-byte old-style ID (not an ECID) and decodes as follows:

```
0:  &00  - (&01 if generating IRQ)
1:  (reserved)
2:  (reserved)
3:  &24  - Product type low
4:  &00  - Product type high
5:  &0E  - Manufacturer low
6:  &00  - Manufacturer high
7:  &00  - Country code
```

The PAL data seems to use A3 to indicate FIQ status (1=FIQ active), but the Link Podule doesn't use FIQs. A4 is similarly used to indicate IRQs.

There are also two bytes programmed in locations 1 and 2 which are the same in every copy. These areas are marked Reserved in the Podule specification, so should be programmed to zero!
This data seems to be the card's serial number.

The image from Gnome is identified by their `TPROD` utility as having serial number 47, which is encoded into the second and third bytes of the Podule ID PROM:

```
0000: 00 f0 02 24 00 0e 00 00
0008: 04 f0 02 24 00 0e 00 00
0010: 01 f0 02 24 00 0e 00 00
0018: 05 f0 02 24 00 0e 00 00
         ^  ^^

Serial number 47 = &2F => stored in the upper 12 bits of a ui16le at prom[1].

This leaves bits W[1:0] (code width), IS (interrupt status relocation) and CD (chunks present) clear.
```

These are then converted into licence keys or "Podule keys" which are checked by `afserver`, `nbserver` and `Server14`, and can be generated with Kobold (see above).


#### Product type codes

  * `&24`: Link Adapter
  * `&4B`: TRAM Motherboard

Other than the product ID and serial number, the Link and TRAM cards have identical PROM contents.


