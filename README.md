# CardMatch.io
CSCB58 Project File: Summer 2017
 
Team Member A
-------------
First Name: Yasir
Last Name: Haque
Student Number: 1002418225
UofT E-mail Address: yasir.haque@mail.utoronto.ca
 
Team Member B
-------------
First Name: Eric
Last Name: Papagiannis
Student Number: 1002577160
UofT E-mail Address: eric.papagiannis@mail.utoronto.ca
 
Team Member C
-------------
First Name: Marion 
Last Name: Vasantharajah
Student Number: 1002299327
UofT E-mail Address: marion.vasantharajah@mail.utoronto.ca 
 
Team Member D
-------------
First Name: Kareem
Last Name: Mohamed
Student Number: 1002431941
UofT E-mail Address:kareem.mohamed@mail.utoronto.ca 
 
Project Details
---------------
Project Title: CardMatch.io
 
Project Description: 
This will be a card matching game. The game will be multiplayer. The game begins with a 6 x 3 grid of face down cards while each player takes turns selecting a pair of cards. Card selection will be done using a joystick to navigate/select the given cards. Each player earns a point if they find a pair. Player’s turns are also timed using an internal clock. The 20 second timer will be displayed on two hex displays on the board. If a player does not select a pair of cards in time, the game will skip to the other player’s turn. Players are notified if it is their turn through a hex display on the board (i.e. 1 or 2) as well. The game ends when all pairs have been selected, and a winner is determined by whoever has the highest number of pairs. 
Video URL: 
 
Code URL (please upload a copy of this file to your repository at the end of the project as well, it will
serve as a useful resource for future development):
 
 
Proposal
--------
 
What do you plan to have completed by the end of the first lab session?:
 
Develop modules to make cards appear on the VGA display; Design the FSM to keep track of the moves for navigation/selection; Implement full adder modules for keeping track of scores.
 
What do you plan to have completed by the end of the second lab session?:
 
Figure out how to interface joystick with FPGA and process user input (i.e.: highlighting a selected card), i.e. when the card is selected, change its color, and when a button is input, flip card. Also, implement the score system according to the pairs of cards flipped.
 
What do you plan to have completed by the end of the third lab session?:
 
Find out how to randomly generate the board; Working demo of game should be fully implemented; Potential for extra VGA components if possible.
 
What is your backup plan if things don’t work out as planned?
 
Make a simpler version of the game using the FPGA switches as input instead of  the Joystick; Only implement game mode (single player or multiplayer)
 
What hardware will you need beyond the DE2 board 
(be sure to e-mail Brian if it’s anything beyond the basics to make sure there’s enough to go around)
 
Joystick for user control
 
 
 
 
Motivations
-----------
How does this project relate to the material covered in CSCB58?:
 
This project will make use of FSMs to navigate/select cards and will be VGA intensive considering all the cards that will be displayed on the screen. We will also be making use of Registers and Full adders for score computation and addition. We will also need to have a joystick connect to the FPGA board for user input.
 
Why is this project interesting/cool (for CSCB58 students, and for non CSCB58 students?):
 
It's a classic game that can be appreciated by people of all ages and backgrounds. Also the logic behind it takes advantage of everything that we have learned throughout the course
 
Why did you personally choose this project?:
 
This is a game that we all played when we were young, so bringing it back and creating it with our own twist on it is exciting. It will be interesting to see how we go about using the knowledge that we learned in class to implement a game that is relatively well known.
 
Attributions
------------
Provide a complete list of any external resources your project used (attributions should also be included in your
code).  
 
Updates
-------
 
<Example update. Delete this and add your own updates after each lab session>
Week 1: We built the hardware and tested the sensors. The distance sensor we had intended to use didn't work as
expected (wasn't precise enough at further distances, only seems to work accurately within 5-10cm), so instead
we've decided to change the project to use a light sensor instead. Had trouble getting the FSM to work (kept
getting stuck in state 101, took longer to debug than expected), so we may not be able to add the
high score feature, have updated that in the project description as (optional).
 
