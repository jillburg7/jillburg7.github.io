
// BUTTONS
RectButton checkButt, newButt, revealButt, tutorialButt;

color clicked;
boolean ready = false, gameStarted = false, check = false, selected = false, set = false;

// game modes
int CURRENT_PROGRAM_MODE = -1, GUESS_MODE = 1, FEEDBACK_MODE = 2, CODE_MODE = 3;

// game variables
int numGuess = 0, numWhite = 0, numBlack = 0;
int position = 0;

// peg maps
HashMap<Integer, RandomPeg> c = new HashMap<Integer, RandomPeg>(4);
HashMap<Integer, Peg> g = new HashMap<Integer, Peg>(4);
HashMap<Integer, Peg> colorpegs = new HashMap<Integer, Peg>(8);
ArrayList colorMap = new ArrayList();
FeedbackPeg[] fb = new FeedbackPeg[4];
ArrayList pQ;

// Define and create rectangle button
color buttoncolor = color(204);
color highlight = color(153);

//drawing locations
int off = 25;
int xLoc, yLoc;
int sizer;
int xoff, yoff;
int xScale, yScale;

//colors
color RED, ORANGE, YELLOW, GREEN, TEAL, BLUE, PURPLE, PINK, EMPTY, WHITE, BLACK;

void setup () {
  size( 570, 900 );
  set = false;
  
  CURRENT_PROGRAM_MODE = -1;
  
  xScale = width/570;
  yScale = height/900;
  xoff = (off + 25);
  yoff = 100;

  checkButt = new RectButton(xoff-5+307, 824, 80, buttoncolor, highlight, 46, 15, 19);
  newButt = new RectButton(470, 148, 76, buttoncolor, highlight, 32, 6, 25);
  revealButt = new RectButton(470, 192, 76, buttoncolor, highlight, 30, 2, 27);
  tutorialButt = new RectButton(470, 237, 76, buttoncolor, highlight, 30, 3, 27);
  
  setColors();
  noStroke();
  setColorMap();
} //end setup

void draw() {
  update(mouseX, mouseY);
  
  newButt.display();
  textSize(18);
  text("New", 491, 173);
  checkButt.display();
  text("Check", 368, 848);
  revealButt.display();
  text("Reveal", 480, 217);
  tutorialButt.display();
  text("How-To", 477, 262);
  
  if (CURRENT_PROGRAM_MODE == GUESS_MODE) {
    if(clicked != null && g.size() < 4) {
      position = pQ.remove(0);
      console.log(position);
      sizer = 50;
      xLoc = (position*70)+45+(xoff-5);
      yLoc = 842;
      Peg p = new Peg(xLoc, yLoc, sizer, clicked);
      g.put(position, p);  //add to guess peg map
      stroke(0);
      p.drawPeg();  //draw peg
      clicked = null;
    }
  } //endif GUESS_MODE
  else if (CURRENT_PROGRAM_MODE == FEEDBACK_MODE) {
    yLoc = yoff-10+725-(numGuess*65);
    commitGuess();
    xLoc = xoff+314;
    
    fb[0] = new FeedbackPeg(xLoc+14, yLoc+14, 0, EMPTY);  
    fb[1] = new FeedbackPeg(xLoc+40, yLoc+14, 0, EMPTY);
    fb[2] = new FeedbackPeg(xLoc+14, yLoc+40, 0, EMPTY);
    fb[3] = new FeedbackPeg(xLoc+40, yLoc+40, 0, EMPTY);
    
    for (int i = 0; i <numBlack; i++) {
      fb[i].setColor(BLACK);
      fb[i].drawPeg();
    }
    for (int i = numBlack; i < numBlack+numWhite; i++) {
      fb[i].setColor(WHITE);
      fb[i].drawPeg();
    }
    //empties
    noStroke();
    for (int i = numBlack+numWhite; i < fb.length; i++) {
      fb[i].setColor(EMPTY);
      fb[i].drawPeg();
    }
    
    //CASE 1: REVEAL CODE IN CODE PANEL IF...
    if (numBlack == 4 || numGuess == 10) {
      stroke(0);
      fill(255);
      rect(xoff-5, yoff, 300, 54);  // code panel
      for (int i = 0; i < 4; i++) {
        c.get(i).setColor(getColorValue(c.get(i).getValue()));
        c.get(i).drawPeg();  // draw code pegs
      }
    }
    //CASE 2: DIDN'T BREAK CODE && HAVEN'T REACHED MAX # OF GUESSES
    else {
      //prepare for next guess 
      drawNewGuess();  //--> draw empty pegs holes, initialize PositionQueue
    }
  } //endif FEEDBACK_MODE
  else if (CURRENT_PROGRAM_MODE == CODE_MODE) {
    stroke(0);
    fill(255);
    rect(xoff-5, yoff, 300, 54);  // code panel
    for (int i = 0; i < 4; i++) {
      c.get(i).setColor(getColorValue(c.get(i).getValue()));
      c.get(i).drawPeg();  // draw code pegs
    }
  } //endif CODE_MODE
  else {
    if (!set) {
      initializeBoard();
      initializeControlPanel(); //score + controls
      initializeColors();  // color options panel
      set = true;
    }
  } //endif else_MODE..
} //end draw()

