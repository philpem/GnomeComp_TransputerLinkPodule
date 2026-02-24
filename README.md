# Gnome Computers Transputer Link Podule recreation

Phil Pemberton, Feb 2026.

This is a recreation of the Transputer Link Podule by Gnome Computers Ltd.

Unfortunately I don't have access to a real Link Podule, so I've recreated the PAL equations and PROM contents from the descriptions in the manual.
Provided mine are used together, they should be equivalent to the originals.

Please get in touch if you have access to an original Podule and would be willing to dump the PROM, PAL or both.

Thanks are due to Chris Stenton of the former Gnome Computers Ltd., who graciously dug into his archives to find some blank PCBs and the PAL/PROM programming files, which were used to build this.

## Files included

  * `doc/*`: Documentation in GCAL and PDF format.
  * `kicad/*`: KiCAD schematic and PCB files, reverse-engineered from scans of the original PCB.
  * `ic3.bin`: IC3 (82S123 PROM) data, binary -- my recreation. TPROD identifies this as a Transputer Link, serial number 0.
  * `lap.{bin,hex}`: IC3 (82S123 PROM) data -- original from Gnome. TPROD identifies this as a Transputer Link, serial number 47.
  * `ic4/lap11.{pld,jed,wcp}`: IC4 logic equations in WinCUPL format.
  * `ic4_orig`: IC4 logic equations for PAL16L8 -- original from Gnome. Format unknown.
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

### Which files to program into the devices

Use the original PROM file if you can. If you're programming 82S123s and accidentally programmed one with `ic3.bin`, you can reprogram it with `lap.bin` if you bypass the Blank Check. This works because blowing a fuse in an 82S123 sets the bit, and programming `lap.bin` only involves setting more bits.

I've not been able to find a tool which can assemble the original IC4 logic (CUPL and ABEL rejected it). I suspect it might be written in AMD's PLPL language. If that's the case, PALASM4 seems to be able to convert it to PALASM, but this fool's errand is left as an exercise for the reader. (To the someone who actually does it: please send me a PR!)

### About GCAL

