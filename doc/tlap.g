. > tlap
.
.set maintypesize 9
.set typeface "Palatino"
.include "a5atl"
.
.bindfont 14 "atl/~~typeface-Bold" 14000
.bindfont 15 "atl/~~typeface-Bold" 12000
.
.usegreek
.
.parspace 1
.parindent 0
.justify
.
.cancelflag $chead
.cancelflag $shead
.cancelflag $sshead
.
.flag $chead "$f14" "$f"
.flag $shead "$f15" "$f"
.flag $sshead "$bf" "$unbf"

.set chapter -1
.set section -1
.set subsection -1
.
.nofoot
.copy
.goto 144.0
.
$c $f14 Transputer Link Adapter Board $f
.
.space
.
$c $f14 User Guide $f
.
.goto 414.0
.
Gnome Computers Ltd
25A Huntingdon St.
St. Neots
Cambridgeshire
PE19 1BG
.
.
.blank
.
Tel. (0480) 406164 $e Issue 2
.
.fill
.set sectname "Introduction"
.
.headlength 2
.head
~%page $e $it~!sectname$unit
.endh
.
.
.newpage
.
.footlength 1
.foot
$c--
.endf
.
.section Introduction

The Transputer Link Adapter Board (TLAB) is a circuit card which plugs into
the expansion bus of the Acorn Archimedes computer. Expansion cards for
the Archimedes are called podules and the TLAB is a so-called Simple Podule.
Its function is to allow the Archimedes to access data sent over Inmos
transputer links. This is achieved with the use of an Inmos link adapter chip
on the TLAB. This chip has a register interface which is mapped into the
Archimedes' I/O address space and an Inmos link interface which is available
on a connector on the card. Data written to the chip from the Archimedes may
be sent down the link while data received from the link may be read by the
Archimedes.

The TLAB can also be programmed to interrupt the Archimedes when the link is
ready to send more data and/or when data has been received from the link.
It also contains a control/status register which is used to configure
the card and control various lines which appear on the link interface on the
card.
.
.section Installation

The TLAB card is a single Eurocard PCB measuring 100x160mm. It has a 64 way
connector at one end and a 12 way connector and mounting panel at the other
end. The card contains static sensitive ICs and so appropriate precautions
should be taken while handling and installing it.

The card is installed by plugging it into a free slot in the expansion
backplane. There is no need to configure the card to respond to a particular
address as each slot has a distinct address range. The driving software will
normally scan all the slots to locate the appropriate podule.

The machine should be switched off while the installation is done. The lid of
the machine should be removed and the board plugged into a free slot in the
podule backplane. The rear panel can then be screwed down to secure the card
in the machine. Note that a design feature of the Archimedes means that
podules designed to the Eurocard format will protrude from the rear of the
machine by approximately 2.5mm. Finally, the lid should be replaced and
the installation is then complete.

The TLAB draws power from the +5V rail of the Archimedes and requires
approximately 150mA.
.
.section Link connections

The link connection is made via a 12 way connector which protrudes through
the TLAB mounting panel. The connector is formed from two 5 pin Molex
connectors with locking mechanisms. There is a 0.2" gap between the two
connectors and one connector has a pin removed so that there are only 9 pins
actually present. The pins are numbered from the left when viewed from the
rear of the machine as follows:
.
.tabset 10 20 35
.copy
.contig inline
.space
.
$t _Pin $t Signal   $t Function_

$t 1  $t GND        $t Connected to Archimedes' 0V rail
$t 2  $t            $t (absent)
$t 3  $t LinkOut    $t Link data out of TLAB
$t 4  $t LinkIn     $t Link data into TLAB
$t 5  $t GND
$t 6  $t            $t (absent)
$t 7  $t            $t (absent)
$t 8  $t ResetOut   $t Reset line to transputer
$t 9  $t AnalyseOut $t Analyse line to transputer
$t 10 $t ErrorIn    $t Error line from transputer
$t 11 $t GND
$t 12 $t GND
.
.space
.endc
.fill
.
All the outputs are driven by a 74HCT244 driver chip. The LinkOut line has a 
100$gcomega$$ ohm series resistor, the others are driven directly. The inputs
are buffered by the same 74HCT244. The LinkIn line has a 10K$gcomega$$
pulldown resistor and the ErrorIn line has a 100K$gcomega$$ pulldown.

