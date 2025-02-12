BJT Example (ECE 322 Spice Assignment)

.OPTION 	$ The options are listed below:
+ ingold=1	$ Use fixed-point and exponential form on output
+ numdgt=4	$ print 4 digits 

.INC /nfs/guille/analog1/m/moon/ece323/npn322.inc


Vcc	vcc	0	=12.0
q1	c	b	e	npn322
Rb1	vcc	b	2.1k
Rb2	b	0	300
Rc	vcc	c	100
Re1	e	e1	9.5
Re2	e1	0	6.5
Cout	e1	0	63u
Cin	vi	b	1u
Vin	vi	0	AC=1 SIN 0 amp 100K 0 0 180

.OP

.AC DEC 10 1 1G
.NET V(c) Vin
.PRINT AC Vdb(c)

.MEASURE AC A0 FIND VR(c) AT=100K		$ Measure the gain at 10kHz.
.MEASURE AC AdB FIND VdB(c) AT=100K		$ Measure the gain at 10kHz.
.MEASURE AC mzi FIND PAR('v(vi)/i(vin)') AT=100K $ Measure the input impe
.MEASURE AC mzo FIND ZOUT(M) AT=100K		$ Measure the out. imp. @10kHz.
.MEASURE AC fl WHEN VM(c)='.707*ABS(A0)'	$ Find the lower 3dB frequency.
.MEASURE AC fu WHEN VM(c)='.707*ABS(A0)' TD=1e5	$ Find the upper 3dB frequency.

.TRAN .1u 20u SWEEP amp POINTS 2 110m 500m
.PRINT TRAN V(c)

.END