void update(int x, int y) {
  if(mousePressed) {
    if(newButt.over() && ready == false) {
      gameStarted = true;
      numGuess = 0;  //(re)initialize game variables
      numBlack = 0;
      numWhite = 0;
      
      clearBoard(); //initalize game board
      g.clear();    //clear guess structure
      
      //set = false;
      generateCodeMap();  //set new random code
      setGuessMode();
      redraw();
    } //end newButt.pressed()
    else if(checkButt.over()) {
      if (gameStarted) {
        if (numGuess == 9 && g.size() == 4) {
          numGuess = 10;
          getNumBlack();
          getNumWhite();
          setFeedbackMode();
          redraw();
          if (numBlack == 4) {
            String s = "YOU WON! ...on your last chance!";
            console.log(s);
            gameStarted = false;
            ready = false;
          }
          else {
            String s = "Gameover!";
            console.log(s);
            gameStarted = false;
            ready = false;
          }
        }
        else if(numGuess < 10 && g.size() == 4) {
          numGuess++;  //increment number of guesses
          getNumBlack();
          getNumWhite();
          setFeedbackMode();  //display feedback
          if (numBlack == 4) {
            String s = "You broke the code in " + numGuess + " guesses!";
            console.log(s);
            gameStarted = false;
            ready = false;
          }
        }//end else if
      }//end if (gameStarted)
    }//end checkButt.pressed()
    else if (revealButt.over()) {
      if (gameStarted && ready == true) {
        setCodeMode();
        gameStarted = false;
        ready = false;
      }
    }//end revealButt.pressed()
    else if (tutorialButt.over()) {
      //show tutorial !!! 
      //make boolean to let game known what state its in and only update screen if backButt is pressed?
//      getTutorial();
//      set = true;
//      redraw();
    }
  }//end if (mousePressed)
}//end update()

void mousePressed() {  
  clicked = null;
  if (CURRENT_PROGRAM_MODE == GUESS_MODE && (mouseX > 470) && (mouseY > 265)) {
    //color chosen
    float closest = 48;
    Iterator it = colorpegs.entrySet().iterator();  // Get an iterator
    while (it.hasNext()) {
      Map.Entry me = (Map.Entry)it.next();
      Peg p = (Peg)me.getValue();
      float d = dist(mouseX, mouseY, p.getX(), p.getY());
      if (d < closest) {
        closest = d;
        clicked = p.getColor();
      }
    }
  }
  else if (CURRENT_PROGRAM_MODE == GUESS_MODE && (mouseX < xoff+300) && (mouseY > (11*65)+yoff)) {
    //REMOVE A PEG
    float closest = 48;
    Iterator<Integer> keySetIterator = g.keySet().iterator();
    Integer temp = null;

    while (keySetIterator.hasNext()) {
      Integer keys = keySetIterator.next();
      Peg p = g.get(keys);
      float d = dist(mouseX, mouseY, p.getX(), p.getY());
      if (d < closest) {
        temp = keys;
        closest = d;
      }
    }
    
    if (temp != null && (CURRENT_PROGRAM_MODE == GUESS_MODE)) {
      //Removes the mapping for this key from guess peg map 
      setEmpty(g.remove(temp));
      console.log(temp);
      pQ.add(temp);
    }
  }
  redraw();
} //end mousePressed() 

