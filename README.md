# HockeyTourney
The program is designed to emulate a scoreboard and seven segment display for a hockey tournament in ARM assembly.
View my flowchart for this program at: https://drive.google.com/file/d/1jkeZEBap6PB27HxGQ2tysDYolQMW2xxF/view?usp=sharing
The program is designed to emulate a scoreboard and seven segment display for
a hockey tournament.
• There is (in the DATA section) two null-terminated integer arrays called
homescores and awayscores. These are used to hold packed values (as in HW8)
that represent team scores. The maximum score is 9.
• The most significant four bits of the integer are the first score, then the next
four bits, etc., with the four least significant bits read last. This means if the
first value of homescores is 0x12345678 and the first value of awayscores is
0x90182736, the scores are to be dealt with in this order: home 1, away 9; then
home 2, away 0; then home 3, away 1; home 4, away 8; home 5, away 2; home 6,
away 7; home 7, away 3; home 8, away 6.
• Also in the DATA section is a byte array named scoreboard that holds two
values. The first represents how the home team’s score would be shown on a
seven-segment display, and the second represents the away team in the same
manner.
• For the seven segment display’s values to be represented in binary, a 0 will
represent “off” and a 1 will represent “on”. A single byte will be necessary to
represent a single digit, and the most significant bit will always be 0. To
represent a 0, for example, all of the segments except for the middle one will be
on. The table below shows each digit and what will be stored for display on a 7-
segment display.
Digit represented 0 1 2 3 4 5 6 7 8 9
Byte stored (7seg) 0x3F 0x03 0x5B 0x4F 0x66 0x6D 0x7D 0x07 0x7F 0x77
• For example, if the home score is 5 and the away score is 2, the scoreboard array
will hold 0x6D, 0x5B.
• Also also in the DATA section is a single byte called winning. This value will be a
0 if the home team won (a.k.a. their score was higher), a 1 if the away team won,
and a -1 (0xFF) if it’s a tie (a.k.a. both scores are the same).
• The program cycles through the home and away scores one value at a time
then stores the values for scoreboard and winning. Each time through the loop,
these are overwritten.

