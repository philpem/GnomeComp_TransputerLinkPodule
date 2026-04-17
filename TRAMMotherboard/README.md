# Gnome Computers Transputer TRAM Motherboard Podule recreation

Phil Pemberton, April 2026.

This is a rebuild of the TRAM Motherboard Podule by Gnome Computers Ltd.

Unlike the Link Adapter, the logic equations are direct conversions of the Gnome Computers ones. The card should work identically to the original.
The PROM file has been altered to have the same serial number as the Transputer Link card. This means only one licence key is needed.

Thanks are due to Chris Stenton of the former Gnome Computers Ltd., who graciously dug into his archives to find some blank PCBs and the PAL/PROM programming files, which were used to build this.

## Files included

  * `doc/*`: Documentation in GCAL and PDF format.
  * `kicad/*`: KiCAD schematic and PCB files, reverse-engineered from scans of the original PCB.
  * `tmp.{bin,hex}`: IC3 (82S123 PROM) data -- from Gnome, with altered serial number. TPROD identifies this as a TRAM Motherboard, serial number 47.
  * `ic2/tmp11.pld`: IC2 logic equations in WinCUPL format.
  * `ic7/tmp21.pld`: IC7 logic equations in WinCUPL format.

## Assembly notes

Assembly should be fairly straightforward. The only possibly point of issue is the Subsystem connector. I haven't seen an original Gnome Computers board, but I suspect the Subsystem pins might have been round-pin (Harwin) headers, the mating halves of the turned-pin sockets used for the TRAMs themselves.

Inmos TRAM motherboards usually use a recessed socket (e.g. Harwin H3153 or Mill-Max 0552-1-15-01-11-27-10-0) and a double-ended 3-pin header (e.g. Samtec HLT-0103-G-R). The 3-pin header is pushed into the recessed socket and connects it to the recessed socket on the TRAM. With careful design of the TRAM motherboard (e.g. jumpers or multiplexing for the Subsystem port), pin headers can be used as above, and this complex mechanical arrangement becomes unnecessary.

Low-profile IC sockets need to be used (if they're used at all) or there's a risk of the top of the chips hitting the bottom of the TRAMs. On my build I only socketed the programmable devices.


## Bill of Materials

```
           TRAM Motherboard, Issue 1
           =========================

Part    Description                       Source      Order Code   Price

R1      10K 0.25W 5% carbon film          Farnell     DCR25 10K    0.0124 (100)
R2      100R        "                     Farnell     DCR25 100R   0.0124 (100)

RP1     100R*4 8 pin SIL                  Farnell     107-055      0.18   (1)
RP2     4K7*8  9 pin SIL                  Farnell     148-983      0.22   (1)

LK1-2   3 pin header                  (1) Farnell     148-533      0.72   (1)
LK3-4   2 pin header                  (1) Farnell     148-533      0.72   (1)

J1      64 way DIN 41612 plug             Farnell     104-985      1.03   (1)
J2      37 way D plug                     Farnell     150-819      1.94   (1)
J3-10   8 way socket strip            (2) Verospeed   19-2185A     0.4055 (20)

IC1     74HCT245                          Quarndon    SN74HCT245N  0.34   (10)
IC2     TIBPAL16L8-25                     Quarndon    <---         1.20   (10)
IC3     N82S123AN                         Quarndon    <---         0.86   (10)
IC4     74HCT174                          Quarndon    PC74HCT174P  0.40   (10)
IC5     IMSCO12-P20S                      Anzac etc   <---         5.31   (1)
IC6     5MHz crystal oscillator           ACT         ACT1100 5MHz 2.75   (10)
IC7     TIBPAL16L8-25                     Quarndon    <---         1.20   (10)
IC8     74LS132                           Quarndon    N74LS132N    0.30   (10)
IC9     74HCT04                           Quarndon    SN74HCT04N   0.12   (10)

C1      1u0 ceramic multilayer            Farnell     146-235      0.267  (100)
C2-5    100n ceramic multilayer           Farnell     106-444      0.11   (1)
C6-7    6.8uF 16V tantalum bead           STC         015772R      0.09   (100)
C8      470u 16V electrolytic             Farnell     106-005      0.267  (1)
C9-13   100n ceramic multilayer           Farnell     106-444      0.11   (1)

Other parts

PCB     TRAM podule PCB (Issue 1)         Camb Cct Co <---        29.33   (5)
Panel   TRAM motherboard panel            Entec       <---         2.18   (25)
Board mounts (1 pack of 2)                Verospeed   173-12525B   0.40   (10)
Nuts    M2.5 (4 off)                      Farnell     149-679      0.0065 (100)
Bolts   M2.5 10mm (4 off)                 Farnell     149-462      0.0074 (100)

PALS    IC2     TMP11.JED
        IC7     TMP21.JED
PROMS   IC3     TMP.HEX

Note    (1) Supplied as strips of 36 pins to be cut
        (2) Supplied as strips of 20 contacts to be cut
```