In order to conform to the Inmos standard it is necessary to cut off
pins 11 and 12. The board is normally supplied with these pins intact so
that a ground connection is available where the application requires it.
.
.section Programming the TLAB

It is assumed that the reader is familiar with the Acorn documentation for
podules ("A Series Podules", Acorn Computers, May 1987) and the Inmos data
sheet for the IMSC012 link adapter chip. All devices on the TLAB are byte
wide and should therefore be accessed with byte (as opposed to word) cycles.

The TLAB contains a podule identity (PI) ROM which is mapped into the PI
space. The ROM contains an extended (8 byte) PI as follows:
.
.copy
.contig inline
.space
.
$t _Byte $t Content $t Comment_

$t 0 $t X'00' $t (X'01' if generating IRQ)
$t 1 $t       $t (reserved)
$t 2 $t       $t (reserved)
$t 3 $t X'24' $t Product type (low)
$t 4 $t X'00' $t Product type (high)
$t 5 $t X'0E' $t Manufacturer (low)
$t 6 $t X'00' $t Manufacturer (high)
$t 7 $t X'00' $t Country
.
.space
.endc
.fill
.
Bit 0 of byte 0 is a 1 when the TLAB is generating an IRQ interrupt. The TLAB
does not generate FIQ interrupts.

The TLAB is a Simple Podule and is thus accessed by cycles controlled by the
Archimedes' I/O controller chip. All devices on the TLAB may be accessed
using fast cycles. In addition to the podule ID ROM the TLAB contains an
Inmos C012 (or equivalent C011) link adapter chip and a control/status
register (CSR). The four registers of the link adapter are mapped into
successive words in the I/O space and the CSR is mapped into the next word.
Thus, if the TLAB is placed in podule slot 0 in the Archimedes the memory map
is as follows:
.
.copy
.contig inline
.space
.tabset 10 20 41c
.
$t _Address $t Content $t Access speed_

$t X'33C0000' $t PI byte 0    $t synchronous
$t X'33C0004' $t PI byte 1    $t "
$t . . .      $t . . .        $t "
$t X'33C001C' $t PI byte 7    $t "

$t X'3342000' $t C012 reg 0   $t fast
$t X'3342004' $t C012 reg 1   $t "
$t X'3342008' $t C012 reg 2   $t "
$t X'334200C' $t C012 reg 3   $t "
$t X'3342010' $t CSR          $t "
.
.space
.endc
.fill
.
This set of registers repeats at 8 word intervals throughout the podule
address space. To maintain compatability with future products of a similar
type, only the lowest set of addresses should be used.

The control status register contains 4 bits which may be read or written and
one bit which is read-only. The read/write bits are cleared to zero when the
Archimedes' reset line is asserted. When writing to the CSR, the unused bits 
(4 to 7) should be zero to maintain compatibility with other similar products.

The functions of the bits in this register are as follows

$bf Bit 0 - ResetOut$unbf. Writing a 1 asserts (drives low) the reset line on
the link connector.

$bf Bit 1 - AnalyseOut$unbf. Writing a 1 asserts (drives low) the analyse
line on the link connector.

$bfBit 2 - LinkSpeed$unbf. Connected to the LinkSpeed pin of the link adapter
chip. Writing a 1 causes the link adapter chip to operate with a 20MHz link
speed. A zero causes a link speed of 10MHz.

$bfBit 3 - ChipReset$unbf. Writing a 1 asserts the reset line of the link
adapter chip. Normally asserted with ResetOut and may be useful if the chip
locks up because of a faulty link connection.

$bfBit 4 - ErrorIn$unbf. Reflects the state of the ErrorIn signal on the link
connector. This bit is read-only and a 0 indicates the presence of an error
(or absence of a link cable!).

The two interrupt signals of the link adapter chip are ORed together to
generate the IRQ signal required by the Archimedes. The link adapter chip is
reset whenever the Archimedes' reset line is asserted, thus ensuring that
interrupts are disabled when the system starts up.
.
