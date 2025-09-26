# OffCourse
This repo contains my original code and assets for an in-development 2D golf rpg. Feel free to download the prototype and mess around with it. All rights reserved.


# Current Functionality
## Beginning state:
The player is spawned on an open, boundless, unfinished fairway. The player begins in an idle animation facing 'South'.

## Movement:
Use the arrow keys or 'W', 'A', 'S', 'D' to move the player up, left, down, and right respectively. Valid combinations of these controls will move the player diagonally.

## Balls:
- Press 'P' to place a golf ball.
- While within range and facing a golf ball, press 'P' to pick it up.
- Although not yet displayed, the player starts with 5 balls and will be unable to place more than that amount without retreiving a ball that is already in play.

## Swinging:
- To swing the golf club, hold 'space'. This will enter the player into Swing View.
- While holding 'space', left-click and drag right and then left to perform your back and forward swing, respectively.
- A sound will play to indicate the tempo of the swing.
- Releasing 'space' immediately exits Swing View.
- To hit a golf ball, the player must be facing and within range of a golf ball when entering Swing View.

## Flight Chart
- While the player's ball is in motion, a live graph is displayed tracking the ball's height.
