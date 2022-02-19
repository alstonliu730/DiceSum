import processing.serial.*;

// global variables
Serial myPort;
String type = "";
int linefeed = '\n';
String[] myData;
int mode = 1; // display mode: 0, 1, 2;

//constants
final int STR_LIMIT = 53;
final int FONT_SIZE = 50;

// data variables
String data,guess; // data after the type
int lives, round, prize, sum, distance;
float roll,limit;

StringList console = new StringList();
Boolean over, reveal = false , win, rolling = false;
String display;

IntList rolls = new IntList();

// display variables
PFont pixel;
PFont oldFont;

// IMAGES
PImage bg,bubble1,bubble2,end;
PImage dice1, dice2, dice3, dice4, dice5, dice6;
PImage[] dice = {dice1, dice2, dice3, dice4, dice5, dice6};
public void settings() {
  fullScreen(); // puts the window to full screen
  //size(720,480);
}

// SETUP FUNCTIONS
// start menu
void mode0(){
  bg = loadImage("end-screen.jpg");
  imageMode(CENTER);
  image(bg,width/2, height/2);
}

// mid-game screen
void mode1(){
  pixel = createFont("zx_spectrum-7_bold.ttf",FONT_SIZE);
  textFont(pixel);
  // background image at center of screen
  bg = loadImage("CasinoBackground3.png");
  bubble1 = loadImage("bubble3.png");
  bubble2 = loadImage("bubble3.png");
  imageMode(CENTER);
  image(bg, width/2, height/2); 
  
  // TITLE
  fill(46, 255, 248); //text color (r, g, b)
  textSize(FONT_SIZE);
  text("DICE ROLL", width/2 - 160, height/8); // creates a text at x-coord and y-coord

  //LIVES
  fill(255, 194, 99); // color of the lives tab
  textSize(FONT_SIZE);
  text("LIVES", width/8, height/8);  
  stroke(255, 194, 99);
  line(width/8, height/8 + 2, width/8 + textWidth("LIVES"), height/8 + 2);

  //ROUND
  fill(255, 194, 99);
  textSize(FONT_SIZE);
  text("ROUND", 6*width/8, height/8);
  stroke(255, 194, 99);
  line(6*width/8, height/8 + 2, 6*width/8 + textWidth("ROUND"), height/8 + 2);
  
  // TEXT BOX
  fill(0, 0, 0); // black
  stroke(255, 0, 0); // with red lines
  rectMode(CORNER);
  rect(width/6, 2*height/3, (4*width)/6, 2*height/8); //text box dimensions and positions
  
  // GUESS BOX
  fill(0,0,0);
  stroke(46, 255, 248);
  rectMode(CORNER);
  rect(width/2 - 140, height/8 + 20, 300, 200);
  fill(46, 255, 248);
  textSize(FONT_SIZE - 20);
  noStroke();
  text("YOUR GUESS:", width/2 - 110, height/8 + FONT_SIZE);
  
  // LIMIT BUBBLE
  imageMode(CENTER);
  image(bubble1,width/4-100, height/2 - 40);
  
  // PRIZE BUBBLE
  imageMode(CENTER);
  image(bubble2,3*width/4+100, height/2 - 40);
  
  // Dice Title
  fill(0);
  textSize(FONT_SIZE);
  text("SUM:", width/2-60, height/2 - 100);
  
  // dice shape
  rectMode(CENTER);
  fill(255);
  stroke(0);
  rect(width/2,height/2,200,200,15);
}
// end game screen
void mode2(){
  // load end screen
  pixel = createFont("zx_spectrum-7_bold.ttf",FONT_SIZE + 20);
  textFont(pixel);
  bubble1 = loadImage("bubble3.png");
  background(0);
  
  // load bubble
  image(bubble1, width/2, height/2);
  
  // prize title
  fill(255);
  String s = "CONGRATULATIONS! YOU WIN";
  text(s, width/2 - textWidth(s)/2,height/4);
  
  fill(0);
  text(prize, width/2 - 30, height/2+10);
  
  fill(255);
  String s2 = "CHIPS!!!";
  text(s2 , width/2 - textWidth(s2)/2, (3*height)/4);
  
}

//setup the scene and connection to the Serial port in the Arduino
void setup()
{ 
  mode1();
  frameRate(30);
  // CONNECTION TO SERIAL PORT
  // Find the port in the serial list.
  // ex. COM1 COM2
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil(linefeed);
}

// DRAW FUNCTIONS
void drawLives(int currentLives)
{
  fill(255, 194, 99); // color of the lives tab
  textSize(FONT_SIZE);
  text(currentLives, width/8+textWidth("LIVES")/2, height/8+FONT_SIZE);
}

void drawRound(int currentRound)
{
  fill(255, 194, 99); // color of the round num
  textSize(FONT_SIZE);
  text(currentRound, 6*width/8 + textWidth("ROUND")/2, height/8+FONT_SIZE);
}

void drawGuess(String userGuess)
{
  // User's Guess
  fill(46, 255, 248);
  textSize(FONT_SIZE);
  text(userGuess, width/2-(FONT_SIZE + 20),2*height/8);
}

// simple version
void drawDie(int sum){
  // the actual number
  int x = width/2 - 30;
  int y = height/2 + 10;
  //fill(255, 194, 99);
  fill(0);
  text("Range: " + round + " -", x-150, y+ 150);
  text(round*6, x-150+textWidth("Range: 1 - "), y + 150);
  if(reveal){
    fill(0);
    textSize(FONT_SIZE);
    text(sum, x,y);
  } else {
    fill(0);
    textSize(FONT_SIZE);
    text("...", x - 30,y);
  }
  
}