void setEmpty(Peg toRemove) {
  xLoc = toRemove.getX();
  yLoc = toRemove.getY();
  stroke(209);
  strokeWeight(2);
  fill(EMPTY); //empty peg color
  ellipse(xLoc, yLoc, sizer, sizer);
  strokeWeight(1);
} //end setEmpty

// ------- Game control methods -------
void setGuessMode() {
  CURRENT_PROGRAM_MODE = GUESS_MODE;
  initializeGuess();
  initPositionQueue();
}

void setFeedbackMode() {
  CURRENT_PROGRAM_MODE = FEEDBACK_MODE;
  displayNumGuess("" + numGuess);
}

void drawNewGuess() {
  CURRENT_PROGRAM_MODE = GUESS_MODE;
  initPositionQueue();
  initializeGuess();
}
  
void setCodeMode() {
  CURRENT_PROGRAM_MODE = CODE_MODE;
}

void clearBoard() {
  initializeBoard();
  initializeControlPanel();
  displayNumGuess("0");
}
// ----- end Game control methods -----

//Updates guess peg y-coords & draws them in their perminant location
void commitGuess() {
  if (g.size() > 0) {
    for (int i = 0; i < 4; i++) {
      g.get(i).setY(yLoc+27);  //set respective y location
      g.get(i).drawPeg();    //update peg component
      g.remove(i);  //remove from guess peg map
    }
  }
  stroke(0);  
  fill(255);
  rect(xoff-5, (11*65)+yoff, 300, 54);  //clear guess panel
} //end commitGuess

void initPositionQueue() {
  pQ = new ArrayList();
  for(int i = 0; i < 4; i++)
    pQ.add(i);
} //end initPositionQueue

void initializeGuess() {
  int x = (xoff-5);
  int y = (yoff-10);
  stroke(0);
  fill(255);
  rect(xoff-5, (11*65)+yoff, 300, 54);  // clears guess panel
  stroke(209);
  fill(EMPTY);
  for (int position = 0; position < 4; position++) {  
    xLoc = (position*70)+45;
    yLoc = 752;
    ellipse(x+xLoc, y+yLoc, sizer, sizer); 
  }
} //end initializeGuess

void displayNumGuess(String s) {
  stroke(0);
  fill(255);
  rect(470, 107, 76, 36);  //redraw score panel
  textSize(16);
  fill(0);
  text(s, 504, 131);//guess tracker -- for user
} //end displayNumGuess

void initializeControlPanel() {
  stroke(0);
  fill(247);
  rect(460, 84, 96, 198);  //control panel border
  fill(255);
  rect(470, 107, 76, 36);  //score panel
  textSize(16);
  fill(0);
  text("Guesses:", 472, 89, 145, 84); //header text
} //end initializeControlPanel

void initializeColors() {
  stroke(0);
  fill(247);
  rect(460, 299, 96, 487+yoff); //outer color peg panel
  fill(255);
  rect(472, 312, 72, 460+yoff);  //inner panel
  color[] clr = getColors(); 
  int sizer = 55;
  Peg p;
  for (int i = 0; i < 8; i++) {
    p = new Peg(473+36, (i*70)+347, sizer, clr[i]);
    colorpegs.put(i, p);
    stroke(0);
    p.drawPeg();  //draw peg
  }
} //end initializeColors

