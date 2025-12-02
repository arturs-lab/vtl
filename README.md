# vtl
Very Tiny Language
Copied from https://deramp.com/downloads/altair/software/

# rtfm
You really have to know how to even get started. Start sequence is bizarre. So read the manual. 
doc/VTL-2 Manual.pdf
Page 0 must be RAM because currently that's what VTL is using for variables.
VTL loads at $f800 and has to be started from there.
Line endings are LF and VTL gets confused if it gets anything else.
VTL expects all capital letters.

```
*=1024*39
&=320
?=*-&
```