The documents for Gnome products were prepared using the University of Cambridge GCAL system, developed by Philip Hazel and [mentioned in his autobiography](https://gwern.net/doc/cs/algorithm/2017-hazel.pdf#page=48) (and very few other places).

GCAL had a successor, SGCAL, which is similarly lightly documented on the public internet. The [source code to version 1.33](https://web.archive.org/web/20151030064313/https://www-uxsup.csx.cam.ac.uk/~bjh21/sgcal_1.33.orig.tar.gz) is preserved, but precious little else. I haven't tried to use SGCAL.

The GCAL manual is preserved in the `doc` directory, and has been converted to PDF format.

Unsurprisingly, [GCAL output is supported by the Aspic utility](https://manpages.ubuntu.com/manpages/trusty/man1/aspic.1.html), which converts a text description of an line-art graphic into EPS, SVG or GCAL line-art.

## Assembly instructions

This is a fairly straightforward build, but has some unusual parts.
The Inmos C012 link adapter chip might be tricky to find, but the C011 can be used instead by fitting a larger socket in the IC7 footprint.

There are two programmable devices:

  * IC3: 82S123N PROM, 32*8-bit wide = 256 bit.
    * Substitutes: MMI 6331-1, 63S081 or 63LS081. TI TBP18S030. Harris HM7603-5. AMD AM27S19, AM27S19AC, AM27S09 or AM27LS09. National 74S2788.
  * IC4: TIBPAL16L8-25 PAL.
    * Substitutes: ATF16V8 or GAL16V8.

The 82S123 PROM has a number of substitutes, but finding a programmer which can program them might be tricky. If all else fails, the PROM can be replaced with another GAL in a socket adapter. This is left as an exercise to the reader, but [Mark Haysman's article on a 'reprogrammable 82S123'](http://www.retroclinic.com/leopardcats/galprom/galprom.htm) will probably be helpful.

The bipolar PROM cross-references I use are:

  * https://www.pe1abr.nl/pdf/TTL-BIPOLAR_PROM-RAM_REFERENCE_GUIDE_V5.pdf
  * http://matthieu.benoit.free.fr/cross/data_sheets/NS_bipolar_.prom_cross_reference_guide.pdf
  * https://www.mikesarcade.com/cgi-bin/spies.cgi?action=url&type=info&page=PromRef.txt


### IC3: Podule ID PROM.

The PROM has A3 grounded, and A4 is driven by the PAL to indicate an interrupt is being signalled.
This means that only two banks of 8 bytes are ever addressed.

The Podule ID is an old-style ID (not an ECID) and decodes as follows:

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

The PAL data seems to use A3 to indicate FIQ status (1=FIQ active), but the Link Podule doesn't use FIQs.

There are also two bytes programmed in locations 1 and 2 which are the same in every copy. These areas are marked Reserved in the Podule specification, so should be programmed to zero!  I suspect this might be related to the copy-protection on some of the Gnome software.

The image from Gnome is identified by their `TPROD` utility as having serial number 47. I suspect this is encoded into the second and third bytes of the Podule ID PROM:

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

### IC4: Address decoder PAL.

This is a PAL16L8 in the original design, but it can be replaced with a GAL16V8. If you use a PAL16L8, program it with the original Gnome Computers JEDEC file. If you use a GAL16V8, use my recreated WinCUPL programming files.

25ns speed grade is plenty fast enough. I used a 10ns chip and it worked fine.


## Bill of Materials and assembly notes

This is the original BOM given to me by Gnome Computers.

A few notes on part substitutions:

  * IC5 may be an Inmos IMSC012, but the larger footprint will take the more easily obtained IMSC011.
  * C1 (1uF monolithic multilayer ceramic) is critical, as it's the filter capacitor for the link chip's internal PLL.
  * C2 and C3 are fairly non-critical. I've used 10uF electrolytics.
  * C4 thru C11 are also fairly non-critical. I used 100nF 63V metallised polyester film capacitors, Arcotronics (now Yageo/Kemet) R82DC3100DQ50J.
  * The pitch for all the non-polarised capacitors is 5mm.

J2 needs some care. A 5-pin header is fitted at each end of the 12-pin connector, with the middle 2 pins empty. The left header should have pins 1 and 5 grounded, and pin 2 is removed. If you look at the PCB, you'll see that pin 2 has nothing connected to it. Pin 1 of J2 is nearest the crystal oscillator.

```
           Link Adapter Board, Issue 1
           ===========================

Part    Description                       Source      Order Code   Price

R1      100R 0.25W 5% carbon film         Farnell     DCR25 100R   0.0124 (100)
R2      10K          "                    Farnell     DCR25 10K    0.0124 (100)
R3      100K         "                    Farnell     DCR25 100K   0.0124 (100)

C1      1u0 ceramic multilayer            Farnell     146-235      0.267  (100)
C2-3    6.8uF 16V tantalum bead           STC         015772R      0.09   (100)
C4-11   10nF 63V ceramic plate            Farnell     629 19103    0.04   (100)

IC1-2   74HCT245                          Quarndon    SN74HCT245N  0.34   (10)
IC3     N82S123AN                         Quarndon    <---         0.86   (10)
IC4     TIBPAL16L8-25                     Quarndon    <---         1.20   (10)
IC5     IMSC012-P20S                      Anzac etc   <---         5.31   (1)
IC6     5MHz crystal oscillator           ACT         ACT1100 5MHz 2.75   (10)
IC7     74HCT175                          Quarndon    PC74HCT175P  0.32   (10)
IC8     74HCT244                          Quarndon    SN74HCT244N  0.31   (10)

J1      64 way DIN 41612 plug             Farnell     104-985      1.03   (1)
J2      5 way Molex header (2 off)        Farnell     146-694      0.312  (1)

Other parts

Socket  20 way (IC8)                      Farnell     178-858      0.1175 (20)
PCB     Link Adapter Board (Issue 1)      Camb Cct Co <---         18.43  (10)
Board mounts (1 pack of 2)                Verospeed   173-12525B   0.40   (10)
Panel   Link Adapter Panel                Entec       <---         2.18   (25)
Nuts    M2.5 (4 off)                      Farnell     149-679      0.0065 (100)
Bolts   M2.5 10mm (4 off)                 Farnell     149-462      0.0074 (100)

PALS    IC4  LAP11.JED
PROMS   IC3  LAP.HEX
```