void initializeBoard() {
  textSize(60);
  fill(0, 102, 153, 204);
  text("mastermind", off, 25, 350, 75); //GAME NAME
  stroke(0);
  fill(247);
  rect(off, 84, 415, 801);  //board panel
  fill(175);
  rect(xoff-5, yoff, 300, 54);  //code panel
  stroke(0);
  fill(255);
  //10 previous guess panels
  for(int i = 0; i < 10; i++) {              // 10 guess attempt panels
    rect(xoff-5, (i*65)+yoff+65, 300, 54);   //guess peg panels
    rect(xoff+314, (i*65)+yoff+65, 54, 54);  //feedback peg panels
  }
  rect(xoff-5, (11*65)+yoff, 300, 54);  //bottom guess panel
} //end initializeBoard

color getColorValue(int val) {
  return color(unhex(colorMap.get(val)));
} //end getColorValue

void setColorMap() {
 color[] clr = getColors();
  for (int i = 0; i < 8; i++)
    colorMap.add(hex(clr[i]));
} //end setColorMap

void setColors() {
  RED = #FF3C32;     // color(255, 60, 50);   // 0 ---starting vals
  ORANGE = #FF9D28;  //color(255, 157, 40);   // 1
  YELLOW = #FFD923;  //color(255, 235, 0);    // 2
  GREEN = #A8FF0C;   //color(168, 255, 12);   // 3
  TEAL = #51DCAE;    //color(91, 255, 198);   // 4
  BLUE = #1B83CC;    //color(109, 214, 255);  // 5
  PURPLE = #AA66CC;  //color(196, 119, 255);  // 6
  PINK = #FF9BF0;    //color(255, 155, 240);  // 7 ---ending vals
  EMPTY = #D1D1D1;   //color(209, 209, 209);  // 8 -- empty
  WHITE = #FFFFFF;   //color(255, 255, 255);  // 9 --feedback
  BLACK = #000000;   //color(0, 0, 0);        // 10 --feedback
} //end setColors

