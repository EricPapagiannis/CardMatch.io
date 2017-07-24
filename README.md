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

Code URL (please upload a copy of this file to your repository at the end of the project as well, it will serve as a useful resource for future development):


Proposal
--------

What do you plan to have completed by the end of the first lab session?:

Develop modules to make cards appear on the VGA display; Design the FSM to keep track of the moves for navigation/selection; Implement full adder modules for keeping track of scores and registers to save the values.

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
Week 1:
We did work on the VGA display side of the project as well as the FSM. The VGA displays currently the wanted background image with cards facing down, and can display 22 x 32 pixel cards as wanted. We got the full adders / registers for scores, it just needs to be hooked up to the FSM. The FSM is still being developed, we had trouble configuring the multi player aspect of it (debugging it, displaying states with LEDs took time too), and as a result we will make up for lost time in the Maker space next week. 

Week 2:
We finalized the look of the game on the VGA. Cards now can be 'flipped' and reveal the color of the card. The background, the cards and card boders are finalized, all that's left to do on the VGA is to get a working cursor that moves on joystick movement, as well as find out how get 9 pairs of colors on 8 possible color values. For the FSM, we have finished designing the logic of the game, such that when a player matches a card, the same player can go again, and when the player fails to match, the other player can now make their move. What's left of the FSM is score and turn display on the HEXs of the DE2 board. Lastly, now that we have all the components for the joystick, in the next session, a test module will be made to light up LEDs on joystick inputs. We will be connecting the joystick to the GPIO input and pin assign the 4 input pins. If this still gives us trouble by the next session, we will be using DE2 board switches for card selection instead.

Week 3:
We have integrated the VGA component of the game into the games logic (i.e.: The FSM and data control) so most of the game has been completed. We were not able to get the joystick working as well as we wanted it too, so we have decided to use the 18 switches on the DE2 board to control the card flipping (this works perfectly since our board's dimensions are 6x3). At this moment, 2 players are able to play against eachother by selecting cards. Green LED's indicate which players turn it is, and a player can continue to choose cards until they choose an invalid pair. All thats left to do now is to add score tracking, and modify the background .MIF file to include which cards correspond to which switches (to make the players lives easier). Scores will be displayed on the HEX's, with one of the HEX's displaying which player is in the lead. We wanted to give players as much time to memorize the card locations as possible (this is a memory game, not a guesing game), so we designed our game such that the user will "unflip" the cards when they are finished with them and ready (assuming its an invalid pair).