void drawRandomDie(int num){
  fill(0);
  textSize(FONT_SIZE);
  text("SUM:", width/2-60, height/2 - 100);
  rectMode(CENTER);
  fill(255);
  stroke(0);
  rect(width/2,height/2,200,200,15);
  
  int x = width/2 - 30;
  int y = height/2 + 10;
  fill(0);
  textSize(FONT_SIZE);
  text(num,x,y);
}

// display threshold
void drawLimit(float limit){
  fill(0);
  textSize(FONT_SIZE - 2);
  int x = width/7- 20;
  int y = height/4 + 200;
  text("Target: ", x, y);
  
  String lim = nf(limit,1,1);
  text(lim, x + FONT_SIZE, y + 60);
}

// display messages
void display(String str){
  if(str.length() > STR_LIMIT){
    console.append(str.substring(0,STR_LIMIT));
    console.append(str.substring(STR_LIMIT));
  } else {
    console.append(str);
  }
}

void drawDisplay(){
  int textSize = FONT_SIZE - 20;
  int x = width/6;
  int y = 2*height/3 + textSize;
  
  if ((y + (textSize * console.size())) > (y + 2*height/8)){
     console.remove(0);
  }
  for(int i = 0; i < console.size(); i++){
    int temp = y + (textSize * i);
    fill(255,255,255);
    textSize(textSize);
    text(console.get(i), x,temp);
  }
}

void clearDisplay(){
  console.clear();
}

// draw prizes/tickets
void drawPrize(){
  fill(0);
  textSize(FONT_SIZE - 2);
  int x = 3*width/4;
  int y = height/4 + 200;
  text("PRIZE: ", x, y);
  
  text(prize , x + 100, y + 60);
}

void resetBoard(){
  sum = 0;
  limit = 0;
  round = 0;
  lives = 0;
  clearDisplay();
  display("Press the blue button to buy a life for 5 tickets!");
  display("Press the yellow button to start!");
}

void initializeData(String type) {
  switch (type) {
    case ("print"):
    {
      display(data);
      break;
    }
    case ("round"):
    {
      // display round number
      round = int(data);
      break;
    }
    case ("guess"):
    {
      if (int(data) == 1) {
        // guess is over
        guess = "OVER";
      } else {
        // guess is under
        guess = "UNDER";
      }
      break;
    }
    case ("roll") :
    {
      rolls.clear(); // clear the data for the roll
      // will be an array of data
      int myRoll[] = int(split(data, '\t'));
      int count = myRoll.length;
      for(int i = 0; i < count; i++)
      {
        rolls.append(myRoll[i]);
      }
      //println(rolls);
      break;
    }
    case ("lives"):
    {
      lives = int(data) + 1;
      break;
    }
    case ("prize"):
    {
      prize = int(data);
      break;
    }
    case("distance"): {
      distance = int(data);
      //display(String.valueOf(distance));
      break;
    }
    case("sum"): {
      sum = int(data);
      break;
    }
    case("limit"): {
      limit = float(data);
      break;
    }
    case("over"): {
      if(data == "1"){
        over = true;
      } else {
        over = false;
      }
      break;
    }
    case("win"):{
      if(data == "1"){
        win = true;
      }
      else{
        win = false;
      }
      reveal = true;
      break;
    }
    case ("rolling"):
    {
      reveal = false;
      if (int(data) == 1) {
        // rolling dice
        rolling = true;
      } else {
        // not rolling dice
        rolling = false;
      }
      break;
    }
    case ("mode"): {
      mode = int(data);
      if(mode == 2){
        clearDisplay();
      }
      break;
    }
    case ("reset"): {
      resetBoard();
    }
    default:
    {
      println("THIS SHOULD NOT BE HERE!");
      break;
    }
  }
}

// serialEvent method is run automatically
// whenever the buffer receives a linefeed byte
void serialEvent(Serial myPort)
{
  // read the serial buffer:
  String myString = myPort.readStringUntil(linefeed);
  // if we get any bytes other than the linefeed:
  if (myString != null)
  {
    //remove the linefeed
    myString = trim(myString);

    //split the string at the colon and convert the sections into the data
    if (myString.contains(":")) {
      type = myString.substring(0, myString.indexOf(":"));
      data = myString.substring(myString.indexOf(":") + 1);
      println("MyString: " + myString);
      println("Data: " + data);
      // creates the array of data from each command and separates data for each delimiter
      //myData = split(data,"|");
    } else {
      // print it to the box
      type = "print";
      data = myString;
    }
    
    // initialize the data
    initializeData(type);
  }
}
void mousePressed(){mode=1;}

void screens(int m){
  switch(m){
    case 0:{
      mode0();
      break;
    }
    case 1:{
      game();
      break;
    }
    case 2:{
      mode2();
      break;
    }
    default:{
      println("SCREEN BROKEN");
      game();
    }
  }
}
void game(){
  mode1(); // puts a new template of the board basically clearing the screen
  drawRound(round);
  drawLives(lives);
  if(guess == null){
    drawGuess("");
  } else {
    drawGuess(guess);
  }
  
  drawLimit(limit);
  drawDisplay();
  drawPrize();
  
  drawDie(sum); // only display after user guesses
  // rolling the dice
  if(rolling){
    int temp = int(random(round*6));
    drawRandomDie(temp);
  } 
}
// loops through this function like in arduino
void draw()
{
  screens(mode);
  // if any data comes through to serial port
  if(myPort.available() > 0)
  {
     serialEvent(myPort);
  }
  //delay(16); // delays updating the screen, prevents RAM
}