color[] getColors() {
  color[] p = {#FF3C32, #FF9D28, #FFD923, #A8FF0C, #51DCAE, #1B83CC, #AA66CC, #FF9BF0};
  return p; 
} //end getColors

//computes the number of correct colors in the correct positions
void getNumBlack() {
  int b = 0;
  // Iterate through the return 
  Iterator<Integer> keySetIterator = c.keySet().iterator();

  while (keySetIterator.hasNext()) {
    Integer keys = keySetIterator.next();
    if (hex(getColorValue(c.get(keys).getValue())) == hex(g.get(keys).getColor()))
      b++;  //increment number of black pegs
  }
  numBlack = b;
} //end getNumBlack

//computes the number of colors that are in the code but not in the correct positions
void getNumWhite() {
  int w = 0, cNum = 0, gNum = 0;

  // Iterate through the return 
  Iterator keySetIteratorC = c.keySet().iterator();
  Iterator keySetIteratorG = g.keySet().iterator();

  //for each color in the color peg options
  for (String hexColor : colorMap) {
    
    //1. find the # of times a color appears in the guess & in the code
    while(keySetIteratorC.hasNext() && keySetIteratorG.hasNext()) {
      Integer keyCodes = keySetIteratorC.next();
      if (hexColor == hex(getColorValue(c.get(keyCodes).getValue())))  
        cNum++;  //increment number of times the color is in the code

      Integer keyGuess = keySetIteratorG.next();
      if (hexColor == hex(g.get(keyGuess).getColor()))  
        gNum++;  //increment number of times the color is in the guess
    }

    //2. sum the minimum number of times a color appears in both the 
    // code, c and the guess, g
    w += Math.min(cNum, gNum);

    //reset color counters
    cNum = 0;
    gNum = 0;

    //reset iterator back to the beginning to check next PrettyColor entry
    keySetIteratorC = c.keySet().iterator();
    keySetIteratorG = g.keySet().iterator();
  }

  //3. # of white pegs can be computed by subtracting the number of black
  //   pegs from the sum of the minumum number of color appearances 
  numWhite = w - numBlack;
} //end getNumWhite

void generateCodeMap() {
  for (int i = 0; i < 4; i++)
    c.put(i, new RandomPeg( (i*70)+45+xoff-5, yoff-10+752-(11*65), 50, EMPTY));
  ready = true;
} //end generateCodeMap

class Peg {
  int x, y, sizer;
  color paint;
  color EMPTY = color(209, 209, 209); 
  
  Peg() {
    this(0, 0, 100, EMPTY);  //#000000);
  }
  
  Peg(int x, int y, int sizer, color c) {
    this.x = x;
    this.y = y;
    this.sizer = sizer;
    this.paint = c;
  }
  
  void drawPeg() {
    fill(red(paint), green(paint), blue(paint));
    ellipse(x, y, sizer, sizer);
  }
  
  int getX() {
    return x;
  }
  
  void setX(int x) {
    this.x = x;
  }
  
  int getY() {
    return y;
  }
  
  void setY(int y) {
    this.y = y;
  }
  
  color getColor() {
    return paint;
  }
  
  void setColor(color someColor) {
    this.paint = someColor;
  }
} //end Peg class

class RandomPeg extends Peg {
  int value;
  
  RandomPeg() {
    super();
  }
  
  RandomPeg(int x, int y, int sizer, color c) {
    super(x, y, sizer, c);
//    this.x = x;
//    this.y = y;
    value = (int) random(0, 7);
  }
  
  int getValue() {
    return value;
  }
  
  void drawPeg() {
    super.drawPeg();
  }
  
  int getX() {
    super.getX();
    return x;
  }
  
  void setX(int x) {
    super.setX(x);
  }
  
  int getY() {
    super.getY();
    return y;
  }
  
  void setY(int y) {
    super.setY(y);
  }
  
  color getColor() {
    super.getColor();
    return paint;
  }
  
  void setColor(color someColor) {
    super.setColor(someColor);
  }
  
} //end RandomPeg class

class FeedbackPeg extends Peg {
  
  FeedbackPeg() {
    super();
  }
  
  FeedbackPeg(int x, int y, int sizer, color c) {
    super(x, y, 15*xScale, EMPTY);
    //this.x = x;
    //this.y = y;
    //paint = EMPTY;  //#D1D1D1;  //PrettyColor.EMPTY;
    //sizer = 15*xScale;
  }
  
  void drawPeg() {
    super.drawPeg();
  }
  
  int getX() {
    super.getX();
    return x;
  }
  
  void setX(int x) {
    super.setX(x);
  }
  
  int getY() {
    super.getY();
    return y;
  }
  
  void setY(int y) {
    super.setY(y);
  }
  
  color getColor() {
    super.getColor();
    return paint;
  }
  
  void setColor(color someColor) {
    super.setColor(someColor);
  }
  
} //end FeedbackPeg class
class RectButton {
  int x, y;
  int sizer;
  color basecolor, highlightcolor;
  color currentcolor;
  boolean pressed = false;  
  String text = ""; 
  int tsize, tx, ty;
  
  RectButton(int ix, int iy, int isize, color icolor, color ihighlight, int textsize, int textx, int texty)   {
    x = ix;
    y = iy;
    sizer = isize;
    basecolor = icolor;
    highlightcolor = ihighlight;
    currentcolor = basecolor;
    tsize = textsize;
    tx = textx;
    ty = texty;
  }

  boolean over() {
    pressed = overRect(x, y, sizer, 36);
    return pressed;
  }

  boolean overRect(int x, int y, int someWidth, int someHeight) {
    if (mouseX >= x && mouseX <= x+someWidth && mouseY >= y && mouseY <= y+someHeight) {
      return true;
    }
    else {
      return false;
    }
  }

  void display() {
    stroke(255);
    fill(currentcolor);
    rect(x, y, sizer, 36);
    fill(0);
  }
  
} //end RectButton class


